/// Mock data service for web platform
/// Provides sample agricultural data for demonstration purposes
class MockDataService {
  static final MockDataService _instance = MockDataService._();

  MockDataService._();

  static MockDataService get instance => _instance;

  // Sample crop data
  static const List<Map<String, dynamic>> _cropData = [
    {
      'crop_name': 'rice',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 5000,
      'hectares': 1000,
    },
    {
      'crop_name': 'rice',
      'district': 'Narayanganj',
      'year': '2024',
      'production_mt': 4500,
      'hectares': 900,
    },
    {
      'crop_name': 'rice',
      'district': 'Tangail',
      'year': '2024',
      'production_mt': 6000,
      'hectares': 1200,
    },
    {
      'crop_name': 'wheat',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 3000,
      'hectares': 800,
    },
    {
      'crop_name': 'wheat',
      'district': 'Narayanganj',
      'year': '2024',
      'production_mt': 2500,
      'hectares': 700,
    },
    {
      'crop_name': 'potato',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 4000,
      'hectares': 400,
    },
    {
      'crop_name': 'potato',
      'district': 'Bogura',
      'year': '2024',
      'production_mt': 5500,
      'hectares': 550,
    },
    {
      'crop_name': 'maize',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 2500,
      'hectares': 500,
    },
    {
      'crop_name': 'maize',
      'district': 'Norsingdi',
      'year': '2024',
      'production_mt': 3000,
      'hectares': 600,
    },
    {
      'crop_name': 'tomato',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 3500,
      'hectares': 350,
    },
    {
      'crop_name': 'tomato',
      'district': 'Narayanganj',
      'year': '2024',
      'production_mt': 2800,
      'hectares': 280,
    },
    {
      'crop_name': 'lentil',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 1800,
      'hectares': 600,
    },
    {
      'crop_name': 'chickpea',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 2000,
      'hectares': 700,
    },
    {
      'crop_name': 'brinjal',
      'district': 'Dhaka',
      'year': '2024',
      'production_mt': 3200,
      'hectares': 320,
    },
    {
      'crop_name': 'rice',
      'district': 'Dhaka',
      'year': '2023',
      'production_mt': 4800,
      'hectares': 980,
    },
    {
      'crop_name': 'wheat',
      'district': 'Dhaka',
      'year': '2023',
      'production_mt': 2900,
      'hectares': 780,
    },
    {
      'crop_name': 'potato',
      'district': 'Dhaka',
      'year': '2023',
      'production_mt': 3900,
      'hectares': 390,
    },
    {
      'crop_name': 'rice',
      'district': 'Dhaka',
      'year': '2022',
      'production_mt': 4600,
      'hectares': 960,
    },
    {
      'crop_name': 'wheat',
      'district': 'Dhaka',
      'year': '2022',
      'production_mt': 2800,
      'hectares': 760,
    },
    {
      'crop_name': 'maize',
      'district': 'Bogura',
      'year': '2024',
      'production_mt': 2800,
      'hectares': 560,
    },
  ];

  static const List<Map<String, dynamic>> _predictionData = [
    {
      'crop_name': 'rice',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 5200,
      'area_hectares_pred': 1050,
    },
    {
      'crop_name': 'rice',
      'district': 'Narayanganj',
      'year': '2025',
      'production_mt_pred': 4700,
      'area_hectares_pred': 920,
    },
    {
      'crop_name': 'rice',
      'district': 'Tangail',
      'year': '2025',
      'production_mt_pred': 6200,
      'area_hectares_pred': 1220,
    },
    {
      'crop_name': 'wheat',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 3200,
      'area_hectares_pred': 820,
    },
    {
      'crop_name': 'wheat',
      'district': 'Narayanganj',
      'year': '2025',
      'production_mt_pred': 2700,
      'area_hectares_pred': 720,
    },
    {
      'crop_name': 'potato',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 4200,
      'area_hectares_pred': 420,
    },
    {
      'crop_name': 'potato',
      'district': 'Bogura',
      'year': '2025',
      'production_mt_pred': 5800,
      'area_hectares_pred': 580,
    },
    {
      'crop_name': 'maize',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 2700,
      'area_hectares_pred': 520,
    },
    {
      'crop_name': 'maize',
      'district': 'Norsingdi',
      'year': '2025',
      'production_mt_pred': 3200,
      'area_hectares_pred': 620,
    },
    {
      'crop_name': 'tomato',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 3700,
      'area_hectares_pred': 370,
    },
    {
      'crop_name': 'tomato',
      'district': 'Narayanganj',
      'year': '2025',
      'production_mt_pred': 3000,
      'area_hectares_pred': 300,
    },
    {
      'crop_name': 'lentil',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 1900,
      'area_hectares_pred': 620,
    },
    {
      'crop_name': 'chickpea',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 2100,
      'area_hectares_pred': 720,
    },
    {
      'crop_name': 'brinjal',
      'district': 'Dhaka',
      'year': '2025',
      'production_mt_pred': 3400,
      'area_hectares_pred': 340,
    },
  ];

  /// Get all crops from mock data
  List<String> getAllCrops() {
    final crops = <String>{};
    for (var row in _cropData) {
      crops.add(row['crop_name'] as String);
    }
    for (var row in _predictionData) {
      crops.add(row['crop_name'] as String);
    }
    return crops.toList()..sort();
  }

  /// Get all districts from mock data
  List<String> getAllDistricts() {
    final districts = <String>{};
    for (var row in _cropData) {
      districts.add(row['district'] as String);
    }
    return districts.toList()..sort();
  }

  /// Get years for a crop
  List<String> getYearsForCrop(String cropName) {
    final years = <String>{};
    for (var row in _cropData) {
      if ((row['crop_name'] as String).toLowerCase() ==
          cropName.toLowerCase()) {
        years.add(row['year'] as String);
      }
    }
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Get top yield districts
  List<Map<String, dynamic>> getTopYieldDistricts(
    String cropName,
    String year,
    int limit,
  ) {
    final results = _cropData
        .where(
          (row) =>
              (row['crop_name'] as String).toLowerCase() ==
                  cropName.toLowerCase() &&
              (row['year'] as String) == year,
        )
        .map((row) {
          final production = (row['production_mt'] as num? ?? 0).toDouble();
          final hectares = (row['hectares'] as num? ?? 0).toDouble();
          return {
            'district': row['district'],
            'production_mt': production,
            'hectares': hectares,
            'yield_per_hectare': hectares > 0 ? production / hectares : 0.0,
          };
        })
        .toList();

    results.sort(
      (a, b) => (b['yield_per_hectare'] as num).compareTo(
        a['yield_per_hectare'] as num,
      ),
    );

    if (limit > 0) {
      return results.take(limit).toList();
    }
    return results;
  }

  /// Get total yield
  Map<String, dynamic> getTotalYield(String cropName, String year) {
    final filtered = _cropData.where(
      (row) =>
          (row['crop_name'] as String).toLowerCase() ==
              cropName.toLowerCase() &&
          (row['year'] as String) == year,
    );

    double totalProduction = 0;
    double totalHectares = 0;

    for (var row in filtered) {
      totalProduction += (row['production_mt'] as num? ?? 0).toDouble();
      totalHectares += (row['hectares'] as num? ?? 0).toDouble();
    }

    return {
      'total_production': totalProduction,
      'total_hectares': totalHectares,
      'average_yield': totalHectares > 0
          ? totalProduction / totalHectares
          : 0.0,
    };
  }

  /// Get top yield districts from predictions
  List<Map<String, dynamic>> getTopYieldDistrictsFromPredictions(
    String cropName,
    int limit,
  ) {
    final results = _predictionData
        .where(
          (row) =>
              (row['crop_name'] as String).toLowerCase() ==
              cropName.toLowerCase(),
        )
        .map((row) {
          final production = (row['production_mt_pred'] as num? ?? 0)
              .toDouble();
          final hectares = (row['area_hectares_pred'] as num? ?? 0).toDouble();
          return {
            'district': row['district'],
            'production_mt_pred': production,
            'area_hectares_pred': hectares,
            'yield_per_hectare': hectares > 0 ? production / hectares : 0.0,
          };
        })
        .toList();

    results.sort(
      (a, b) => (b['yield_per_hectare'] as num).compareTo(
        a['yield_per_hectare'] as num,
      ),
    );

    if (limit > 0) {
      return results.take(limit).toList();
    }
    return results;
  }

  /// Get total yield from predictions
  Map<String, dynamic> getTotalYieldFromPredictions(String cropName) {
    final filtered = _predictionData.where(
      (row) =>
          (row['crop_name'] as String).toLowerCase() == cropName.toLowerCase(),
    );

    double totalProduction = 0;
    double totalHectares = 0;

    for (var row in filtered) {
      totalProduction += (row['production_mt_pred'] as num? ?? 0).toDouble();
      totalHectares += (row['area_hectares_pred'] as num? ?? 0).toDouble();
    }

    return {
      'total_production': totalProduction,
      'total_hectares': totalHectares,
      'average_yield': totalHectares > 0
          ? totalProduction / totalHectares
          : 0.0,
    };
  }

  /// Get district data for map
  Map<String, Map<String, dynamic>> getDistrictDataForMap(
    String cropName,
    String year,
  ) {
    final districtData = <String, Map<String, dynamic>>{};

    final filtered = _cropData.where(
      (row) =>
          (row['crop_name'] as String).toLowerCase() ==
              cropName.toLowerCase() &&
          (row['year'] as String) == year,
    );

    double totalProduction = 0;
    for (var row in filtered) {
      totalProduction += (row['production_mt'] as num? ?? 0).toDouble();
    }

    for (var row in filtered) {
      final district = row['district'] as String;
      final production = (row['production_mt'] as num? ?? 0).toDouble();
      final hectares = (row['hectares'] as num? ?? 0).toDouble();

      districtData[district] = {
        'production': production,
        'hectares': hectares,
        'yield': hectares > 0 ? production / hectares : 0.0,
        'percentage': totalProduction > 0
            ? (production / totalProduction) * 100
            : 0.0,
      };
    }

    return districtData;
  }

  /// Get pie chart data
  List<Map<String, dynamic>> getPieCropArea() {
    final areaByCategory = <String, double>{};

    for (var row in _cropData.where((r) => r['year'] == '2024')) {
      final cropName = row['crop_name'] as String;
      final hectares = (row['hectares'] as num? ?? 0).toDouble();
      areaByCategory[cropName] = (areaByCategory[cropName] ?? 0) + hectares;
    }

    return areaByCategory.entries
        .map((e) => {'crop': e.key, 'area': e.value})
        .toList();
  }

  /// Get generic pie chart data for different categories
  List<Map<String, dynamic>> getPieCategoryArea(List<String> crops) {
    final areaByCategory = <String, double>{};

    for (var row in _cropData.where(
      (r) => r['year'] == '2024' && crops.contains(r['crop_name']),
    )) {
      final cropName = row['crop_name'] as String;
      final hectares = (row['hectares'] as num? ?? 0).toDouble();
      areaByCategory[cropName] = (areaByCategory[cropName] ?? 0) + hectares;
    }

    return areaByCategory.entries
        .map((e) => {'crop': e.key, 'area': e.value})
        .toList();
  }
}
