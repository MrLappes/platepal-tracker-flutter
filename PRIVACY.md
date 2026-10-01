# PlatePal Tracker Privacy Policy

Effective date: 2026-10-01

## At a glance

PlatePal Tracker is an offline-first nutrition tracker. We do not run servers for your app data or require an account, and the app has no analytics, advertising, or tracking SDKs. The optional network features below contact their providers when used.

## Data on your device

Dishes, meal logs, profile information (including body measurements), goals, chat history, and settings are stored on your device in SQLite or SharedPreferences. Saved food photos may also be kept in app storage. The API key you enter is stored using the platform's secure storage; legacy keys in SharedPreferences are migrated when possible.

## AI chat

AI chat is optional and requires your own API key. When used, your chat messages, attached images, and, when relevant, conversation history, your profile, meal logs or nutrition summaries, and saved dishes are sent to OpenAI or the OpenAI-compatible endpoint you configured. The key is sent to that provider for authentication. That provider handles this information under its own privacy policy; choose an endpoint you trust. We do not receive these requests.

## Open Food Facts

When you search for food or scan a barcode, the app sends your search text or barcode number and selected filters to world.openfoodfacts.org. Product information and images can be downloaded from Open Food Facts.

## Health Connect and Apple Health

With your permission, the app reads calories burned (total and active on Android, active and basal on iOS) from Health Connect or Apple Health and writes nutrition for meals you log to that service. Readings are cached on this device and used for in-app energy and goal calculations; the app does not include Health readings in AI requests or send them to a developer server. Health Connect and Apple Health control their own stored records.

## External links and images

The Contributors screen loads avatar images from GitHub's avatars.githubusercontent.com. Opening GitHub, the online policy, other external websites, or remote product images contacts those services, which may see your IP address and process requests under their own policies.

## Export and import

Export files (JSON, CSV, or a ZIP full backup that also contains your dish photos) are created locally when you choose to export; you can share them using your device. Import reads a file you choose and creates a local pre-import backup first, unless you explicitly continue when backup creation fails. Nothing is uploaded to us.

## Diagnostic log and feedback

If the app hits an unexpected error, it saves a short technical record on your device: time, app version, error type, a shortened error message and the code location. Text that may contain personal data, such as quoted values, email addresses, keys and measurements, is removed, and only the last 20 entries are kept. The log is never sent automatically. It leaves your device only if you choose Report a problem in the menu and share it with an app you pick; Clear diagnostic log deletes it. Send feedback opens your email app, and nothing is sent until you send the email yourself.

## Android backup

Android's system backup may copy the app's database and preferences, including cached Health calorie readings and chat history, to your Google account or transfer them to another device. The backup rules exclude secure-storage preference files, but a legacy API key may be present in other preferences until migration. Check your Android backup settings to control this.

## Delete your data

In Profile, Reset App deletes the SQLite database, SharedPreferences, and saved API key on this device. Uninstalling removes app-private data. Reset does not remove saved images, exported or pre-import backup files, copies shared elsewhere, Health Connect or Apple Health records already written, or system backups; remove those separately where applicable.

## Children

PlatePal Tracker is not intended for children. The app has no age verification; a parent or guardian should supervise use, especially before enabling external services or sharing sensitive information.

## Changes to this policy

We may update this policy when the app changes. The effective date above shows when this version took effect; review the current policy in the app or GitHub repository.

## Contact

For privacy questions, email [mike.busam@plate-pal.de](mailto:mike.busam@plate-pal.de) or open a GitHub issue at [github.com/MrLappes/platepal-tracker-flutter/issues](https://github.com/MrLappes/platepal-tracker-flutter/issues). We cannot access data kept only on your device; use the app and platform controls above to delete it.