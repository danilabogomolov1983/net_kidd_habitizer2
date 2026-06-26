import 'dart:io';
import 'package:path/path.dart' as p;
import 'app_logger.dart';
import 'log_level.dart';

/// File-backed implementation of [IAppLogger].
///
/// Writes structured, timestamped log entries to a file under [directoryPath].
/// The `logs/` directory and today's log file are created lazily on the first
/// write call. A new file is started each calendar day; old files accumulate
/// in the directory.
///
/// **Flutter integration**: obtain the directory path via `path_provider`:
/// ```dart
/// final docsDir = await getApplicationDocumentsDirectory();
/// final logger = FileLogger(directoryPath: '${docsDir.path}/logs');
/// ```
final class FileLogger implements IAppLogger {
  @override
  final LogLevel minimumLevel;

  /// Absolute or relative path to the log directory.
  final String directoryPath;

  /// Maximum size of a single log file in bytes before rotation.
  /// When exceeded the current file is renamed with a `.1` suffix and a new
  /// file is started. Set to `null` to disable size-based rotation.
  final int? maxFileSize;

  FileLogger({
    required this.directoryPath,
    this.minimumLevel = LogLevel.debug,
    this.maxFileSize,
  });

  // ── public API ────────────────────────────────────────────────

  @override
  void debug(String message, {Map<String, Object?>? metadata}) {
    if (LogLevel.debug < minimumLevel) return;
    _write(LogLevel.debug, message, metadata: metadata);
  }

  @override
  void info(String message, {Map<String, Object?>? metadata}) {
    if (LogLevel.info < minimumLevel) return;
    _write(LogLevel.info, message, metadata: metadata);
  }

  @override
  void warning(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
  }) {
    if (LogLevel.warning < minimumLevel) return;
    _write(LogLevel.warning, message, metadata: metadata, stackTrace: stackTrace);
  }

  @override
  void error(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? errorObject,
  }) {
    if (LogLevel.error < minimumLevel) return;
    _write(LogLevel.error, message,
        metadata: metadata, stackTrace: stackTrace, error: errorObject);
  }

  @override
  void fatal(
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? errorObject,
  }) {
    _write(LogLevel.fatal, message,
        metadata: metadata, stackTrace: stackTrace, error: errorObject);
  }

  // ── internal ──────────────────────────────────────────────────

  String _todayFilePath() {
    final dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    final today = DateTime.now();
    final name = 'app_'
        '${today.year}-${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}.log';
    return p.join(directoryPath, name);
  }

  void _maybeRotate(String path) {
    if (maxFileSize == null) return;
    final file = File(path);
    if (!file.existsSync()) return;
    if (file.lengthSync() >= maxFileSize!) {
      final rotated = '$path.1';
      final rotatedFile = File(rotated);
      if (rotatedFile.existsSync()) {
        rotatedFile.deleteSync();
      }
      file.renameSync(rotated);
    }
  }

  void _write(
    LogLevel level,
    String message, {
    Map<String, Object?>? metadata,
    StackTrace? stackTrace,
    Object? error,
  }) {
    try {
      final path = _todayFilePath();
      _maybeRotate(path);

      final buffer = StringBuffer();
      buffer.write(DateTime.now().toIso8601String());
      buffer.write(' ');
      buffer.write(level.label.padRight(5));
      buffer.write(' ');
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

      buffer.write('\n');
      File(path).writeAsStringSync(buffer.toString(), mode: FileMode.append);
    } catch (_) {
      // Silently drop — we must not crash because of logging.
    }
  }
}
