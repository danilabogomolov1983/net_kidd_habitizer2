# lib/features/habit/

The core slice: create, read, update, delete and browse **habit parameters**.
Owns the app's main state (`habitParameterNotifierProvider`).

```
habit/
├── habit.dart                  # public barrel (sibling slices import this)
├── domain/                     # entity, repository interface, slice failures
├── application/                # service (validation + orchestration), DTOs + mappers
├── infrastructure/             # SQLite data source, repository impl, DI providers
└── presentation/               # pages, state, widgets
```

**Data flow**: page → `HabitParameterNotifier` (presentation/state) →
`HabitParameterService` (application) → `IHabitParameterRepository` impl
(infrastructure) → `HabitParameterLocalDataSource` → `DatabaseHelper` (core).

**Public API (barrel)**: `HabitParameter` entity, `HabitFailure`s, repository
interface, service, DTOs + mappers, notifier + search providers, list/detail
pages, `HabitParameterCard`. The `infrastructure/` internals are not exported.

See the per-layer CLAUDE.md files in the subfolders.
