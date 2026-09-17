# lib/features/habit/domain/

Pure Dart domain model of the habit slice. No Flutter, no Riverpod, no SQLite.

| File | Contents |
|---|---|
| `entities/habit_parameter.dart` | Immutable `HabitParameter` entity (`id`, `type`, `description`, `startDate`/`endDate`, `value`, `unit`, `createdAt`) with `create` factory and `copyWith`. Implements `IEntity` and `Equatable`. |
| `repositories/habit_parameter_repository.dart` | `IHabitParameterRepository` interface: `getAll`, `getById`, `save`, `delete` — all returning `Result`. |
| `failures.dart` | Sealed `HabitFailure` hierarchy: `HabitValidationFailure`, `HabitPersistenceFailure`, `HabitNotFoundFailure`, `HabitDuplicateFailure`. |

**Conventions**
- Business rules that are pure (validation of the model itself) may live here;
  orchestration/validation of inputs lives in `application/`.
- Keep `DateTime` handling explicit — entity stores parsed `DateTime?`, string
  mapping is the DTO layer's job.
