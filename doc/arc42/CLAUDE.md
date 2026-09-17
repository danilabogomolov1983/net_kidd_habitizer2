# doc/arc42/

arc42 architecture documentation, 12 sections:

| # | Section | Contents |
|---|---|---|
| 01 | introduction-and-goals | requirements & quality goals |
| 02 | architecture-constraints | technical/organisational constraints |
| 03 | system-scope-and-context | external interfaces |
| 04 | solution-strategy | key architectural ideas |
| 05 | building-block-view | layered + slice decomposition |
| 06 | runtime-view | key runtime scenarios |
| 07 | deployment-view | web/Docker, Android, iOS |
| 08 | crosscutting-concepts | Result monad, logging, DI |
| 09 | architecture-decisions | ADRs (numbered, dated) |
| 10 | quality-requirements | quality tree & scenarios |
| 11 | risks-and-technical-debt | known debt |
| 12 | glossary | terminology |

**Conventions**
- One decision per ADR; mark superseded ADRs instead of deleting them.
- Update sections 05/06/11 whenever the slice structure changes.
