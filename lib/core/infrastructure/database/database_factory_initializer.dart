import 'database_factory_stub.dart'
    if (dart.library.js_interop) 'database_factory_web.dart';

/// Initialize the appropriate [databaseFactory] for the current platform.
///
/// Called from `main()` before `runApp()`. On web it switches to the
/// IndexedDB-backed factory; on native platforms it uses the default.
void initializeDatabaseFactory() {
  setupDatabaseFactory();
}
