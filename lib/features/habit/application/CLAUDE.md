# lib/features/habit/application/

Application layer of the habit slice: use-case orchestration and data mapping.

| File | Contents |
|---|---|
| `services/habit_parameter_service.dart` | `HabitParameterService` — validates inputs (description/type/unit: required + max length), then delegates to `IHabitParameterRepository`. Pure Dart, no Riverpod. |
| `dtos/habit_parameter_dto.dart` | `HabitParameterDto` (persistence shape, snake_case dates as ISO strings) + pure mapper functions `paramFromDto` / `paramToDto`. |

**Conventions**
- Depends only on the slice's `domain/` and `core/domain/result.dart`.
- Never import `infrastructure/` from here — wiring lives in
  `infrastructure/di/habit_parameter_providers.dart`.
- Validation failures are returned as `HabitValidationFailure` via
  `Result.failure`, never thrown.
