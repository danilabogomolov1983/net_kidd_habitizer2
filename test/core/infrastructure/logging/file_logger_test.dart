import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/logging/file_logger.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/logging/log_level.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/logging/composite_logger.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/logging/console_logger.dart';

void main() {
  // Use a temp directory so we don't pollute the project root
  late String tmpDir;

  setUp(() {
    tmpDir = '${Directory.systemTemp.path}/habitizer_log_test_${DateTime.now().millisecondsSinceEpoch}';
  });

  tearDown(() {
    final dir = Directory(tmpDir);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('FileLogger', () {
    test('creates log directory and writes entries', () {
      final logger = FileLogger(directoryPath: tmpDir, minimumLevel: LogLevel.debug);

      logger.info('Application started');
      logger.debug('Loading config', metadata: {'env': 'test'});
      logger.warning('Disk space low', metadata: {'freeMb': 42});
      logger.error('Connection failed', metadata: {'host': 'db.local'}, errorObject: Exception('timeout'));

      // Check directory exists
      expect(Directory(tmpDir).existsSync(), true);

      // Check log file exists (named with today's date)
      final files = Directory(tmpDir).listSync().whereType<File>().toList();
      expect(files.length, 1);

      final content = files.first.readAsStringSync();
      expect(content, contains('INFO  Application started'));
      expect(content, contains('DEBUG Loading config'));
      expect(content, contains('env=test'));
      expect(content, contains('WARN  Disk space low'));
      expect(content, contains('freeMb=42'));
      expect(content, contains('ERROR Connection failed'));
      expect(content, contains('host=db.local'));
      expect(content, contains('Caused by: Exception: timeout'));
    });

    test('respects minimumLevel', () {
      final logger = FileLogger(directoryPath: tmpDir, minimumLevel: LogLevel.warning);

      logger.debug('should not appear');
      logger.info('should not appear');
      logger.warning('should appear');

      final files = Directory(tmpDir).listSync().whereType<File>().toList();
      final content = files.first.readAsStringSync();
      expect(content, isNot(contains('DEBUG')));
      expect(content, isNot(contains('INFO')));
      expect(content, contains('WARN  should appear'));
    });
  });

  group('CompositeLogger', () {
    test('fans out to all children', () {
      final logger = CompositeLogger.pair(
        FileLogger(directoryPath: tmpDir, minimumLevel: LogLevel.info),
        ConsoleLogger(minimumLevel: LogLevel.warning),
      );

      // minimumLevel is the lowest among children
      expect(logger.minimumLevel, LogLevel.info);

      // Writes to file (info threshold)
      logger.info('fan-out test');

      final files = Directory(tmpDir).listSync().whereType<File>().toList();
      expect(files.length, 1);
      expect(files.first.readAsStringSync(), contains('fan-out test'));
    });
  });
}
