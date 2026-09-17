# lib/core/

Shared kernel of the application. Unlike `lib/shared/`, this is architectural
foundation rather than a grab-bag of utilities: every slice builds on these
types.

```
core/
├── core.dart                  # barrel: exports domain + use_case (public kernel API)
├── domain/                    # Result monad, Failure hierarchy, entity/value-object bases
├── application/               # use-case base contracts
└── infrastructure/            # database access and logging (concrete, cross-slice)
```

**Dependency rule**: `core/domain` imports nothing from outside core;
`core/application` may import domain; `core/infrastructure` may import both and
third-party packages (sqflite, dart:io, …). No core layer may import
`features/` or `shared/`.

See the per-folder CLAUDE.md files in `domain/`, `application/` and
`infrastructure/` for details.
