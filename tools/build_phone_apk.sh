#!/bin/sh
# Builds a release APK for a real phone on the same Wi-Fi as this Mac.
# The Mac's IP changes between networks, so it is read fresh on every build.
set -e
cd "$(dirname "$0")/.."
IP=$(ipconfig getifaddr en0 || ipconfig getifaddr en1)
if [ -z "$IP" ]; then echo "Not connected to Wi-Fi"; exit 1; fi
echo "Building for backend at http://$IP:8081"
flutter build apk --release --target-platform android-arm64 --dart-define=API_URL=http://$IP:8081
echo "APK: build/app/outputs/flutter-apk/app-release.apk  (backend must be running on this Mac)"
