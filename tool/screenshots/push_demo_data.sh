#!/usr/bin/env bash
set -euo pipefail

package=com.platepal.platepaltracker
adb_bin="${ADB:-$HOME/Android/Sdk/platform-tools/adb}"
database_file="${DEMO_DB_OUT:-/tmp/platepal_demo/platepal.db}"
preferences_file=/tmp/platepal_demo/FlutterSharedPreferences.xml
locale="${1:-${DEMO_LOCALE:-en}}"

if (( $# > 1 )); then
  printf 'Usage: %s [en|de|es]\n' "$0" >&2
  exit 2
fi
case "$locale" in
  en|de|es) ;;
  *) printf 'Unsupported locale: %s (expected en, de, or es)\n' "$locale" >&2; exit 2 ;;
esac

if ! "$adb_bin" shell run-as "$package" pwd >/dev/null; then
  printf 'A debuggable %s must be installed and an emulator must be attached.\n' "$package" >&2
  exit 1
fi

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"
printf 'Generating fresh demo data (locale: %s)...\n' "$locale"
DEMO_DB_OUT="$database_file" DEMO_LOCALE="$locale" flutter test tool/screenshots/seed_demo_data_test.dart

stage_db=/data/local/tmp/platepal-demo-db-$$
stage_prefs=/data/local/tmp/platepal-demo-prefs-$$
trap '"$adb_bin" shell rm -f "$stage_db" "$stage_prefs"' EXIT

printf 'Force-stopping %s...\n' "$package"
"$adb_bin" shell am force-stop "$package"
printf 'Pushing database and preferences to temporary device paths...\n'
"$adb_bin" push "$database_file" "$stage_db"
"$adb_bin" push "$preferences_file" "$stage_prefs"

printf 'Installing database and preferences with run-as...\n'
"$adb_bin" shell run-as "$package" mkdir -p databases shared_prefs
"$adb_bin" shell run-as "$package" rm -f databases/platepal.db-wal databases/platepal.db-shm databases/platepal.db-journal
"$adb_bin" shell run-as "$package" cp "$stage_db" databases/platepal.db
"$adb_bin" shell run-as "$package" cp "$stage_prefs" shared_prefs/FlutterSharedPreferences.xml

printf 'Installed files:\n'
"$adb_bin" shell run-as "$package" ls databases shared_prefs
printf 'Launching %s...\n' "$package"
"$adb_bin" shell monkey -p "$package" -c android.intent.category.LAUNCHER 1