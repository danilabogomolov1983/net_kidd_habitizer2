import 'package:flutter_test/flutter_test.dart';
import 'package:net_kidd_habitizer2/core/domain/result.dart';
import 'package:net_kidd_habitizer2/core/domain/failure.dart';

void main() {
  group('Result<T>', () {
    group('success', () {
      test('fold calls onSuccess', () {
        final result = Result<int>.success(42);
        final value = result.fold(
          (_) => -1,
          (v) => v,
        );
        expect(value, 42);
      });

      test('map transforms value', () {
        final result = Result<int>.success(42);
        final mapped = result.map((v) => 'Value: $v');
        expect(mapped.orNull, 'Value: 42');
      });

      test('flatMap chains successes', () {
        final result = Result<int>.success(10);
        final chained = result.flatMap(
          (v) => Result<double>.success(v / 2.0),
        );
        expect(chained.orNull, 5.0);
      });

      test('getOrElse returns the value', () {
        final result = Result<String>.success('hello');
        expect(result.getOrElse('default'), 'hello');
      });

      test('forEach executes side-effect', () {
        final result = Result<String>.success('hello');
        String? captured;
        result.forEach((v) => captured = v);
        expect(captured, 'hello');
      });

      test('isSuccess is true', () {
        expect(Result<int>.success(1).isSuccess, true);
      });

      test('isFailure is false', () {
        expect(Result<int>.success(1).isFailure, false);
      });

      test('orNull returns value', () {
        expect(Result<int>.success(7).orNull, 7);
      });

      test('failureOrNull is null', () {
        expect(Result<int>.success(1).failureOrNull, null);
      });

      test('equality by value', () {
        expect(Result<int>.success(1), Result<int>.success(1));
        expect(Result<int>.success(1), isNot(Result<int>.success(2)));
      });

      test('flatMap with failure short-circuits', () {
        final result = Result<int>.success(10);
        final chained = result.flatMap<int>((_) {
          return Result<int>.failure(const ValidationFailure(field: 'x', message: 'bad'));
        });
        expect(chained.isFailure, true);
        expect(chained.failureOrNull, isA<ValidationFailure>());
      });
    });

    group('failure', () {
      final failure = ValidationFailure(field: 'email', message: 'Invalid');

      test('fold calls onFailure', () {
        final result = Result<int>.failure(failure);
        final value = result.fold(
          (f) => f.runtimeType.toString(),
          (v) => 'unexpected',
        );
        expect(value, 'ValidationFailure');
      });

      test('map preserves failure', () {
        final result = Result<int>.failure(failure);
        final mapped = result.map((v) => v.toString());
        expect(mapped.isFailure, true);
        expect(mapped.failureOrNull, failure);
      });

      test('flatMap short-circuits', () {
        final result = Result<int>.failure(failure);
        final chained = result.flatMap((v) => Result<int>.success(v + 1));
        expect(chained.isFailure, true);
        expect(chained.failureOrNull, failure);
      });

      test('getOrElse returns default', () {
        final result = Result<int>.failure(failure);
        expect(result.getOrElse(99), 99);
      });

      test('forEach does nothing', () {
        final result = Result<int>.failure(failure);
        bool called = false;
        result.forEach((_) => called = true);
        expect(called, false);
      });

      test('isSuccess is false', () {
        expect(Result<int>.failure(failure).isSuccess, false);
      });

      test('isFailure is true', () {
        expect(Result<int>.failure(failure).isFailure, true);
      });

      test('orNull is null', () {
        expect(Result<int>.failure(failure).orNull, null);
      });

      test('failureOrNull returns the failure', () {
        expect(Result<int>.failure(failure).failureOrNull, failure);
      });
    });

    group('Failure hierarchy', () {
      test('NotFoundFailure contains type and id', () {
        final f = NotFoundFailure(entityType: 'Task', id: '123');
        expect(f.entityType, 'Task');
        expect(f.id, '123');
        expect(f.toString(), contains('Task#123'));
      });

      test('ValidationFailure contains field and message', () {
        final f = ValidationFailure(field: 'title', message: 'Required');
        expect(f.field, 'title');
        expect(f.message, 'Required');
      });
    });
  });
}
