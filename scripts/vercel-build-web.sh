#!/usr/bin/env bash
# Vercel build for the customer webapp (Flutter web). Vercel's image has no
# Flutter, so fetch the SDK first. Output: build/web.
# Pinned to the version the app is developed and tested with; bump it together
# with the local SDK.
set -euo pipefail
FLUTTER_VERSION=3.47.7
if [ "$(git -C "$HOME/flutter" describe --tags --exact-match 2>/dev/null)" != "$FLUTTER_VERSION" ]; then
  rm -rf "$HOME/flutter"
  git clone --depth 1 -b "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
flutter config --no-analytics >/dev/null
flutter pub get
# Optional Vercel environment variables: SITE_URL and APP_URL (own domain),
# WEB_PUSH_VAPID_KEY (Firebase console → Cloud Messaging → Web configuration).
defines=()
for name in SITE_URL APP_URL WEB_PUSH_VAPID_KEY; do
  if [ -n "${!name:-}" ]; then defines+=("--dart-define=$name=${!name}"); fi
done
flutter build web --release --no-wasm-dry-run ${defines[@]+"${defines[@]}"}
