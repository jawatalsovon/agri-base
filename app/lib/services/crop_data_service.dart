import '../models/district_data.dart';
import '../models/year_statistics.dart';
import 'database_service.dart';

class CropDataService {
  final DatabaseService _dbService = DatabaseService.instance;

  // Crop hierarchy matching Flask app
  static const Map<String, List<String>> cropHierarchy = {
    "Major Cereals": ["Aus Rice", "Aman Rice", "Boro Rice", "Wheat"],
    "Minor Cereals": ["Maize", "Jower (Millet)", "Barley/Jab", "Cheena & Kaon", "Binnidana"],
    "Pulses": ["Lentil (Masur)", "Kheshari", "Mashkalai", "Mung", "Gram", "Motor", "Fallon", "Other Pulses"],
    "Oilseeds": ["Rape and Mustard", "Til", "Groundnut", "Soyabean", "Linseed", "Coconut", "Sunflower"],
    "Spices": ["Onion", "Garlic", "Chillies", "Turmeric", "Ginger", "Coriander", "Other Spices"],
    "Sugar Crops": ["Sugarcane", "Date Palm", "Palmyra Palm"],
    "Fibers": ["Jute", "Cotton", "Sunhemp"],
    "Narcotics": ["Tea", "Betelnut", "Betel Leaves", "Tobacco"],
  };

  static const List<String> availableMajorCrops = ["Aus Rice", "Aman Rice", "Boro Rice", "Wheat"];

  // Map crop names to table name patterns (attempt.db uses year-specific tables)
  // Some tables are district-level (_dist), others are area summaries (_area)
  static String? _getTablePatternForCrop(String crop) {
    final tableMap = {
      "Aus Rice": "aus_total_dist",  // Try _dist first for district data
      "Aman Rice": "aman_total_dist",
      "Boro Rice": "boro_total_dist",
      "Wheat": "wheat_dist",
    };
    return tableMap[crop];
  }

  // Get the latest available year table for a crop
  Future<String?> _getLatestTableForCrop(String crop) async {
    final pattern = _getTablePatternForCrop(crop);
    if (pattern == null) return null;

    final allTables = await _dbService.getAllTableNames();
    
      // Try years from 2024 down to 2017
      for (int year = 2024; year >= 2017; year--) {
        // Try different patterns - prioritize _dist for district data
        final patterns = [
          '${pattern}_$year',           // e.g., wheat_dist_2018
          '${pattern}_dist_$year',      // e.g., aman_total_dist_2018
          '${pattern}_area_$year',      // e.g., aman_total_area_2018 (summary, not district)
          '${pattern}_by_district_$year',
        ];
        
        for (final tableName in patterns) {
          if (allTables.contains(tableName)) {
            // Check if this table has district data (more than a few rows)
            try {
              final countQuery = 'SELECT COUNT(*) as cnt FROM "$tableName"';
              final countResult = await _dbService.queryAttempt(countQuery);
              if (countResult.isNotEmpty) {
                final count = countResult.first['cnt'] as int? ?? 0;
                // District tables should have many rows (one per district)
                if (count > 10) {
                  print('Found table: $tableName for $crop (${count} rows)');
                  return tableName;
                }
              }
            } catch (e) {
              // If count fails, still try the table
              print('Found table: $tableName for $crop (could not count rows)');
              return tableName;
            }
          }
        }
      }
    
    // If no year-specific table found, try without year
    if (allTables.contains(pattern)) {
      return pattern;
    }
    
    return null;
  }

  /// Get all districts from database
  Future<List<String>> getDistricts() async {
    try {
      // Get districts from the latest aman table
      final tableName = await _getLatestTableForCrop('Aman Rice');
      if (tableName == null) {
        print('Could not find aman table for districts');
        return [];
      }

      // Find district column - get more rows to skip header rows
      final sampleQuery = 'SELECT * FROM "$tableName" LIMIT 10';
      final sampleResults = await _dbService.queryAttempt(sampleQuery);
      if (sampleResults.isEmpty) return [];

      final columns = sampleResults.first.keys.toList();
      String? districtCol;
      for (final col in columns) {
        final colStr = col.toString().toLowerCase();
        if ((colStr.contains('district') || colStr.contains('division') || colStr.contains('zila')) 
            && !colStr.contains('unnamed')) {
          districtCol = col;
          break;
        }
      }

      if (districtCol == null) return [];

      final quotedCol = _quoteColumn(districtCol);
      final query = '''
        SELECT DISTINCT $quotedCol as district
        FROM "$tableName" 
        WHERE $quotedCol IS NOT NULL
          AND $quotedCol != 'Bangladesh'
          AND $quotedCol NOT LIKE '%Division'
          AND $quotedCol NOT LIKE '%Acres%'
          AND $quotedCol NOT LIKE '%Hectares%'
          AND $quotedCol NOT LIKE '%Area%'
        ORDER BY $quotedCol
      ''';
      final results = await _dbService.queryAttempt(query);
      return results.map((row) => row['district'] as String).toList();
    } catch (e) {
      print('Error getting districts: $e');
      return [];
    }
  }

  /// Get year-over-year statistics for a crop
  Future<List<YearStatistics>> getYearStatistics(String crop) async {
    try {
      final pattern = _getTablePatternForCrop(crop);
      if (pattern == null) {
        return [];
      }

      final yearStats = <YearStatistics>[];
      final allTables = await _dbService.getAllTableNames();

      // Get data for each available year (2017-2024)
      for (int year = 2017; year <= 2024; year++) {
        // Try different table name patterns
        final tablePatterns = [
          '${pattern}_$year',
          '${pattern}_area_$year',
          '${pattern}_dist_$year',
          '${pattern}_by_district_$year',
        ];

        String? tableName;
        for (final patternName in tablePatterns) {
          if (allTables.contains(patternName)) {
            tableName = patternName;
            break;
          }
        }

        if (tableName == null) continue;

        try {
          // Get sample row to see column structure
          final sampleQuery = 'SELECT * FROM "$tableName" LIMIT 1';
          final sampleResults = await _dbService.queryAttempt(sampleQuery);
          
          if (sampleResults.isEmpty) continue;

          final columns = sampleResults.first.keys.toList();
          
          // Find production, yield, and area columns
          // Skip "Unnamed" columns
          String? prodCol, yieldCol, areaCol;
          for (final col in columns) {
            final colStr = col.toString().toLowerCase();
            if (colStr.contains('unnamed')) continue;
            
            if (colStr.contains('production') && prodCol == null) {
              prodCol = col;
            } else if (colStr.contains('yield') && yieldCol == null) {
              yieldCol = col;
            } else if ((colStr.contains('area') || colStr.contains('acreage')) && areaCol == null) {
              areaCol = col;
            }
          }
          
          // Aggregate data for this year
          double? totalProduction, avgYield, totalArea;

          if (prodCol != null) {
            final quotedProdCol = _quoteColumn(prodCol);
            final prodQuery = '''
              SELECT SUM(CAST($quotedProdCol AS REAL)) as total
              FROM "$tableName"
              WHERE $quotedProdCol IS NOT NULL AND $quotedProdCol != ''
                AND $quotedProdCol NOT LIKE '%Ton%'
                AND $quotedProdCol NOT LIKE '%Acres%'
            ''';
            final prodResult = await _dbService.queryAttempt(prodQuery);
            if (prodResult.isNotEmpty && prodResult.first['total'] != null) {
              totalProduction = _parseDouble(prodResult.first['total']);
            }
          }

          if (yieldCol != null) {
            final quotedYieldCol = _quoteColumn(yieldCol);
            final yieldQuery = '''
              SELECT AVG(CAST($quotedYieldCol AS REAL)) as avg_yield
              FROM "$tableName"
              WHERE $quotedYieldCol IS NOT NULL AND $quotedYieldCol != ''
                AND $quotedYieldCol NOT LIKE '%Ton%'
            ''';
            final yieldResult = await _dbService.queryAttempt(yieldQuery);
            if (yieldResult.isNotEmpty && yieldResult.first['avg_yield'] != null) {
              avgYield = _parseDouble(yieldResult.first['avg_yield']);
            }
          }

          if (areaCol != null) {
            final quotedAreaCol = _quoteColumn(areaCol);
            final areaQuery = '''
              SELECT SUM(CAST($quotedAreaCol AS REAL)) as total
              FROM "$tableName"
              WHERE $quotedAreaCol IS NOT NULL AND $quotedAreaCol != ''
                AND $quotedAreaCol NOT LIKE '%Acres%'
                AND $quotedAreaCol NOT LIKE '%Hectares%'
            ''';
            final areaResult = await _dbService.queryAttempt(areaQuery);
            if (areaResult.isNotEmpty && areaResult.first['total'] != null) {
              totalArea = _parseDouble(areaResult.first['total']);
            }
          }

          if (totalProduction != null || avgYield != null) {
            yearStats.add(YearStatistics(
              year: year,
              production: totalProduction ?? 0,
              yieldValue: avgYield ?? 0,
              areaUnder: totalArea ?? 0,
            ));
          }
        } catch (e) {
          print('Error processing year $year for $crop: $e');
          continue;
        }
      }

      return yearStats;
    } catch (e) {
      print('Error getting year statistics for $crop: $e');
      return [];
    }
  }

  /// Get total production for a crop (latest year available)
  Future<double> getTotalProduction(String crop) async {
    try {
      final yearStats = await getYearStatistics(crop);
      if (yearStats.isEmpty) return 0.0;
      
      yearStats.sort((a, b) => b.year.compareTo(a.year));
      return yearStats.first.production;
    } catch (e) {
      print('Error getting total production: $e');
      return 0.0;
    }
  }

  /// Get average yield for a crop (latest year available)
  Future<double> getAverageYield(String crop) async {
    try {
      final yearStats = await getYearStatistics(crop);
      if (yearStats.isEmpty) return 0.0;
      
      yearStats.sort((a, b) => b.year.compareTo(a.year));
      return yearStats.first.yieldValue;
    } catch (e) {
      print('Error getting average yield: $e');
      return 0.0;
    }
  }

  // Helper to properly quote column names for SQL
  static String _quoteColumn(String col) {
    // If it contains special characters, wrap in quotes
    if (col.contains('/') || col.contains(' ') || col.contains('-')) {
      return '"$col"';
    }
    return col;
  }

  /// Get district data for a crop (for map visualization)
  Future<Map<String, DistrictData>> getDistrictData(String crop) async {
    try {
      // Get the latest available year table
      final tableName = await _getLatestTableForCrop(crop);
      if (tableName == null) {
        print('No table found for crop: $crop');
        return {};
      }

      // Get sample rows to find column names (get more to skip header rows)
      final sampleQuery = 'SELECT * FROM "$tableName" LIMIT 10';
      final sampleResults = await _dbService.queryAttempt(sampleQuery);
      
      if (sampleResults.isEmpty) {
        print('Table $tableName is empty');
        return {};
      }

      final columns = sampleResults.first.keys.toList();
      
      // Find district, production, and yield columns
      // Skip "Unnamed" columns and header-like values
      String? districtCol, prodCol, yieldCol;
      for (final col in columns) {
        final colStr = col.toString().toLowerCase();
        // Skip unnamed columns and columns that look like headers
        if (colStr.contains('unnamed') || colStr == 'variety' || colStr.contains('percentage')) {
          continue;
        }
        
        if ((colStr.contains('district') || colStr.contains('division') || colStr.contains('zila')) && districtCol == null) {
          districtCol = col;
        } else if (colStr.contains('production') && prodCol == null) {
          prodCol = col;
        } else if (colStr.contains('yield') && yieldCol == null) {
          yieldCol = col;
        }
      }

      if (districtCol == null) {
        print('Could not find district column in $tableName. Available columns: $columns');
        // Try to get more rows to see if there's a header row
        if (sampleResults.length > 1) {
          print('First few rows:');
          for (int i = 0; i < sampleResults.length && i < 3; i++) {
            print('  Row $i: ${sampleResults[i]}');
          }
        }
        return {};
      }

      // Build query - skip rows that look like headers
      final quotedDistrictCol = _quoteColumn(districtCol);
      final selectCols = [quotedDistrictCol];
      if (prodCol != null) selectCols.add('${_quoteColumn(prodCol)} as production');
      if (yieldCol != null) selectCols.add('${_quoteColumn(yieldCol)} as yield_value');

      final query = '''
        SELECT ${selectCols.join(', ')}
        FROM "$tableName"
        WHERE $quotedDistrictCol IS NOT NULL
          AND $quotedDistrictCol != 'Bangladesh'
          AND $quotedDistrictCol NOT LIKE '%Division'
          AND $quotedDistrictCol NOT LIKE '%Acres%'
          AND $quotedDistrictCol NOT LIKE '%Hectares%'
          AND $quotedDistrictCol NOT LIKE '%Area%'
          AND $quotedDistrictCol NOT LIKE '%Ton%'
          ${prodCol != null ? 'AND ${_quoteColumn(prodCol)} IS NOT NULL AND ${_quoteColumn(prodCol)} != \'\'' : ''}
      ''';

      final results = await _dbService.queryAttempt(query);
      
      print('Found ${results.length} districts for $crop from $tableName');
      
      final districtMap = <String, DistrictData>{};
      
      for (final row in results) {
        // Get district name
        final districtName = row[districtCol] as String? ?? row['district'] as String?;
        if (districtName == null || districtName.isEmpty) continue;
        
        // Skip if it looks like a header row
        final districtLower = districtName.toLowerCase();
        if (districtLower.contains('area') || 
            districtLower.contains('hectare') ||
            districtLower.contains('acre') ||
            districtLower.contains('production') ||
            districtLower == 'variety' ||
            districtLower.contains('ton') ||
            districtLower.contains('maund')) {
          continue;
        }

        final production = prodCol != null ? (_parseDouble(row['production']) ?? 0.0) : 0.0;
        final yieldValue = yieldCol != null ? (_parseDouble(row['yield_value']) ?? 0.0) : 0.0;

        districtMap[districtName] = DistrictData(
          name: districtName,
          bnName: districtName, // TODO: Add Bengali name mapping
          lat: 23.8103, // TODO: Add actual coordinates from a mapping file
          long: 90.4125,
          production: production,
          yieldValue: yieldValue,
        );
      }

      return districtMap;
    } catch (e, stackTrace) {
      print('Error getting district data for $crop: $e');
      print('Stack trace: $stackTrace');
      return {};
    }
  }

  /// Get crop analysis data by crop and district
  Future<List<Map<String, dynamic>>> getCropAnalysis(String crop, String district) async {
    try {
      final tableName = await _getLatestTableForCrop(crop);
      if (tableName == null) {
        return [];
      }

      // Find district column name
      final sampleQuery = 'SELECT * FROM "$tableName" LIMIT 1';
      final sampleResults = await _dbService.queryAttempt(sampleQuery);
      if (sampleResults.isEmpty) return [];

      final columns = sampleResults.first.keys.toList();
      String? districtCol;
      for (final col in columns) {
        final colStr = col.toString().toLowerCase();
        if (colStr.contains('district') || colStr.contains('division')) {
          districtCol = col;
          break;
        }
      }

      if (districtCol == null) return [];

      final query = 'SELECT * FROM "$tableName" WHERE "$districtCol" = ?';
      final results = await _dbService.queryAttempt(query, [district]);
      return results;
    } catch (e) {
      print('Error getting crop analysis: $e');
      return [];
    }
  }

  /// Get top producing districts for a crop
  Future<List<Map<String, dynamic>>> getTopDistricts(String crop, {int limit = 10}) async {
    try {
      final tableName = await _getLatestTableForCrop(crop);
      if (tableName == null) {
        return [];
      }

      // Find district and production columns
      final sampleQuery = 'SELECT * FROM "$tableName" LIMIT 1';
      final sampleResults = await _dbService.queryAttempt(sampleQuery);
      if (sampleResults.isEmpty) return [];

      final columns = sampleResults.first.keys.toList();
      String? districtCol, prodCol;
      for (final col in columns) {
        final colStr = col.toString().toLowerCase();
        if ((colStr.contains('district') || colStr.contains('division')) && districtCol == null) {
          districtCol = col;
        } else if (colStr.contains('production') && prodCol == null) {
          prodCol = col;
        }
      }

      if (districtCol == null || prodCol == null) return [];

      final query = '''
        SELECT "$districtCol" as district, "$prodCol" as production
        FROM "$tableName"
        WHERE "$prodCol" IS NOT NULL 
          AND "$prodCol" != ''
          AND "$districtCol" != 'Bangladesh' 
          AND "$districtCol" NOT LIKE '%Division'
        ORDER BY CAST("$prodCol" AS REAL) DESC
        LIMIT $limit
      ''';
      
      final results = await _dbService.queryAttempt(query);
      return results;
    } catch (e) {
      print('Error getting top districts: $e');
      return [];
    }
  }

  /// Get top crops for a district
  Future<List<Map<String, dynamic>>> getTopCropsForDistrict(String district) async {
    try {
      final results = <Map<String, dynamic>>[];
      
      // Get production for each crop
      for (final crop in availableMajorCrops) {
        final tableName = await _getLatestTableForCrop(crop);
        if (tableName == null) continue;

        // Find district and production columns
        final sampleQuery = 'SELECT * FROM "$tableName" LIMIT 1';
        final sampleResults = await _dbService.queryAttempt(sampleQuery);
        if (sampleResults.isEmpty) continue;

        final columns = sampleResults.first.keys.toList();
        String? districtCol, prodCol;
        for (final col in columns) {
          final colStr = col.toString().toLowerCase();
          if ((colStr.contains('district') || colStr.contains('division')) && districtCol == null) {
            districtCol = col;
          } else if (colStr.contains('production') && prodCol == null) {
            prodCol = col;
          }
        }

        if (districtCol == null || prodCol == null) continue;

        final query = '''
          SELECT "$prodCol" as production
          FROM "$tableName"
          WHERE "$districtCol" = ?
        ''';
        
        final cropResults = await _dbService.queryAttempt(query, [district]);
        if (cropResults.isNotEmpty && cropResults.first['production'] != null) {
          final production = _parseDouble(cropResults.first['production']);
          if (production != null && production > 0) {
            results.add({
              'Crop': crop,
              'Production': production,
            });
          }
        }
      }

      results.sort((a, b) => (b['Production'] as double).compareTo(a['Production'] as double));
      return results;
    } catch (e) {
      print('Error getting top crops for district: $e');
      return [];
    }
  }

  /// Get area summary data
  Future<List<Map<String, dynamic>>> getAreaSummary() async {
    try {
      // Check if area_summary table exists in attempt.db
      final allTables = await _dbService.getTableNames(_dbService.attemptDb);
      if (allTables.contains('area_summary')) {
        final query = 'SELECT * FROM "area_summary"';
        return await _dbService.queryAttempt(query);
      }
      return [];
    } catch (e) {
      print('Error getting area summary: $e');
      return [];
    }
  }

  /// Get yield summary data
  Future<List<Map<String, dynamic>>> getYieldSummary() async {
    try {
      final allTables = await _dbService.getTableNames(_dbService.attemptDb);
      if (allTables.contains('yield_summery')) {
        final query = 'SELECT * FROM "yield_summery"';
        return await _dbService.queryAttempt(query);
      }
      return [];
    } catch (e) {
      print('Error getting yield summary: $e');
      return [];
    }
  }

  /// Get pie chart tables
  Future<List<String>> getPieChartTables() async {
    try {
      final allTables = await _dbService.getTableNames(_dbService.attemptDb);
      return allTables.where((table) => table.startsWith('pie_')).toList();
    } catch (e) {
      print('Error getting pie chart tables: $e');
      return [];
    }
  }

  /// Get pie chart data for a table
  Future<List<Map<String, dynamic>>> getPieChartData(String tableName) async {
    try {
      final query = 'SELECT "Category", "Percentage" FROM "$tableName"';
      return await _dbService.queryAttempt(query);
    } catch (e) {
      print('Error getting pie chart data: $e');
      return [];
    }
  }

  /// Get prediction data for a crop from predictions.db
  Future<Map<String, dynamic>> getPredictionData(String crop) async {
    try {
      final allTables = await _dbService.getTableNames(_dbService.predictionsDb);
      
      // Look for tables matching the crop name
      final matchingTables = allTables.where((table) => 
        table.toLowerCase().contains(crop.toLowerCase().replaceAll(' ', '_'))
      ).toList();

      if (matchingTables.isEmpty) {
        return {};
      }

      // Query the first matching table
      final tableName = matchingTables.first;
      final query = 'SELECT * FROM "$tableName" LIMIT 1';
      final results = await _dbService.queryPredictions(query);

      if (results.isEmpty) {
        return {};
      }

      return results.first;
    } catch (e) {
      print('Error getting prediction data: $e');
      return {};
    }
  }

  /// Helper to parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Remove commas and parse
      final cleaned = value.replaceAll(',', '').trim();
      return double.tryParse(cleaned);
    }
    return null;
  }
}
