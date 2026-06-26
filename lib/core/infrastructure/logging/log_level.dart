/// Severity levels for log messages, ordered from least to most severe.
enum LogLevel {
  /// Detailed information for diagnosing problems during development.
  debug(0, 'DEBUG'),

  /// General operational entries that describe application progress.
  info(1, 'INFO'),

  /// Potentially harmful situations that do not stop the application.
  warning(2, 'WARN'),

  /// Error events that might still allow the application to continue.
  error(3, 'ERROR'),

  /// Critical errors that cause premature termination.
  fatal(4, 'FATAL');

  const LogLevel(this.severity, this.label);
  final int severity;
  final String label;

  /// Whether this level meets or exceeds [other].
  bool operator >=(LogLevel other) => severity >= other.severity;

  /// Whether this level is strictly less severe than [other].
  bool operator <(LogLevel other) => severity < other.severity;
}
