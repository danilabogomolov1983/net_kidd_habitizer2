import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/logging/log_level.dart';
import 'package:net_kidd_habitizer2/core/infrastructure/logging/noop_logger.dart';

void main() {
  group('LogLevel', () {
    test('severity ordering', () {
      expect(LogLevel.debug < LogLevel.info, true);
      expect(LogLevel.info >= LogLevel.debug, true);
      expect(LogLevel.warning < LogLevel.error, true);
      expect(LogLevel.fatal >= LogLevel.error, true);
      expect(LogLevel.fatal >= LogLevel.fatal, true);
      expect(LogLevel.debug >= LogLevel.debug, true);
    });

    test('severity values', () {
      expect(LogLevel.debug.severity, 0);
      expect(LogLevel.info.severity, 1);
      expect(LogLevel.warning.severity, 2);
      expect(LogLevel.error.severity, 3);
      expect(LogLevel.fatal.severity, 4);
    });

    test('labels', () {
      expect(LogLevel.debug.label, 'DEBUG');
      expect(LogLevel.info.label, 'INFO');
      expect(LogLevel.warning.label, 'WARN');
      expect(LogLevel.error.label, 'ERROR');
      expect(LogLevel.fatal.label, 'FATAL');
    });
  });

  group('NoOpLogger', () {
    test('minimumLevel is fatal', () {
      const logger = NoOpLogger();
      expect(logger.minimumLevel, LogLevel.fatal);
    });

    test('all methods execute without throwing', () {
      const logger = NoOpLogger();
      // None of these should throw
      logger.debug('test');
      logger.info('test');
      logger.warning('test');
      logger.error('test');
      logger.fatal('test');

      logger.debug('test', metadata: {'key': 'value'});
      logger.info('test', metadata: {'key': 'value'});
      logger.warning('test', metadata: {'key': 'value'}, stackTrace: StackTrace.current);
      logger.error('test', metadata: {'key': 'value'}, errorObject: Exception('oops'), stackTrace: StackTrace.current);
      logger.fatal('test', metadata: {'key': 'value'}, errorObject: 'critical', stackTrace: StackTrace.current);
    });
  });
}
