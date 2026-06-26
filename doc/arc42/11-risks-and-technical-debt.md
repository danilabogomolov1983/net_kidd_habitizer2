# 11. Risks and Technical Debt

## 11.1 Known Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| SQLite schema changes require manual migration scripts | Medium | Medium | Add versioned `_onUpgrade` handlers in `DatabaseHelper` |
| Feature slices grow too large (violating SRP) | Low | Medium | Extract sub-features or split by use case |
| Riverpod provider graph becomes tangled | Low | High | Keep providers scoped to features; use `ProviderScope` overrides in tests |
| No network layer means no cloud sync | Certain (design choice) | Medium | Offline-first is intentional; future: add optional sync layer |

## 11.2 Technical Debt

| Item | Severity | Plan |
|------|----------|------|
| No i18n — all strings hardcoded | Low | Extract to ARB files when second language is needed |
| ~~No structured logging~~ | ~~Low~~ | ✅ Resolved — custom `IAppLogger` + `ConsoleLogger` + `NoOpLogger` implemented |
| No analytics / crash reporting | Low | Integrate Firebase Crashlytics or Sentry |
| `TaskForm` and `TagForm` share similar structure but are not abstracted | Low | Create a reusable `FormSheet` widget when a third form appears |
| Integration tests use real SQLite — CI needs `sqflite_common_ffi` | Medium | Document CI setup in `operations/ci.yml` |
