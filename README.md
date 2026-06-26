# Habitizer 2.0

> **Modular Monolith** — Flutter application demonstrating **Clean Architecture**
> fused with **Vertical Slice Architecture**, functional programming principles,
> SQLite persistence, and comprehensive automated testing.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Features](#features)
3. [Project Structure](#project-structure)
4. [Quick Start](#quick-start)
5. [Running Tests](#running-tests)
6. [Deployment](#deployment)
7. [Documentation](#documentation)
8. [Technology Stack](#technology-stack)
9. [License](#license)

---

## Architecture Overview

Habitizer 2.0 combines two complementary architectural patterns:

### 🧅 Clean Architecture (dependency rule)

```
Presentation  ──►  Application  ──►  Domain  ◄──  Infrastructure
(Flutter UI)       (use cases)       (entities)    (SQLite, Riverpod)
```

- **Domain** — pure Dart, zero dependencies. Entities, repository interfaces, failures.
- **Application** — use cases / services orchestrating domain logic.
- **Infrastructure** — implements repository interfaces (SQLite data sources).
- **Presentation** — Flutter widgets, Riverpod state notifiers.

### 🍰 Vertical Slice Architecture

Each feature is a self-contained module:

```
features/task/
  domain/          ← entities, repository interface, failures
  application/     ← service, DTOs, pure mapping functions
  infrastructure/  ← data source, repository impl, Riverpod providers
  presentation/    ← pages, widgets, state notifier
```

**Why both?** Clean Architecture keeps the core testable and framework-independent.
Vertical slices keep features decoupled — you can modify the `tag` slice without
touching the `task` slice.

### 🧪 Functional Programming

| Principle | Implementation |
|-----------|---------------|
| Immutable data | `final class` entities with `copyWith` |
| Pure functions | Top-level DTO mappers, domain validation |
| Either monad | `Result<T>` sealed class (Success | Failure) |
| Pattern matching | `switch` on sealed `Failure` hierarchy |
| No exceptions in public API | All methods return `Result<T>` |

---

## Features

| Feature | Description | Domain model |
|---------|-------------|-------------|
| **Tasks** | Create, update, complete, and delete tasks with priorities and due dates | `Task` (id, title, description, status, priority, dueDate) |
| **Tags** | Create and manage colour-coded labels for tasks | `Tag` (id, name, color) |
| **Task ↔ Tag** | Many-to-many relationship: assign multiple tags to a task | `task_tags` junction table |

### Screens

- 📋 **Task List** — browse tasks, filter by status, complete/delete
- 🏷️ **Tag List** — manage tag catalogue
- ➕ **Task Form** — bottom sheet with title, description, priority, due date
- 🎨 **Tag Form** — bottom sheet with name and colour picker (19 colours)

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # Root widget, navigation, ProviderScope
├── core/                              # Shared kernel
│   ├── domain/
│   │   ├── result.dart                # Result<T> monad
│   │   ├── failure.dart               # Sealed Failure hierarchy
│   │   └── base_types.dart            # IEntity, IValueObject
│   ├── application/
│   │   └── use_case.dart              # IUseCase base class
│   └── infrastructure/
│       └── database/
│           ├── database_helper.dart    # SQLite connection & schema
│           └── database_module.dart    # Riverpod DB providers
├── features/
│   ├── task/                          # Task vertical slice
│   │   ├── domain/
│   │   │   ├── entities/task.dart
│   │   │   ├── repositories/task_repository.dart
│   │   │   └── failures.dart
│   │   ├── application/
│   │   │   ├── services/task_service.dart
│   │   │   └── dtos/task_dto.dart
│   │   ├── infrastructure/
│   │   │   ├── data_sources/task_local_data_source.dart
│   │   │   └── repositories/task_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/task_list_page.dart
│   │       ├── widgets/task_card.dart
│   │       ├── widgets/task_form.dart
│   │       └── state/task_notifier.dart
│   ├── tag/                           # Tag vertical slice
│   │   └── … (mirrors task structure)
│   └── task_tag/                      # Cross-feature bridge
│       └── application/services/task_tag_service.dart
└── shared/
    ├── database/tables.dart
    └── extensions/functional_extensions.dart

test/                                   # Unit & integration tests
├── core/domain/result_test.dart
├── features/
│   ├── task/
│   │   ├── domain/entities/task_test.dart
│   │   ├── application/services/task_service_test.dart
│   ├── tag/
│   │   ├── domain/entities/tag_test.dart
│   │   ├── application/services/tag_service_test.dart
│   └── task_tag/infrastructure/task_tag_integration_test.dart
└── shared/database/database_test.dart

integration_test/                       # End-to-end Flutter tests
├── app_test.dart

doc/arc42/                              # Architecture documentation (arc42)
├── 01-introduction-and-goals.md
├── …
└── 12-glossary.md

operations/                             # Deployment artefacts
├── Dockerfile
├── nginx.conf
└── deploy.sh
```

---

## Quick Start

### Prerequisites

- [Flutter SDK](https://flutter.dev) ≥ 3.12
- Android Studio / Xcode (for mobile) or Chrome (for web)
- Docker (optional, for containerised web deployment)

### Run the application

```bash
# Install dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Run on web (Chrome)
flutter run -d chrome

# Run on Linux desktop
flutter run -d linux
```

### Code generation (optional)

```bash
# Riverpod needs code generation only if you modify providers
dart run build_runner build --delete-conflicting-outputs
```

---

## Running Tests

### Unit tests

```bash
# All unit tests (fast, no UI)
flutter test

# Specific test file
flutter test test/features/task/application/services/task_service_test.dart
```

### Integration tests (persistence layer)

```bash
# Integration tests use real SQLite via sqflite_common_ffi
flutter test test/features/task_tag/infrastructure/

# Requires the sqflite_common_ffi dev dependency
```

### End-to-end tests

```bash
# E2E tests launch the full Flutter app
flutter test integration_test/
```

### Test coverage

```bash
flutter test --coverage
# Then open coverage/lcov.info with your favourite tool
```

---

## Deployment

### Web (Docker)

```bash
cd operations
./deploy.sh web

# Run the container
docker run -p 8080:80 habitizer:latest
# Open http://localhost:8080
```

### Android

```bash
cd operations
./deploy.sh android
# APK at build/app/outputs/flutter-apk/app-release.apk
```

### iOS

```bash
cd operations
./deploy.sh ios
# macOS only; opens Xcode for signing
```

### Manual build

```bash
flutter build web --release     # → build/web/
flutter build apk --release     # → build/app/outputs/flutter-apk/
flutter build ios --release     # → build/ios/
flutter build linux --release   # → build/linux/
```

---

## Documentation

Comprehensive architecture documentation in **arc42** format is available in the
[`doc/arc42/`](doc/arc42/) directory:

| Chapter | Topic |
|---------|-------|
| [01](doc/arc42/01-introduction-and-goals.md) | Introduction and Goals |
| [02](doc/arc42/02-architecture-constraints.md) | Architecture Constraints |
| [03](doc/arc42/03-system-scope-and-context.md) | System Scope and Context |
| [04](doc/arc42/04-solution-strategy.md) | Solution Strategy |
| [05](doc/arc42/05-building-block-view.md) | Building Block View |
| [06](doc/arc42/06-runtime-view.md) | Runtime View |
| [07](doc/arc42/07-deployment-view.md) | Deployment View |
| [08](doc/arc42/08-crosscutting-concepts.md) | Crosscutting Concepts |
| [09](doc/arc42/09-architecture-decisions.md) | Architecture Decisions (ADR) |
| [10](doc/arc42/10-quality-requirements.md) | Quality Requirements |
| [11](doc/arc42/11-risks-and-technical-debt.md) | Risks and Technical Debt |
| [12](doc/arc42/12-glossary.md) | Glossary |

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter ≥ 3.12 |
| **Language** | Dart ≥ 3.12 |
| **State management** | Riverpod 2.x |
| **Persistence** | SQLite via sqflite |
| **Database path** | path_provider |
| **Value equality** | Equatable |
| **Unique IDs** | uuid |
| **Testing (unit)** | flutter_test |
| **Testing (integration)** | sqflite_common_ffi + integration_test |
| **Deployment** | Docker + Nginx |
| **Documentation** | arc42 |

---

## Architecture Decisions

Key decisions are recorded as [Architecture Decision Records](doc/arc42/09-architecture-decisions.md):

| ADR | Decision |
|-----|----------|
| ADR-001 | Modular Monolith over Microservices |
| ADR-002 | Clean Architecture + Vertical Slices |
| ADR-003 | Riverpod over BLoC / Provider |
| ADR-004 | Custom `Result<T>` over dartz |
| ADR-005 | SQLite with DatabaseHelper abstraction |
| ADR-006 | No persistence layer unit tests |

---

## License

MIT
