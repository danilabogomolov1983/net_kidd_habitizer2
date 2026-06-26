import 'app_logger.dart';
import 'log_level.dart';

/// A logger that discards all messages — useful for tests and environments
/// where logging is undesirable.
final class NoOpLogger implements IAppLogger {
  const NoOpLogger();

  @override
  LogLevel get minimumLevel => LogLevel.fatal;

  @override
  void debug(String message, {Map<String, Object?>? metadata}) {}

  @override
  void info(String message, {Map<String, Object?>? metadata}) {}

  @override
  void warning(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace}) {}

  @override
  void error(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace, Object? errorObject}) {}

  @override
  void fatal(String message, {Map<String, Object?>? metadata, StackTrace? stackTrace, Object? errorObject}) {}
}
