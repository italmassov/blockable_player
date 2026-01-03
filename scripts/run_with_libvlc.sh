#!/bin/bash
set -euo pipefail

VLC_LIB_DIR="/Applications/VLC.app/Contents/MacOS/lib"
if [[ ! -d "${VLC_LIB_DIR}" ]]; then
  echo "VLC libraries not found at ${VLC_LIB_DIR}."
  exit 1
fi

export DYLD_LIBRARY_PATH="${VLC_LIB_DIR}"
export DYLD_FALLBACK_LIBRARY_PATH="${VLC_LIB_DIR}"
export VLC_PLUGIN_PATH="/Applications/VLC.app/Contents/MacOS/plugins"
swift run BlockablePlayer
