# lib/features/

Vertical slices — one folder per feature. Each slice is self-contained:
domain, application, infrastructure and presentation for that feature only.

```
features/
├── habit/        # habit CRUD + browsing (the core slice, owns habit state)
├── shell/        # app shell: navigation, menu, FAB; composes other slices' screens
├── statistics/   # read-only statistics view over habit data
└── profile/      # read-only profile/about view over habit data
```

**Slice rules**
- A slice's public API is its barrel file (`<slice>/<slice>.dart`).
- Sibling slices import each other only through the barrel — never reach into
  another slice's internal folders.
- `shell` is the composition root of the presentation layer and is allowed to
  import sibling slice pages directly; other slices should avoid doing so.
- Read-only slices (statistics, profile) may `watch` habit state via its
  barrel; they must not mutate it.
- Presentation-only slices are fine: a slice contains only the layers it needs.

**Adding a new slice**
1. Create `features/<name>/{domain,application,infrastructure,presentation}`.
2. Add `<name>/<name>.dart` barrel exporting the public API.
3. Wire providers in `<name>/infrastructure/di/`.
4. Mirror tests under `test/features/<name>/`.
5. Document the slice in its own `CLAUDE.md` and update this file.
