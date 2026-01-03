# Distribution (Homebrew Cask)

This project ships a GUI app, so a Homebrew **cask** is the recommended path.

## Package the app
1) Build and bundle libVLC:
   - `./scripts/package_cask.sh`
2) Upload `dist/BlockablePlayer.zip` to a public URL.
3) Note the SHA256 printed by the script.

Optional signing:
- Provide a Developer ID identity:
  - `SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)" ./scripts/package_cask.sh`

## Create a tap + cask
1) Create a new repo for your tap (e.g., `homebrew-tap`) with a `Casks/` folder.
2) Copy `Casks/blockableplayer.rb` into the tap.
3) Replace placeholders:
   - `__URL__` with your zip URL
   - `__SHA256__` with the printed hash
   - `__HOMEPAGE__` with your project page
4) Commit and push your tap repo.

## Install via Homebrew
```bash
brew tap yourname/tap
brew install --cask blockableplayer
```

Notes:
- This cask bundles libVLC and plugins into the app bundle, so it does not depend on VLC.app at runtime.
