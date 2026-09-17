# shared/theme

Design system for the Habitizer UI (LinkedIn-mobile-inspired).

**Rationale** — before the redesign every slice hard-coded its own copy of
brand colours (`0xFF0058A3`, `0xFFF5F7FA`, …), which drifted across widgets
and made dark mode impossible. All tokens now live here:

- `Brand` — mode-independent constants (blue `#0A66C2`, danger, success).
- `HabitizerPalette` — a `ThemeExtension` with semantic, brightness-aware
  colours (canvas, surface, border, search fill, muted text, gradients).
  Widgets read them via `context.habitizer.*`.
- `buildLightTheme()` / `buildDarkTheme()` — component themes (cards, inputs,
  pill buttons, sheets, dialogs, snackbars) in one place.
- `themeModeProvider` — user theme preference (`ThemeMode`), watched by
  `app.dart` (`themeMode`) and toggled on the profile tab.

**Trade-offs**
- Keeping the palette as a `ThemeExtension` (rather than a second global
  class) means widgets stay theme-aware and switch instantly with brightness.
- The extension carries only colours; typography and component shapes stay in
  `ThemeData`, where Flutter expects them.
