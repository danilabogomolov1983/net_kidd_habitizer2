# lib/shared/

Cross-slice code that is not part of the architectural kernel (`lib/core/`).
If a module is needed by two or more slices and is not a domain/Result/DB/logging
concern, it belongs here.

```
shared/
├── theme/        # design system: tokens (ThemeExtension), light/dark themes, themeModeProvider
├── extensions/   # language / framework extension helpers
└── widgets/      # brand, category and slice-agnostic widgets
```

**Theme (`theme/app_theme.dart`)**
- `Brand` — mode-independent brand constants (LinkedIn-style blue `#0A66C2`,
  danger, success).
- `HabitizerPalette` — semantic colours that adapt to brightness, exposed as a
  `ThemeExtension` (`context.habitizer.card`, `.canvas`, `.border`, …).
- `buildLightTheme()` / `buildDarkTheme()` — full `ThemeData` for both modes.
- `themeModeProvider` — app-wide user theme preference, watched by `app.dart`
  and toggled from the profile slice.

**Widgets**
- `AppLogo` — the brand mark (empty-state watermark).
- `HabitAvatar` — circular category avatar (LinkedIn-style "profile picture"
  of a habit).
- `EmptyState` — reusable icon + title + subtitle + optional CTA.
- `habit_type_style.dart` — single source of truth for category colour, icon
  and label (`habitTypeColor`, `habitTypeIcon`, `habitTypeLabel`, `habitTypes`).

**Conventions**
- Never import `features/` from here — shared code must stay slice-agnostic.
- Prefer many small files over a `shared_utils.dart` catch-all.
- If a widget starts requiring slice state, move it into that slice's
  `presentation/widgets/` instead of coupling shared to a slice.
