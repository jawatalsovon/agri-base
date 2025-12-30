import 'database_service.dart';

/// Service for querying the crops.db database (created from CSV files)
class CropsDatabaseService {
  final DatabaseService _dbService = DatabaseService.instance;

  /// Get all available crops
  Future<List<String>> getAllCrops() async {
    try {
      final query =
          'SELECT DISTINCT crop_name FROM crop_data ORDER BY crop_name';
      final results = await _dbService.queryCrops(query);
      return results.map((row) => row['crop_name'] as String).toList();
    } catch (e) {

      return [];
    }
  }

  /// Get all available years for a crop
  Future<List<String>> getYearsForCrop(String cropName) async {
    try {
      final query = '''
        SELECT DISTINCT year 
        FROM crop_data 
        WHERE crop_name = ? 
        ORDER BY year DESC
      ''';
      final results = await _dbService.queryCrops(query, [cropName]);
      return results.map((row) => row['year'] as String).toList();
    } catch (e) {

      return [];
    }
  }

  /// Get all districts
  Future<List<String>> getAllDistricts() async {
    try {
      final query =
          'SELECT DISTINCT district FROM crop_data WHERE district IS NOT NULL ORDER BY district';
      final results = await _dbService.queryCrops(query);
      final districts = results
          .map((row) => row['district'] as String)
          .toList();
      return districts;
    } catch (e) {

      return [];
    }
  }

  /// Get top yield districts for a crop and year
  Future<List<Map<String, dynamic>>> getTopYieldDistricts(
    String cropName,
    String year, {
    int limit = 10,
  }) async {
    try {
      final query = '''
        SELECT 
          district,
          production_mt,
          hectares,
          CASE 
            WHEN hectares > 0 THEN production_mt / hectares 
            ELSE 0 
          END as yield_per_hectare
        FROM crop_data
        WHERE crop_name = ? AND year = ? AND production_mt IS NOT NULL
        ORDER BY yield_per_hectare DESC
        LIMIT ?
      ''';
      final results = await _dbService.queryCrops(query, [
        cropName,
        year,
        limit,
      ]);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get total yield for a crop and year
  Future<Map<String, dynamic>> getTotalYield(
    String cropName,
    String year,
  ) async {
    try {
      final query = '''
        SELECT 
          SUM(production_mt) as total_production,
          SUM(hectares) as total_hectares,
          CASE 
            WHEN SUM(hectares) > 0 THEN SUM(production_mt) / SUM(hectares)
            ELSE 0 
          END as average_yield
        FROM crop_data
        WHERE crop_name = ? AND year = ?
      ''';
      final results = await _dbService.queryCrops(query, [cropName, year]);
      if (results.isNotEmpty) {
        return results.first;
      }
      return {};
    } catch (e) {

      return {};
    }
  }

  /// Get yield by years for a crop and district (for analytics)
  Future<List<Map<String, dynamic>>> getYieldByYears(
    String cropName,
    String district,
  ) async {
    try {
      final query = '''
        SELECT 
          year,
          production_mt,
          hectares,
          CASE 
            WHEN hectares > 0 THEN production_mt / hectares 
            ELSE 0 
          END as yield_per_hectare
        FROM crop_data
        WHERE crop_name = ? AND district = ?
        ORDER BY year ASC
      ''';
      final results = await _dbService.queryCrops(query, [cropName, district]);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get district data for map visualization (for a specific crop and year)
  /// Returns a map with district name as key and data including percentage
  Future<Map<String, Map<String, dynamic>>> getDistrictDataForMap(
    String cropName,
    String year,
  ) async {
    try {
      final query = '''
        SELECT 
          district,
          production_mt,
          hectares,
          CASE 
            WHEN hectares > 0 THEN production_mt / hectares 
            ELSE 0 
          END as yield_per_hectare
        FROM crop_data
        WHERE crop_name = ? AND year = ? AND district IS NOT NULL
      ''';
      final results = await _dbService.queryCrops(query, [cropName, year]);

      // Calculate total production for percentage calculation
      double totalProduction = 0;
      for (final row in results) {
        totalProduction += (row['production_mt'] as num? ?? 0).toDouble();
      }

      final districtMap = <String, Map<String, dynamic>>{};
      for (final row in results) {
        final district = row['district'] as String?;
        if (district == null) continue;

        final production = (row['production_mt'] as num? ?? 0).toDouble();
        final percentage = totalProduction > 0
            ? (production / totalProduction * 100)
            : 0;

        districtMap[district] = {
          'production': production,
          'hectares': row['hectares'],
          'yield': row['yield_per_hectare'],
          'percentage': percentage,
        };
      }

      return districtMap;
    } catch (e) {

      return {};
    }
  }

  /// Get top crops for a district and year (for My Region)
  Future<List<Map<String, dynamic>>> getTopCropsForDistrict(
    String district,
    String year, {
    int limit = 10,
  }) async {
    try {
      final query = '''
        SELECT 
          crop_name,
          production_mt,
          hectares,
          CASE 
            WHEN hectares > 0 THEN production_mt / hectares 
            ELSE 0 
          END as yield_per_hectare
        FROM crop_data
        WHERE district = ? AND year = ? AND production_mt IS NOT NULL
        ORDER BY production_mt DESC
        LIMIT ?
      ''';
      final results = await _dbService.queryCrops(query, [
        district,
        year,
        limit,
      ]);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get prediction data for a crop
  Future<List<Map<String, dynamic>>> getPredictionData(String cropName) async {
    try {
      final query = '''
        SELECT 
          district,
          area_hectares_pred,
          production_mt_pred
        FROM crop_predictions
        WHERE crop_name = ?
        ORDER BY production_mt_pred DESC
      ''';
      final results = await _dbService.queryCrops(query, [cropName]);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get top yield districts from predictions
  Future<List<Map<String, dynamic>>> getTopYieldDistrictsFromPredictions(
    String cropName, {
    int limit = 10,
  }) async {
    try {
      final query = '''
        SELECT 
          district,
          area_hectares_pred,
          production_mt_pred,
          CASE 
            WHEN area_hectares_pred > 0 THEN production_mt_pred / area_hectares_pred 
            ELSE 0 
          END as yield_per_hectare
        FROM crop_predictions
        WHERE crop_name = ? AND production_mt_pred IS NOT NULL
        ORDER BY yield_per_hectare DESC
        LIMIT ?
      ''';
      final results = await _dbService.queryCrops(query, [cropName, limit]);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get total yield from predictions
  Future<Map<String, dynamic>> getTotalYieldFromPredictions(
    String cropName,
  ) async {
    try {
      final query = '''
        SELECT 
          SUM(production_mt_pred) as total_production,
          SUM(area_hectares_pred) as total_hectares,
          CASE 
            WHEN SUM(area_hectares_pred) > 0 THEN SUM(production_mt_pred) / SUM(area_hectares_pred)
            ELSE 0 
          END as average_yield
        FROM crop_predictions
        WHERE crop_name = ?
      ''';
      final results = await _dbService.queryCrops(query, [cropName]);
      if (results.isNotEmpty) {
        return results.first;
      }
      return {};
    } catch (e) {

      return {};
    }
  }

  /// Get pie chart data for crop area
  Future<List<Map<String, dynamic>>> getPieCropArea() async {
    try {
      final query = 'SELECT * FROM pie_crop_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for fibre area
  Future<List<Map<String, dynamic>>> getPieFibreArea() async {
    try {
      final query = 'SELECT * FROM pie_fibre_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for narcos area
  Future<List<Map<String, dynamic>>> getPieNarcosArea() async {
    try {
      final query = 'SELECT * FROM pie_narcos_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for oilseed area
  Future<List<Map<String, dynamic>>> getPieOilseedArea() async {
    try {
      final query = 'SELECT * FROM pie_oilseed_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for pulse area
  Future<List<Map<String, dynamic>>> getPiePulseArea() async {
    try {
      final query = 'SELECT * FROM pie_pulse_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for rice area
  Future<List<Map<String, dynamic>>> getPieRiceArea() async {
    try {
      final query = 'SELECT * FROM pie_rice_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for spices area
  Future<List<Map<String, dynamic>>> getPieSpicesArea() async {
    try {
      final query = 'SELECT * FROM pie_spices_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }

  /// Get pie chart data for suger area
  Future<List<Map<String, dynamic>>> getPieSugerArea() async {
    try {
      final query = 'SELECT * FROM pie_sugar_area';
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {

      return [];
    }
  }
}
