#!/usr/bin/env python3
"""storeart - render Play Store screenshots as tilted phone mockups.

A screenshot spec is plain JSON: background colours, one headline + subline
per screen, and where the raw 1080x1920 captures live. Rendering is pure
Pillow, deterministic, and needs no GPU, browser or emulator.

    ./storeart render specs/tracker.json
    ./storeart render specs/tracker.json --locale de-DE --only 1,3
    ./storeart sheet out/tracker/en-US -o out/tracker-en.png

Text uses Roboto, the font the Flutter apps actually ship with.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).resolve().parent
DEFAULT_OUT = HERE / "out"
ROOT = HERE  # repo root while rendering; set from the spec location

def _font_dir() -> Path:
    """Roboto ships with the Flutter SDK; use it instead of a host path."""
    env = os.environ.get("STOREART_FONTS")
    if env:
        return Path(env).expanduser()
    candidates = [
        Path("/home/lappes/toolchains/flutter/bin/cache/artifacts/material_fonts"),
        Path.home() / "toolchains/flutter/bin/cache/artifacts/material_fonts",
    ]
    flutter = shutil.which("flutter")
    if flutter:
        flutter_bin = Path(flutter).resolve()
        candidates.append(flutter_bin.parent / "cache/artifacts/material_fonts")
        candidates.append(flutter_bin.parent.parent
                          / "bin/cache/artifacts/material_fonts")
    for candidate in candidates:
        if (candidate / FONT_FILES["black"]).exists():
            return candidate
    return candidates[0]

SS = 2  # phone is drawn at 2x and sampled down by the perspective transform
CANVAS = (1080, 1920)

FONT_FILES = {
    "black": "Roboto-Black.ttf",
    "bold": "Roboto-Bold.ttf",
    "medium": "Roboto-Medium.ttf",
    "regular": "Roboto-Regular.ttf",
    "light": "Roboto-Light.ttf",
}

_font_cache: dict[tuple[str, int], ImageFont.FreeTypeFont] = {}


def font(weight: str, size: int) -> ImageFont.FreeTypeFont:
    key = (weight, size)
    if key not in _font_cache:
        path = _font_dir() / FONT_FILES[weight]
        if not path.exists():
            sys.exit(f"missing font {path}")
        _font_cache[key] = ImageFont.truetype(str(path), size)
    return _font_cache[key]


# ---------------------------------------------------------------- colour --

def rgb(value: str) -> tuple[int, int, int]:
    value = value.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))  # type: ignore[return-value]


def rgba(value: str, alpha: int = 255) -> tuple[int, int, int, int]:
    return (*rgb(value), alpha)


def lerp(a: tuple[int, int, int], b: tuple[int, int, int], t: float):
    return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))


def vgradient(size, stops, horizontal: bool = False) -> Image.Image:
    """Multi-stop linear gradient. stops = [(position 0..1, '#rrggbb'), ...]."""
    length = size[0] if horizontal else size[1]
    strip = Image.new("RGB", (length, 1) if horizontal else (1, length))
    pixels = strip.load()
    stops = sorted(((pos, rgb(col)) for pos, col in stops), key=lambda s: s[0])
    for i in range(length):
        t = i / max(1, length - 1)
        left = stops[0]
        right = stops[-1]
        for j in range(len(stops) - 1):
            if stops[j][0] <= t <= stops[j + 1][0]:
                left, right = stops[j], stops[j + 1]
                break
        span = right[0] - left[0]
        f = 0.0 if span <= 0 else (t - left[0]) / span
        col = lerp(left[1], right[1], f)
        if horizontal:
            pixels[i, 0] = col
        else:
            pixels[0, i] = col
    return strip.resize(size, Image.Resampling.BILINEAR)


def radial_alpha(radius: int, strength: float, power: float = 2.0) -> Image.Image:
    """Soft circular falloff mask, white = opaque at the centre."""
    base = Image.radial_gradient("L").resize((radius * 2, radius * 2))
    return base.point(
        lambda v: int(255 * strength * max(0.0, 1.0 - v / 255.0) ** power)
    )


def add_glow(canvas: Image.Image, center, radius, colour, strength, power=2.0):
    mask = radial_alpha(radius, strength, power)
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    patch = Image.new("RGBA", mask.size, rgba(colour))
    patch.putalpha(mask)
    layer.alpha_composite(patch, (int(center[0]) - radius, int(center[1]) - radius))
    return Image.alpha_composite(canvas, layer)


def add_grain(canvas: Image.Image, amount: float = 0.022) -> Image.Image:
    noise = Image.effect_noise(canvas.size, 26).convert("L")
    white = Image.new("RGB", canvas.size, (255, 255, 255))
    return Image.composite(white, canvas, noise.point(lambda v: int(v * amount)))


def add_dots(canvas: Image.Image, colour: str, alpha: int = 9,
             spacing: int = 54, radius: int = 2) -> Image.Image:
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    for y in range(spacing // 2, canvas.height, spacing):
        for x in range(spacing // 2, canvas.width, spacing):
            draw.ellipse((x - radius, y - radius, x + radius, y + radius),
                         fill=rgba(colour, alpha))
    return Image.alpha_composite(canvas, layer)


def vignette(canvas: Image.Image, strength: float = 0.30) -> Image.Image:
    w, h = canvas.size
    mask = Image.radial_gradient("L").resize((w, h)).point(
        lambda v: int(255 * strength * (v / 255.0) ** 1.6)
    )
    dark = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    dark.putalpha(mask)
    return Image.alpha_composite(canvas.convert("RGBA"), dark).convert("RGB")


# ----------------------------------------------------------------- phone --

def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size[0] - 1, size[1] - 1), radius=radius, fill=255
    )
    return mask


def asset_shape(width: int, src_w: int = 1080, src_h: int = 1920):
    """Pixel size the phone asset will have; used before it is rendered."""
    w = width * SS
    bezel = max(4, round(w * 0.0225))
    screen_w = w - 2 * bezel
    screen_h = round(screen_w * src_h / src_w)
    h = screen_h + 2 * bezel
    pad = round(w * 0.014) + 4  # room for the side buttons
    return w + 2 * pad, h + 2 * pad


def phone_asset(screenshot: Image.Image, width: int, theme: dict) -> Image.Image:
    """A phone body + screen with transparent surroundings, at SS scale."""
    s = SS
    w = width * s
    bezel = max(4, round(w * 0.0225))
    screen_w = w - 2 * bezel
    screen_h = round(screen_w * screenshot.height / screenshot.width)
    h = screen_h + 2 * bezel
    pad = round(w * 0.014) + 4  # room for the side buttons

    outer_r = round(w * 0.083)
    screen_r = round(screen_w * 0.072)

    canvas = Image.new("RGBA", (w + 2 * pad, h + 2 * pad), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)

    # Side buttons sit under the body silhouette.
    button = rgba(theme["frame"][1])
    for side, top_f, bot_f, thick in (
        (-1, 0.235, 0.335, 0.010),
        (-1, 0.355, 0.455, 0.010),
        (1, 0.285, 0.400, 0.010),
    ):
        x_edge = pad if side < 0 else pad + w
        bw = round(w * thick)
        y0 = pad + round(h * top_f)
        y1 = pad + round(h * bot_f)
        x0 = x_edge - bw if side < 0 else x_edge
        draw.rounded_rectangle((x0, y0, x0 + bw * 2, y1), radius=bw, fill=button,
                               outline=(0, 0, 0, 90), width=2)

    frame = vgradient(
        (w, h),
        [(0.0, theme["frame"][0]), (0.45, theme["frame"][1]),
         (0.80, theme["frame"][0]), (1.0, theme["frame"][1])],
    ).convert("RGBA")
    sheen = vgradient(
        (w, h),
        [(0.0, "#ffffff"), (0.16, "#ffffff"), (0.5, "#ffffff"),
         (0.84, "#000000"), (1.0, "#000000")],
        horizontal=True,
    ).convert("RGBA")
    sheen.putalpha(36)
    frame = Image.alpha_composite(frame, sheen)

    # Metal rim: bright hairline on the edge, dark line just inside. The mask
    # goes on last, otherwise the hairline bleeds outside the silhouette and
    # reads as a pale outline next to the phone.
    rim = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    rd = ImageDraw.Draw(rim)
    rd.rounded_rectangle((2, 2, w - 3, h - 3), radius=outer_r - 1, outline=(0, 0, 0, 105), width=2)
    frame = Image.alpha_composite(frame, rim)
    frame.putalpha(rounded_mask((w, h), outer_r))
    canvas.alpha_composite(frame, (pad, pad))

    # Recessed screen: dark inner shadow then the capture.
    sx, sy = pad + bezel, pad + bezel
    shadow = Image.new("RGBA", (screen_w + 40, screen_h + 40), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (20, 20, 20 + screen_w - 1, 20 + screen_h - 1), radius=screen_r,
        fill=(0, 0, 0, 190),
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(10))
    canvas.alpha_composite(shadow, (sx - 20, sy - 20))

    screen = screenshot.convert("RGB").resize((screen_w, screen_h), Image.Resampling.LANCZOS)
    screen = screen.convert("RGBA")
    screen.putalpha(rounded_mask((screen_w, screen_h), screen_r))

    # Glass: a soft diagonal sheen plus a narrow specular streak on the left.
    glass = Image.new("RGBA", (screen_w, screen_h), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glass)
    gd.polygon(
        [(0, 0), (round(screen_w * 0.92), 0), (0, round(screen_h * 0.52))],
        fill=(255, 255, 255, 14),
    )
    gd.rounded_rectangle(
        (1, 1, screen_w - 2, screen_h - 2), radius=screen_r,
        outline=(255, 255, 255, 34), width=2,
    )
    glass = glass.filter(ImageFilter.GaussianBlur(18))
    screen = Image.alpha_composite(screen, glass)
    screen.putalpha(rounded_mask((screen_w, screen_h), screen_r))
    canvas.alpha_composite(screen, (sx, sy))

    # Punch-hole camera, centred in the status bar.
    hole_r = max(3, round(screen_w * 0.021))
    hx, hy = sx + screen_w // 2, sy + round(screen_w * 0.052)
    hd = ImageDraw.Draw(canvas)
    hd.ellipse((hx - hole_r - 3, hy - hole_r - 3, hx + hole_r + 3, hy + hole_r + 3),
               fill=(0, 0, 0, 70))
    hd.ellipse((hx - hole_r, hy - hole_r, hx + hole_r, hy + hole_r), fill=(8, 8, 10, 255))
    hd.ellipse((hx - hole_r + 2, hy - hole_r + 2, hx - hole_r // 3, hy - hole_r // 3),
               fill=(40, 56, 78, 255))
    hd.ellipse((hx - hole_r, hy - hole_r, hx + hole_r, hy + hole_r),
               outline=(255, 255, 255, 26), width=1)
    return canvas


def solve(a: list[list[float]], b: list[float]) -> list[float]:
    """Gaussian elimination with partial pivoting (8x8 in, 8 out)."""
    n = len(b)
    m = [row[:] + [b[i]] for i, row in enumerate(a)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(m[r][col]))
        if abs(m[pivot][col]) < 1e-12:
            raise ValueError("degenerate perspective")
        m[col], m[pivot] = m[pivot], m[col]
        inv = 1.0 / m[col][col]
        m[col] = [v * inv for v in m[col]]
        for r in range(n):
            if r == col:
                continue
            factor = m[r][col]
            if factor:
                m[r] = [v - factor * w for v, w in zip(m[r], m[col])]
    return [m[r][n] for r in range(n)]


def perspective_coeffs(dst, src) -> tuple[float, ...]:
    """Pillow PERSPECTIVE coefficients mapping destination pixels to source."""
    rows, values = [], []
    for (x, y), (u, v) in zip(dst, src):
        rows.append([x, y, 1, 0, 0, 0, -x * u, -y * u])
        values.append(u)
        rows.append([0, 0, 0, x, y, 1, -x * v, -y * v])
        values.append(v)
    return tuple(solve(rows, values))


def project_quad(w: float, h: float, roll: float, yaw: float, pitch: float,
                 distance: float = 2.6) -> list[tuple[float, float]]:
    """Rotate the phone plane in 3D and project it with a pinhole camera.

    roll  = in-plane rotation (clockwise degrees)
    yaw   = turn around the vertical axis (one side moves towards the viewer)
    pitch = tip around the horizontal axis (top away/towards the viewer)
    """
    d = max(1.2, distance) * w
    ax, ay, az = (math.radians(v) for v in (pitch, yaw, roll))
    cx_, sx_ = math.cos(ax), math.sin(ax)
    cy_, sy_ = math.cos(ay), math.sin(ay)
    cz_, sz_ = math.cos(az), math.sin(az)
    out = []
    for x, y in ((-w / 2, -h / 2), (w / 2, -h / 2), (w / 2, h / 2), (-w / 2, h / 2)):
        x1 = x * cy_
        z1 = -x * sy_
        y2 = y * cx_ - z1 * sx_
        z2 = y * sx_ + z1 * cx_
        x3 = x1 * cz_ - y2 * sz_
        y3 = x1 * sz_ + y2 * cz_
        scale = d / (d + z2)
        out.append((x3 * scale, y3 * scale))
    return out


def phone_geometry(asset_w: int, asset_h: int, cfg: dict) -> dict:
    w, h = asset_w / SS, asset_h / SS
    pts = project_quad(w, h, cfg.get("roll", 0.0), cfg.get("yaw", 0.0),
                       cfg.get("pitch", 0.0), cfg.get("distance", 2.6))
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    return {"pts": pts, "width": max(xs) - min(xs), "height": max(ys) - min(ys),
            "min_x": min(xs), "max_x": max(xs), "min_y": min(ys), "max_y": max(ys)}


def place_phone(canvas: Image.Image, asset: Image.Image, geom: dict,
                cx: float, top: float, theme: dict) -> tuple[int, int, int, int]:
    dx = cx - (geom["min_x"] + geom["max_x"]) / 2
    dy = top - geom["min_y"]
    pts = [(x + dx, y + dy) for x, y in geom["pts"]]

    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    x0, y0 = math.floor(min(xs)), math.floor(min(ys))
    x1, y1 = math.ceil(max(xs)), math.ceil(max(ys))
    size = (x1 - x0, y1 - y0)

    src = [(0, 0), (asset.width, 0), (asset.width, asset.height), (0, asset.height)]
    dst = [(p[0] - x0, p[1] - y0) for p in pts]
    coeffs = perspective_coeffs(dst, src)

    def warp(img):
        return img.transform(size, Image.Transform.PERSPECTIVE, coeffs,
                             Image.Resampling.BICUBIC)

    # One warp of the silhouette feeds the glow and both shadow layers.
    warped_mask = warp(asset.getchannel("A"))

    def soft(mask, radius):
        """Blur away from the bounding box, so the falloff never gets cut."""
        pad = radius * 3
        padded = Image.new("L", (mask.width + 2 * pad, mask.height + 2 * pad), 0)
        padded.paste(mask, (pad, pad))
        return padded.filter(ImageFilter.GaussianBlur(radius)), pad

    if theme.get("phone_glow"):
        glow, pad = soft(warped_mask, 58)
        glow = glow.point(lambda v: int(v * 0.48))
        layer = Image.new("RGBA", glow.size, rgba(theme.get("glow", "#ffffff")))
        layer.putalpha(glow)
        canvas.alpha_composite(layer, (x0 - pad, y0 - pad))

    # Ambient shadow, then a tighter contact shadow: two layers read as depth.
    shadow_rgb = rgba(theme.get("shadow_color", "#000000"))
    for blur, opacity, sdx, sdy in ((52, 0.26, 26, 48), (14, 0.30, 12, 20)):
        shadow, pad = soft(warped_mask, blur)
        shadow = shadow.point(lambda v: int(v * opacity * theme.get("shadow", 1.0)))
        layer = Image.new("RGBA", shadow.size, shadow_rgb)
        layer.putalpha(shadow)
        canvas.alpha_composite(layer, (x0 + sdx - pad, y0 + sdy - pad))

    canvas.alpha_composite(warp(asset), (x0, y0))
    return (x0, y0, x1, y1)


# ------------------------------------------------------------------ text --

def parse_line(line: str) -> list[tuple[str, bool]]:
    """'Find your [table.]' -> [('Find your ', False), ('table.', True)]."""
    runs, buf, accent = [], "", False
    for ch in line:
        if ch == "[":
            if buf:
                runs.append((buf, accent))
            buf, accent = "", True
        elif ch == "]":
            if buf:
                runs.append((buf, accent))
            buf, accent = "", False
        else:
            buf += ch
    if buf:
        runs.append((buf, accent))
    return runs


def runs_width(draw, runs, fnt, tracking=0.0) -> float:
    width = 0.0
    for text, _ in runs:
        if tracking:
            width += sum(draw.textlength(c, font=fnt) for c in text)
            width += tracking * max(0, len(text) - 1)
        else:
            width += draw.textlength(text, font=fnt)
    return width


def draw_runs(draw, x, baseline, runs, fnt, colours, tracking=0.0):
    for text, accent in runs:
        colour = colours["accent"] if accent else colours["ink"]
        if tracking:
            cx = x
            for ch in text:
                draw.text((cx, baseline), ch, font=fnt, fill=colour, anchor="ls")
                cx += draw.textlength(ch, font=fnt) + tracking
            x = cx
        else:
            draw.text((x, baseline), text, font=fnt, fill=colour, anchor="ls")
            x += draw.textlength(text, font=fnt)


def wrap(draw, text, fnt, max_width):
    words = text.split()
    lines, current = [], ""
    for word in words:
        trial = f"{current} {word}".strip()
        if current and draw.textlength(trial, font=fnt) > max_width:
            lines.append(current)
            current = word
        else:
            current = trial
    if current:
        lines.append(current)
    return lines


def text_block(spec: dict, screen: dict, size: int) -> dict:
    eyebrow = screen.get("eyebrow", spec.get("eyebrow", ""))
    lines = screen["headline"].split("\n")
    sub = screen.get("sub")
    line_h = round(size * 1.06)
    return {
        "eyebrow": eyebrow,
        "lines": lines,
        "sub": sub,
        "line_h": line_h,
        "headline_h": line_h * len(lines),
        "eyebrow_h": 34 if eyebrow else 0,
        "gap": 30 if eyebrow else 0,
        "sub_h": 44 if sub else 0,
        "sub_gap": 22 if sub else 0,
    }


def block_height(block: dict) -> int:
    return (block["eyebrow_h"] + block["gap"] + block["headline_h"]
            + block["sub_gap"] + block["sub_h"])


def fit_size(draw, lines, size, avail_height, canvas_w, tracking=-1.0,
             max_width=None, weight="black"):
    """Largest size at which the headline fits the available box."""
    max_width = max_width or (canvas_w - 2 * 88)
    while size > 52:
        fnt = font(weight, size)
        line_h = round(size * 1.06)
        widest = max(runs_width(draw, parse_line(l), fnt, tracking) for l in lines)
        if widest <= max_width and line_h * len(lines) <= avail_height:
            break
        size -= 2
    return size


def draw_text(draw, spec: dict, screen: dict, size: int, colours: dict,
              canvas_w: int) -> int:
    cfg = screen.get("layout", {})
    placement = cfg.get("placement", "top")
    align = cfg.get("align", "center")
    block = text_block(spec, screen, size)
    layout = spec.get("layout", {})
    if placement == "bottom":
        top = layout.get("text_anchor", 1834) - block_height(block)
    else:
        top = layout.get("text_top", 96)

    def x_for(width):
        return 88 if align == "left" else (canvas_w - width) / 2

    y = top
    if block["eyebrow"]:
        fnt = font("medium", 26)
        tracking = 7.0
        x = x_for(runs_width(draw, [(block["eyebrow"], False)], fnt, tracking))
        for ch in block["eyebrow"]:
            draw.text((x, y), ch, font=fnt, fill=colours["accent"], anchor="la")
            x += draw.textlength(ch, font=fnt) + tracking
        y += block["eyebrow_h"] + block["gap"]

    fnt = font("black", size)
    ascent = fnt.getmetrics()[0]
    for i, line in enumerate(block["lines"]):
        runs = parse_line(line)
        draw_runs(draw, x_for(runs_width(draw, runs, fnt, -1.0)),
                  y + i * block["line_h"] + ascent, runs, fnt, colours, -1.0)
    y += block["headline_h"] + block["sub_gap"]

    if block["sub"]:
        sub_fnt = font("regular", 37)
        if draw.textlength(block["sub"], font=sub_fnt) > canvas_w - 2 * 88:
            sub_fnt = font("regular", 32)
        if draw.textlength(block["sub"], font=sub_fnt) > canvas_w - 2 * 88:
            parts = wrap(draw, block["sub"], sub_fnt, canvas_w - 2 * 88)
            for i, part in enumerate(parts):
                draw.text((x_for(draw.textlength(part, font=sub_fnt)), y + i * 42),
                          part, font=sub_fnt, fill=colours["muted"], anchor="la")
        else:
            draw.text((x_for(draw.textlength(block["sub"], font=sub_fnt)), y),
                      block["sub"], font=sub_fnt, fill=colours["muted"], anchor="la")
    return top + block_height(block)


# ------------------------------------------------------------- statement --

def _icon(path: Path, size: int) -> Image.Image:
    icon = Image.open(path).convert("RGBA")
    side = min(icon.size)
    icon = icon.crop(((icon.width - side) // 2, (icon.height - side) // 2,
                      (icon.width + side) // 2, (icon.height + side) // 2))
    return icon.resize((size, size), Image.Resampling.LANCZOS)


def _statement_text(draw, spec, screen, size, colours):
    """Draw the headline block and return the y below it."""
    block = text_block(spec, screen, size)
    layout = {**spec.get("layout", {}), **screen.get("layout", {})}
    top = layout.get("text_top", 96)
    y = top
    if block["eyebrow"]:
        fnt = font("medium", 26)
        tracking = 7.0
        text = block["eyebrow"]
        width = runs_width(draw, [(text, False)], fnt, tracking)
        x = (CANVAS[0] - width) / 2
        for ch in text:
            draw.text((x, y), ch, font=fnt, fill=colours["accent"], anchor="la")
            x += draw.textlength(ch, font=fnt) + tracking
        y += block["eyebrow_h"] + block["gap"]

    fnt = font("black", size)
    ascent = fnt.getmetrics()[0]
    for i, line in enumerate(block["lines"]):
        runs = parse_line(line)
        width = runs_width(draw, runs, fnt, -1.0)
        draw_runs(draw, (CANVAS[0] - width) / 2,
                  y + i * block["line_h"] + ascent, runs, fnt, colours, -1.0)
    y += block["headline_h"] + block["sub_gap"]

    if block["sub"]:
        sub_fnt = font("regular", 38)
        if draw.textlength(block["sub"], font=sub_fnt) > CANVAS[0] - 2 * 88:
            sub_fnt = font("regular", 33)
        width = draw.textlength(block["sub"], font=sub_fnt)
        draw.text(((CANVAS[0] - width) / 2, y), block["sub"], font=sub_fnt,
                  fill=colours["muted"], anchor="la")
        y += block["sub_h"]
    return y


def render_statement(spec: dict, screen: dict, locale: str, size: int) -> Image.Image:
    theme = spec["theme"]
    w, h = CANVAS
    canvas = vgradient((w, h), theme["bg"]).convert("RGBA")
    if theme.get("phone_glow"):
        canvas = add_glow(canvas, (w // 2, 940), 940, theme["glow"], 0.26, 2.6)
    else:
        canvas = add_glow(canvas, (w // 2, 900), 980, "#ffffff", 0.35, 2.8)
    canvas = add_glow(canvas, (230, 220), 640,
                      theme.get("glow_top", theme["glow"]), 0.14, 2.2)
    if theme.get("dots"):
        canvas = add_dots(canvas, theme["dots"], theme.get("dot_alpha", 9))

    draw = ImageDraw.Draw(canvas)
    colours = {"ink": rgb(theme["ink"]), "accent": rgb(theme["accent"]),
               "muted": rgb(theme["muted"])}
    y = _statement_text(draw, spec, screen, size, colours)

    icon_rel = screen.get("icon", spec.get("icon"))
    icon_size = int(screen.get("icon_size", 176))
    bullets = screen.get("bullets") or []
    icon_path = resolve_path(icon_rel, locale) if icon_rel else None
    if icon_path and icon_path.exists():
        icon_y = int(y + 56)
        mark = _icon(icon_path, icon_size)
        # glow behind the mark, then a soft shadow under it
        if theme.get("phone_glow"):
            canvas = add_glow(canvas, (w // 2, icon_y + icon_size // 2),
                              icon_size + 150, theme["glow"], 0.22, 2.2)
        else:
            canvas = add_glow(canvas, (w // 2, icon_y + icon_size // 2),
                              icon_size + 170, "#ffffff", 0.30, 2.4)
        shadow = Image.new("RGBA", (icon_size + 100, icon_size + 100), (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle(
            (50, 54, 50 + icon_size, 54 + icon_size), radius=38,
            fill=(0, 0, 0, 120))
        shadow = shadow.filter(ImageFilter.GaussianBlur(22))
        canvas.alpha_composite(shadow, ((w - icon_size) // 2 - 50, icon_y - 50))
        mask = rounded_mask((icon_size, icon_size), 38)
        mark.putalpha(mask)
        canvas.alpha_composite(mark, ((w - icon_size) // 2, icon_y))
        draw = ImageDraw.Draw(canvas)
        y = icon_y + icon_size

    if bullets:
        bullet_fnt = font("bold", 38)
        gap = 86
        widths = [draw.textlength(text, font=bullet_fnt) for text in bullets]
        block_w = int(max(widths)) + 74
        x0 = (w - block_w) // 2
        y += 66
        for i, (text, width) in enumerate(zip(bullets, widths)):
            cy = y + i * gap
            cx = x0 + 22
            draw.ellipse((cx - 22, cy - 22, cx + 22, cy + 22),
                         fill=rgb(theme["accent"]))
            draw.line((cx - 10, cy, cx - 2, cy + 9, cx + 12, cy - 10),
                      fill=rgb(theme["bg"][0][1]), width=5, joint="curve")
            draw.text((x0 + 66, cy - 24), text, font=bullet_fnt,
                      fill=colours["ink"], anchor="la")

    footer = screen.get("footer", spec.get("footer"))
    if footer:
        footer_fnt = font("medium", 26)
        width = draw.textlength(footer, font=footer_fnt)
        draw.text(((w - width) / 2, 1774), footer, font=footer_fnt,
                  fill=colours["muted"], anchor="la")

    canvas = add_grain(canvas.convert("RGB"), 0.018)
    if theme.get("vignette"):
        canvas = vignette(canvas, theme["vignette"])
    return canvas


# ---------------------------------------------------------------- render --

def phone_cfg(spec: dict, screen: dict) -> dict:
    placement = screen.get("layout", {}).get("placement", "top")
    preset = spec.get("presets", {}).get(placement, {}).get("phone", {})
    return {**spec.get("phone", {}), **preset, **screen.get("phone", {})}


def resolve_layout(spec: dict, screen: dict, size: int, src_size=(1080, 1920)):
    """Phone placement after respecting the text block and the canvas edge."""
    cfg = phone_cfg(spec, screen)
    block = text_block(spec, screen, size)
    layout = spec.get("layout", {})
    placement = screen.get("layout", {}).get("placement", "top")
    width = int(cfg.get("width", 740))
    top = float(cfg.get("top", 512))
    if placement == "top":
        top = max(top, layout.get("text_top", 96) + block_height(block) + 44)
        limit = 1858.0
    else:
        top = min(top, layout.get("text_anchor", 1832) - block_height(block) - 500)
        limit = layout.get("text_anchor", 1832) - block_height(block) - 44

    geom = phone_geometry(*asset_shape(width, *src_size), cfg)
    slack = limit - top
    if geom["height"] > slack:  # the projection is scale invariant, so one ratio is enough
        width = max(400, int(width * slack / geom["height"]))
        geom = phone_geometry(*asset_shape(width, *src_size), cfg)
    cfg = {**cfg, "width": width}
    return cfg, geom, top, CANVAS[0] / 2 + cfg.get("dx", 0)


def render(spec: dict, screen: dict, locale: str, source: Path,
           headline_size: int) -> Image.Image:
    theme = spec["theme"]
    w, h = CANVAS
    image = Image.open(source)
    cfg, geom, top, cx = resolve_layout(spec, screen, headline_size, image.size)
    asset = phone_asset(image, cfg["width"], theme)

    canvas = vgradient((w, h), theme["bg"]).convert("RGBA")
    glow_y = top + geom["height"] * 0.52
    if theme.get("phone_glow"):
        canvas = add_glow(canvas, (w // 2, glow_y), 900, theme["glow"], 0.30, 2.6)
    else:
        canvas = add_glow(canvas, (w // 2, glow_y - 100), 1000, "#ffffff", 0.32, 2.8)
    canvas = add_glow(canvas, (230, 220), 640, theme.get("glow_top", theme["glow"]), 0.14, 2.2)
    if theme.get("dots"):
        canvas = add_dots(canvas, theme["dots"], theme.get("dot_alpha", 9))

    place_phone(canvas, asset, geom, cx, top, theme)

    draw = ImageDraw.Draw(canvas)
    colours = {"ink": rgb(theme["ink"]), "accent": rgb(theme["accent"]),
               "muted": rgb(theme["muted"])}
    draw_text(draw, spec, screen, headline_size, colours, w)

    canvas = add_grain(canvas.convert("RGB"), 0.018)
    if theme.get("vignette"):
        canvas = vignette(canvas, theme["vignette"])
    return canvas


def resolve_path(template: str, locale: str) -> Path:
    path = Path(template.format(locale=locale)).expanduser()
    if not path.is_absolute():
        path = ROOT / path
    return path


def cmd_render(args):
    global ROOT
    spec_path = Path(args.spec).expanduser()
    if len(spec_path.resolve().parents) >= 3:
        ROOT = spec_path.resolve().parents[2]
    spec = json.loads(spec_path.read_text())
    out_root = Path(args.out).expanduser() if args.out else DEFAULT_OUT / spec["name"]
    only = None
    if args.only:
        only = {x.strip() for x in args.only.split(",")}

    locales = args.locale or list(spec["locales"])
    count = 0
    for locale in locales:
        loc = spec["locales"][locale]
        if args.source_root:
            source_root = Path(args.source_root).expanduser()
            if not source_root.is_absolute():
                source_root = Path.cwd() / source_root
        else:
            source_root = resolve_path(loc.get("source", spec["source"]), locale)
        out_dir = out_root / locale
        out_dir.mkdir(parents=True, exist_ok=True)

        # One headline size for the whole locale: a carousel must not resize
        # the type from screen to screen. Each screen only limits how big it
        # may get; the smallest fit wins.
        probe = ImageDraw.Draw(Image.new("RGB", (4, 4)))
        layout = spec.get("layout", {})
        text_top = layout.get("text_top", 96)
        anchor = layout.get("text_anchor", 1834)
        start_size = spec.get("type", {}).get("headline", 104)
        sizes = []
        for sc in loc["screens"]:
            block = text_block(spec, sc, start_size)
            if sc.get("statement"):
                sizes.append(fit_size(probe, block["lines"], start_size, 280,
                                      CANVAS[0], -1.0, 880))
                continue
            src_path = source_root / sc["src"]
            sw, sh = Image.open(src_path).size if src_path.exists() else (1080, 1920)
            cfg, geom, ptop, _ = resolve_layout(spec, sc, start_size, (sw, sh))
            if sc.get("layout", {}).get("placement", "top") == "bottom":
                phone_bottom = ptop + geom["height"]
                avail = (anchor - block["sub_h"] - block["sub_gap"]
                         - block["eyebrow_h"] - block["gap"]) - (phone_bottom + 44)
            else:
                avail = layout.get("headline_bottom", 402) - (
                    text_top + block["eyebrow_h"] + block["gap"])
            sizes.append(fit_size(probe, block["lines"], start_size, max(avail, 60),
                                  CANVAS[0], -1.0, None))
        headline_size = min(sizes)
        print(f"  {locale}: headline {headline_size}px")

        for i, screen in enumerate(loc["screens"], start=1):
            label = screen.get("src") or screen.get("out")
            if only and str(i) not in only and label not in only:
                continue
            if screen.get("statement"):
                image = render_statement(spec, screen, locale, headline_size)
            else:
                src = source_root / screen["src"]
                if not src.exists():
                    print(f"  missing {src}", file=sys.stderr)
                    continue
                image = render(spec, screen, locale, src, headline_size)
            dest = out_dir / screen.get("out", screen.get("src"))
            image.save(dest)
            count += 1
            print(f"  {dest.relative_to(HERE) if HERE in dest.parents else dest}")
    print(f"{count} image(s) -> {out_root}")


def cmd_sheet(args):
    directory = Path(args.directory).expanduser()
    files = sorted(directory.glob("*.png"))
    if not files:
        sys.exit(f"no PNGs in {directory}")
    cols = args.cols
    thumb_w = args.width
    thumb_h = round(thumb_w * 1920 / 1080)
    gap, label_h = 24, 0
    rows = math.ceil(len(files) / cols)
    sheet = Image.new(
        "RGB",
        (cols * thumb_w + (cols + 1) * gap, rows * thumb_h + (rows + 1) * gap),
        (24, 24, 27),
    )
    for i, path in enumerate(files):
        img = Image.open(path).convert("RGB").resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        x = gap + (i % cols) * (thumb_w + gap)
        y = gap + (i // cols) * (thumb_h + gap)
        sheet.paste(img, (x, y))
    out = Path(args.output).expanduser()
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(out)


def cmd_publish(args):
    global ROOT
    spec_path = Path(args.spec).expanduser()
    if len(spec_path.resolve().parents) >= 3:
        ROOT = spec_path.resolve().parents[2]
    spec = json.loads(spec_path.read_text())
    out_root = Path(args.out).expanduser() if args.out else DEFAULT_OUT / spec["name"]
    locales = args.locale or list(spec["locales"])
    writes = []
    for locale in locales:
        if "dest" not in spec:
            sys.exit("spec has no \"dest\" - add one to publish")
        dest_root = resolve_path(spec["dest"], locale)
        source_root = resolve_path(spec["locales"][locale].get("source", spec["source"]), locale)
        if dest_root.resolve() == source_root.resolve():
            sys.exit(f"refusing to overwrite the raw captures in {source_root}")
        for screen in spec["locales"][locale]["screens"]:
            name = screen.get("out", screen.get("src"))
            src = out_root / locale / name
            if not src.exists():
                sys.exit(f"missing render {src}; run render first")
            writes.append((src, dest_root / name))

    for src, dst in writes:
        print(f"{'write' if args.write else 'would write'} {dst}")
    if not args.write:
        print(f"{len(writes)} file(s); pass --write to copy")
        return
    for src, dst in writes:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
    print(f"published {len(writes)} file(s)")


def cmd_check(args):
    global ROOT
    spec_path = Path(args.spec).expanduser()
    if len(spec_path.resolve().parents) >= 3:
        ROOT = spec_path.resolve().parents[2]
    spec = json.loads(spec_path.read_text())
    for locale, loc in spec["locales"].items():
        root = resolve_path(loc.get("source", spec["source"]), locale)
        print(f"{locale}: {root}  exists={root.exists()}")
        for screen in loc["screens"]:
            if screen.get("statement"):
                print(f"  skip {screen.get('out')} (statement)")
                continue
            ok = (root / screen["src"]).exists()
            print(f"  {'ok ' if ok else 'MISSING'} {screen['src']}")


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)

    p = sub.add_parser("render", help="render a spec")
    p.add_argument("spec")
    p.add_argument("--locale", action="append", help="locale (repeatable)")
    p.add_argument("--only", help="screen numbers or filenames, comma separated")
    p.add_argument("--out", help="output root")
    p.add_argument("--source-root", help="override the raw capture directory")
    p.set_defaults(func=cmd_render)

    p = sub.add_parser("sheet", help="contact sheet from a rendered directory")
    p.add_argument("directory")
    p.add_argument("-o", "--output", default=str(DEFAULT_OUT / "sheet.png"))
    p.add_argument("--cols", type=int, default=3)
    p.add_argument("--width", type=int, default=360)
    p.set_defaults(func=cmd_sheet)

    p = sub.add_parser("publish", help="copy rendered images into the app repo")
    p.add_argument("spec")
    p.add_argument("--locale", action="append", help="locale (repeatable)")
    p.add_argument("--out", help="render root")
    p.add_argument("--write", action="store_true", help="actually copy (default: dry run)")
    p.set_defaults(func=cmd_publish)

    p = sub.add_parser("check", help="verify source screenshots exist")
    p.add_argument("spec")
    p.set_defaults(func=cmd_check)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
