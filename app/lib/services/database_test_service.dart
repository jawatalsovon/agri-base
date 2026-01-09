import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'database_service.dart';

class DatabaseTestService {
  final DatabaseService _dbService = DatabaseService.instance;

  /// Test database connection and output sample data
  Future<void> testDatabase() async {
    // Skip database tests on web platform
    if (kIsWeb) {
      debugPrint('Web platform: skipping database tests');
      return;
    }

    try {
      // Test 1: List all tables in attempt.db

      final attemptTables = await _dbService.getTableNames(
        _dbService.attemptDb,
      );

      for (int i = 0; i < attemptTables.length && i < 30; i++) {}

      // Test 2: Try to read from a specific table

      // Try aman_total_area_2018
      if (attemptTables.contains('aman_total_area_2018')) {
        final query1 = 'SELECT * FROM "aman_total_area_2018" LIMIT 5';
        final results1 = await _dbService.queryAttempt(query1);

        if (results1.isNotEmpty) {
          results1.first.forEach((key, value) {});
        }
      }

      // Try wheat_dist_2018
      if (attemptTables.contains('wheat_dist_2018')) {
        final query2 = 'SELECT * FROM "wheat_dist_2018" LIMIT 5';
        final results2 = await _dbService.queryAttempt(query2);

        if (results2.isNotEmpty) {
          results2.first.forEach((key, value) {});
        }
      }

      // Test 3: Count rows in some tables

      final keyTables = [
        'aman_total_area_2018',
        'wheat_dist_2018',
        'aus_total_area_2018',
        'boro_total_area_2018',
      ];
      for (final table in keyTables) {
        if (attemptTables.contains(table)) {
          try {
            final countQuery = 'SELECT COUNT(*) as cnt FROM "$table"';
            final countResult = await _dbService.queryAttempt(countQuery);
            if (countResult.isNotEmpty) {}
          } catch (e) {
            // ignore: empty_catches
          }
        } else {}
      }

      // Test 4: Try to find district column and get unique districts

      if (attemptTables.contains('wheat_dist_2018')) {
        try {
          // Get sample rows to find district column
          final sampleQuery = 'SELECT * FROM "wheat_dist_2018" LIMIT 10';
          final sample = await _dbService.queryAttempt(sampleQuery);
          if (sample.isNotEmpty) {
            final columns = sample.first.keys.toList();

            // Find district column (look for Zila/Division or similar)
            String? districtCol;
            for (final col in columns) {
              final colStr = col.toString().toLowerCase();
              if (colStr.contains('district') ||
                  colStr.contains('division') ||
                  colStr.contains('zila')) {
                districtCol = col;
                break;
              }
            }

            if (districtCol != null) {
              // Properly quote column name
              final quotedCol = districtCol.contains('/')
                  ? '"$districtCol"'
                  : districtCol;
              final districtQuery =
                  '''
                SELECT DISTINCT $quotedCol as district
                FROM "wheat_dist_2018"
                WHERE $quotedCol IS NOT NULL
                  AND $quotedCol != 'Bangladesh'
                  AND $quotedCol NOT LIKE '%Acres%'
                  AND $quotedCol NOT LIKE '%Hectares%'
                LIMIT 20
              ''';
              final districts = await _dbService.queryAttempt(districtQuery);

              for (final _ in districts) {}
            } else {}

            // Show first few data rows (skip headers)

            for (int i = 0; i < sample.length && i < 5; i++) {
              final districtVal = districtCol != null
                  ? sample[i][districtCol]
                  : 'N/A';
              if (districtVal != null &&
                  districtVal.toString().toLowerCase() != 'acres' &&
                  districtVal.toString().toLowerCase() != 'hectares') {}
            }
          }
        } catch (e) {
          // ignore: empty_catches
        }
      }

      // Test 5: Check predictions.db

      final predictionsTables = await _dbService.getTableNames(
        _dbService.predictionsDb,
      );

      if (predictionsTables.isNotEmpty) {
        for (int i = 0; i < predictionsTables.length && i < 10; i++) {}
      }
    } catch (e) {
      // ignore: empty_catches
    }
  }
}
