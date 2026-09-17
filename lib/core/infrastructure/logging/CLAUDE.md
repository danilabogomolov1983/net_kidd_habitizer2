# lib/core/infrastructure/logging/

Structured logging subsystem.

| File | Contents |
|---|---|
| `log_level.dart` | `LogLevel` enum (debug … fatal) with `severity` and `label`. |
| `app_logger.dart` | `IAppLogger` interface: `debug/info/warning/error/fatal` with optional `metadata`, `stackTrace`, `errorObject`. |
| `console_logger.dart` | Timestamped, colour-coded console/dev-log output. |
| `file_logger.dart` | Rotating log file under the app documents directory. |
| `composite_logger.dart` | Fans out to several `IAppLogger`s; `minimumLevel` is the lowest of its children. |
| `noop_logger.dart` | Silent implementation (default when no logger is injected). |
| `logging_module.dart` | Riverpod provider `appLoggerProvider` — build the composite here. |

**Conventions**
- Depend on `IAppLogger`, never on a concrete logger.
- `DatabaseHelper` already logs lifecycle events; keep new log calls at
  infrastructure/application boundaries.
