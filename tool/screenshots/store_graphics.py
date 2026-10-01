"""Renders the Play Store icon and feature graphic from assets/icons/icon.png.

Usage: python3 tool/screenshots/store_graphics.py  (needs Pillow and Noto Sans)
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
LOGO = ROOT / "assets/icons/icon.png"
OUT = ROOT / "fastlane/metadata/android/en-US/images"
FONT_DIR = Path("/usr/share/fonts/noto")

BACKGROUND = (11, 11, 11)
CARD = (20, 20, 20)
PINK = (255, 168, 234)
MUTED = (170, 170, 170)


def logo(size: int) -> Image.Image:
    return Image.open(LOGO).convert("RGBA").resize((size, size), Image.LANCZOS)


def icon() -> None:
    canvas = Image.new("RGB", (512, 512), CARD)
    mark = logo(360)
    canvas.paste(mark, (76, 76), mark)
    canvas.save(OUT / "icon.png", optimize=True)


def feature_graphic() -> None:
    canvas = Image.new("RGB", (1024, 500), BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    draw.rectangle((40, 40, 983, 459), fill=CARD, outline=(40, 40, 40), width=2)

    mark = logo(300)
    canvas.paste(mark, (80, 100), mark)

    title = ImageFont.truetype(str(FONT_DIR / "NotoSans-Black.ttf"), 60)
    tagline = ImageFont.truetype(str(FONT_DIR / "NotoSans-Medium.ttf"), 30)
    small = ImageFont.truetype(str(FONT_DIR / "NotoSans-Bold.ttf"), 22)

    x = 420
    draw.text((x, 150), "PLATEPAL", font=title, fill=(255, 255, 255))
    draw.text((x, 215), "TRACKER //", font=title, fill=(255, 255, 255))
    draw.text((x, 305), "Meals, macros & goals.", font=tagline, fill=PINK)
    draw.text((x, 350), "Private. Open source. Optional AI.", font=small, fill=MUTED)
    canvas.save(OUT / "featureGraphic.png", optimize=True)


if __name__ == "__main__":
    OUT.mkdir(parents=True, exist_ok=True)
    icon()
    feature_graphic()
    print(f"Wrote {OUT / 'icon.png'} and {OUT / 'featureGraphic.png'}")
