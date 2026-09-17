# lib/features/habit/presentation/

Flutter UI of the habit slice, organised by role:

```
presentation/
├── pages/
│   ├── habit_parameter_list_page.dart   # home tab: search + list + empty states
│   └── habit_parameter_detail_page.dart # create/edit form (auto-saves on change)
├── state/
│   ├── habit_parameter_notifier.dart    # HabitParameterNotifier (CRUD over AsyncValue<List<HabitParameter>>)
│   └── habit_search_provider.dart       # searchQueryProvider (StateProvider<String>)
└── widgets/
    └── habit_parameter_card.dart        # list card with Dismissible delete confirm
```

**Conventions**
- Pages stay dumb: `watch` providers, render widgets, delegate mutations to the
  notifier. No business rules (validation lives in `application/`), no SQL.
- State notifiers are the only place that talks to the application service
  (`habitParameterServiceProvider`).
- Page-local private widgets (`_SectionLabel`, `_EmptyState`, …) stay in the
  page file; reusable ones move to `widgets/`.
- Routes are pushed with `MaterialPageRoute` from pages/shell; there is no
  central router yet.
- `searchQueryProvider` lives here (habit browsing concern) even though the
  search box renders on the shell's home tab.
