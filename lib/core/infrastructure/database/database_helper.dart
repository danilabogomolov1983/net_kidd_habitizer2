import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../logging/app_logger.dart';
import '../logging/noop_logger.dart';

/// Central SQLite database helper.
///
/// Manages a single [Database] instance, schema migrations, and provides
/// typed access to tables. Every feature data source obtains its database
/// reference through this class — never by opening a connection directly.
///
/// This is the **only** place that calls [openDatabase]. All SQL execution
/// is encapsulated behind public methods, keeping raw SQL out of feature code
/// while still leveraging SQLite's power.
final class DatabaseHelper {
  static const _databaseName = 'habitizer.db';
  static const _databaseVersion = 1;

  final IAppLogger _logger;
  Database? _db;

  DatabaseHelper({IAppLogger? logger}) : _logger = logger ?? const NoOpLogger();

  /// Open (or return the cached) database.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _databaseName);
    _logger.info('Opening database', metadata: {'path': path, 'version': _databaseVersion});
    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.info('Creating database schema v$version');
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL DEFAULT 'todo',
        priority TEXT NOT NULL DEFAULT 'medium',
        due_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tags (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL DEFAULT '#2196F3',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE task_tags (
        task_id TEXT NOT NULL,
        tag_id TEXT NOT NULL,
        PRIMARY KEY (task_id, tag_id),
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
        FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.info('Upgrading database', metadata: {'from': oldVersion, 'to': newVersion});
  }

  /// Run [action] inside a transaction.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// Execute a raw insert/update/delete. Prefer typed methods on data sources.
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return db.rawInsert(sql, arguments);
  }

  /// Execute a raw query that returns rows.
  Future<List<Map<String, Object?>>> rawQuery(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  /// Execute a raw update/delete.
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return db.rawUpdate(sql, arguments);
  }

  /// Execute a raw delete.
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return db.rawDelete(sql, arguments);
  }

  /// Close the database (e.g. in tests).
  Future<void> close() async {
    final db = _db;
    if (db != null) {
      _logger.info('Closing database');
      await db.close();
      _db = null;
    }
  }
}
