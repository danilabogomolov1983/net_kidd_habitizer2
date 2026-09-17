# doc/

Architecture documentation.

```
doc/
├── arc42/          # full arc42 documentation (12 sections, 01…12)
└── architecture/   # per-folder notes mirroring lib/ structure
```

- `arc42/` — read `01-introduction-and-goals.md` first; `05-building-block-view.md`
  and `09-architecture-decisions.md` (ADRs) are the most important for developers.
- `architecture/` — mirrors `lib/{core,features,shared}`; intended for deeper
  notes than the in-tree `CLAUDE.md` files.

**Conventions**
- The in-tree `CLAUDE.md` files are the primary reference for AI coding agents;
  update them first, then reflect structural decisions here and in arc42.
- Keep arc42 sections consistent with the actual code; when restructuring
  slices, update `05-building-block-view.md` and add an ADR in
  `09-architecture-decisions.md`.
