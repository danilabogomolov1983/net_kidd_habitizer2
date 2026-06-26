import 'failure.dart';

/// Functional [Result] type — a monadic container for values that may fail.
///
/// This is the primary mechanism for error propagation across all layers.
/// Domain logic returns [Result<T>] instead of throwing exceptions.
///
/// Usage:
/// ```dart
/// Result<int> divide(int a, int b) {
///   if (b == 0) return Result.failure(ValidationFailure(field: 'b', message: 'Division by zero'));
///   return Result.success(a ~/ b);
/// }
///
/// final msg = divide(10, 2).fold(
///   (f) => 'Error: $f',
///   (v) => 'Result: $v',
/// ); // "Result: 5"
/// ```
sealed class Result<T> {
  const Result();

  /// Fold over the two possible states (failure | success).
  B fold<B>(B Function(Failure failure) onFailure, B Function(T value) onSuccess);

  /// Transform the success value with [f]. Does nothing on failure.
  Result<B> map<B>(B Function(T value) f);

  /// Chain another [Result]-producing function. Short-circuits on failure.
  Result<B> flatMap<B>(Result<B> Function(T value) f);

  /// Return the success value or [defaultValue] on failure.
  T getOrElse(T defaultValue);

  /// Execute [action] when this [Result] is a success.
  void forEach(void Function(T value) action);

  /// Return `true` iff this [Result] is a success.
  bool get isSuccess;

  /// Return `true` iff this [Result] is a failure.
  bool get isFailure;

  /// Return the success value or `null` on failure.
  T? get orNull;

  /// Return the [Failure] or `null` on success.
  Failure? get failureOrNull;

  /// Factory constructor for a success [Result].
  factory Result.success(T value) = Success<T>;

  /// Factory constructor for a failure [Result].
  factory Result.failure(Failure failure) = FailureResult<T>;
}

final class Success<T> extends Result<T> {
  final T _value;
  const Success(this._value);

  T get value => _value;

  @override
  B fold<B>(B Function(Failure failure) onFailure, B Function(T value) onSuccess) =>
      onSuccess(_value);

  @override
  Result<B> map<B>(B Function(T value) f) => Success(f(_value));

  @override
  Result<B> flatMap<B>(Result<B> Function(T value) f) => f(_value);

  @override
  T getOrElse(T defaultValue) => _value;

  @override
  void forEach(void Function(T value) action) => action(_value);

  @override
  bool get isSuccess => true;

  @override
  bool get isFailure => false;

  @override
  T? get orNull => _value;

  @override
  Failure? get failureOrNull => null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other._value == _value);

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Success($_value)';
}

final class FailureResult<T> extends Result<T> {
  final Failure _failure;
  const FailureResult(this._failure);

  Failure get failure => _failure;

  @override
  B fold<B>(B Function(Failure failure) onFailure, B Function(T value) onSuccess) =>
      onFailure(_failure);

  @override
  Result<B> map<B>(B Function(T value) f) => FailureResult<B>(_failure);

  @override
  Result<B> flatMap<B>(Result<B> Function(T value) f) => FailureResult<B>(_failure);

  @override
  T getOrElse(T defaultValue) => defaultValue;

  @override
  void forEach(void Function(T value) action) {}

  @override
  bool get isSuccess => false;

  @override
  bool get isFailure => true;

  @override
  T? get orNull => null;

  @override
  Failure? get failureOrNull => _failure;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FailureResult<T> && other._failure == _failure);

  @override
  int get hashCode => _failure.hashCode;

  @override
  String toString() => 'FailureResult($_failure)';
}
