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
features/habit/
  domain/          ← entities, repository interface, failures
  application/     ← service, DTOs, pure mapping functions
  infrastructure/  ← data source, repository impl, di/ (Riverpod providers)
  presentation/    ← pages, widgets, state notifiers
```

**Why both?** Clean Architecture keeps the core testable and framework-independent.
Vertical slices keep features decoupled — you can modify the `statistics` slice
without touching the `habit` slice.

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

| Slice | Description | Domain model |
|---------|-------------|-------------|
| **habit** | Create, browse, edit and delete habit parameters (type, target value, unit, start/end dates) | `HabitParameter` (id, type, description, startDate, endDate, value, unit, createdAt) |
| **shell** | App shell: navigation bar, menu, FAB — composes screens from the other slices | — (composition root) |
| **statistics** | Read-only totals, active/done counts and breakdown by category | — (projection over habit state) |
| **profile** | Read-only profile/about view with habit counts | — (projection over habit state) |

### Screens

- 🏠 **Home** — search and browse habits, swipe to delete, refresh to reload
- 📈 **Statistics** — total / active / done summary cards and per-category bars
- 👤 **Profile** — habit counts, joined date, about card
- ➕ **Habit form** — create/edit page with auto-save, type chips and date pickers

---

## Project Structure

```
lib/
├── main.dart                          # App entry point (DB factory init + runApp)
├── app.dart                           # HabitizerApp: MaterialApp, theme, ProviderScope
├── core/                              # Shared kernel
│   ├── domain/
│   │   ├── result.dart                # Result<T> monad
│   │   ├── failure.dart               # Sealed Failure hierarchy
│   │   └── base_types.dart            # IEntity, IValueObject
│   ├── application/
│   │   └── use_case.dart              # IUseCase base class
│   └── infrastructure/
│       ├── database/
│       │   ├── database_helper.dart    # SQLite connection & schema
│       │   ├── database_module.dart    # Riverpod DB providers
│       │   └── database_factory_*.dart # platform DB factory selection
│       └── logging/                    # IAppLogger + console/file/composite impls
├── shared/                            # Cross-slice, non-architectural code
│   ├── extensions/functional_extensions.dart
│   └── widgets/app_logo.dart          # brand logo (used by empty states)
├── features/                          # Vertical slices
│   ├── habit/                         # Habit CRUD slice (core state owner)
│   │   ├── habit.dart                 # public barrel
│   │   ├── domain/                    # HabitParameter, IHabitParameterRepository, failures
│   │   ├── application/               # HabitParameterService, HabitParameterDto + mappers
│   │   ├── infrastructure/            # local data source, repository impl, di/ providers
│   │   └── presentation/              # list/detail pages, notifier, search provider, card
│   ├── shell/                         # MainShell: navigation composition root
│   │   └── presentation/pages/main_shell.dart
│   ├── statistics/                    # Read-only stats over habit state
│   │   └── presentation/pages/statistics_page.dart
│   └── profile/                       # Read-only profile/about over habit state
│       └── presentation/pages/profile_page.dart
└── …

test/                                   # Unit tests mirroring lib/
├── core/domain/result_test.dart
├── core/infrastructure/logging/
└── features/habit/
    ├── domain/entities/habit_parameter_test.dart
    └── application/services/habit_parameter_service_test.dart

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
flutter test test/features/habit/application/services/habit_parameter_service_test.dart
```

### End-to-end tests

```bash
# E2E tests launch the full Flutter app on a device/emulator
flutter test integration_test/ -d <device-id>
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
