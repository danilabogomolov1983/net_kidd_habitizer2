# operations/

Deployment tooling for Habitizer 2.0.

| File | Contents |
|---|---|
| `deploy.sh` | Builds the Flutter web app (and optionally Android/iOS) and packages it as a Docker image; can push to a registry. |
| `Dockerfile` | Static web server image for the built web app. |
| `nginx.conf` | nginx configuration served by the container. |

**Usage**: `./deploy.sh web|android|ios|all` from the repo root.
**Related**: release/version workflow is a pi skill — `.pi/skills/release/SKILL.md`.
