# lib/core/infrastructure/database/

SQLite access shared by all slices.

| File | Contents |
|---|---|
| `database_helper.dart` | Single `Database` holder: opens `habitizer.db`, owns schema creation/migrations, exposes `rawInsert/rawQuery/rawUpdate/rawDelete` + `transaction`. The **only** place that calls `openDatabase`. |
| `database_module.dart` | Riverpod providers: `databaseHelperProvider` (singleton helper) and `databaseProvider` (resolved `Database`). |
| `database_factory_initializer.dart` | `initializeDatabaseFactory()` — called from `main.dart` before `runApp`; switches factory per platform via conditional import. |
| `database_factory_stub.dart` | Native setup: `sqflite_common_ffi` on Linux/Windows, platform default elsewhere. |
| `database_factory_web.dart` | Web setup: IndexedDB-backed `sqflite_ffi_web` factory. |

**Conventions**
- Feature data sources receive `DatabaseHelper` via constructor injection from
  the slice's `infrastructure/di/` providers.
- Schema changes: bump `_databaseVersion` and extend `_onUpgrade` (keep
  migrations idempotent with `IF NOT EXISTS`/`DROP TABLE IF EXISTS`).
- New platform factory: add a conditional-import branch, don't sprinkle
  platform checks through feature code.
