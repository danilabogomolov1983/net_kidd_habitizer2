/// Base class for domain entities.
///
/// Every entity has a unique identity ([id]) that distinguishes it from other
/// instances even when their properties are identical.
///
/// Entities are **mutable in terms of business state** but implemented as
/// immutable value records: each mutation produces a new instance via
/// [copyWith].
abstract class IEntity {
  const IEntity();
  String get id;
}

/// Base class for domain value objects.
///
/// Value objects have no identity — two instances with the same properties
/// are considered equal. They MUST override `==` and `hashCode`.
abstract class IValueObject {
  const IValueObject();
}
