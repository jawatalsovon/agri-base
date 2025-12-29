import 'database_service.dart';

class DatabaseTestService {
  final DatabaseService _dbService = DatabaseService.instance;

  /// Test database connection and output sample data
  Future<void> testDatabase() async {
    print('\n========== DATABASE TEST START ==========');
    
    try {
      // Test 1: List all tables in attempt.db
      print('\n--- Test 1: Listing all tables in attempt.db ---');
      final attemptTables = await _dbService.getTableNames(_dbService.attemptDb);
      print('Total tables found: ${attemptTables.length}');
      print('First 30 tables:');
      for (int i = 0; i < attemptTables.length && i < 30; i++) {
        print('  ${i + 1}. ${attemptTables[i]}');
      }

      // Test 2: Try to read from a specific table
      print('\n--- Test 2: Reading sample data from tables ---');
      
      // Try aman_total_area_2018
      if (attemptTables.contains('aman_total_area_2018')) {
        print('\nReading from aman_total_area_2018:');
        final query1 = 'SELECT * FROM "aman_total_area_2018" LIMIT 5';
        final results1 = await _dbService.queryAttempt(query1);
        print('  Rows found: ${results1.length}');
        if (results1.isNotEmpty) {
          print('  Columns: ${results1.first.keys.toList()}');
          print('  First row sample:');
          results1.first.forEach((key, value) {
            print('    $key: $value');
          });
        }
      }

      // Try wheat_dist_2018
      if (attemptTables.contains('wheat_dist_2018')) {
        print('\nReading from wheat_dist_2018:');
        final query2 = 'SELECT * FROM "wheat_dist_2018" LIMIT 5';
        final results2 = await _dbService.queryAttempt(query2);
        print('  Rows found: ${results2.length}');
        if (results2.isNotEmpty) {
          print('  Columns: ${results2.first.keys.toList()}');
          print('  First row sample:');
          results2.first.forEach((key, value) {
            print('    $key: $value');
          });
        }
      }

      // Test 3: Count rows in some tables
      print('\n--- Test 3: Counting rows in key tables ---');
      final keyTables = ['aman_total_area_2018', 'wheat_dist_2018', 'aus_total_area_2018', 'boro_total_area_2018'];
      for (final table in keyTables) {
        if (attemptTables.contains(table)) {
          try {
            final countQuery = 'SELECT COUNT(*) as cnt FROM "$table"';
            final countResult = await _dbService.queryAttempt(countQuery);
            if (countResult.isNotEmpty) {
              print('  $table: ${countResult.first['cnt']} rows');
            }
          } catch (e) {
            print('  $table: Error counting - $e');
          }
        } else {
          print('  $table: NOT FOUND');
        }
      }

      // Test 4: Try to find district column and get unique districts
      print('\n--- Test 4: Finding districts in wheat_dist_2018 ---');
      if (attemptTables.contains('wheat_dist_2018')) {
        try {
          // Get sample rows to find district column
          final sampleQuery = 'SELECT * FROM "wheat_dist_2018" LIMIT 10';
          final sample = await _dbService.queryAttempt(sampleQuery);
          if (sample.isNotEmpty) {
            final columns = sample.first.keys.toList();
            print('  Available columns: $columns');
            
            // Find district column (look for Zila/Division or similar)
            String? districtCol;
            for (final col in columns) {
              final colStr = col.toString().toLowerCase();
              if (colStr.contains('district') || colStr.contains('division') || colStr.contains('zila')) {
                districtCol = col;
                break;
              }
            }
            
            if (districtCol != null) {
              print('  Found district column: $districtCol');
              // Properly quote column name
              final quotedCol = districtCol.contains('/') ? '"$districtCol"' : districtCol;
              final districtQuery = '''
                SELECT DISTINCT $quotedCol as district
                FROM "wheat_dist_2018"
                WHERE $quotedCol IS NOT NULL
                  AND $quotedCol != 'Bangladesh'
                  AND $quotedCol NOT LIKE '%Acres%'
                  AND $quotedCol NOT LIKE '%Hectares%'
                LIMIT 20
              ''';
              final districts = await _dbService.queryAttempt(districtQuery);
              print('  Sample districts (first 20):');
              for (final row in districts) {
                print('    - ${row['district']}');
              }
            } else {
              print('  No district column found');
            }
            
            // Show first few data rows (skip headers)
            print('\n  First 5 data rows (skipping headers):');
            for (int i = 0; i < sample.length && i < 5; i++) {
              final row = sample[i];
              final districtVal = districtCol != null ? row[districtCol] : 'N/A';
              if (districtVal != null && 
                  districtVal.toString().toLowerCase() != 'acres' &&
                  districtVal.toString().toLowerCase() != 'hectares') {
                print('    Row $i: $districtVal');
              }
            }
          }
        } catch (e) {
          print('  Error finding districts: $e');
        }
      }

      // Test 5: Check predictions.db
      print('\n--- Test 5: Checking predictions.db ---');
      final predictionsTables = await _dbService.getTableNames(_dbService.predictionsDb);
      print('  Total tables in predictions.db: ${predictionsTables.length}');
      if (predictionsTables.isNotEmpty) {
        print('  First 10 tables:');
        for (int i = 0; i < predictionsTables.length && i < 10; i++) {
          print('    ${i + 1}. ${predictionsTables[i]}');
        }
      }

      print('\n========== DATABASE TEST END ==========\n');
    } catch (e, stackTrace) {
      print('\nERROR in database test: $e');
      print('Stack trace: $stackTrace');
      print('========== DATABASE TEST END (WITH ERRORS) ==========\n');
    }
  }
}

