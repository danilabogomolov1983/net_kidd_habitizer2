import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_logger.dart';
import 'console_logger.dart';
import 'file_logger.dart';
import 'composite_logger.dart';
import 'log_level.dart';

/// Riverpod provider for the application-wide [IAppLogger].
///
/// The default implementation is a [CompositeLogger] that fans out to:
/// - [ConsoleLogger] — colour-coded terminal output
/// - [FileLogger] — persistent logs under `logs/` directory
///
/// Override this provider in tests to inject a [NoOpLogger] or a mock.
final appLoggerProvider = Provider<IAppLogger>((ref) {
  final console = ConsoleLogger(prefix: '[Habitizer]');
  final file = FileLogger(
    directoryPath: 'logs',
    minimumLevel: LogLevel.info,
    maxFileSize: 5 * 1024 * 1024, // 5 MB rotation
  );
  return CompositeLogger.pair(console, file);
});
