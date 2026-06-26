# 3. System Scope and Context

## 3.1 Business Context

Habitizer 2.0 is a standalone mobile / web application. It has **no external system
dependencies** — all data is stored locally.

```
┌──────────────────────────────────────┐
│               User                    │
│         (mobile / browser)            │
└──────────────┬───────────────────────┘
               │ interacts via Flutter UI
┌──────────────▼───────────────────────┐
│           Habitizer 2.0               │
│                                       │
│  ┌─────────┐  ┌──────────┐           │
│  │  Tasks   │  │   Tags   │           │
│  │  slice   │  │  slice   │           │
│  └────┬─────┘  └────┬─────┘           │
│       └──────┬──────┘                 │
│              ▼                        │
│       ┌─────────────┐                 │
│       │   SQLite DB │                 │
│       └─────────────┘                 │
└──────────────────────────────────────┘
```

## 3.2 Technical Context

The application communicates with:
- **SQLite database** (via `sqflite`) — for task, tag, and relationship storage
- **Platform file system** (via `path_provider`) — to locate the database file

No HTTP clients, no cloud services, no external APIs.
