import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseFactoryInitializer {
  static void initialize() {
    // Initialize ffi for desktop platforms and set global databaseFactory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
