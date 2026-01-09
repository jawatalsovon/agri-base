import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class SoilData {
  final double latitude;
  final double longitude;
  final double ph;
  final double organicCarbon; // %
  final double clayContent; // %
  final double sandContent; // %
  final double siltContent; // %
  final String soilType;
  final Map<String, dynamic>? rawData;
  final String? lastUpdated;

  SoilData({
    required this.latitude,
    required this.longitude,
    required this.ph,
    required this.organicCarbon,
    required this.clayContent,
    required this.sandContent,
    required this.siltContent,
    required this.soilType,
    this.rawData,
    this.lastUpdated,
  });

  String getPhInterpretation() {
    if (ph < 6.5) {
      return 'Acidic (pH < 6.5) - Lime addition may be needed';
    } else if (ph > 7.5) {
      return 'Alkaline (pH > 7.5) - Sulfur addition may help';
    } else {
      return 'Neutral (pH 6.5-7.5) - Optimal for most crops';
    }
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'ph': ph,
    'organicCarbon': organicCarbon,
    'clayContent': clayContent,
    'sandContent': sandContent,
    'siltContent': siltContent,
    'soilType': soilType,
    'lastUpdated': lastUpdated,
  };

  factory SoilData.fromJson(Map<String, dynamic> json) => SoilData(
    latitude: json['latitude'],
    longitude: json['longitude'],
    ph: json['ph'],
    organicCarbon: json['organicCarbon'],
    clayContent: json['clayContent'],
    sandContent: json['sandContent'],
    siltContent: json['siltContent'],
    soilType: json['soilType'],
    lastUpdated: json['lastUpdated'],
  );
}

class SoilService {
  static const String storageKey = 'soil_data_cache';

  /// Fetch soil data from SoilGrids API
  /// SoilGrids provides 250m resolution soil properties
  Future<SoilData?> fetchSoilData(double latitude, double longitude) async {
    try {
      // Check cache first
      final cached = await _loadCachedSoil();
      if (cached != null &&
          _isCacheValid(cached) &&
          _isSameLocation(cached, latitude, longitude)) {
        return cached;
      }

      // Query SoilGrids REST API
      // Properties: phh2o (pH), soc (soil organic carbon), clay, sand, silt
      const String baseUrl = 'https://rest.soilgrids.org/soilgrids/v2.0';

      final properties =
          'phh2o,soc,clay,sand,silt'; // pH in H2O, organic carbon, clay%, sand%, silt%
      final depths = '0-5cm'; // Top 5cm for immediate crop relevance

      final uri = Uri.parse(
        '$baseUrl/properties/query?lon=$longitude&lat=$latitude&depth=$depths&property=$properties',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final soilData = _parseSoilGridsResponse(jsonData, latitude, longitude);
        if (soilData != null) {
          await _cacheSoil(soilData);
          return soilData;
        }
      }
    } catch (e) {
      debugPrint('Error fetching soil data: $e');
      // Return cached data on error if available
      final cached = await _loadCachedSoil();
      if (cached != null) {
        return cached;
      }
    }
    return null;
  }

  /// Parse SoilGrids API response
  SoilData? _parseSoilGridsResponse(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    try {
      final properties = json['properties']?[0];
      if (properties == null) return null;

      // Extract mean values from the depth layer
      double ph = _extractValue(properties, 'phh2o') ?? 6.5;
      double soc =
          _extractValue(properties, 'soc') ?? 1.5; // Soil organic carbon %
      double clay = _extractValue(properties, 'clay') ?? 25.0;
      double sand = _extractValue(properties, 'sand') ?? 40.0;
      double silt = _extractValue(properties, 'silt') ?? 35.0;

      // Scale values appropriately
      ph = ph / 10; // SoilGrids returns pH * 10
      soc = soc / 10; // Organic carbon as percentage

      // Determine soil type based on texture triangle
      String soilType = _determineSoilType(clay, sand, silt);

      return SoilData(
        latitude: latitude,
        longitude: longitude,
        ph: ph,
        organicCarbon: soc,
        clayContent: clay,
        sandContent: sand,
        siltContent: silt,
        soilType: soilType,
        rawData: json,
        lastUpdated: DateTime.now().toString(),
      );
    } catch (e) {
      debugPrint('Error parsing SoilGrids response: $e');
      return null;
    }
  }

  /// Extract value from nested SoilGrids structure
  double? _extractValue(Map<String, dynamic> properties, String property) {
    try {
      final propData = properties[property];
      if (propData is Map && propData['values'] is List) {
        final values = propData['values'] as List;
        if (values.isNotEmpty && values[0] is Map) {
          return (values[0]['mean'] as num?)?.toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error extracting $property: $e');
    }
    return null;
  }

  /// Determine soil type from clay, sand, silt percentages
  /// Using USDA soil texture triangle
  String _determineSoilType(double clay, double sand, double silt) {
    if (clay < 8 && sand > 80) {
      return 'Sand';
    } else if (clay < 8 && sand > 50) {
      return 'Loamy Sand';
    } else if (clay < 18 && sand > 50) {
      return 'Sandy Loam';
    } else if (clay < 18 && silt > 50) {
      return 'Silt Loam';
    } else if (clay < 27 && silt < 28) {
      return 'Sandy Clay Loam';
    } else if (clay < 27 && silt >= 28) {
      return 'Clay Loam';
    } else if (clay >= 27 && sand > 45) {
      return 'Sandy Clay';
    } else if (clay >= 27 && silt >= 40) {
      return 'Silty Clay';
    } else if (clay >= 40) {
      return 'Clay';
    } else {
      return 'Loam'; // Default/central
    }
  }

  Future<void> _cacheSoil(SoilData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('soil_data_cache', jsonEncode(data.toJson()));
    } catch (e) {
      debugPrint('Error caching soil data: $e');
    }
  }

  Future<SoilData?> _loadCachedSoil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(storageKey);
      if (cached == null) return null;
      return SoilData.fromJson(jsonDecode(cached));
    } catch (e) {
      debugPrint('Error loading cached soil data: $e');
    }
    return null;
  }

  bool _isCacheValid(SoilData data) {
    if (data.lastUpdated == null) return false;
    final lastUpdate = DateTime.parse(data.lastUpdated!);
    final now = DateTime.now();
    return now.difference(lastUpdate).inDays < 30;
  }

  bool _isSameLocation(SoilData data, double lat, double lon) {
    return (data.latitude - lat).abs() < 0.1 &&
        (data.longitude - lon).abs() < 0.1;
  }

  /// Get soil recommendations based on properties
  List<String> getSoilRecommendations(SoilData soil) {
    final recommendations = <String>[];

    // pH recommendations
    if (soil.ph < 6.0) {
      recommendations.add(
        '🔵 Add lime to increase pH (currently ${soil.ph.toStringAsFixed(1)})',
      );
    } else if (soil.ph > 8.0) {
      recommendations.add(
        '🟡 Add sulfur to decrease pH (currently ${soil.ph.toStringAsFixed(1)})',
      );
    } else {
      recommendations.add(
        '✅ pH level is optimal (${soil.ph.toStringAsFixed(1)})',
      );
    }

    // Organic matter recommendations
    if (soil.organicCarbon < 2.0) {
      recommendations.add('🟠 Low organic matter - Add compost or manure');
    } else if (soil.organicCarbon > 5.0) {
      recommendations.add(
        '✅ Good organic matter content (${soil.organicCarbon.toStringAsFixed(1)}%)',
      );
    } else {
      recommendations.add('🟡 Moderate organic matter - Consider adding more');
    }

    // Texture recommendations
    if (soil.clayContent > 40) {
      recommendations.add(
        '🌾 Heavy clay soil - Improve drainage, add organic matter',
      );
    } else if (soil.sandContent > 70) {
      recommendations.add(
        '🌾 Sandy soil - Add clay/organic matter for water retention',
      );
    } else {
      recommendations.add('✅ Good soil texture (${soil.soilType})');
    }

    return recommendations;
  }
}
