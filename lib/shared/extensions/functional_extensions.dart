import '../../core/domain/result.dart';
import '../../core/domain/failure.dart';

/// Functional-programming extensions for [Result].
extension ResultExtensions<T> on Result<T> {
  /// Convert this [Result] to a nullable value, logging failures.
  T? toNullableWithLog(void Function(Failure) logger) {
    return fold((f) {
      logger(f);
      return null;
    }, (v) => v);
  }
}

/// Extensions on [Failure] for user-friendly messages.
extension FailureMessage on Failure {
  String get userFriendlyMessage {
    return switch (this) {
      ServerFailure s => s.message,
      CacheFailure c => c.message,
      ValidationFailure v => v.message,
      NotFoundFailure n => '${n.entityType} #${n.id} not found',
      _ => 'An unexpected error occurred',
    };
  }
}
