# lib/core/application/

Cross-slice application-layer contracts.

| File | Contents |
|---|---|
| `use_case.dart` | `IUseCase<Input, Output>` / `INoInputUseCase<Output>` base classes with a single `call` entry point returning `Result`. |

**Note**: current slice services (`HabitParameterService`) are async and do not
implement `IUseCase` (its `call` is synchronous). Keep this folder for the
base contracts; concrete per-slice use cases/services live in
`features/<slice>/application/`. If a use case needs async, extend the contract
here first rather than drifting per slice.
