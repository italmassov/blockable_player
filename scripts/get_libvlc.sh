#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required. Install it from https://brew.sh/"
  exit 1
fi

VLC_APP="/Applications/VLC.app"
VLC_PKGCONFIG="${VLC_APP}/Contents/MacOS/lib/pkgconfig"
LOCAL_PKGCONFIG_DIR="${ROOT_DIR}/pkgconfig"
LOCAL_PKGCONFIG_FILE="${LOCAL_PKGCONFIG_DIR}/libvlc.pc"

if [[ -d "${VLC_APP}" ]]; then
  echo "VLC.app already exists at ${VLC_APP}."
else
  echo "Installing VLC (libVLC) via Homebrew cask..."
  brew install --cask vlc
fi

echo "Installing pkg-config..."
brew install pkg-config

if [[ -d "${VLC_PKGCONFIG}" ]] && [[ -f "${VLC_PKGCONFIG}/libvlc.pc" ]]; then
  echo "Export PKG_CONFIG_PATH for this session:"
  echo "  export PKG_CONFIG_PATH=\"${VLC_PKGCONFIG}\""
  echo "Verify with: pkg-config --cflags --libs libvlc"
  exit 0
fi

echo "Creating local pkg-config file at ${LOCAL_PKGCONFIG_FILE}."
mkdir -p "${LOCAL_PKGCONFIG_DIR}"
cat > "${LOCAL_PKGCONFIG_FILE}" <<EOF
prefix=${VLC_APP}/Contents/MacOS
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libvlc
Description: VLC media player library
Version: 0.0.0
Libs: -L\${libdir} -lvlc -lvlccore
Cflags: -I\${includedir}
EOF

echo "Export PKG_CONFIG_PATH for this session:"
echo "  export PKG_CONFIG_PATH=\"${LOCAL_PKGCONFIG_DIR}\""
echo "Verify with: pkg-config --cflags --libs libvlc"

echo "Done. You can now build with: swift build"
