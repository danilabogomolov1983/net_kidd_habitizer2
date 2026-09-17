# lib/features/profile/

Read-only profile/about slice.

```
profile/
└── presentation/
    └── pages/profile_page.dart   # avatar, habit counts, "Joined" date, about card
```

`ProfilePage` watches `habitParameterNotifierProvider` (via the habit slice's
barrel) to derive the counts and the earliest `createdAt`. It never mutates
habit state and has no persistence of its own.

**Conventions**
- Same as statistics: read habit state through the barrel only.
- Version/app metadata shown here is hard-coded; sync it with `pubspec.yaml`
  on release (see `.pi/skills/release/SKILL.md`).
