import '../../../core/domain/failure.dart';

sealed class HabitFailure extends Failure {
  const HabitFailure();
}

final class HabitValidationFailure extends HabitFailure {
  final String field;
  final String message;
  const HabitValidationFailure({required this.field, required this.message});

  @override
  String toString() => 'HabitValidationFailure($field): $message';
}

final class HabitPersistenceFailure extends HabitFailure {
  final String message;
  final StackTrace? stackTrace;
  const HabitPersistenceFailure(this.message, [this.stackTrace]);

  @override
  String toString() => 'HabitPersistenceFailure: $message';
}

final class HabitNotFoundFailure extends HabitFailure {
  final String id;
  const HabitNotFoundFailure(this.id);

  @override
  String toString() => 'HabitNotFoundFailure: habit#$id';
}

final class HabitDuplicateFailure extends HabitFailure {
  final String name;
  const HabitDuplicateFailure(this.name);

  @override
  String toString() => 'HabitDuplicateFailure: name "$name" already exists';
}
