#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="BlockablePlayer"
APP_DIR="${ROOT_DIR}/${APP_NAME}.app"
DIST_DIR="${ROOT_DIR}/dist"
VLC_APP="/Applications/VLC.app"
VLC_LIB_DIR="${VLC_APP}/Contents/MacOS/lib"
VLC_PLUGIN_DIR="${VLC_APP}/Contents/MacOS/plugins"

if [[ ! -d "${VLC_APP}" ]]; then
  echo "VLC.app not found at ${VLC_APP}. Install VLC first."
  exit 1
fi

echo "Building release binary..."
swift build -c release

echo "Creating app bundle..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Frameworks"
mkdir -p "${APP_DIR}/Contents/Resources/vlc"

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

echo "Bundling libVLC and plugins..."
cp "${VLC_LIB_DIR}/libvlc.dylib" "${APP_DIR}/Contents/Frameworks/"
cp "${VLC_LIB_DIR}/libvlccore.dylib" "${APP_DIR}/Contents/Frameworks/"
cp -R "${VLC_PLUGIN_DIR}" "${APP_DIR}/Contents/Resources/vlc/plugins"

echo "Fixing rpaths and dylib install names..."
install_name_tool -id "@rpath/libvlc.dylib" "${APP_DIR}/Contents/Frameworks/libvlc.dylib"
install_name_tool -id "@rpath/libvlccore.dylib" "${APP_DIR}/Contents/Frameworks/libvlccore.dylib"
install_name_tool -change "${VLC_LIB_DIR}/libvlccore.dylib" "@rpath/libvlccore.dylib" \
  "${APP_DIR}/Contents/Frameworks/libvlc.dylib" || true
install_name_tool -add_rpath "@executable_path/../Frameworks" "${APP_DIR}/Contents/MacOS/${APP_NAME}" || true

if [[ -n "${SIGN_IDENTITY:-}" ]]; then
  echo "Codesigning with identity: ${SIGN_IDENTITY}"
  codesign --deep --force --options runtime --sign "${SIGN_IDENTITY}" "${APP_DIR}"
elif [[ "${SIGN_ADHOC:-0}" == "1" ]]; then
  echo "Codesigning with ad-hoc identity."
  codesign --deep --force --sign "-" "${APP_DIR}"
fi

mkdir -p "${DIST_DIR}"
ZIP_PATH="${DIST_DIR}/${APP_NAME}.zip"
rm -f "${ZIP_PATH}"
ditto -c -k --sequesterRsrc --keepParent "${APP_DIR}" "${ZIP_PATH}"

echo "Created ${ZIP_PATH}"
echo "SHA256: $(shasum -a 256 "${ZIP_PATH}" | awk '{print $1}')"
echo "Upload the zip and use the SHA256 in your Homebrew cask."
