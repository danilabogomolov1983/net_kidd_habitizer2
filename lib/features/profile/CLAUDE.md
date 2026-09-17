# lib/features/profile/

Read-only profile/about slice.

```
profile/
└── presentation/
    └── pages/profile_page.dart   # LinkedIn-style profile: gradient cover, avatar, stats, preferences, about
```

`ProfilePage` watches `habitParameterNotifierProvider` (via the habit slice's
barrel) to derive the counts and the earliest `createdAt`. It never mutates
habit state and has no persistence of its own. The one app-wide preference it
owns is the dark-mode toggle, which writes to `themeModeProvider`
(`lib/shared/theme/app_theme.dart`).

**Conventions**
- Same as statistics: read habit state through the barrel only.
- Version/app metadata shown here is hard-coded; sync it with `pubspec.yaml`
  on release (see `.pi/skills/release/SKILL.md`).
