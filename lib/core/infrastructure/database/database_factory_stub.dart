import 'dart:io' show Platform;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Initialize the appropriate [databaseFactory] for native platforms.
///
/// On Linux and Windows we use [sqflite_common_ffi] with the bundled SQLite
/// provided by the [sqlite3] package (v3+). On Android, iOS and macOS the
/// default factory provided by the platform plugin is used.
void setupDatabaseFactory() {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}
