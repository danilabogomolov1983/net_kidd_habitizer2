# 5. Building Block View

## 5.1 Level 1 — System

```
Habitizer 2.0
├── Core Layer (shared kernel)
├── Shared Layer (brand widgets, extensions)
├── Slice: Habit        (habit CRUD — owns app state)
├── Slice: Shell        (navigation composition root)
├── Slice: Statistics   (read-only projection over habit state)
└── Slice: Profile      (read-only projection over habit state)
```

## 5.2 Level 2 — Core Layer

```
core/
├── domain/
│   ├── result.dart         ← Result<T> monad (Success | Failure)
│   ├── failure.dart        ← sealed Failure hierarchy
│   └── base_types.dart     ← IEntity, IValueObject abstract classes
├── application/
│   └── use_case.dart       ← IUseCase<Input, Output> base class
└── infrastructure/
    ├── database/
    │   ├── database_helper.dart           ← SQLite connection & schema
    │   ├── database_module.dart           ← Riverpod providers for DB
    │   ├── database_factory_initializer.dart ← platform factory selection
    │   ├── database_factory_stub.dart     ← native factory setup (FFI on desktop)
    │   └── database_factory_web.dart      ← web factory setup (IndexedDB)
    └── logging/
        ├── app_logger.dart        ← IAppLogger abstraction
        ├── console_logger.dart    ← dev-log output
        ├── file_logger.dart       ← rotating file output
        ├── composite_logger.dart  ← fan-out over multiple loggers
        ├── noop_logger.dart       ← silent default
        ├── log_level.dart         ← LogLevel enum
        └── logging_module.dart    ← appLoggerProvider
```

## 5.3 Level 2 — Slice: Habit

```
features/habit/
├── habit.dart                           ← public barrel (sibling slices import this)
├── domain/
│   ├── entities/habit_parameter.dart    ← HabitParameter (id, type, description,
│   │                                      start/end dates, value, unit, createdAt)
│   ├── repositories/habit_parameter_repository.dart  ← abstract interface
│   └── failures.dart                    ← sealed HabitFailure hierarchy
├── application/
│   ├── services/habit_parameter_service.dart  ← validation + CRUD orchestration
│   └── dtos/habit_parameter_dto.dart          ← DTO + pure mapping functions
├── infrastructure/
│   ├── data_sources/habit_parameter_local_data_source.dart  ← SQL queries
│   ├── repositories/habit_parameter_repository_impl.dart    ← concrete impl
│   └── di/habit_parameter_providers.dart   ← slice composition root (Riverpod)
└── presentation/
    ├── pages/habit_parameter_list_page.dart    ← home tab: search + list
    ├── pages/habit_parameter_detail_page.dart  ← create/edit form (auto-save)
    ├── widgets/habit_parameter_card.dart       ← list card + delete confirm
    └── state/
        ├── habit_parameter_notifier.dart       ← CRUD notifier (AsyncValue list)
        └── habit_search_provider.dart          ← search query StateProvider
```

## 5.4 Level 2 — Slice: Shell

```
features/shell/
└── presentation/
    └── pages/main_shell.dart   ← Scaffold, AppBar menu, NavigationBar, FAB;
                                   composes habit/statistics/profile pages
```

## 5.5 Level 2 — Slice: Statistics

```
features/statistics/
└── presentation/
    └── pages/statistics_page.dart  ← totals, active/done, per-category bars
```

## 5.6 Level 2 — Slice: Profile

```
features/profile/
└── presentation/
    └── pages/profile_page.dart  ← avatar, habit counts, joined date, about
```

## 5.7 Shared Layer

```
shared/
├── extensions/functional_extensions.dart  ← Result/failure helpers
└── widgets/app_logo.dart                  ← brand logo (CustomPaint)
```

## 5.8 Database Schema (SQLite)

```sql
CREATE TABLE habits (
  id          TEXT PRIMARY KEY,
  type        TEXT NOT NULL,
  description TEXT NOT NULL,
  start_date  TEXT,
  end_date    TEXT,
  value       REAL NOT NULL,
  unit        TEXT NOT NULL,
  created_at  TEXT NOT NULL
);
```
