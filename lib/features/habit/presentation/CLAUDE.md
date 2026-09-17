# lib/features/habit/presentation/

Flutter UI of the habit slice, organised by role:

```
presentation/
├── pages/
│   ├── habit_parameter_list_page.dart   # home tab: LinkedIn-style feed (header, filter pills, cards, empty states)
│   └── habit_parameter_detail_page.dart # create/edit form (auto-saves on change, explicit "Done")
├── state/
│   ├── habit_parameter_notifier.dart    # HabitParameterNotifier (CRUD over AsyncValue<List<HabitParameter>>)
│   ├── habit_search_provider.dart       # searchQueryProvider (StateProvider<String>)
│   └── habit_feed_filter_provider.dart  # HabitFeedFilter enum + habitFeedFilterProvider
└── widgets/
    └── habit_parameter_card.dart        # LinkedIn-post-style card: avatar, meta, progress, action row, ⋮ bottom sheet
```

**Design notes**
- The home tab mirrors the LinkedIn mobile feed: fixed search header with a
  brand avatar, filter pills (All / Active / Due soon / Completed) with live
  counts, and post-style cards whose action row (Log / Edit / Delete) stands
  in for Like / Comment / Share. Delete is confirmed via dialog and also
  offered in the card's ⋮ bottom sheet.
- All colours come from the theme (`context.habitizer…`) and category identity
  from `shared/widgets/habit_type_style.dart`; no hard-coded hex values.

**Conventions**
- Pages stay dumb: `watch` providers, render widgets, delegate mutations to the
  notifier. No business rules (validation lives in `application/`), no SQL.
- State notifiers are the only place that talks to the application service
  (`habitParameterServiceProvider`).
- Page-local private widgets (`_FeedHeader`, `_FilterBar`, …) stay in the page
  file; reusable ones move to `widgets/`.
- Routes are pushed with `MaterialPageRoute` from pages/shell; there is no
  central router yet.
- `searchQueryProvider` / `habitFeedFilterProvider` live here (habit browsing
  concern) even though the controls render on the shell's home tab.
- The integration test relies on: the first `TextFormField` being the
  description field, auto-save on change, and a single `AppLogo` in the
  empty state.
