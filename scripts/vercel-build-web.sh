#!/usr/bin/env bash
# Vercel build for the customer webapp (Flutter web). Vercel's image has no
# Flutter, so fetch the stable SDK first. Output: build/web.
set -euo pipefail
if [ ! -x "$HOME/flutter/bin/flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"
flutter config --no-analytics >/dev/null
flutter pub get
flutter build web --release --no-wasm-dry-run
