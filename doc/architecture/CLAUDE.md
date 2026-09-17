# doc/architecture/

Per-folder architecture notes mirroring `lib/`:

```
architecture/
├── core/            # core/{domain,application,infrastructure}
├── features/        # one folder per slice (habit)
├── operations/      # deployment notes
└── shared/          # shared/{extensions, widgets}
```

**Conventions**
- The folder tree must mirror `lib/`; when you add or rename a folder in
  `lib/`, add/rename it here as well.
- Prefer the in-tree `CLAUDE.md` files for everyday guidance; use this tree
  for longer-form notes (diagrams, rationale, trade-offs).
