# Demo data for store screenshots

This generates a fresh local demo database with Alex's profile and goals, 12
recipes, 21 days of meals (today has only breakfast and lunch), and eight weeks
of weight history. Dish names remain in English; `en`, `de`, and `es` select
the app's interface language. No images or screenshots are generated.

**Use a disposable emulator with a debug build.** The push script replaces
the app's entire SQLite database and Flutter preferences on that device;
existing app data and settings will be lost. It does not uninstall or clear
the package, and it refuses to run unless `run-as` works.

```bash
export PATH=/home/lappes/development/flutter-3.47/bin:$PATH
flutter build apk --debug
"$HOME/Android/Sdk/platform-tools/adb" install -r build/app/outputs/flutter-apk/app-debug.apk
bash tool/screenshots/push_demo_data.sh en
```

Replace `en` with `de` or `es` for another UI locale. The script runs
`flutter test tool/screenshots/seed_demo_data_test.dart`, force-stops the app,
copies the files via `adb shell run-as com.platepal.platepaltracker`, and
relaunches it. It expects exactly one connected device (or an `ADB` wrapper
that selects one). If installing the debug APK fails with a signing mismatch,
use a fresh emulator instead of uninstalling an app whose data you need.

To generate and inspect the files without pushing to a device:

```bash
flutter test tool/screenshots/seed_demo_data_test.dart
DEMO_LOCALE=de flutter test tool/screenshots/seed_demo_data_test.dart
DEMO_DB_OUT=/tmp/custom-demo/platepal.db flutter test tool/screenshots/seed_demo_data_test.dart
```

The database defaults to `/tmp/platepal_demo/platepal.db` (override it with
`DEMO_DB_OUT` for either the test or the script). The Android preferences XML
is always at `/tmp/platepal_demo/FlutterSharedPreferences.xml`. Each run
rebuilds the database, and the dates are relative to the local day on the host.
For accurate calendar screenshots, set the emulator to the same date/time zone
as the host before generating the data.

To save a screenshot manually after navigating to the desired screen:

```bash
"$HOME/Android/Sdk/platform-tools/adb" exec-out screencap -p > platepal-demo.png
```