# lib/core/infrastructure/

Concrete, cross-slice technical services. This layer may use third-party
packages and platform APIs; slices consume it through `core/core.dart` or
direct imports of the subfolders below.

```
infrastructure/
├── database/   # SQLite: connection helper, platform factories, Riverpod providers
└── logging/    # structured logging: IAppLogger + console/file/composite/no-op impls
```

See `database/CLAUDE.md` and `logging/CLAUDE.md`.

**Conventions**
- Features never open a DB connection themselves — always via `DatabaseHelper`.
- Logging is an effect: keep calls at the layer boundaries (infrastructure,
  application), never inside pure domain logic.
