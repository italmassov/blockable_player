# Blockable Player

Blockable Player is a macOS video player built for parent-controlled playback. It plays MKV and common formats using bundled libVLC, supports a PIN lock, and provides VLC-style controls and shortcuts so kids cannot pause, seek, or close the app while locked.

## Install (Homebrew)
```
brew tap italmassov/tap
brew install --cask blockableplayer
```

## Install (Manual)
1) Download the latest zip from:
   https://github.com/italmassov/blockable_player/releases
2) Unzip and move `BlockablePlayer.app` to `/Applications`.
3) Launch from Spotlight or Finder.

## Allow in macOS Security
If Gatekeeper blocks the app:
- Finder: right-click `BlockablePlayer.app` -> Open -> Open.
- Or System Settings -> Privacy & Security -> Open Anyway.
- Terminal option:
  `xattr -dr com.apple.quarantine /Applications/BlockablePlayer.app`

## Shortcuts (Unlocked)
- `Space`: play/pause
- `Left` / `Right`: seek -10s / +10s
- `Up` / `Down`: volume down/up
- `Cmd+O` / `Ctrl+O`: open file
- `Cmd+F` / `Ctrl+F`: full screen
- `Cmd+L`: lock/unlock

## Build (Local)
```
./scripts/get_libvlc.sh
swift build
./scripts/run_with_libvlc.sh
```

## Notes
- This project bundles libVLC for distribution (non-App-Store).
- App Store builds require an AVFoundation-only variant (no MKV).
