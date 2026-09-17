# lib/shared/extensions/

Extension methods over core types.

| File | Contents |
|---|---|
| `functional_extensions.dart` | `ResultExtensions.toNullableWithLog` (fold a `Result` to a nullable value while logging failures) and `FailureMessage.userFriendlyMessage` (human-readable text per failure kind, with a fallback arm for slice-specific failures). |

**Conventions**
- Pure functions only — no side effects beyond an injected logger callback.
- Add new extensions here only when they are useful to more than one slice.
