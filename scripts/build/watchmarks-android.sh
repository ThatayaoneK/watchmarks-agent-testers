#!/usr/bin/env bash
# Build WatchMarks Android from the monorepo root.
# Called by agent-testers with the source repository as the working directory.
set -euo pipefail

test -f package.json || { echo "Run this from the WatchMarks repository root" >&2; exit 1; }
test -f apps/mobile/app.config.ts || { echo "apps/mobile/app.config.ts not found" >&2; exit 1; }

required=(FIREBASE_API_KEY FIREBASE_AUTH_DOMAIN FIREBASE_PROJECT_ID FIREBASE_STORAGE_BUCKET FIREBASE_MESSAGING_SENDER_ID FIREBASE_APP_ID)
for name in "${required[@]}"; do
  if [ -z "${!name:-}" ]; then
    echo "::error::Missing required build variable: $name"
    exit 1
  fi
done

npm ci
cd apps/mobile
CI=1 npx expo prebuild --platform android --no-install
cd android
./gradlew assembleRelease -PreactNativeArchitectures=x86_64 --build-cache
