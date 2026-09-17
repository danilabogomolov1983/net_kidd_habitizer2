# lib/features/shell/

App shell — the composition root of the presentation layer.

```
shell/
└── presentation/
    └── pages/main_shell.dart   # MainShell: Scaffold, AppBar menu, NavigationBar, FAB
```

`MainShell` owns nothing but navigation: it composes `HabitParameterListPage`
(habit slice), `StatisticsPage` (statistics slice) and `ProfilePage` (profile
slice) in an `IndexedStack`, and routes to `HabitParameterDetailPage` for the
FAB/menu actions.

**Conventions**
- This is the only slice allowed to import sibling slice pages directly
  (composition root). All other cross-slice access goes through barrels.
- No domain/application layers here; if the shell needs state, that state
  belongs in the slice that owns the feature.
- `lib/app.dart` depends only on this slice's `MainShell`.
