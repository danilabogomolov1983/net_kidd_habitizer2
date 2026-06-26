# 9. Architecture Decisions

## ADR-001: Modular Monolith over Microservices

**Status**: Accepted  
**Date**: 2026-06-26

**Context**: The application scope is small (two entities, local storage). A distributed
architecture would add network latency, deployment complexity, and operational
overhead without providing benefits.

**Decision**: Build a **modular monolith** — a single deployable with internal
feature boundaries enforced by convention and folder structure.

**Consequences**:
- (+) Simple deployment: one binary per platform
- (+) No network serialisation overhead
- (+) Easier debugging and tracing
- (-) All features share the same process; a bug in one could crash the whole app

---

## ADR-002: Clean Architecture + Vertical Slices

**Status**: Accepted  
**Date**: 2026-06-26

**Context**: We need a structure that scales with feature count while keeping the
domain logic testable in isolation.

**Decision**: Combine Clean Architecture's **layered dependency rule** with
Vertical Slice Architecture's **feature-first packaging**.

**Consequences**:
- (+) Each feature is independently readable and modifiable
- (+) Domain logic is pure Dart, testable without Flutter or SQLite
- (+) New features follow the same template — no decision fatigue
- (-) More files than a flat structure; mitigated by barrel files

---

## ADR-003: Riverpod over BLoC / Provider

**Status**: Accepted  
**Date**: 2026-06-26

**Context**: Need compile-safe, testable, functional-reactive state management.

**Decision**: Use **Riverpod 2.x** with code generation.

**Consequences**:
- (+) No `BuildContext` needed for reading providers — easier testing
- (+) `Notifier` / `AsyncNotifier` pattern aligns with clean architecture
- (+) Auto-dispose prevents memory leaks
- (-) Learning curve for newcomers

---

## ADR-004: Custom Result<T> over dartz

**Status**: Accepted  
**Date**: 2026-06-26

**Context**: Need a monadic error type. `dartz` is powerful but adds 50+ transitive
dependencies and a steep learning curve.

**Decision**: Implement a minimal `Result<T>` sealed class with `fold`, `map`,
`flatMap`, `getOrElse`, `forEach`.

**Consequences**:
- (+) Zero external dependencies for the core monad
- (+) Full control over the API surface
- (+) Dart 3 sealed classes provide exhaustiveness checking
- (-) Less feature-rich than dartz (no Task, Either, IList, etc.)

---

## ADR-005: SQLite with DatabaseHelper abstraction

**Status**: Accepted  
**Date**: 2026-06-26

**Context**: Need local persistence. Options: SQLite, Hive, ObjectBox, Drift.

**Decision**: Use raw **sqflite** with a thin `DatabaseHelper` wrapper.

**Consequences**:
- (+) Full SQL power — complex joins for many-to-many
- (+) Mature, battle-tested library
- (+) Fine-grained control over queries
- (-) Manual SQL writing; no compile-time query verification
- (-) Manual DTO ↔ entity mapping

---

## ADR-006: No persistence layer unit tests

**Status**: Accepted  
**Date**: 2026-06-26

**Context**: Persistence tests (repository implementations, data sources) are
covered by integration tests using real SQLite (via `sqflite_common_ffi`).
Unit-testing them with mocks adds maintenance burden without proportional value.

**Decision**: Skip unit tests for the infrastructure/persistence layer. Cover
persistence behaviour through integration tests.

**Consequences**:
- (+) Less test code to maintain
- (+) Integration tests catch real SQLite behaviour
- (-) Integration tests are slower than pure unit tests
