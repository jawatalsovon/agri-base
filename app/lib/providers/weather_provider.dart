import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _error;
  double? _latitude;
  double? _longitude;
  String? _locationName;

  WeatherData? get weatherData => _weatherData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String? get locationName => _locationName;

  Future<void> fetchWeather(
    double latitude,
    double longitude, {
    String? locationName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      _latitude = latitude;
      _longitude = longitude;
      _locationName = locationName ?? 'Location';
      notifyListeners();

      _weatherData = await _weatherService.fetchWeatherForecast(
        latitude,
        longitude,
      );
      _isLoading = false;
    } catch (e) {
      _error = 'Error fetching weather: $e';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_latitude != null && _longitude != null) {
      await fetchWeather(_latitude!, _longitude!, locationName: _locationName);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
