# 12. Glossary

| Term | Definition |
|------|------------|
| **Clean Architecture** | A layered architecture where dependencies point inward: Presentation → Application → Domain ← Infrastructure |
| **Vertical Slice** | A feature organised as a self-contained module spanning all layers (domain, application, infrastructure, presentation) |
| **Modular Monolith** | A single-deployment application with strong internal module boundaries |
| **Result\<T\>** | A sealed monadic type representing either a success value of type T or a Failure |
| **IEntity** | A domain object contract with a unique identity (e.g., Task, Tag) |
| **IValueObject** | A domain object contract defined by its attributes, not identity |
| **DTO** (Data Transfer Object) | A plain data container used to cross layer boundaries (e.g., to/from SQLite) |
| **Repository** | A domain-level interface for persistence; implemented in the infrastructure layer |
| **Data Source** | An infrastructure class that directly executes SQL queries |
| **Riverpod** | A compile-safe, functional-reactive state management library for Dart/Flutter |
| **Provider** | A Riverpod construct that exposes a value (object, service, state) to the widget tree |
| **Notifier** | A Riverpod class that holds mutable state and exposes methods to mutate it |
| **Barrel File** | A Dart file that only contains `export` statements, re-exporting all public symbols of a module |
| **sqflite** | A Flutter plugin providing SQLite database access on mobile and desktop |
| **arc42** | A standardised template for documenting software architectures |
| **ADR** | Architecture Decision Record — documents a significant architectural choice |
