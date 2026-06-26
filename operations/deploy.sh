#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────
# Habitizer 2.0 — deployment script
# ──────────────────────────────────────────────
# Builds the Flutter web app and packages it as a
# Docker container, then optionally pushes to a
# registry.
#
# Usage:
#   ./deploy.sh web          # build web + Docker image
#   ./deploy.sh android      # build Android APK
#   ./deploy.sh ios          # build iOS (macOS only)
#   ./deploy.sh all          # all platforms
# ──────────────────────────────────────────────

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPS_DIR="$ROOT_DIR/operations"
BUILD_DIR="$ROOT_DIR/build"

info()  { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
ok()    { echo -e "\033[1;32m[OK]\033[0m    $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
err()   { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

check_flutter() {
  if ! command -v flutter &>/dev/null; then
    err "Flutter SDK not found. Install from https://flutter.dev"
  fi
}

check_docker() {
  if ! command -v docker &>/dev/null; then
    warn "Docker not found — skipping container build"
    return 1
  fi
  return 0
}

deploy_web() {
  info "Building Flutter web release..."
  cd "$ROOT_DIR"
  flutter clean
  flutter pub get
  flutter build web --release
  ok "Web build complete → $BUILD_DIR/web"

  if check_docker; then
    info "Building Docker image..."
    docker build -t habitizer:latest -f "$OPS_DIR/Dockerfile" .
    ok "Docker image built → habitizer:latest"
    echo ""
    info "Run locally with:"
    echo "    docker run -p 8080:80 habitizer:latest"
    echo "    open http://localhost:8080"
  fi
}

deploy_android() {
  info "Building Android APK (release)..."
  cd "$ROOT_DIR"
  flutter clean
  flutter pub get
  flutter build apk --release
  ok "APK built → build/app/outputs/flutter-apk/app-release.apk"
}

deploy_ios() {
  if [[ "$(uname)" != "Darwin" ]]; then
    warn "iOS builds require macOS — skipping"
    return
  fi
  info "Building iOS (release)..."
  cd "$ROOT_DIR"
  flutter clean
  flutter pub get
  flutter build ios --release --no-codesign
  ok "iOS build complete"
}

# ── Main ─────────────────────────────────────

check_flutter

TARGET="${1:-web}"

case "$TARGET" in
  web)     deploy_web ;;
  android) deploy_android ;;
  ios)     deploy_ios ;;
  all)
    deploy_web
    deploy_android
    deploy_ios
    ;;
  *)
    echo "Usage: $0 {web|android|ios|all}"
    exit 1
    ;;
esac

ok "Deployment finished successfully!"
