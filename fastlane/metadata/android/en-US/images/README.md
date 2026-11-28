# Store image assets

- `icon.png`: 512 x 512 px store icon.
- `featureGraphic.png`: 1024 x 500 px feature graphic.
- `phoneScreenshots/N_*.png`: 1080 x 1920 phone mockups in display order.

Regenerate the icon and feature graphic with `python3 tool/screenshots/store_graphics.py`.

The screenshots are captured on a 1080 x 2400 Pixel-7 emulator and rendered by
`tool/screenshots/render_store.py` from `tool/screenshots/spec.json`:

```bash
python3 tool/screenshots/render_store.py render tool/screenshots/spec.json
python3 tool/screenshots/render_store.py publish tool/screenshots/spec.json --write
```

The release workflow does this automatically after installing the debug build
and pushing the demo data. Never capture screenshots that contain personal data
or API keys.
