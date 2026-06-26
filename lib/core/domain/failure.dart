/// Base class for all domain failures.
///
/// Every feature may extend [Failure] to model its own error cases.
/// Use `abstract base class` so subclasses can be declared in other
/// libraries while still preventing external `implements`.
abstract base class Failure {
  const Failure();
}

/// Failure caused by an unexpected technical problem.
final class ServerFailure extends Failure {
  final String message;
  final StackTrace? stackTrace;
  const ServerFailure(this.message, [this.stackTrace]);

  @override
  String toString() => 'ServerFailure: $message';
}

/// Failure caused by missing or invalid data.
final class CacheFailure extends Failure {
  final String message;
  const CacheFailure(this.message);

  @override
  String toString() => 'CacheFailure: $message';
}

/// Failure caused by invalid user input.
final class ValidationFailure extends Failure {
  final String field;
  final String message;
  const ValidationFailure({required this.field, required this.message});

  @override
  String toString() => 'ValidationFailure($field): $message';
}

/// Failure caused by a missing entity (not-found).
final class NotFoundFailure extends Failure {
  final String entityType;
  final String id;
  const NotFoundFailure({required this.entityType, required this.id});

  @override
  String toString() => 'NotFoundFailure: $entityType#$id not found';
}
