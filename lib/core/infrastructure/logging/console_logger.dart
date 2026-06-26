import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'app_logger.dart';
import 'log_level.dart';

/// Console-backed implementation of [IAppLogger].
///
/// Emits colour-coded, timestamped messages to the debug console via
/// `dart:developer.log`. In debug mode messages go to the Dart DevTools
/// logging page; in release mode they are suppressed unless the minimum
/// level is [LogLevel.warning] or above.
final class ConsoleLogger implements IAppLogger {
  @override
  final LogLevel minimumLevel;

  /// Optional prefix prepended to every message (e.g. `[Habitizer]`).
  final String? prefix;

  /// Whether to include ANSI colour codes in the output.
  final bool useColors;

  const ConsoleLogger({
    this.minimumLevel = LogLevel.debug,
    this.prefix,
    this.useColors = true,
  });

  @override
  void debug(String message, {Map<String, Object?>? metadata}) {
    if (LogLevel.debug < minimumLevel) return;
    _emit(LogLevel.debug, message, metadata: metadata);
  }

  @override
  void info(String message, {Map<String, Object?>? metadata}) {
    if (LogLevel.info < minimumLevel) return;
    _emit(LogLevel.info, message, metadata: metadata);
  }

  @override
  void warning(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
  }) {
    if (LogLevel.warning < minimumLevel) return;
    _emit(LogLevel.warning, message, metadata: metadata, stackTrace: stackTrace);
  }

  @override
  void error(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? errorObject,
  }) {
    if (LogLevel.error < minimumLevel) return;
    _emit(LogLevel.error, message, metadata: metadata, stackTrace: stackTrace, error: errorObject);
  }

  @override
  void fatal(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? errorObject,
  }) {
    _emit(LogLevel.fatal, message, metadata: metadata, stackTrace: stackTrace, error: errorObject);
  }

  void _emit(
    LogLevel level,
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? error,
  }) {
    final buffer = StringBuffer();

    // Timestamp
    final now = DateTime.now();
    buffer.write(
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}:'
      '${now.second.toString().padLeft(2, '0')}'
      '.${now.millisecond.toString().padLeft(3, '0')} ',
    );

    // Level label with optional colour
    if (useColors) {
      buffer.write(_colorFor(level));
    }
    buffer.write(level.label.padRight(5));
    if (useColors) {
      buffer.write('\x1B[0m');
    }
    buffer.write(' ');

    if (prefix != null) {
      buffer.write(prefix);
      buffer.write(' ');
    }

    buffer.write(message);

    if (metadata != null && metadata.isNotEmpty) {
      buffer.write(' │ ');
      buffer.write(metadata.entries.map((e) => '${e.key}=${e.value}').join(' '));
    }

    if (stackTrace != null) {
      buffer.write('\n');
      buffer.write(stackTrace.toString());
    }

    if (error != null) {
      buffer.write('\n');
      buffer.write('Caused by: $error');
    }

    // Use dart:developer.log for structured output in debug mode;
    // fall back to print in release so messages still appear in logcat / syslog.
    if (kDebugMode) {
      dev.log(buffer.toString(), name: prefix ?? 'Habitizer');
    } else {
      // ignore: avoid_print — the whole point is to emit logs
      print(buffer.toString());
    }
  }

  String _colorFor(LogLevel level) => switch (level) {
        LogLevel.debug => '\x1B[90m', // grey
        LogLevel.info => '\x1B[36m', // cyan
        LogLevel.warning => '\x1B[33m', // yellow
        LogLevel.error => '\x1B[31m', // red
        LogLevel.fatal => '\x1B[35m', // magenta
      };
}
