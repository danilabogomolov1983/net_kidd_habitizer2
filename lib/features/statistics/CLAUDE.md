# lib/features/statistics/

Read-only statistics slice.

```
statistics/
└── presentation/
    └── pages/statistics_page.dart   # "Insights": gradient hero + completion ring, KPIs, category bars, due-soon list
```

`StatisticsPage` is a pure projection over habit state: it watches
`habitParameterNotifierProvider` (imported from the habit slice's public API)
and derives counts in `build`. It has no domain, application or infrastructure
of its own and never mutates habit state.

**Conventions**
- Import habit state via the barrel (`features/habit/habit.dart`), not the
  internal file paths.
- Keep aggregation logic here in the page or, when it grows, extract it into a
  `presentation/state/` projection provider — but never duplicate habit data.
