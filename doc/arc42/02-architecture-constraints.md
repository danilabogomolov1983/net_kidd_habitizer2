# 2. Architecture Constraints

## 2.1 Technical Constraints

| Constraint | Rationale |
|------------|-----------|
| **Flutter SDK** (≥ 3.12) | Target platform SDK; cross-platform UI |
| **Dart** (≥ 3.12) | Language with sealed classes, pattern matching, records |
| **SQLite** (via `sqflite`) | Embedded relational database; no server required |
| **Riverpod** (≥ 2.6) | Compile-safe, functional-reactive state management |
| **Equatable** | Value equality for domain entities |

## 2.2 Organisational Constraints

| Constraint | Impact |
|------------|--------|
| Single codebase (monorepo) | All features coexist in one Dart package |
| No code generation required at runtime | Build runner is dev-only |
| Offline-first | No cloud dependencies; all data is local |

## 2.3 Convention Constraints

- **File naming**: `snake_case` for files, `PascalCase` for classes
- **Folder structure**: feature-first (`features/<name>/<layer>`)
- **Barrel files**: each feature exports a single `lib/features/<name>/<name>.dart`
- **Imports**: relative imports within a feature; absolute for cross-feature
