# lib/features/habit/infrastructure/

Outer layer of the habit slice: persistence and dependency wiring.

| File | Contents |
|---|---|
| `data_sources/habit_parameter_local_data_source.dart` | Raw SQL against the `habits` table via `DatabaseHelper`; returns/accepts `HabitParameterDto`. |
| `repositories/habit_parameter_repository_impl.dart` | Implements `IHabitParameterRepository`: calls the data source, maps DTO ↔ entity, converts exceptions to `HabitPersistenceFailure`. Framework-free. |
| `di/habit_parameter_providers.dart` | **Composition root of the slice.** Riverpod providers `habitParameterRepositoryProvider` (data source + impl) and `habitParameterServiceProvider`. The only file in the slice that constructs concrete implementations. |

**Conventions**
- All `sqflite` SQL stays in the data source.
- The repository converts every thrown exception into a `Result.failure`
  (`HabitPersistenceFailure` / `HabitNotFoundFailure`).
- Presentation code reads providers from `di/`, never instantiates the
  repository or data source directly.
