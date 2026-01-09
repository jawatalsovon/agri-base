// Web stub: do not initialize native ffi on web.
// On web, sqflite uses IndexedDB via the default factory which is automatically set up.
// Keep this as a no-op to avoid importing native-only packages into web builds.
class DatabaseFactoryInitializer {
  static void initialize() {
    // intentionally empty for web - IndexedDB factory is default
  }
}
