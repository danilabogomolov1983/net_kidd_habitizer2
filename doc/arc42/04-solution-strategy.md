# 4. Solution Strategy

## 4.1 Architecture Style

Habitizer 2.0 combines two architectural patterns:

### Clean Architecture (dependency rule)

```
Presentation  ──►  Application  ──►  Domain  ◄──  Infrastructure
(Flutter UI)       (use cases)       (entities)    (SQLite, Riverpod)
```

- **Domain** has zero dependencies — pure Dart, no Flutter
- **Application** depends only on Domain
- **Infrastructure** implements Domain interfaces (dependency inversion)
- **Presentation** depends on Application (via Riverpod providers)

### Vertical Slice Architecture

Each feature (`task`, `tag`, `task_tag`) is a self-contained vertical slice:

```
features/task/
  domain/          ← entities, repository interface, failures
  application/     ← service, DTOs, pure mapping functions
  infrastructure/  ← data source, repository impl, providers
  presentation/    ← pages, widgets, state notifier
```

Slices are independent: changing the `tag` slice does not break the `task` slice.

## 4.2 Functional Programming Principles

| Principle | How it's applied |
|-----------|-----------------|
| **Immutable data** | All entities are `final class` with `const` constructors and `copyWith` |
| **Pure functions** | DTO mapping functions are top-level, side-effect-free |
| **Either monad** | `Result<T>` sealed class propagates errors without exceptions |
| **Pattern matching** | `switch` expressions on sealed `Failure` hierarchy |
| **No `null` leakage** | `Result.orNull` is explicit; domain code avoids `null` |

## 4.3 Persistence Strategy

- **SQLite** as the single embedded database
- **DatabaseHelper** singleton manages schema, migrations, transactions
- Each feature has its own **LocalDataSource** that encapsulates all SQL
- Repository implementations map DTOs ↔ entities via pure functions

## 4.4 State Management

- **Riverpod** for dependency injection and reactive state
- `Notifier` / `AsyncNotifier` for async request state (loading / error / data)
- Global providers in `core/infrastructure/database/database_module.dart`
- Feature-scoped providers in each feature's `infrastructure/repositories/`
