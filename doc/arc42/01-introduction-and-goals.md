# 1. Introduction and Goals

## 1.1 Project Overview

**Habitizer 2.0** is a modular monolith Flutter application for habit and task tracking.
It demonstrates a fusion of **Clean Architecture** and **Vertical Slice Architecture**
with functional programming principles, SQLite persistence, and comprehensive automated testing.

## 1.2 Business Goals

| Goal | Description |
|------|-------------|
| G1 | Allow users to create, update, and delete tasks with priorities and due dates |
| G2 | Allow users to categorise tasks with colour-coded tags |
| G3 | Support many-to-many relationships between tasks and tags |
| G4 | Provide a responsive, offline-first mobile and web experience |
| G5 | Serve as a reference architecture for Flutter projects |

## 1.3 Quality Goals

| ID | Quality Attribute | Target |
|----|-------------------|--------|
| Q1 | Testability | ≥ 80 % unit test coverage on domain & application layers |
| Q2 | Maintainability | Feature slices are independently modifiable |
| Q3 | Portability | Single codebase → Android, iOS, Web, Linux, macOS, Windows |
| Q4 | Offline capability | All data stored locally via SQLite; no network required |

## 1.4 Stakeholders

| Role | Interest |
|------|----------|
| Developer | Understand and extend the architecture |
| Architect | Evaluate the modular monolith / clean architecture pattern |
| QA | Automated test suite covering domain, application, and integration |
| DevOps | Container-based deployment via Docker |
