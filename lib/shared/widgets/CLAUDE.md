# lib/shared/widgets/

Slice-agnostic, reusable Flutter widgets.

| File | Contents |
|---|---|
| `app_logo.dart` | `AppLogo` — the Habitizer brand mark (CustomPaint spiral + sprout). Parameters: `size`, `opacity`, `color`. Used by the habit list empty state. |

**Conventions**
- Widgets here must not depend on any slice (no slice state, no Riverpod).
- Theme colours are passed in or hard-coded as brand constants; global theming
  lives in `lib/app.dart`.
