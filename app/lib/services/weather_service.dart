import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class WeatherData {
  final String location;
  final double latitude;
  final double longitude;
  final List<DailyForecast> dailyForecasts;
  final double? currentTemp;
  final int? currentWeatherCode;
  final String? lastUpdated;

  WeatherData({
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.dailyForecasts,
    this.currentTemp,
    this.currentWeatherCode,
    this.lastUpdated,
  });

  factory WeatherData.fromJson(
    Map<String, dynamic> json,
    String location,
    double lat,
    double lon,
  ) {
    final daily = json['daily'] ?? {};
    final hourly = json['hourly'] ?? {};

    List<DailyForecast> forecasts = [];

    final times = List<String>.from(daily['time'] ?? []);
    final maxTemps = List<num>.from(daily['temperature_2m_max'] ?? []);
    final minTemps = List<num>.from(daily['temperature_2m_min'] ?? []);
    final precipitation = List<num>.from(daily['precipitation_sum'] ?? []);
    final precipitationProb = List<num>.from(
      daily['precipitation_probability_max'] ?? [],
    );
    final weatherCodes = List<int>.from(daily['weather_code'] ?? []);
    final windSpeeds = List<num>.from(daily['wind_speed_10m_max'] ?? []);

    for (int i = 0; i < times.length; i++) {
      forecasts.add(
        DailyForecast(
          date: times[i],
          maxTemp: maxTemps[i].toDouble(),
          minTemp: minTemps[i].toDouble(),
          precipitation: precipitation[i].toDouble(),
          precipitationProbability: precipitationProb[i].toInt(),
          weatherCode: weatherCodes[i],
          windSpeed: windSpeeds[i].toDouble(),
        ),
      );
    }

    final currentTemp =
        (hourly['temperature_2m'] as List?)?.firstOrNull as num?;
    final currentWeatherCode =
        (hourly['weather_code'] as List?)?.firstOrNull as int?;

    return WeatherData(
      location: location,
      latitude: lat,
      longitude: lon,
      dailyForecasts: forecasts,
      currentTemp: currentTemp?.toDouble(),
      currentWeatherCode: currentWeatherCode,
      lastUpdated: DateTime.now().toString(),
    );
  }
}

class DailyForecast {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double precipitation;
  final int precipitationProbability;
  final int weatherCode;
  final double windSpeed;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitation,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.windSpeed,
  });

  String getWeatherDescription() {
    return WeatherCodeInterpreter.getDescription(weatherCode);
  }

  String getWeatherIcon() {
    return WeatherCodeInterpreter.getIcon(weatherCode);
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'maxTemp': maxTemp,
    'minTemp': minTemp,
    'precipitation': precipitation,
    'precipitationProbability': precipitationProbability,
    'weatherCode': weatherCode,
    'windSpeed': windSpeed,
  };

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
    date: json['date'],
    maxTemp: json['maxTemp'],
    minTemp: json['minTemp'],
    precipitation: json['precipitation'],
    precipitationProbability: json['precipitationProbability'],
    weatherCode: json['weatherCode'],
    windSpeed: json['windSpeed'],
  );
}

class WeatherCodeInterpreter {
  static String getDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1 || 2:
        return 'Mostly clear';
      case 3:
        return 'Overcast';
      case 45 || 48:
        return 'Foggy';
      case 51 || 53 || 55:
        return 'Drizzle';
      case 61 || 63 || 65:
        return 'Rain';
      case 71 || 73 || 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80 || 81 || 82:
        return 'Rain showers';
      case 85 || 86:
        return 'Snow showers';
      case 95 || 96 || 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }

  static String getIcon(int code) {
    switch (code) {
      case 0:
        return '☀️';
      case 1 || 2:
        return '🌤️';
      case 3:
        return '☁️';
      case 45 || 48:
        return '🌫️';
      case 51 || 53 || 55:
        return '🌧️';
      case 61 || 63 || 65:
        return '🌧️';
      case 71 || 73 || 75:
        return '❄️';
      case 77:
        return '❄️';
      case 80 || 81 || 82:
        return '🌧️';
      case 85 || 86:
        return '❄️';
      case 95 || 96 || 99:
        return '⛈️';
      default:
        return '🌡️';
    }
  }
}

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1';
  static const String storageKey = 'weather_data_cache';

  Future<WeatherData?> fetchWeatherForecast(
    double latitude,
    double longitude, {
    String location = 'Current Location',
  }) async {
    try {
      // Try to load cached data first
      final cached = await _loadCachedWeather();
      if (cached != null &&
          _isCacheValid(cached) &&
          _isSameLocation(cached, latitude, longitude)) {
        return cached;
      }

      final params = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'timezone': 'Asia/Dhaka',
        'forecast_days': '7',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max',
        'hourly': 'temperature_2m,weather_code',
        'current': 'temperature_2m,weather_code',
      };

      final uri = Uri.parse(
        '$baseUrl/forecast',
      ).replace(queryParameters: params);

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final weatherData = WeatherData.fromJson(
          jsonDecode(response.body),
          location,
          latitude,
          longitude,
        );
        await _cacheWeather(weatherData);
        return weatherData;
      }
    } catch (e) {
      // Return cached data on error if available
      final cached = await _loadCachedWeather();
      if (cached != null) {
        return cached;
      }
    }
    return null;
  }

  Future<WeatherData?> fetchHistoricalWeather(
    double latitude,
    double longitude,
    DateTime startDate,
    DateTime endDate, {
    String location = 'Current Location',
  }) async {
    try {
      final params = {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'start_date': startDate.toString().split(' ')[0],
        'end_date': endDate.toString().split(' ')[0],
        'daily':
            'temperature_2m_max,temperature_2m_min,precipitation_sum,weather_code',
        'timezone': 'Asia/Dhaka',
      };

      final uri = Uri.parse(
        '$baseUrl/archive',
      ).replace(queryParameters: params);

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return WeatherData.fromJson(
          jsonDecode(response.body),
          location,
          latitude,
          longitude,
        );
      }
    } catch (e) {
      debugPrint('Error fetching historical weather: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getWeatherClimateNormals(
    double latitude,
    double longitude,
  ) async {
    try {
      // Get 30-year climate data (1990-2020)
      final startDate = DateTime(1990, 1, 1);
      final endDate = DateTime(2020, 12, 31);

      final weatherData = await fetchHistoricalWeather(
        latitude,
        longitude,
        startDate,
        endDate,
      );

      if (weatherData == null) return null;

      // Calculate statistics
      final temps = weatherData.dailyForecasts
          .map((f) => (f.maxTemp + f.minTemp) / 2)
          .toList();
      final precip = weatherData.dailyForecasts
          .map((f) => f.precipitation)
          .toList();

      return {
        'avgTemp': temps.isNotEmpty
            ? temps.reduce((a, b) => a + b) / temps.length
            : 0,
        'maxTemp': temps.isNotEmpty ? temps.reduce((a, b) => a > b ? a : b) : 0,
        'minTemp': temps.isNotEmpty ? temps.reduce((a, b) => a < b ? a : b) : 0,
        'avgPrecipitation': precip.isNotEmpty
            ? precip.reduce((a, b) => a + b) / precip.length
            : 0,
        'totalPrecipitation': precip.isNotEmpty
            ? precip.reduce((a, b) => a + b)
            : 0,
      };
    } catch (e) {
      debugPrint('Error getting climate normals: $e');
    }
    return null;
  }

  Future<void> _cacheWeather(WeatherData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = {
        'location': data.location,
        'latitude': data.latitude,
        'longitude': data.longitude,
        'currentTemp': data.currentTemp,
        'currentWeatherCode': data.currentWeatherCode,
        'forecasts': data.dailyForecasts.map((f) => f.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString(storageKey, jsonEncode(jsonData));
    } catch (e) {
      debugPrint('Error caching weather: $e');
    }
  }

  Future<WeatherData?> _loadCachedWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(storageKey);
      if (cached == null) return null;

      final jsonData = jsonDecode(cached) as Map<String, dynamic>;
      final forecasts = (jsonData['forecasts'] as List)
          .map((f) => DailyForecast.fromJson(f))
          .toList();

      return WeatherData(
        location: jsonData['location'],
        latitude: jsonData['latitude'],
        longitude: jsonData['longitude'],
        dailyForecasts: forecasts,
        currentTemp: jsonData['currentTemp'],
        currentWeatherCode: jsonData['currentWeatherCode'],
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          jsonData['timestamp'],
        ).toString(),
      );
    } catch (e) {
      debugPrint('Error loading cached weather: $e');
    }
    return null;
  }

  bool _isCacheValid(WeatherData data) {
    if (data.lastUpdated == null) return false;
    final lastUpdate = DateTime.parse(data.lastUpdated!);
    final now = DateTime.now();
    return now.difference(lastUpdate).inHours < 6;
  }

  bool _isSameLocation(WeatherData data, double lat, double lon) {
    return (data.latitude - lat).abs() < 0.1 &&
        (data.longitude - lon).abs() < 0.1;
  }
}
