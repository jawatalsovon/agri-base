import 'package:sqflite/sqflite.dart';

import 'database_service.dart';

/// Logical databases that roughly map to how the Flask app used them.
///
/// - `attempt`: historical data 2017–2024
/// - `predictions`: forecast / prediction data (e.g. 2025)
/// - `crops`: cleaned crop CSV-derived data
enum TargetDb { attempt, predictions, crops }

/// Thin wrapper around `DatabaseService` that exposes a generic
/// read-only query interface for the different SQLite databases.
///
/// This is what the AI assistant will use when executing model-generated
/// SELECT queries, so we keep it minimal and safe.
class DbService {
  DbService._();

  static final DbService instance = DbService._();

  final DatabaseService _dbService = DatabaseService.instance;

  /// Get the underlying `Database` for a logical target.
  Database _getDatabase(TargetDb db) {
    switch (db) {
      case TargetDb.attempt:
        return _dbService.attemptDb;
      case TargetDb.predictions:
        return _dbService.predictionsDb;
      case TargetDb.crops:
        return _dbService.cropsDb;
    }
  }

  /// Execute a raw **read-only** query against the selected database.
  ///
  /// This should only be used with validated, SELECT-only SQL.
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, {
    List<Object?> arguments = const [],
    TargetDb target = TargetDb.attempt,
  }) async {
    final db = _getDatabase(target);
    return db.rawQuery(sql, arguments);
  }

  /// Convenience helper that picks a database heuristically based on the query text.
  ///
  /// - Mentions of "predict", "forecast", "2025" → `predictions`
  /// - Crop CSV-style analytics (table `crop_data` or `crop_predictions`) → `crops`
  /// - Otherwise → `attempt`
  Future<List<Map<String, Object?>>> smartQuery(
    String sql, {
    List<Object?> arguments = const [],
  }) async {
    final lower = sql.toLowerCase();

    TargetDb target;
    if (lower.contains('crop_data') || lower.contains('crop_predictions')) {
      target = TargetDb.crops;
    } else if (lower.contains('predict') ||
        lower.contains('forecast') ||
        lower.contains('2025')) {
      target = TargetDb.predictions;
    } else {
      target = TargetDb.attempt;
    }

    return rawQuery(sql, arguments: arguments, target: target);
  }
}


