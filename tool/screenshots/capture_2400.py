#!/usr/bin/env python3
"""Capture the six store screens on a 1080x2400 emulator.

Navigation is by fixed coordinates: the top of the UI keeps its pixel
positions at the same density, only the bottom navigation moves down.
Every step is screenshotted, so a missed tap is visible in the artifacts.

Usage: capture_2400.py <out-dir>
"""

import subprocess
import sys
import time
from pathlib import Path

OUT = Path(sys.argv[1] if len(sys.argv) > 1 else "shots")
OUT.mkdir(parents=True, exist_ok=True)
NAV_Y = 2292


def adb(*args, binary=False):
    result = subprocess.run(["adb", *args], capture_output=True, check=False)
    if result.returncode:
        print("adb", args, "->", result.returncode, result.stderr.decode()[:200])
    return result.stdout if binary else result.stdout.decode(errors="replace")


def tap(x, y, wait=2.0, label=""):
    print(f"tap {x},{y} {label}")
    adb("shell", "input", "tap", str(x), str(y))
    time.sleep(wait)


def back(wait=1.5):
    adb("shell", "input", "keyevent", "4")
    time.sleep(wait)


def dismiss_anr():
    """The launcher can ANR under emulator load; its dialog must not be shot."""
    windows = adb("shell", "dumpsys", "window", "windows")
    if "Not Responding" in windows:
        print("dismissing ANR dialog")
        tap(540, 1343, 2.0, "Wait")


def shot(name):
    dismiss_anr()
    data = adb("exec-out", "screencap", "-p", binary=True)
    (OUT / f"{name}.png").write_bytes(data)
    print("shot", name, len(data))


def demo(*args):
    adb("shell", "am", "broadcast", "-a", "com.android.systemui.demo",
        "-e", "command", *args)


def main():
    adb("shell", "settings", "put", "global", "sysui_demo_allowed", "1")
    demo("enter")
    demo("clock", "-e", "hhmm", "0900")
    demo("battery", "-e", "level", "100", "-e", "plugged", "false")
    demo("network", "-e", "wifi", "show", "-e", "level", "4", "-e", "fully", "true")
    demo("network", "-e", "mobile", "hide")
    demo("notifications", "-e", "visible", "false")
    # A debug build cold-starts slowly on the emulator; wait for the first
    # frame and the seeded database before the first capture.
    time.sleep(12)

    # 1 - meals (home)
    shot("1_meals")

    # 2 - calendar
    tap(405, NAV_Y, 2.5, "Calendar")
    shot("2_calendar")

    # 3 - log dish, opened from the first meal card
    tap(135, NAV_Y, 1.0, "Meals")
    tap(540, 860, 2.5, "first meal")
    shot("3_log_meal")
    back()

    # 4 - statistics: Menu > View Statistics
    tap(945, NAV_Y, 2.0, "Menu")
    shot("debug_menu")
    tap(540, 1335, 3.0, "View Statistics")
    shot("4_statistics")
    back()

    # 5 - nutrition goals: Menu > Nutrition Goals
    tap(945, NAV_Y, 2.0, "Menu")
    tap(540, 1162, 3.0, "Nutrition Goals")
    shot("5_macros")
    back()

    # 6 - profile: Menu > User Profile
    tap(945, NAV_Y, 2.0, "Menu")
    tap(540, 990, 2.5, "User Profile")
    shot("6_profile")
    back()

    demo("exit")
    print("done")


if __name__ == "__main__":
    main()
