import 'app_logger.dart';
import 'log_level.dart';

/// A logger that delegates every call to a list of child [IAppLogger]
/// instances — typically a [ConsoleLogger] and a [FileLogger].
///
/// This follows the **composite pattern**: clients see a single logger,
/// but messages are fanned out to every underlying logger simultaneously.
///
/// The composite's [minimumLevel] is the *lowest* among its children,
/// ensuring no child misses a message it would otherwise accept.
final class CompositeLogger implements IAppLogger {
  final List<IAppLogger> _loggers;

  CompositeLogger(this._loggers);

  /// Convenience constructor for exactly two loggers.
  CompositeLogger.pair(IAppLogger first, IAppLogger second)
      : _loggers = [first, second];

  @override
  LogLevel get minimumLevel {
    if (_loggers.isEmpty) return LogLevel.fatal;
    return _loggers
        .map((l) => l.minimumLevel)
        .reduce((a, b) => a.severity < b.severity ? a : b);
  }

  @override
  void debug(String message, {Map<String, Object?>? metadata}) {
    for (final l in _loggers) {
      l.debug(message, metadata: metadata);
    }
  }

  @override
  void info(String message, {Map<String, Object?>? metadata}) {
    for (final l in _loggers) {
      l.info(message, metadata: metadata);
    }
  }

  @override
  void warning(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace}) {
    for (final l in _loggers) {
      l.warning(message, metadata: metadata, stackTrace: stackTrace);
    }
  }

  @override
  void error(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace, Object? errorObject}) {
    for (final l in _loggers) {
      l.error(message, metadata: metadata, stackTrace: stackTrace, errorObject: errorObject);
    }
  }

  @override
  void fatal(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace, Object? errorObject}) {
    for (final l in _loggers) {
      l.fatal(message, metadata: metadata, stackTrace: stackTrace, errorObject: errorObject);
    }
  }
}
