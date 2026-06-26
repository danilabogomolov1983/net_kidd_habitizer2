import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../logging/logging_module.dart';
import 'database_helper.dart';

/// Riverpod provider for the singleton [DatabaseHelper].
///
/// Feature data sources depend on this provider and through it obtain a
/// reference to the SQLite database. The helper is created once and lives
/// for the application lifetime.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  final logger = ref.read(appLoggerProvider);
  return DatabaseHelper(logger: logger);
});

/// Provider that resolves the database asynchronously.
///
/// Use this provider in repository implementations that need to await the
/// database opening.
final databaseProvider = FutureProvider((ref) async {
  final helper = ref.read(databaseHelperProvider);
  return helper.database;
});
