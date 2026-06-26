import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// On web, replace the default sqflite factory with the IndexedDB-backed one.
void setupDatabaseFactory() {
  databaseFactory = databaseFactoryFfiWeb;
}
