# lib/features/shell/

App shell — the composition root of the presentation layer.

```
shell/
└── presentation/
    └── pages/main_shell.dart   # MainShell: tab navigation, LinkedIn-style bottom bar
```

`MainShell` owns nothing but navigation: it composes `HabitParameterListPage`
(habit slice), `StatisticsPage` (statistics slice) and `ProfilePage` (profile
slice) in an `IndexedStack`. There is no global `AppBar` — each tab owns its
header (search on Home, title on Statistics, hero on Profile), mirroring the
LinkedIn mobile structure.

The bottom bar (`_AppBottomBar` + `_NavItem`) is custom: icon+label tabs with
the creation action (`New habit`, tooltip required by the integration tests)
elevated as a primary-coloured circle between the tabs. It routes to
`HabitParameterDetailPage` via `MaterialPageRoute`.

**Conventions**
- This is the only slice allowed to import sibling slice pages directly
  (composition root). All other cross-slice access goes through barrels.
- No domain/application layers here; if the shell needs state, that state
  belongs in the slice that owns the feature.
- `lib/app.dart` depends only on this slice's `MainShell`.
