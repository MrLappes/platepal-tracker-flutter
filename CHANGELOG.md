# Changelog

Notable changes to PlatePal Tracker are documented here, following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.16.0] - 2026-10-01

### Added

- "Log food" button on the diary and meals screens: search saved dishes, pick from favorites or the 10 most recently logged dishes, scan a barcode, search Open Food Facts, or quick add.
- Quick add: log calories (and optional name, macros, fiber, meal type, date and time) without creating a dish.
- Edit diary entries (servings, meal type, date, time, notes), copy an entry to today or another date, and copy a whole meal from the previous day.
- Star button on dish cards to mark favorites.
- Recipe yield: set how many servings a dish makes (0.5 to 100). Dish lists and the log sheet show nutrition per serving, logging one serving records the recipe total divided by the yield, and the gram input uses the weight of one serving. Existing dishes keep a yield of 1; exports and backups include the yield.
- The chat assistant can propose diary entries ("Log 1.5 servings of Pasta as Lunch today – 640 kcal") for saved dishes or as a quick add. Nothing is logged until you tap Confirm; Edit opens the prefilled log sheet and Dismiss discards the proposal. Confirmed entries sync to Health Connect like manual ones.
- Automatic backup (Menu → Backup): daily or weekly full ZIP backups with photos, written when you open the app and one is due, to a folder you choose or the app's storage. The newest 5 automatic backups are kept; the screen shows the last backup and has "Back up now". A failed automatic backup is reported the next time you open the app.
- Import a dish shared from the PlatePal app (`platepaltracker://import-dish` links): the link is validated and opens a new, unsaved dish form with the name, description, servings and ingredient names filled in, and a banner to check the ingredients and amounts. Invalid links show an error.
- Menu entry "PlatePal – share meals with others" that opens the PlatePal app on Google Play.
- Help & feedback (Menu): send feedback by e-mail with the app version, or share a local diagnostic log of recent crashes (time, app version, error type, sanitized message, short stack). Nothing is sent automatically, and the log can be cleared.
- Full backup (.zip) export with the dish photos; importing it restores the photos.
- When a scanned barcode is not found: search by name, enter the product manually with the barcode filled in, or scan again. The empty meals screen also offers scanning and searching.

### Changed

- Portions are entered as servings (steps of 0.25, up to 20) or, when the dish weight is known, in grams or millilitres, with nutrition updating as you type.
- The diary groups entries by meal and shows localized meal names.
- Quick add accepts at most 10,000 kcal and 1,000 g per macro, like diary entries proposed by the chat.
- Choosing a backup folder checks that the app can write to it; otherwise the previous folder is kept.
- After a failed automatic backup, the next attempt is made the following day instead of on every app resume.

### Fixed

- Statistics show the calorie history whenever meals are logged; weight, BMI and body-fat charts explain how much data they need, and maintenance calories fall back to the profile.
- Product search shows clear errors (offline, timeout, rate limit, server) with a Retry button instead of raw error text.
- Imported meal logs without stored nutrition count one serving of the dish instead of the whole recipe.
- Editing an entry of a dish that changed after logging no longer offers a gram input that would record wrong amounts.
- Chat cards for saved dishes show nutrition per serving, like the log sheet; inspecting one edits the saved dish with its yield.
- Automatic backup rotation never deletes the backup it has just written.
- Photos restored from a backup for dishes skipped as duplicates are removed again.
- The last dish card on the meals screen is no longer covered by the buttons, and the diary's kcal unit is translated.

### Security

- Full backups only include image files from the app's own photo folder, and imports drop dish image paths that point anywhere else, so a crafted backup cannot pull private app files into later backups.
- Backup archives are checked against their real decompressed size, not only the sizes in the zip headers.
- The diagnostic log keeps only the first line of error messages and hides numbers with two or more digits.
- Dish links from PlatePal are rejected if they contain invisible or text-direction control characters.

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
