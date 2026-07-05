#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# Habitizer 2.0 — Release Script
# ──────────────────────────────────────────────
# Bumps version in pubspec.yaml, creates a git
# tag, and builds platform artifacts.
#
# Usage:
#   ./release.sh              # interactive
#   ./release.sh 1.1.0 web    # direct
#   ./release.sh 1.1.0 all    # direct, all platforms
# ──────────────────────────────────────────────

ROOT_DIR="$(cd "$(dirname "$0")/../../../.." && pwd)"
PUBSPEC="$ROOT_DIR/pubspec.yaml"
OPS_SCRIPT="$ROOT_DIR/operations/deploy.sh"

RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
err()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ── Parse current version ─────────────────────

CURRENT_VERSION=$(grep -E '^version:' "$PUBSPEC" | sed -E 's/version:\s*//' | head -1)
CURRENT_SEMVER=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
CURRENT_BUILD=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

if [ -z "$CURRENT_SEMVER" ]; then
  err "Could not parse version from $PUBSPEC"
fi

# ── Determine new version ─────────────────────

NEW_VERSION="${1:-}"

if [ -z "$NEW_VERSION" ]; then
  # Interactive mode
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║       Habitizer Release Builder      ║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════╝${NC}"
  echo ""
  echo -e "Current version: ${GREEN}$CURRENT_VERSION${NC}"

  # Suggest next patch version
  IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_SEMVER"
  NEXT_PATCH="$MAJOR.$MINOR.$((PATCH + 1))"
  NEXT_MINOR="$MAJOR.$((MINOR + 1)).0"
  NEXT_MAJOR="$((MAJOR + 1)).0.0"

  echo ""
  echo "Suggested next versions:"
  echo "  1) patch — $NEXT_PATCH  (bug fixes)"
  echo "  2) minor — $NEXT_MINOR  (new features)"
  echo "  3) major — $NEXT_MAJOR  (breaking changes)"
  echo "  4) custom"
  echo ""

  read -r -p "Choose [1-4] (default: 1): " CHOICE
  CHOICE="${CHOICE:-1}"

  case "$CHOICE" in
    1) NEW_VERSION="$NEXT_PATCH" ;;
    2) NEW_VERSION="$NEXT_MINOR" ;;
    3) NEW_VERSION="$NEXT_MAJOR" ;;
    4)
      read -r -p "Enter version (x.y.z): " NEW_VERSION
      ;;
    *) err "Invalid choice: $CHOICE" ;;
  esac
fi

# Validate semver
if ! echo "$NEW_VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  err "Invalid semver: $NEW_VERSION (must be x.y.z)"
fi

NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_FULL="${NEW_VERSION}+${NEW_BUILD}"

echo ""
info "Bumping version: ${RED}$CURRENT_VERSION${NC} → ${GREEN}$NEW_FULL${NC}"

# ── Determine platform ────────────────────────

PLATFORM="${2:-}"
if [ -z "$PLATFORM" ] && [ "$#" -lt 2 ]; then
  echo ""
  echo "Build target:"
  echo "  1) web"
  echo "  2) android"
  echo "  3) ios (macOS only)"
  echo "  4) all"
  echo "  5) skip build"
  echo ""
  read -r -p "Choose [1-5] (default: 1): " PLAT_CHOICE
  PLAT_CHOICE="${PLAT_CHOICE:-1}"

  case "$PLAT_CHOICE" in
    1) PLATFORM="web" ;;
    2) PLATFORM="android" ;;
    3) PLATFORM="ios" ;;
    4) PLATFORM="all" ;;
    5) PLATFORM="skip" ;;
    *) err "Invalid choice: $PLAT_CHOICE" ;;
  esac
fi

# ── Confirm ───────────────────────────────────

if [ "${CI:-}" != "true" ]; then
  TAG="v$NEW_VERSION"
  echo ""
  echo -e "Summary:"
  echo -e "  Version:   ${GREEN}$NEW_FULL${NC}"
  echo -e "  Tag:       ${CYAN}$TAG${NC}"
  echo -e "  Build:     ${YELLOW}$PLATFORM${NC}"
  echo ""
  read -r -p "Proceed? [Y/n] " CONFIRM
  CONFIRM="${CONFIRM:-Y}"
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    info "Aborted."
    exit 0
  fi
fi

# ── Update pubspec.yaml ───────────────────────

info "Updating $PUBSPEC..."
sed -i "s/^version: .*/version: $NEW_FULL/" "$PUBSPEC"
ok "pubspec.yaml updated to $NEW_FULL"

# ── Git commit and tag ────────────────────────

info "Committing version bump..."
git -C "$ROOT_DIR" add "$PUBSPEC"
if [ -f "$ROOT_DIR/CHANGELOG.md" ]; then
  git -C "$ROOT_DIR" add "$ROOT_DIR/CHANGELOG.md"
fi
git -C "$ROOT_DIR" commit -m "chore: bump version to $NEW_VERSION" || {
  warn "Nothing to commit — version may already be set"
}

info "Creating tag v$NEW_VERSION..."
if git -C "$ROOT_DIR" tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION" 2>/dev/null; then
  ok "Tag v$NEW_VERSION created"
else
  warn "Tag v$NEW_VERSION already exists — skipping"
fi

# ── Build ─────────────────────────────────────

RELEASE_ARTIFACT=""

if [ "$PLATFORM" != "skip" ]; then
  echo ""
  info "Building for platform: $PLATFORM"
  if [ ! -x "$OPS_SCRIPT" ]; then
    err "Deploy script not found or not executable: $OPS_SCRIPT"
  fi
  bash "$OPS_SCRIPT" "$PLATFORM"

  # Copy release artifact to repo root with versioned name
  case "$PLATFORM" in
    android|all)
      APK_SRC="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
      APK_DST="$ROOT_DIR/habitizer-${NEW_VERSION}.apk"
      if [ -f "$APK_SRC" ]; then
        cp "$APK_SRC" "$APK_DST"
        ok "Artifact copied → habitizer-${NEW_VERSION}.apk"
        RELEASE_ARTIFACT="$APK_DST"
      fi
      ;;
  esac

  case "$PLATFORM" in
    web|all)
      WEB_SRC="$ROOT_DIR/build/web"
      WEB_DST="$ROOT_DIR/habitizer-${NEW_VERSION}-web.tar.gz"
      if [ -d "$WEB_SRC" ]; then
        tar -czf "$WEB_DST" -C "$ROOT_DIR/build" web
        ok "Artifact copied → habitizer-${NEW_VERSION}-web.tar.gz"
        [ -z "$RELEASE_ARTIFACT" ] && RELEASE_ARTIFACT="$WEB_DST"
      fi
      ;;
  esac
else
  info "Skipping build"
fi

# ── Done ──────────────────────────────────────

echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Release Complete! 🎉         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
echo ""
echo -e "  Version:   ${GREEN}$NEW_FULL${NC}"
echo -e "  Tag:       ${CYAN}v$NEW_VERSION${NC}"
if [ -n "$RELEASE_ARTIFACT" ]; then
  echo -e "  Artifact:  ${GREEN}$(basename "$RELEASE_ARTIFACT")${NC}"
fi
echo ""
echo -e "To push to remote:"
echo -e "  ${YELLOW}git push origin main --tags${NC}"
echo ""
