// Conditional import will pick the appropriate initializer for the platform
import 'database_factory_init_io.dart'
    if (dart.library.html) 'database_factory_init_web.dart'
    as impl;

class DatabaseFactoryInitializer {
  static void initialize() => impl.DatabaseFactoryInitializer.initialize();
}
