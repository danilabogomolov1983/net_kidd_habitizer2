import '../domain/result.dart';

/// Base class for use cases / application services.
///
/// Parameterised by [Input] and [Output]. Every use case has a single
/// entry point — `call` — which returns a [Result].
///
/// **Functional style**: use cases are pure orchestrations. They delegate
/// persistence to repository interfaces and keep no mutable state.
abstract base class IUseCase<Input, Output> {
  /// Execute the use case.
  Result<Output> call(Input input);
}

/// A use case that requires no input.
abstract base class INoInputUseCase<Output> {
  Result<Output> call();
}
