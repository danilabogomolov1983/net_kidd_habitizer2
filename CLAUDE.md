# Habitizer 2.0

Flutter habit-tracking app built as a **modular monolith** that fuses **Clean
Architecture** (layered dependency rule) with **Vertical Slice Architecture**
(feature-first packaging).

## Architecture in one paragraph

Every feature lives in its own slice under `lib/features/<slice>/` with the
four Clean Architecture layers inside it:

```
presentation → application → domain ← infrastructure
```

- **domain** — pure Dart: entities, repository interfaces, slice failures. No Flutter, no packages (except `equatable`), no IO.
- **application** — pure Dart: services/use cases orchestrating domain logic, DTOs + mappers. Depends only on domain.
- **infrastructure** — implements repository interfaces (SQLite data sources) and wires Riverpod providers in `infrastructure/di/`. May depend on `core` and `lib/shared`.
- **presentation** — Flutter widgets, pages and Riverpod state notifiers. May depend on anything below it.

Errors are propagated with the `Result<T>` monad (`lib/core/domain/result.dart`)
instead of exceptions; failures are sealed class hierarchies per slice.

Cross-slice reuse goes through `lib/shared/` (branding widgets, extensions) and
`lib/core/` (Result/Failure types, DB helper, logging). Slices import sibling
slices only through their public barrel file (`features/<slice>/<slice>.dart`).

## Repository map

| Path | Purpose |
|---|---|
| `lib/` | App source — see `lib/CLAUDE.md` |
| `test/` | Unit/widget tests mirroring `lib/` — see `test/CLAUDE.md` |
| `integration_test/` | On-device integration tests (empty state + create workflow) |
| `doc/` | Architecture docs (arc42 + per-folder mirror) — see `doc/CLAUDE.md` |
| `operations/` | Deployment: `deploy.sh`, Dockerfile, nginx.conf |
| `assets/` | App icon, images |
| `.pi/skills/release/` | Release workflow skill (version bump, tag, artifacts) |

## Conventions

- **Layer rule**: a file may only import from layers at or below it in its own
  slice, from `lib/core/`, from `lib/shared/`, or from a sibling slice's barrel.
- **No framework in domain/application**: `flutter_riverpod` imports belong in
  `infrastructure/di/` and `presentation/`.
- **Providers**: concrete wiring happens only in `infrastructure/di/`; the
  service/repository classes stay framework-free.
- **Barrels**: each slice exports its public API from `<slice>.dart`; the
  slice's `infrastructure/` internals are not exported.
- **Errors**: return `Result<T>`, never throw for control flow.
- **New slice template**: `features/<name>/{domain,application,infrastructure,presentation}`,
  a `<name>.dart` barrel, mirrored tests under `test/features/<name>/`.
- **Imports**: relative imports inside `lib/`; package imports only in tests.

## Commands

```bash
flutter pub get          # fetch dependencies
flutter analyze          # static analysis (must stay clean)
flutter test             # unit + widget tests
flutter test integration_test -d <device>   # on-device integration tests
flutter run -d <device>  # run the app
./.pi/skills/release/scripts/release.sh     # release workflow (see .pi/skills/release/SKILL.md)
```

## Documentation

- `doc/arc42/` — full arc42 architecture documentation (12 sections).
- `doc/architecture/` — per-folder notes mirroring `lib/`.
- Every folder of interest carries its own `CLAUDE.md`; read the one in the
  folder you are about to modify.
