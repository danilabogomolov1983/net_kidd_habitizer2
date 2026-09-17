# 6. Runtime View

## 6.1 Create Habit Scenario

```
User          HabitParameterListPage   HabitParameterDetailPage   HabitParameterNotifier   HabitParameterService   RepositoryImpl   LocalDataSource   SQLite
 │                    │                        │                          │                         │                   │                 │
 │  tap "New habit"   │                        │                          │                         │                   │                 │
 │───────────────────►│                        │                          │                         │                   │                 │
 │                    │ push(detail page)       │                          │                         │                   │                 │
 │                    │───────────────────────►│                          │                         │                   │                 │
 │  type description  │                        │                          │                         │                   │                 │
 │───────────────────►│                        │                          │                         │                   │                 │
 │                    │                        │ _save() (auto-save)      │                         │                   │                 │
 │                    │                        │─────────────────────────►│                         │                   │                 │
 │                    │                        │                          │ create(id, type, …)     │                   │                 │
 │                    │                        │                          │────────────────────────►│                   │                 │
 │                    │                        │                          │                         │ validate fields    │                 │
 │                    │                        │                          │                         │────┐               │                 │
 │                    │                        │                          │                         │◄───┘ (pure Result)│                 │
 │                    │                        │                          │                         │                   │                 │
 │                    │                        │                          │                         │ save(param)       │                 │
 │                    │                        │                          │                         │──────────────────►│                 │
 │                    │                        │                          │                         │                   │ getById(id)     │                 │
 │                    │                        │                          │                         │                   │────────────────►│                 │
 │                    │                        │                          │                         │                   │◄────────────────│                 │
 │                    │                        │                          │                         │                   │ insert(dto)     │                 │
 │                    │                        │                          │                         │                   │────────────────►│                 │
 │                    │                        │                          │                         │                   │◄────────────────│                 │
 │                    │                        │                          │                         │◄──────────────────│                 │
 │                    │                        │                          │◄────────────────────────│                   │                 │
 │                    │                        │                          │ load()                  │                   │                 │
 │                    │                        │                          │────────────────────────►│                   │                 │
 │                    │                        │                          │                         │ getAll()          │                 │
 │                    │                        │                          │                         │──────────────────►│ getAll()        │                 │
 │                    │                        │                          │                         │                   │────────────────►│                 │
 │                    │                        │                          │                         │                   │◄────────────────│                 │
 │                    │                        │                          │◄────────────────────────│                   │                 │
 │                    │                        │                          │ state = data(list)     │                   │                 │
 │                    │                        │◄─────────────────────────│                         │                   │                 │
 │  pop back          │                        │                          │                         │                   │                 │
 │───────────────────►│                        │                          │                         │                   │                 │
 │  see new card      │                        │                          │                         │                   │                 │
 │◄───────────────────│                        │                          │                         │                   │                 │
```

## 6.2 Important Runtime Properties

- **All public API calls return `Result<T>`** — exceptions are caught at the
  repository implementation layer and converted to failures.
- **State updates are unidirectional**: UI → Notifier → Service → Repository → DataSource → SQLite → DataSource → Repository → Service → Notifier → UI
- **The detail page auto-saves**: text/chip/date changes trigger `_save()`
  immediately (debounced by the `_isSaving` guard); there is no submit button.
- **Transactions**: The `DatabaseHelper.transaction()` method wraps multi-statement
  operations when they arise.
