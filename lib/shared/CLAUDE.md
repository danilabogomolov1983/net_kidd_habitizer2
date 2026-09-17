# lib/shared/

Cross-slice code that is not part of the architectural kernel (`lib/core/`).
If a module is needed by two or more slices and is not a domain/Result/DB/logging
concern, it belongs here.

```
shared/
├── extensions/   # language / framework extension helpers
└── widgets/      # brand and other slice-agnostic widgets
```

**Conventions**
- Never import `features/` from here — shared code must stay slice-agnostic.
- Prefer many small files over a `shared_utils.dart` catch-all.
- If a widget starts requiring slice state, move it into that slice's
  `presentation/widgets/` instead of coupling shared to a slice.
