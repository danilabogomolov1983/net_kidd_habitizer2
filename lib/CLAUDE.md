# lib/

Application source, organised in three top-level areas:

```
lib/
├── main.dart            # entry point: DB factory init + runApp
├── app.dart             # HabitizerApp: MaterialApp, theme, root ProviderScope
├── core/                # shared kernel (framework-agnostic + cross-cutting infra)
├── shared/              # cross-slice utilities and widgets
└── features/            # vertical slices (one folder per feature)
```

- `core/` — reusable building blocks every slice may use: `Result<T>` monad,
  `Failure` hierarchy, DB helper, logging. See `core/CLAUDE.md`.
- `shared/` — code that is shared but not part of the kernel: brand widget,
  extensions. See `shared/CLAUDE.md`.
- `features/` — the product features as self-contained vertical slices.
  See `features/CLAUDE.md`.

`main.dart` / `app.dart` are the composition root of the app: they only wire
the entry point and the theme; all screens come from `features/shell`.

**Rule of thumb**: when adding code, ask whether it belongs to one slice
(`features/<slice>/`), to all slices (`core/`, `shared/`), or is app-wide glue
(`app.dart`). Nothing else goes into `lib/`.
