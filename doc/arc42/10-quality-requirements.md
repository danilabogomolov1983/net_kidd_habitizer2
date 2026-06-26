# 10. Quality Requirements

## 10.1 Quality Tree

```
Habitizer 2.0 Quality
├── Maintainability
│   ├── Feature isolation (vertical slices)
│   ├── Dependency inversion (ports & adapters)
│   └── Consistent naming conventions
├── Testability
│   ├── Pure domain logic (no Flutter dependency)
│   ├── Fake repositories for service tests
│   └── Real SQLite for integration tests
├── Reliability
│   ├── Result<T> error propagation
│   ├── No unhandled exceptions in public APIs
│   └── Transactions for multi-step writes
├── Portability
│   ├── Single Dart/Flutter codebase
│   └── Platform-agnostic SQLite via sqflite
└── Performance
    ├── Indexed queries on primary/foreign keys
    ├── Lightweight UI rebuilds (Riverpod select)
    └── Lazy database initialisation
```

## 10.2 Quality Scenarios

| ID | Scenario | Target |
|----|----------|--------|
| QS1 | Developer adds a new feature (e.g., "Projects") in under 30 minutes following the existing slice template | < 30 min |
| QS2 | All unit tests pass in under 5 seconds (excluding integration) | < 5 s |
| QS3 | App launches and displays task list within 2 seconds on a mid-range device | < 2 s |
| QS4 | UI remains responsive while loading 1000+ tasks | 60 fps |
| QS5 | Database migration from v1 to v2 does not lose data | 0 data loss |
