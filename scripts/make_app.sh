#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="BlockablePlayer"
APP_DIR="${ROOT_DIR}/${APP_NAME}.app"

echo "Building release binary..."
swift build -c release

echo "Creating app bundle..."
mkdir -p "${APP_DIR}/Contents/MacOS"
cp "${ROOT_DIR}/.build/release/${APP_NAME}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"

cat > "${APP_DIR}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key><string>com.example.blockableplayer</string>
  <key>CFBundleExecutable</key><string>${APP_NAME}</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>LSMinimumSystemVersion</key><string>12.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict>
</plist>
PLIST

echo "App bundle created at: ${APP_DIR}"
echo "Move it to /Applications if you want Spotlight/Dock access."
echo "For Homebrew distribution, use ./scripts/package_cask.sh"
