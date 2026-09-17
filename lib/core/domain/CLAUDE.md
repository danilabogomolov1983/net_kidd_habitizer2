# lib/core/domain/

Pure-Dart foundation types used by every slice. **No Flutter, no packages, no IO.**

| File | Contents |
|---|---|
| `result.dart` | `Result<T>` sealed monad: `Success<T>` / `FailureResult<T>`. `map`, `flatMap`, `fold`, `orNull`, `failureOrNull`. The app's error-propagation mechanism. |
| `failure.dart` | `abstract base class Failure` + generic cases: `ServerFailure`, `CacheFailure`, `ValidationFailure`, `NotFoundFailure`. Slices extend `Failure` with their own sealed hierarchies. |
| `base_types.dart` | `IEntity` (identity via `id`) and `IValueObject` (equality by value) marker interfaces. |

**Conventions**
- Never throw for control flow — return `Result.failure(...)`.
- New failure kinds: add generic ones here only if they apply to several slices;
  slice-specific failures belong in the slice's `domain/failures.dart`.
- Keep the folder free of third-party imports.
