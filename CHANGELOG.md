# Changelog

Notable changes to PlatePal Tracker are documented here, following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- "Log food" button on the diary and meals screens: search saved dishes, pick from favorites or the 10 most recently logged dishes, scan a barcode, search Open Food Facts, or quick add.
- Quick add: log calories (and optional name, macros, fiber, meal type, date and time) without creating a dish.
- Edit diary entries (servings, meal type, date, time, notes), copy an entry to today or another date, and copy a whole meal from the previous day.
- Star button on dish cards to mark favorites.
- Recipe yield: set how many servings a dish makes (0.5 to 100). Dish lists and the log sheet show nutrition per serving, logging one serving records the recipe total divided by the yield, and the gram input uses the weight of one serving. Existing dishes keep a yield of 1; exports and backups include the yield.
- The chat assistant can propose diary entries ("Log 1.5 servings of Pasta as Lunch today – 640 kcal") for saved dishes or as a quick add. Nothing is logged until you tap Confirm; Edit opens the prefilled log sheet and Dismiss discards the proposal. Confirmed entries sync to Health Connect like manual ones.
- Automatic backup (Menu → Backup): daily or weekly full ZIP backups with photos, written when you open the app and one is due, to a folder you choose or the app's storage. The newest 5 automatic backups are kept; the screen shows the last backup and has "Back up now". A failed automatic backup is reported the next time you open the app.

### Changed

- Portions are entered as servings (steps of 0.25, up to 20) or, when the dish weight is known, in grams or millilitres, with nutrition updating as you type.
- The diary groups entries by meal and shows localized meal names.

## [1.15.0] - 2026-10-01

### Changed

- Calorie targets are no longer raised to 1200 kcal; targets below 1200 kcal show a warning to check your profile values and to seek medical supervision instead.
- Imports no longer limit how many items a section may contain; large imports write ingredients in one transaction and keep the screen responsive.
- Import results list at most 50 detailed errors per section and say how many more there are.

### Fixed

- Enable the HealthKit entitlement on iOS so Apple Health sync can be authorized; iOS 14 is now the minimum, and devices without HealthKit can still install the app.
- A profile that would produce a calorie target of 0 kcal or less is no longer saved, so custom macro splits are not lost.
- An ingredient with missing or non-numeric nutrition is skipped instead of being imported without it, and a database failure such as a full disk fails the ingredients section instead of reporting rolled-back rows as imported.

## [1.14.0] - 2026-10-01

### Added

- Log meals directly from a selected day in the calendar diary.
- Read the privacy policy in the app and in the repository.

### Changed

- Profile-based calorie targets use Mifflin-St Jeor while preserving custom macro splits.
- Follow the system theme and language by default; expand translations throughout the app.
- Improve Android release configuration, backup rules, and splash screen.
- Improve the meals screen, dish logging, statistics loading, and accessible controls.

### Fixed

- Correct dish nutrition calculations and make meal logs consistent across the diary, statistics, and import/export.
- Make barcode scanning and Open Food Facts searches more reliable and import product nutrients correctly.
- Correct calendar markers, daily summaries, profile editing, and weight/calorie statistics.
- Avoid duplicate AI replies and fix logging dishes suggested by chat.
- Make imports and restores safer with confirmation, pre-import backups, clearer results, and support for legacy profiles.
- Correct calories burned calculations for Health Connect and Apple Health.
- Show decimal numbers with the separator of the app language (for example 24,0 in German and Spanish).

### Security

- Store the AI API key in platform secure storage instead of ordinary preferences, with migration for older keys.
- Remove API keys and personal data from diagnostic logs; restrict custom AI endpoints and bound chat history.

### Removed

- Unused legacy screens, widgets, and services.
