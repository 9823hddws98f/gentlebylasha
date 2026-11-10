#!/usr/bin/env bash
# Runs the iOS app in a simulator against the local Firebase emulators.
#
# On iOS the native Firebase app is configured from GoogleService-Info.plist
# before Dart starts, so --dart-define can't switch projects there. The plist
# points at the demo project for the duration of the run and is restored after.
#
#   npm --prefix functions run emulators      # in another terminal
#   scripts/run-ios-emulators.sh -d "iPhone 17 Pro"
set -euo pipefail
cd "$(dirname "$0")/.."

PLIST=ios/Runner/GoogleService-Info.plist
# A killed earlier run may have left the original behind.
if [ -f "$PLIST.orig" ]; then mv "$PLIST.orig" "$PLIST"; fi
cp "$PLIST" "$PLIST.orig"
trap 'mv "$PLIST.orig" "$PLIST"' EXIT
trap 'exit 130' INT TERM

plutil -replace PROJECT_ID -string demo-gentle "$PLIST"
plutil -replace STORAGE_BUCKET -string demo-gentle.appspot.com "$PLIST"

flutter run --dart-define=FIREBASE_EMULATORS=true "$@"
