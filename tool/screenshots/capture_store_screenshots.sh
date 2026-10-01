#!/usr/bin/env bash
# Captures the Play Store phone screenshots for one locale on the attached emulator.
# Usage: bash tool/screenshots/capture_store_screenshots.sh [en|de|es]
# Expects a 1080x1920 device (tap coordinates) and a debug build installed.
set -euo pipefail

adb_bin="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"
locale="${1:-en}"
case "$locale" in
  en) dir=en-US ;;
  de) dir=de-DE ;;
  es) dir=es-ES ;;
  *) printf 'Unsupported locale: %s\n' "$locale" >&2; exit 2 ;;
esac

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
out="$repo_root/fastlane/metadata/android/$dir/images/phoneScreenshots"
mkdir -p "$out"

demo() { "$adb_bin" shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
tap() { "$adb_bin" shell input tap "$1" "$2"; sleep "${3:-2}"; }
shot() { "$adb_bin" exec-out screencap -p > "$out/$1.png"; }
back() { "$adb_bin" shell input keyevent 4; sleep 1; }

"$adb_bin" shell settings put global sysui_demo_allowed 1
demo enter
demo clock -e hhmm 0900
demo battery -e level 100 -e plugged false
demo network -e wifi show -e level 4 -e fully true
demo network -e mobile hide
demo notifications -e visible false

bash "$repo_root/tool/screenshots/push_demo_data.sh" "$locale" >/dev/null
sleep 8

shot 1_meals
tap 405 1780; shot 2_calendar
tap 135 1780 1; tap 540 860; shot 3_log_meal; back
tap 945 1780 1; tap 540 1335 3
"$adb_bin" shell input swipe 540 1500 540 900 600; sleep 2; shot 4_statistics; back
tap 540 1162; shot 5_macros; back
tap 945 1780 1; tap 540 990; shot 6_profile; back

demo exit
printf 'Screenshots written to %s\n' "$out"
