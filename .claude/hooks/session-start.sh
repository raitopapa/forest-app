#!/bin/bash
# SessionStart hook for Claude Code on the web.
#
# Installs the Flutter SDK (this repo is a Flutter/Dart app — `forest_app`) and
# fetches project dependencies so that `flutter analyze` and `flutter test`
# work out of the box in a fresh remote session.
#
# Runs synchronously: the session waits until this completes, guaranteeing the
# toolchain is ready before Claude tries to analyze or test anything.
set -euo pipefail

# Only run in the remote (Claude Code on the web) environment. Local machines
# are expected to already have their own Flutter toolchain on PATH.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Pinned to the version recorded in .metadata / README (Flutter 3.38.4 stable,
# Dart 3.10.x). Matches the resolved pubspec.lock and the pinned analyzer 7.6.0.
FLUTTER_VERSION="3.38.4"
FLUTTER_DIR="${FLUTTER_HOME:-$HOME/flutter}"
FLUTTER_BIN="$FLUTTER_DIR/bin"
ARCHIVE_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"

# 1. Install the Flutter SDK (idempotent: skip if the pinned version is present).
installed_version=""
if [ -x "$FLUTTER_BIN/flutter" ] && [ -f "$FLUTTER_DIR/version" ]; then
  installed_version="$(cat "$FLUTTER_DIR/version" 2>/dev/null || true)"
fi

if [ "$installed_version" != "$FLUTTER_VERSION" ]; then
  echo "Installing Flutter ${FLUTTER_VERSION}..."
  rm -rf "$FLUTTER_DIR"
  mkdir -p "$FLUTTER_DIR"
  tmp_archive="$(mktemp --suffix=.tar.xz)"
  curl -fsSL "$ARCHIVE_URL" -o "$tmp_archive"
  # The tarball has a top-level flutter/ directory; strip it into FLUTTER_DIR.
  tar -xf "$tmp_archive" -C "$FLUTTER_DIR" --strip-components=1
  rm -f "$tmp_archive"
else
  echo "Flutter ${FLUTTER_VERSION} already installed; skipping download."
fi

export PATH="$FLUTTER_BIN:$PATH"

# Flutter's bundled SDK is a git checkout; running as root would otherwise trip
# git's "dubious ownership" guard on the first flutter invocation.
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

# Persist the SDK on PATH for the rest of the session.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo "export PATH=\"$FLUTTER_BIN:\$PATH\"" >> "$CLAUDE_ENV_FILE"
fi

# 2. Warm the toolchain (first run unpacks the bundled Dart SDK) and install
#    the project's pub dependencies.
#
# SessionStart fires on resume/clear/compact too, inheriting whatever cwd the
# session currently has — which may not be the project root. The only pubspec
# lives at the repo root, so move there before `flutter pub get`. Fall back to
# resolving the root from this script's own location when run outside a hook.
cd "${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"

flutter --version
flutter pub get

echo "Flutter environment ready."
