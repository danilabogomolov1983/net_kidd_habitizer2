---
name: release
description: Build a release with version bump, git tag, and platform artifacts for this Flutter project. Use when the user asks to create a release, bump a version, tag a release, or build/publish a new version of the app.
---

# Release

Build a release with semantic versioning for this Flutter project. The skill handles version bumping in `pubspec.yaml`, git tagging, changelog updates, and platform builds (web, Android, iOS).

## Quick Start

```bash
# Interactive wizard (recommended):
./.pi/skills/release/scripts/release.sh

# Or specify version and target directly:
./.pi/skills/release/scripts/release.sh 1.1.0 web
```

## Full Workflow

### Step 1 — Decide Version

Read `pubspec.yaml` to see the current version (e.g., `version: 1.0.0+1`).
The format is `<semver>+<build-number>`.

Determine the next version using [semantic versioning](https://semver.org):
- **patch** (1.0.0 → 1.0.1): bug fixes, minor improvements
- **minor** (1.0.0 → 1.1.0): new features, backward-compatible
- **major** (1.0.0 → 2.0.0): breaking changes

Increment the build number (+1) on every release.

Ask the user which version to use, or if they provided one, use it directly.

### Step 2 — Update pubspec.yaml

Use `edit` to change the `version:` line in `pubspec.yaml` to the new version.

### Step 3 — Update CHANGELOG (if it exists)

If `CHANGELOG.md` exists, add a new entry for the version with recent commits. Use `git log` to gather changes since the last tag:

```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
  git log "${LAST_TAG}..HEAD" --oneline --no-merges
else
  git log --oneline --no-merges
fi
```

### Step 4 — Git Commit and Tag

```bash
git add pubspec.yaml CHANGELOG.md 2>/dev/null || git add pubspec.yaml
git commit -m "chore: bump version to X.Y.Z"
git tag -a "vX.Y.Z" -m "Release vX.Y.Z"
```

### Step 5 — Build and Copy Artifact

Run the build for the requested platform(s):

```bash
# Single platform
./operations/deploy.sh <web|android|ios>

# All platforms
./operations/deploy.sh all
```

After a successful build, copy the release artifact to the repo root following the naming template:
- **Android**: `habitizer-<version>.apk` (e.g., `habitizer-1.0.3.apk`)
- **Web**: `habitizer-<version>-web.tar.gz` (e.g., `habitizer-1.0.3-web.tar.gz`)

```bash
# Example for Android:
cp build/app/outputs/flutter-apk/app-release.apk ./habitizer-1.0.3.apk

# Example for web:
tar -czf habitizer-1.0.3-web.tar.gz -C build web
```

### Step 6 — Summary

Report what was done:
- New version
- Git tag created
- Build artifacts produced and their locations (repo root: `habitizer-X.Y.Z.apk`)

Optionally remind the user that they can push with:
```bash
git push origin main --tags
```

## Helper Script

A helper script at `./.pi/skills/release/scripts/release.sh` automates steps 2, 4, and 5. Use it for convenience, or perform each step manually.

```bash
# Usage:
./.pi/skills/release/scripts/release.sh [version] [platform]

# Examples:
./.pi/skills/release/scripts/release.sh 1.1.0 web       # bump to 1.1.0, build web
./.pi/skills/release/scripts/release.sh                 # interactive mode
./.pi/skills/release/scripts/release.sh 1.1.0 all       # bump + all platforms
```

The script:
1. Parses the current version from `pubspec.yaml`
2. Bumps to the new version (provided or prompted)
3. Increments the build number (+1)
4. Updates `pubspec.yaml`
5. Stages and commits the change
6. Creates a `v<version>` git tag
7. Runs `operations/deploy.sh <platform>` for the build
8. Copies the release artifact to repo root as `habitizer-<version>.apk` (Android) or `habitizer-<version>-web.tar.gz` (web)
