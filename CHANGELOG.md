# Changelog

Notable changes to PlatePal Tracker are documented here, following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Changed

- Calorie targets are no longer raised to 1200 kcal; targets below 1200 kcal show a warning to check your profile values and to seek medical supervision instead.

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
