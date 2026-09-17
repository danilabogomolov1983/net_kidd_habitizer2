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

The bottom bar (`_AppBottomBar` + `_NavItem`) is custom: three icon+label
tabs (Home, Statistics, Profile). The primary creation action is **not** part
of the bar — it lives on the home tab as an icon-only FAB (`New habit`,
tooltip required by the integration tests) floating right-aligned over the
bar. It routes to `HabitParameterDetailPage` via `MaterialPageRoute`.

**Conventions**
- This is the only slice allowed to import sibling slice pages directly
  (composition root). All other cross-slice access goes through barrels.
- No domain/application layers here; if the shell needs state, that state
  belongs in the slice that owns the feature.
- `lib/app.dart` depends only on this slice's `MainShell`.
