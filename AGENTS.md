# Repository Guidelines

## Project Structure & Module Organization
- This repository is currently empty (no source, tests, or assets committed yet).
- When adding code, keep a clear top-level layout such as `src/` for app code, `tests/` for automated tests, and `assets/` for static files. If you choose a different layout, document it here with examples.

## Build, Test, and Development Commands
- No build or test commands are defined yet.
- When you add tooling, list the exact commands here (for example: `npm run dev` to start a local server, `npm test` to run the test suite). Keep them runnable from the repo root.

## Coding Style & Naming Conventions
- Use consistent indentation (2 spaces for JS/TS, 4 spaces for Python, or document your choice).
- Prefer descriptive, kebab-case file names (for example: `video-player.ts`, `blocklist-loader.js`).
- If you add a formatter or linter (Prettier, ESLint, Black, etc.), document the config file location and how to run it (for example: `npm run lint`).

## Testing Guidelines
- Choose a framework appropriate to the stack (for example: Jest, Vitest, Pytest).
- Name tests clearly to reflect behavior (for example: `video-player.spec.ts`, `test_blocklist.py`).
- Document coverage expectations once you establish them.

## Commit & Pull Request Guidelines
- Git is initialized; keep commits focused and descriptive.
- Use conventional-style prefixes: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
- Pull requests should include a short summary, linked issue (if any), and screenshots for UI changes.

## Configuration & Security Notes
- Keep secrets out of the repo. Use `.env` files and document required keys in a `.env.example`.
- Document any local configuration steps (ports, API keys, platform requirements) when they are introduced.
