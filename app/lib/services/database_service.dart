import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'database_factory_init.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static DatabaseService? _instance;
  Database? _attemptDb;
  Database? _predictionsDb;
  Database? _cropsDb;
  Database? _historicalDb;
  bool _initialized = false;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Initialize database factory for desktop platforms only
  static Future<void> initializeDatabaseFactory() async {
    try {
      // Only initialize FFI on non-web, non-mobile platforms
      if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
        DatabaseFactoryInitializer.initialize();
      }
    } catch (e) {
      debugPrint('Error initializing database factory: $e');
    }
  }

  /// Initialize databases by copying from assets to device storage
  Future<void> initialize() async {
    if (_initialized &&
        _attemptDb != null &&
        _predictionsDb != null &&
        _cropsDb != null) {
      return; // Already initialized
    }

    // Skip file operations on web platform and use in-memory database
    if (kIsWeb) {
      // For web, do not attempt to open databases since FFI is not available
      // Web users will get "not initialized" errors but app won't crash
      debugPrint(
        'Web platform: database initialization skipped. Using fallback.',
      );
      _initialized = true;
      return;
    }

    // Get database path based on platform
    String databasesPath;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Use application documents directory for desktop
      final appDir = await getApplicationDocumentsDirectory();
      databasesPath = appDir.path;
    } else {
      // Use standard path provider for mobile
      databasesPath = await getDatabasesPath();
    }

    final attemptDbPath = join(databasesPath, 'attempt.db');
    final predictionsDbPath = join(databasesPath, 'predictions.db');
    final cropsDbPath = join(databasesPath, 'crops.db');

    // Copy databases from assets if they don't exist
    if (!await File(attemptDbPath).exists()) {
      try {
        final data = await rootBundle.load('assets/databases/attempt.db');
        final bytes = data.buffer.asUint8List();
        await File(attemptDbPath).writeAsBytes(bytes);
      } catch (e) {
        // ignore: empty_catches
      }
    }

    if (!await File(predictionsDbPath).exists()) {
      try {
        final data = await rootBundle.load('assets/databases/predictions.db');
        final bytes = data.buffer.asUint8List();
        await File(predictionsDbPath).writeAsBytes(bytes);
      } catch (e) {
        // ignore: empty_catches
      }
    }

    if (!await File(cropsDbPath).exists()) {
      try {
        final data = await rootBundle.load('assets/databases/crops.db');
        final bytes = data.buffer.asUint8List();
        await File(cropsDbPath).writeAsBytes(bytes);
      } catch (e) {
        // ignore: empty_catches
      }
    }

    // Open databases
    if (await File(attemptDbPath).exists()) {
      _attemptDb = await openDatabase(attemptDbPath, readOnly: true);
    } else {}

    if (await File(predictionsDbPath).exists()) {
      _predictionsDb = await openDatabase(predictionsDbPath, readOnly: true);
    } else {}

    if (await File(cropsDbPath).exists()) {
      _cropsDb = await openDatabase(cropsDbPath, readOnly: true);
    } else {}

    _initialized = true;
  }

  /// Get connection to attempt.db (historical data 2017-2024)
  Database get attemptDb {
    if (_attemptDb == null) {
      if (kIsWeb) {
        throw Exception('Databases not available on web platform.');
      }
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _attemptDb!;
  }

  /// Get connection to predictions.db (prediction data for 2025)
  Database get predictionsDb {
    if (_predictionsDb == null) {
      if (kIsWeb) {
        throw Exception('Databases not available on web platform.');
      }
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _predictionsDb!;
  }

  /// Get connection to crops.db (crop data from CSVs)
  Database get cropsDb {
    if (_cropsDb == null) {
      if (kIsWeb) {
        throw Exception('Databases not available on web platform.');
      }
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _cropsDb!;
  }

  /// Get connection to agri-base.db (historical data)
  Database? get historicalDb => _historicalDb;

  /// Query crops database
  Future<List<Map<String, dynamic>>> queryCrops(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await cropsDb.rawQuery(sql, arguments);
  }

  /// Query attempt database
  Future<List<Map<String, dynamic>>> queryAttempt(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await attemptDb.rawQuery(sql, arguments);
  }

  /// Query predictions database
  Future<List<Map<String, dynamic>>> queryPredictions(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await predictionsDb.rawQuery(sql, arguments);
  }

  /// Get all table names from a database
  Future<List<String>> getTableNames(Database db) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Get all table names from attempt.db
  Future<List<String>> getAllTableNames() async {
    try {
      return await getTableNames(attemptDb);
    } catch (e) {
      return [];
    }
  }

  /// Close all database connections
  Future<void> close() async {
    await _attemptDb?.close();
    await _predictionsDb?.close();
    await _cropsDb?.close();
    _attemptDb = null;
    _predictionsDb = null;
    _cropsDb = null;
  }
}
