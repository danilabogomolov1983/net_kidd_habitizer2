# 5. Building Block View

## 5.1 Level 1 — System

```
Habitizer 2.0
├── Core Layer (shared kernel)
├── Feature: Task
├── Feature: Tag
└── Feature: Task-Tag Bridge
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
    └── database/
        ├── database_helper.dart    ← SQLite connection & schema
        └── database_module.dart    ← Riverpod providers for DB
```

## 5.3 Level 2 — Feature: Task

```
features/task/
├── domain/
│   ├── entities/task.dart              ← Task (id, title, status, priority, …)
│   ├── repositories/task_repository.dart  ← abstract interface
│   └── failures.dart                   ← TaskFailure sealed hierarchy
├── application/
│   ├── services/task_service.dart      ← business logic orchestration
│   └── dtos/task_dto.dart              ← TaskDto + pure mapping functions
├── infrastructure/
│   ├── data_sources/task_local_data_source.dart  ← SQL queries
│   └── repositories/task_repository_impl.dart    ← concrete impl + providers
└── presentation/
    ├── pages/task_list_page.dart
    ├── widgets/task_card.dart
    ├── widgets/task_form.dart
    └── state/task_notifier.dart
```

## 5.4 Level 2 — Feature: Tag

```
features/tag/
├── domain/
│   ├── entities/tag.dart
│   ├── repositories/tag_repository.dart
│   └── failures.dart
├── application/
│   ├── services/tag_service.dart
│   └── dtos/tag_dto.dart
├── infrastructure/
│   ├── data_sources/tag_local_data_source.dart
│   └── repositories/tag_repository_impl.dart
└── presentation/
    ├── pages/tag_list_page.dart
    ├── widgets/tag_chip.dart
    ├── widgets/tag_form.dart
    └── state/tag_notifier.dart
```

## 5.5 Level 2 — Feature: Task-Tag Bridge

```
features/task_tag/
└── application/
    └── services/task_tag_service.dart  ← orchestrates both feature data sources
```

## 5.6 Database Schema (SQLite)

```sql
CREATE TABLE tasks (
  id          TEXT PRIMARY KEY,
  title       TEXT NOT NULL,
  description TEXT,
  status      TEXT NOT NULL DEFAULT 'todo',
  priority    TEXT NOT NULL DEFAULT 'medium',
  due_date    TEXT,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL
);

CREATE TABLE tags (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL UNIQUE,
  color      TEXT NOT NULL DEFAULT '#2196F3',
  created_at TEXT NOT NULL
);

CREATE TABLE task_tags (
  task_id TEXT NOT NULL,
  tag_id  TEXT NOT NULL,
  PRIMARY KEY (task_id, tag_id),
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id)  REFERENCES tags(id)  ON DELETE CASCADE
);
```
