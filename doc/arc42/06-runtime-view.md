# 6. Runtime View

## 6.1 Create Task Scenario

```
User                TaskListPage         TaskNotifier         TaskService         TaskRepositoryImpl    TaskLocalDataSource    SQLite
 │                      │                     │                    │                      │                    │                    │
 │  tap "+" FAB         │                     │                    │                      │                    │                    │
 │─────────────────────►│                     │                    │                      │                    │                    │
 │                      │ showModalBottomSheet│                    │                      │                    │                    │
 │                      │ (TaskForm)          │                    │                      │                    │                    │
 │  fill title, submit  │                     │                    │                      │                    │                    │
 │─────────────────────►│                     │                    │                      │                    │                    │
 │                      │ createTask(id,title)│                    │                      │                    │                    │
 │                      │────────────────────►│                    │                      │                    │                    │
 │                      │                     │ createTask(...)    │                      │                    │                    │
 │                      │                     │───────────────────►│                      │                    │                    │
 │                      │                     │                    │ validateTitle(title) │                    │                    │
 │                      │                     │                    │────┐                 │                    │                    │
 │                      │                     │                    │◄───┘ (pure)           │                    │                    │
 │                      │                     │                    │                      │                    │                    │
 │                      │                     │                    │ save(task)           │                    │                    │
 │                      │                     │                    │─────────────────────►│                    │                    │
 │                      │                     │                    │                      │ getById(id)        │                    │
 │                      │                     │                    │                      │───────────────────►│                    │
 │                      │                     │                    │                      │◄───────────────────│                    │
 │                      │                     │                    │                      │ insert(dto)        │                    │
 │                      │                     │                    │                      │───────────────────►│                    │
 │                      │                     │                    │                      │◄───────────────────│                    │
 │                      │                     │                    │◄─────────────────────│                    │                    │
 │                      │                     │◄───────────────────│                      │                    │                    │
 │                      │                     │ loadTasks()        │                      │                    │                    │
 │                      │                     │───────────────────►│                      │                    │                    │
 │                      │                     │                    │ getAll()             │                    │                    │
 │                      │                     │                    │─────────────────────►│ getAll()           │                    │
 │                      │                     │                    │                      │───────────────────►│                    │
 │                      │                     │                    │                      │◄───────────────────│                    │
 │                      │                     │                    │◄─────────────────────│                    │                    │
 │                      │                     │◄───────────────────│                      │                    │                    │
 │                      │ state = data(tasks) │                    │                      │                    │                    │
 │                      │◄────────────────────│                    │                      │                    │                    │
 │                      │ rebuild UI          │                    │                      │                    │                    │
 │                      │────────────────────►│                    │                      │                    │                    │
 │  see new task        │                     │                    │                      │                    │                    │
 │◄─────────────────────│                     │                    │                      │                    │                    │
```

## 6.2 Important Runtime Properties

- **All public API calls return `Result<T>`** — exceptions are caught at the
  repository implementation layer and converted to failures.
- **State updates are unidirectional**: UI → Notifier → Service → Repository → DataSource → SQLite → DataSource → Repository → Service → Notifier → UI
- **Transactions**: The `DatabaseHelper.transaction()` method wraps multi-statement
  operations (e.g., creating a task + linking tags atomically).
