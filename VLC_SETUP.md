# libVLC Setup

This app uses libVLC via Homebrew and links to it with `pkg-config`.

1) Install VLC and `pkg-config`:
   - `./scripts/get_libvlc.sh`
   - or `brew install --cask vlc pkg-config`
2) Build and run:
   - `swift build`
   - `swift run BlockablePlayer`
   - If you hit a `@rpath/libvlc.dylib` error, use:
     - `./scripts/run_with_libvlc.sh`

Notes:
- SwiftPM uses `pkg-config` to find libVLC headers/libraries.
- If VLC.app is installed, try:
  - `export PKG_CONFIG_PATH="/Applications/VLC.app/Contents/MacOS/lib/pkgconfig"`
- If that folder does not exist, use the repo-local file created by the script:
  - `export PKG_CONFIG_PATH="$(pwd)/pkgconfig"`
- Verify with: `pkg-config --cflags --libs libvlc`
- This repo also includes a small header shim at `Sources/CLibVLC/include/vlc/vlc.h` that looks for VLC headers in common locations.
