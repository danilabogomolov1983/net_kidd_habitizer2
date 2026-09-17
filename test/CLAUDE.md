# test/

Unit and widget tests. The folder mirrors `lib/`:

```
test/
├── core/         # kernel tests (result monad, logging)
└── features/     # slice tests, mirroring lib/features/<slice>/
```

| File | Covers |
|---|---|
| `core/domain/result_test.dart` | `Result<T>` monad behaviour |
| `core/infrastructure/logging/*` | logger implementations (file, composite/console) |
| `features/habit/domain/entities/habit_parameter_test.dart` | entity equality/copyWith |
| `features/habit/application/services/habit_parameter_service_test.dart` | validation + CRUD orchestration against a `FakeRepo` |

**Conventions**
- Domain/application tests are pure Dart: no Flutter, no SQLite — fakes in
  the test file implement the repository interface.
- Mirror the slice structure 1:1 so finding a test for a file is mechanical.
- Run: `flutter test` (must stay green). On-device flows live in
  `integration_test/`, not here.
