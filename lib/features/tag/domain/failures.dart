import '../../../../core/domain/failure.dart';

sealed class TagFailure extends Failure {
  const TagFailure();
}

final class TagValidationFailure extends TagFailure {
  final String field;
  final String message;
  const TagValidationFailure({required this.field, required this.message});

  @override
  String toString() => 'TagValidationFailure($field): $message';
}

final class TagPersistenceFailure extends TagFailure {
  final String message;
  final StackTrace? stackTrace;
  const TagPersistenceFailure(this.message, [this.stackTrace]);

  @override
  String toString() => 'TagPersistenceFailure: $message';
}

final class TagNotFoundFailure extends TagFailure {
  final String id;
  const TagNotFoundFailure(this.id);

  @override
  String toString() => 'TagNotFoundFailure: tag#$id';
}

final class TagDuplicateFailure extends TagFailure {
  final String name;
  const TagDuplicateFailure(this.name);

  @override
  String toString() => 'TagDuplicateFailure: name "$name" already exists';
}
