import '../../../../core/domain/failure.dart';

/// Failure sealed hierarchy for the Task feature.
sealed class TaskFailure extends Failure {
  const TaskFailure();
}

final class TaskValidationFailure extends TaskFailure {
  final String field;
  final String message;
  const TaskValidationFailure({required this.field, required this.message});

  @override
  String toString() => 'TaskValidationFailure($field): $message';
}

final class TaskPersistenceFailure extends TaskFailure {
  final String message;
  final StackTrace? stackTrace;
  const TaskPersistenceFailure(this.message, [this.stackTrace]);

  @override
  String toString() => 'TaskPersistenceFailure: $message';
}

final class TaskNotFoundFailure extends TaskFailure {
  final String id;
  const TaskNotFoundFailure(this.id);

  @override
  String toString() => 'TaskNotFoundFailure: task#$id';
}
