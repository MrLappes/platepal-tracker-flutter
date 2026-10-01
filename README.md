# PlatePal Tracker

PlatePal Tracker is an open-source, local-first nutrition diary. Log meals, compare daily nutrition with your goals, and keep control of your data without an account.

## Features

- **Meals and dishes:** Create dishes from ingredients and log them for breakfast, lunch, dinner, or snacks. Scan barcodes or search Open Food Facts for products.
- **Calendar diary:** Review meals and daily calories, protein, carbs, fat, and fiber against your targets; use **Log meal** to add an entry for a selected day.
- **Personal goals:** Calculate calorie and macro targets from your profile with the Mifflin-St Jeor formula, then customize the macro split.
- **Statistics:** See weight trends and calorie intake over time.
- **Optional AI chat:** Bring your own OpenAI or OpenAI-compatible API key for dish suggestions.
- **Optional health connection:** Read calories burned from Health Connect (Android) or Apple Health (iOS), and write logged meal nutrition with your permission.
- **Your data:** Export and import JSON or CSV. Imports create a local backup for undo; if backup creation fails, you can choose whether to continue without one.
- **Your preferences:** Choose English, Spanish, or German and a light, dark, or system theme.

Meal logging and your data work locally. Product lookup, AI chat, and health integrations depend on their respective services and permissions. Nutrition targets and AI suggestions are informational, not medical advice.

## Screenshots

Store screenshots will be added to `fastlane/metadata/android/en-US/images/phoneScreenshots/`. See the [store image requirements](fastlane/metadata/android/en-US/images/README.md); no screenshots are included yet.

## Getting Started

Use [Flutter stable 3.35 or newer](https://docs.flutter.dev/get-started/install) and a configured Android device or emulator (or an iOS development setup). CI installs Flutter from the stable channel. The project declares Dart SDK `^3.7.0`; Flutter includes Dart.

```bash
git clone https://github.com/MrLappes/platepal-tracker-flutter.git
cd platepal-tracker-flutter
flutter pub get
flutter gen-l10n
flutter run
```

Run the tests with `flutter test`. App code lives in `lib/`, localization sources in `lib/l10n/`, and unit/widget tests in `test/`.

## AI Setup

AI chat is optional. In the app's API key settings, enter your own OpenAI API key or an API key for an OpenAI-compatible service and choose a model. The key is kept in platform secure storage; no project-root `.env` file is needed. Custom endpoints must use HTTPS; HTTP is allowed only for local development hosts (localhost, loopback, or the Android emulator's `10.0.2.2` alias). Provider charges and their own privacy terms may apply. Scanning/searching Open Food Facts does not require an OpenAI key.

## Health Connect and Apple Health

With your permission, PlatePal reads calories burned and writes nutrition from logged meals to Health Connect on Android or Apple Health on iOS. On Android it reads total and active energy when available; on iOS it reads active and basal energy. Availability depends on the device and health service configuration. Health access is optional and does not require an API key.

## Privacy

There is no account, advertising, or tracking. Meals, profile information, and settings are stored locally, but optional AI chat sends relevant messages and context to the chosen provider, and product searches/barcodes go to Open Food Facts. Platform backups may also copy local data. Read the [privacy policy](PRIVACY.md) for details and deletion guidance.

## Contributing

Open an issue to discuss bugs or proposed changes. To contribute code, fork the repository, work on a feature branch, add or update relevant tests and localization strings, run `flutter test` and `flutter analyze`, then open a pull request.

## License

PlatePal Tracker is licensed under GPL-2.0. See [LICENSE](LICENSE).

## Acknowledgments

- Flutter team for the framework
- OpenAI for the optional AI integration
- Open Food Facts for product data
- Material Design for UI guidelines
- Community contributors

## Support

For problems or questions, [open an issue](https://github.com/MrLappes/platepal-tracker-flutter/issues).
