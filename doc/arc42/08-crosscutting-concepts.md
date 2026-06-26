# 8. Crosscutting Concepts

## 8.1 Error Handling

All errors are represented as **values** (never thrown):

```
Result<T> = Success<T> | FailureResult<T>
Failure   = ServerFailure | CacheFailure | ValidationFailure | NotFoundFailure
           | TaskFailure | TagFailure | …
```

- Domain layer defines abstract `Failure` subclasses
- Each feature extends its own sealed failure hierarchy
- Repository implementations **catch all exceptions** and return `FailureResult`
- UI renders errors via `AsyncValue.when(error: …)`

## 8.2 Dependency Injection

Riverpod providers serve as the DI container:

| Provider | Scope | Purpose |
|----------|-------|---------|
| `appLoggerProvider` | singleton | Structured application logging |
| `databaseHelperProvider` | singleton | SQLite connection |
| `taskRepositoryProvider` | singleton | Task persistence |
| `tagRepositoryProvider` | singleton | Tag persistence |
| `taskServiceProvider` | singleton | Task business logic |
| `tagServiceProvider` | singleton | Tag business logic |
| `taskTagServiceProvider` | singleton | Cross-feature bridge |
| `taskNotifierProvider` | per-feature | Reactive task list state |
| `tagNotifierProvider` | per-feature | Reactive tag list state |

## 8.3 Testing Strategy

| Layer | Test type | Tool | Mock/Real |
|-------|-----------|------|-----------|
| Domain entities | Unit | `flutter_test` | Real objects |
| Domain value objects | Unit | `flutter_test` | Real objects |
| Application services | Unit | `flutter_test` | Fake repositories |
| Core Result type | Unit | `flutter_test` | Real objects |
| Infrastructure (persistence) | **Not unit-tested** | — | — |
| Integration (task↔tag) | Integration | `flutter_test` + sqflite_ffi | Real SQLite |
| End-to-end (UI) | Integration | `integration_test` | Real SQLite + Flutter |

## 8.4 Logging & Monitoring

### Architecture

- **`IAppLogger` interface** (`core/infrastructure/logging/`) — abstract contract with `debug`, `info`, `warning`, `error`, `fatal` methods
- **`ConsoleLogger`** — colour-coded, timestamped output via `dart:developer.log` (debug mode) or `print` (release)
- **`NoOpLogger`** — silent logger for tests and environments where logging is undesirable
- **Riverpod provider** `appLoggerProvider` — single injection point; overridable in tests

### Log Levels

| Level | Usage |
|-------|-------|
| `debug` | SQL queries, cache hits, internal state transitions |
| `info` | Business operations (task created, tag deleted, etc.) |
| `warning` | Validation failures, not-found lookups, duplicate attempts |
| `error` | Caught exceptions in repositories / data sources |
| `fatal` | Unrecoverable errors (not yet used; reserved for DB corruption, etc.) |

### Integration Points

| Layer | Class | What is logged |
|-------|-------|----------------|
| Infrastructure | `DatabaseHelper` | DB open, schema creation, migrations, close |
| Infrastructure | `TaskLocalDataSource` | Insert, delete, link/unlink tag operations |
| Infrastructure | `TagLocalDataSource` | Insert, delete, link/unlink task operations |
| Infrastructure | `TaskRepositoryImpl` (`implements ITaskRepository`) | All CRUD results + caught exceptions (with stack traces) |
| Infrastructure | `TagRepositoryImpl` (`implements ITagRepository`) | All CRUD results + caught exceptions (with stack traces) |
| Application | `TaskService` | Business operations + validation failures |
| Application | `TagService` | Business operations + validation failures + duplicates |
| Application | `TaskTagService` | Assign / remove tag operations + exceptions |

### Design Principles

- **Logger is an effect** — injected via constructor (optional, defaults to `NoOpLogger`)
- **Domain layer is pure** — no logging in entities, value objects, or repository interfaces
- **Structured metadata** — every log call accepts an optional `Map<String, Object?> metadata` for key-value context
- **Configurable** — `ConsoleLogger` accepts `minimumLevel` and `prefix`; release builds can raise the threshold

## 8.5 Internationalisation (i18n)

- Not yet implemented — all strings are hardcoded in English
- Future: use Flutter's `flutter_localizations` + ARB files
