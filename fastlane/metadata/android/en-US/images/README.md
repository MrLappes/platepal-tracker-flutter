# Store image assets

- `icon.png`: 512 x 512 px store icon.
- `featureGraphic.png`: 1024 x 500 px feature graphic.
- `phoneScreenshots/N_*.png`: 1080 x 1920 phone screenshots in display order.

Regenerate the icon and feature graphic with `python3 tool/screenshots/store_graphics.py`.
Regenerate the screenshots from demo data on a 1080 x 1920 emulator with
`bash tool/screenshots/capture_store_screenshots.sh en` (see `tool/screenshots/README.md`).
Never capture screenshots that contain personal data or API keys.
