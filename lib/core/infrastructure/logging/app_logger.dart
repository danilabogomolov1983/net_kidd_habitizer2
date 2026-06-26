import 'log_level.dart';

/// Structured application logger abstraction.
///
/// Declared in the infrastructure layer so that services and repositories
/// can depend on it without pulling in a concrete implementation. Every
/// method accepts an optional [metadata] map for structured key-value data
/// and an optional [stackTrace] / [errorObject] for error reporting.
///
/// The logging call itself is an **effect** — it is kept at the boundaries
/// (infrastructure, application), never in the pure domain layer.
abstract interface class IAppLogger {
  /// Minimum level this logger will emit. Messages below this level are
  /// silently discarded.
  LogLevel get minimumLevel;

  /// Fine-grained diagnostic information.
  void debug(String message, {Map<String, Object?>? metadata});

  /// General operational entries.
  void info(String message, {Map<String, Object?>? metadata});

  /// Potentially harmful situations.
  void warning(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace});

  /// Error events that may still allow the application to continue.
  void error(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? errorObject,
  });

  /// Critical errors that cause premature termination.
  void fatal(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? errorObject,
  });
}
