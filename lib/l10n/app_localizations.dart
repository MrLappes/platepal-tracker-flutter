import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker'**
  String get appTitle;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlatePal'**
  String get welcome;

  /// Meals label
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// Nutrition label
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Add meal button text
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMeal;

  /// Breakfast meal type
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// Lunch meal type
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// Dinner meal type
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// Snack meal type
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// Empty state message when no meals are logged
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get noMealsLogged;

  /// Empty state subtitle encouraging users to log meals
  ///
  /// In en, this message translates to:
  /// **'Start tracking your meals to see them here'**
  String get startTrackingMeals;

  /// Section title for today's logged meals
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// Filter option to show all meals
  ///
  /// In en, this message translates to:
  /// **'All Meals'**
  String get allMeals;

  /// Title for meal history section
  ///
  /// In en, this message translates to:
  /// **'Meal History'**
  String get mealHistory;

  /// Tooltip for meal type filter
  ///
  /// In en, this message translates to:
  /// **'Filter by meal type'**
  String get filterByMealType;

  /// Button text to log a meal
  ///
  /// In en, this message translates to:
  /// **'Log Meal'**
  String get logMeal;

  /// Shows when a meal was logged
  ///
  /// In en, this message translates to:
  /// **'Logged at {time}'**
  String mealLoggedAt(String time);

  /// Calories label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Protein label
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// Carbs label
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// Fat label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// Calendar label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Label for dish when name is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown Dish'**
  String get unknownDish;

  /// Message shown when no meals are logged for selected day
  ///
  /// In en, this message translates to:
  /// **'No meals logged for this day'**
  String get noMealsLoggedForDay;

  /// Title for nutrition summary section
  ///
  /// In en, this message translates to:
  /// **'Nutrition Summary'**
  String get nutritionSummary;

  /// Button text to get AI nutrition tip
  ///
  /// In en, this message translates to:
  /// **'Get AI Tip'**
  String get getAiTip;

  /// Title for delete log dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Log'**
  String get deleteLog;

  /// Confirmation message for deleting a meal log
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this logged meal?'**
  String get deleteLogConfirmation;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Success message after deleting a meal log
  ///
  /// In en, this message translates to:
  /// **'Meal log deleted successfully'**
  String get mealLogDeletedSuccessfully;

  /// Error message when meal log deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal log'**
  String get failedToDeleteMealLog;

  /// Chat label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Menu label
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// User profile settings
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// Nutrition goals settings
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoals;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// AI and features settings section
  ///
  /// In en, this message translates to:
  /// **'AI & Features'**
  String get aiFeatures;

  /// Data management settings section
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Information settings section
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get information;

  /// API key settings
  ///
  /// In en, this message translates to:
  /// **'API Key Settings'**
  String get apiKeySettings;

  /// Export data option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Import data option
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Button text to select a file
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// Button text to select files for import
  ///
  /// In en, this message translates to:
  /// **'Select files to import'**
  String get selectFilesToImport;

  /// Import from file option
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get importFromFile;

  /// Import JSON file option
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get importJson;

  /// Import CSV file option
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// Export as JSON option
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get exportAsJson;

  /// Export as CSV option
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// Title for export data selection
  ///
  /// In en, this message translates to:
  /// **'Select data to export'**
  String get selectDataToExport;

  /// Title for import data selection
  ///
  /// In en, this message translates to:
  /// **'Select data to import'**
  String get selectDataToImport;

  /// User profiles data type
  ///
  /// In en, this message translates to:
  /// **'User Profiles'**
  String get userProfiles;

  /// Meal logs data type
  ///
  /// In en, this message translates to:
  /// **'Meal Logs'**
  String get mealLogs;

  /// Dishes data type
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get dishes;

  /// Ingredients data type
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// Supplements data type
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get supplements;

  /// Nutrition goals data type
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoalsData;

  /// All data option
  ///
  /// In en, this message translates to:
  /// **'All Data'**
  String get allData;

  /// Import progress message
  ///
  /// In en, this message translates to:
  /// **'Importing data...'**
  String get importProgress;

  /// Export progress message
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get exportProgress;

  /// Import success message
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get importSuccessful;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccessful;

  /// Import failed message
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// Export failed message
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No file selected error
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// Invalid file format error
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get invalidFileFormat;

  /// File not found error
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// Data validation failed error
  ///
  /// In en, this message translates to:
  /// **'Data validation failed'**
  String get dataValidationFailed;

  /// Shows how many items were imported
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items'**
  String importedItemsCount(int count);

  /// Shows how many items were exported
  ///
  /// In en, this message translates to:
  /// **'Exported {count} items'**
  String exportedItemsCount(int count);

  /// Backup and restore section title
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// Create backup button
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Restore from backup button
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// Backup creation success message
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully'**
  String get backupCreatedSuccessfully;

  /// Restore success message
  ///
  /// In en, this message translates to:
  /// **'Restore completed successfully'**
  String get restoreSuccessful;

  /// Warning message about data replacement
  ///
  /// In en, this message translates to:
  /// **'Warning: Existing data will be replaced'**
  String get warningDataWillBeReplaced;

  /// Confirmation message for restore operation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to restore? This will replace all existing data.'**
  String get confirmRestore;

  /// Shows file size
  ///
  /// In en, this message translates to:
  /// **'File size: {size}'**
  String fileSize(String size);

  /// Shows number of duplicate items found
  ///
  /// In en, this message translates to:
  /// **'Duplicate items found: {count}'**
  String duplicateItemsFound(int count);

  /// Question about handling duplicate items
  ///
  /// In en, this message translates to:
  /// **'How to handle duplicates?'**
  String get howToHandleDuplicates;

  /// Skip duplicates option
  ///
  /// In en, this message translates to:
  /// **'Skip Duplicates'**
  String get skipDuplicates;

  /// Overwrite duplicates option
  ///
  /// In en, this message translates to:
  /// **'Overwrite Duplicates'**
  String get overwriteDuplicates;

  /// Merge duplicates option
  ///
  /// In en, this message translates to:
  /// **'Merge Duplicates'**
  String get mergeDuplicates;

  /// Format not supported error
  ///
  /// In en, this message translates to:
  /// **'Format not supported: {format}'**
  String formatNotSupported(String format);

  /// About option
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About the app title
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutAppTitle;

  /// App creator credit
  ///
  /// In en, this message translates to:
  /// **'Made by MrLappes'**
  String get madeBy;

  /// Website URL
  ///
  /// In en, this message translates to:
  /// **'plate-pal.de'**
  String get website;

  /// GitHub repository URL
  ///
  /// In en, this message translates to:
  /// **'github.com/MrLappes/platepal-tracker'**
  String get githubRepository;

  /// App motto
  ///
  /// In en, this message translates to:
  /// **'Made by gym guys for gym guys that hate paid apps'**
  String get appMotto;

  /// Message for coders
  ///
  /// In en, this message translates to:
  /// **'Coders shouldn\'t have to pay'**
  String get codersMessage;

  /// Why PlatePal section title
  ///
  /// In en, this message translates to:
  /// **'Why PlatePal?'**
  String get whyPlatePal;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker was created to provide a privacy-focused, open-source alternative to expensive nutrition tracking apps. We believe in putting control in your hands with no subscriptions, no ads, and no data collection.'**
  String get aboutDescription;

  /// Privacy feature
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get dataStaysOnDevice;

  /// AI key feature
  ///
  /// In en, this message translates to:
  /// **'Use your own AI key for full control'**
  String get useOwnAiKey;

  /// Open source feature
  ///
  /// In en, this message translates to:
  /// **'100% free and open source'**
  String get freeOpenSource;

  /// Error message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// Error message for link opening failure
  ///
  /// In en, this message translates to:
  /// **'An error occurred opening the link'**
  String get linkError;

  /// Contributors option
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributors;

  /// Subtitle for user profile settings
  ///
  /// In en, this message translates to:
  /// **'Edit your personal information'**
  String get editPersonalInfo;

  /// Subtitle for nutrition goals settings
  ///
  /// In en, this message translates to:
  /// **'Set your daily nutrition targets'**
  String get setNutritionTargets;

  /// Subtitle for API key settings
  ///
  /// In en, this message translates to:
  /// **'Configure your OpenAI API key'**
  String get configureApiKey;

  /// Subtitle for export data option
  ///
  /// In en, this message translates to:
  /// **'Export your meal data'**
  String get exportMealData;

  /// Subtitle for import data option
  ///
  /// In en, this message translates to:
  /// **'Import meal data from backup'**
  String get importMealDataBackup;

  /// Subtitle for about option
  ///
  /// In en, this message translates to:
  /// **'Learn more about PlatePal'**
  String get learnMorePlatePal;

  /// Subtitle for contributors option
  ///
  /// In en, this message translates to:
  /// **'View project contributors'**
  String get viewContributors;

  /// Theme selector label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// German language option
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// Singular form for contributor count
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get contributorSingular;

  /// Plural form for contributor count
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get contributorPlural;

  /// Thank you message for contributors
  ///
  /// In en, this message translates to:
  /// **'Thanks to everyone who has contributed to making PlatePal Tracker possible!'**
  String get contributorsThankYou;

  /// Want to contribute section title
  ///
  /// In en, this message translates to:
  /// **'Want to Contribute?'**
  String get wantToContribute;

  /// Open source invitation message
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker is open source - join us on GitHub!'**
  String get openSourceMessage;

  /// GitHub repository button text
  ///
  /// In en, this message translates to:
  /// **'Check Out Our GitHub Repository'**
  String get checkGitHub;

  /// Support development section title
  ///
  /// In en, this message translates to:
  /// **'Support Development'**
  String get supportDevelopment;

  /// Support development message
  ///
  /// In en, this message translates to:
  /// **'You want to buy me my creatine? Your support is greatly appreciated but not at all mandatory.'**
  String get supportMessage;

  /// Buy me creatine button text
  ///
  /// In en, this message translates to:
  /// **'Buy Me Creatine'**
  String get buyMeCreatine;

  /// Loading message for opening external link
  ///
  /// In en, this message translates to:
  /// **'Opening Buy Me Creatine page...'**
  String get openingLink;

  /// Section title for API key information
  ///
  /// In en, this message translates to:
  /// **'About OpenAI API Key'**
  String get aboutOpenAiApiKey;

  /// Description of what the API key is used for
  ///
  /// In en, this message translates to:
  /// **'To use AI features like meal analysis and suggestions, you need to provide your own OpenAI API key. This ensures your data stays private and you have full control.'**
  String get apiKeyDescription;

  /// Bullet points explaining API key usage
  ///
  /// In en, this message translates to:
  /// **'• Get your API key from platform.openai.com\n• Your key is stored locally on your device\n• Usage charges apply directly to your OpenAI account'**
  String get apiKeyBulletPoints;

  /// Status message when API key is set up
  ///
  /// In en, this message translates to:
  /// **'API Key Configured'**
  String get apiKeyConfigured;

  /// Status message when AI features are available
  ///
  /// In en, this message translates to:
  /// **'AI features are enabled'**
  String get aiFeaturesEnabled;

  /// Label for API key input field
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get openAiApiKey;

  /// Placeholder text for API key input
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get apiKeyPlaceholder;

  /// Helper text for API key input field
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API key or leave empty to disable AI features'**
  String get apiKeyHelperText;

  /// Button text for updating existing API key
  ///
  /// In en, this message translates to:
  /// **'Update API Key'**
  String get updateApiKey;

  /// Button text for saving new API key
  ///
  /// In en, this message translates to:
  /// **'Save API Key'**
  String get saveApiKey;

  /// Button text for opening OpenAI platform
  ///
  /// In en, this message translates to:
  /// **'Get API Key from OpenAI'**
  String get getApiKeyFromOpenAi;

  /// Title for remove API key confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Remove API Key'**
  String get removeApiKey;

  /// Confirmation message for removing API key
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your API key? This will disable AI features.'**
  String get removeApiKeyConfirmation;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Validation error for invalid API key format
  ///
  /// In en, this message translates to:
  /// **'API key must start with \"sk-\"'**
  String get apiKeyMustStartWith;

  /// Validation error for API key length
  ///
  /// In en, this message translates to:
  /// **'API key appears to be too short'**
  String get apiKeyTooShort;

  /// Success message for removing API key
  ///
  /// In en, this message translates to:
  /// **'API key removed successfully'**
  String get apiKeyRemovedSuccessfully;

  /// Success message for saving API key
  ///
  /// In en, this message translates to:
  /// **'API key saved successfully'**
  String get apiKeySavedSuccessfully;

  /// Error message for loading API key
  ///
  /// In en, this message translates to:
  /// **'Failed to load API key'**
  String get failedToLoadApiKey;

  /// Error message for saving API key
  ///
  /// In en, this message translates to:
  /// **'Failed to save API key'**
  String get failedToSaveApiKey;

  /// Error message for removing API key
  ///
  /// In en, this message translates to:
  /// **'Failed to remove API key'**
  String get failedToRemoveApiKey;

  /// Message directing user to OpenAI platform
  ///
  /// In en, this message translates to:
  /// **'Visit platform.openai.com to get your API key'**
  String get visitOpenAiPlatform;

  /// Button text for pasting API key from clipboard
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get pasteFromClipboard;

  /// Error message when clipboard is empty
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get clipboardEmpty;

  /// Success message when pasting from clipboard
  ///
  /// In en, this message translates to:
  /// **'Pasted from clipboard'**
  String get pastedFromClipboard;

  /// Error message when clipboard access fails
  ///
  /// In en, this message translates to:
  /// **'Failed to access clipboard'**
  String get failedToAccessClipboard;

  /// Label for model selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// Button text for testing and saving API key
  ///
  /// In en, this message translates to:
  /// **'Test & Save API Key'**
  String get testAndSaveApiKey;

  /// Loading message while testing API key
  ///
  /// In en, this message translates to:
  /// **'Testing API key...'**
  String get testingApiKey;

  /// Information about GPT-4 models
  ///
  /// In en, this message translates to:
  /// **'GPT-4 models provide the best analysis but cost more'**
  String get gpt4ModelsInfo;

  /// Information about GPT-3.5 models
  ///
  /// In en, this message translates to:
  /// **'GPT-3.5 models are more cost-effective for basic analysis'**
  String get gpt35ModelsInfo;

  /// Loading message while fetching models
  ///
  /// In en, this message translates to:
  /// **'Loading available models...'**
  String get loadingModels;

  /// Error message when model loading fails
  ///
  /// In en, this message translates to:
  /// **'Could not load available models. Using default model list'**
  String get couldNotLoadModels;

  /// Warning message about API key testing
  ///
  /// In en, this message translates to:
  /// **'Your API key will be tested with a small request to verify it works. The key is only stored on your device and never sent to our servers'**
  String get apiKeyTestWarning;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Welcome message for PlatePal Tracker
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlatePal Tracker'**
  String get welcomeToPlatePalTracker;

  /// Profile settings screen title
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Height field label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// Weight field label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Target weight field label
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// Activity level field label
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// Sedentary activity level
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// Lightly active activity level
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get lightlyActive;

  /// Moderately active activity level
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get moderatelyActive;

  /// Very active activity level
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get veryActive;

  /// Extra active activity level
  ///
  /// In en, this message translates to:
  /// **'Extra Active'**
  String get extraActive;

  /// Fitness goals section title
  ///
  /// In en, this message translates to:
  /// **'Fitness Goals'**
  String get fitnessGoals;

  /// Fitness goal field label
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get fitnessGoal;

  /// Lose weight fitness goal
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get loseWeight;

  /// Maintain weight fitness goal
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get maintainWeight;

  /// Gain weight fitness goal
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get gainWeight;

  /// Build muscle fitness goal
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get buildMuscle;

  /// Preferences section title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Unit system field label
  ///
  /// In en, this message translates to:
  /// **'Unit System'**
  String get unitSystem;

  /// Metric unit system option
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, cm)'**
  String get metric;

  /// Imperial unit system option
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb, ft)'**
  String get imperial;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Discard changes button text
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get discardChanges;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// Profile update error message
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFailed;

  /// Unsaved changes dialog title
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// Unsaved changes dialog message
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them before leaving?'**
  String get unsavedChangesMessage;

  /// Delete profile button text
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// Delete profile confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your profile? This action cannot be undone.'**
  String get deleteProfileConfirmation;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// Age range validation message
  ///
  /// In en, this message translates to:
  /// **'Age must be between 13 and 120'**
  String get ageRange;

  /// Height range validation message
  ///
  /// In en, this message translates to:
  /// **'Height must be between 100-250 cm'**
  String get heightRange;

  /// Weight range validation message
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 30-300 kg'**
  String get weightRange;

  /// Current stats section title
  ///
  /// In en, this message translates to:
  /// **'Current Stats'**
  String get currentStats;

  /// BMI label
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// BMR (Basal Metabolic Rate) label
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get bmr;

  /// TDEE (Total Daily Energy Expenditure) label
  ///
  /// In en, this message translates to:
  /// **'TDEE'**
  String get tdee;

  /// Years unit
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Centimeters unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// Kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// Pounds unit
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// Feet unit
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get ft;

  /// Inches unit
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inches;

  /// Chat assistant title
  ///
  /// In en, this message translates to:
  /// **'AI Chat Assistant'**
  String get chatAssistant;

  /// Chat screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Get personalized meal suggestions and nutrition advice'**
  String get chatSubtitle;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Send message button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// Analyze dish button text
  ///
  /// In en, this message translates to:
  /// **'Analyze Dish'**
  String get analyzeDish;

  /// Scan barcode button text
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// Search product button text
  ///
  /// In en, this message translates to:
  /// **'Search Product'**
  String get searchProduct;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Suggest meal quick action
  ///
  /// In en, this message translates to:
  /// **'Suggest a meal'**
  String get suggestMeal;

  /// Analyze nutrition quick action
  ///
  /// In en, this message translates to:
  /// **'Analyze nutrition'**
  String get analyzeNutrition;

  /// Find alternatives quick action
  ///
  /// In en, this message translates to:
  /// **'Find alternatives'**
  String get findAlternatives;

  /// Calculate macros quick action
  ///
  /// In en, this message translates to:
  /// **'Calculate macros'**
  String get calculateMacros;

  /// Meal plan help quick action
  ///
  /// In en, this message translates to:
  /// **'Meal plan help'**
  String get mealPlan;

  /// Ingredient info quick action
  ///
  /// In en, this message translates to:
  /// **'Ingredient info'**
  String get ingredientInfo;

  /// Clear chat button text
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// Clear chat confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the chat history? This action cannot be undone.'**
  String get clearChatConfirmation;

  /// Chat cleared success message
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get chatCleared;

  /// Message send failure error
  ///
  /// In en, this message translates to:
  /// **'Failed to send message'**
  String get messageFailedToSend;

  /// Retry message button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryMessage;

  /// Copy message accessibility label
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copyMessage;

  /// Message copied success message
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get messageCopied;

  /// AI thinking status message
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No API key error title
  ///
  /// In en, this message translates to:
  /// **'No API key configured'**
  String get noApiKeyConfigured;

  /// No API key error message
  ///
  /// In en, this message translates to:
  /// **'Please configure your OpenAI API key in settings to use the AI chat assistant.'**
  String get configureApiKeyToUseChat;

  /// Configure API key button text
  ///
  /// In en, this message translates to:
  /// **'Configure API Key'**
  String get configureApiKeyButton;

  /// Button text for reloading API key configuration
  ///
  /// In en, this message translates to:
  /// **'Reload API Key'**
  String get reloadApiKeyButton;

  /// Welcome message for chat
  ///
  /// In en, this message translates to:
  /// **'Welcome to your AI nutrition assistant! Ask me anything about meals, nutrition, or your fitness goals.'**
  String get welcomeToChat;

  /// Attach image button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Attach image'**
  String get attachImage;

  /// Image attached confirmation
  ///
  /// In en, this message translates to:
  /// **'Image attached'**
  String get imageAttached;

  /// Remove image button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get removeImage;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Image source selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get imageSourceSelection;

  /// Nutrition analysis section title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get nutritionAnalysis;

  /// Add to meals button text
  ///
  /// In en, this message translates to:
  /// **'Add to Meals'**
  String get addToMeals;

  /// Details button text
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Agent steps tap instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to view agent steps'**
  String get tapToViewAgentSteps;

  /// Success message when dish is added to meals
  ///
  /// In en, this message translates to:
  /// **'Added {dishName} to meals'**
  String addedToMealsSuccess(String dishName);

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Serving size label
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get servingSize;

  /// Per serving label
  ///
  /// In en, this message translates to:
  /// **'per serving'**
  String get perServing;

  /// Dish name label
  ///
  /// In en, this message translates to:
  /// **'Dish Name'**
  String get dishName;

  /// Cooking instructions label
  ///
  /// In en, this message translates to:
  /// **'Cooking Instructions'**
  String get cookingInstructions;

  /// Meal type label
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// Added to meals success message
  ///
  /// In en, this message translates to:
  /// **'Added to meals successfully'**
  String get addedToMeals;

  /// Failed to add meal error message
  ///
  /// In en, this message translates to:
  /// **'Failed to add meal'**
  String get failedToAddMeal;

  /// Welcome message for test chat mode
  ///
  /// In en, this message translates to:
  /// **'This is test mode! I can help you explore PlatePal\'s features. Try asking me about nutrition, meal planning, or food recommendations.'**
  String get testChatWelcome;

  /// Test response message when no API key is configured
  ///
  /// In en, this message translates to:
  /// **'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.'**
  String get testChatResponse;

  /// Chat welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlatePal'**
  String get chatWelcomeTitle;

  /// Chat welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Your AI nutrition assistant is here to help'**
  String get chatWelcomeSubtitle;

  /// Get started section title
  ///
  /// In en, this message translates to:
  /// **'Get started today'**
  String get getStartedToday;

  /// Help options question
  ///
  /// In en, this message translates to:
  /// **'What can I help you with?'**
  String get whatCanIHelpWith;

  /// Message shown when a feature is not yet implemented
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get featureComingSoon;

  /// Statistics page title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// View statistics button text
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get viewStatistics;

  /// Weight history chart title
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get weightHistory;

  /// BMI history chart title
  ///
  /// In en, this message translates to:
  /// **'BMI History'**
  String get bmiHistory;

  /// Body fat history chart title
  ///
  /// In en, this message translates to:
  /// **'Body Fat History'**
  String get bodyFatHistory;

  /// Calorie intake history chart title
  ///
  /// In en, this message translates to:
  /// **'Calorie Intake vs Maintenance'**
  String get calorieIntakeHistory;

  /// Tooltip for weight statistics
  ///
  /// In en, this message translates to:
  /// **'The graph shows median weekly weight to account for daily fluctuations due to water weight.'**
  String get weightStatsTip;

  /// Tooltip for BMI statistics
  ///
  /// In en, this message translates to:
  /// **'Body Mass Index (BMI) is calculated from your weight and height measurements.'**
  String get bmiStatsTip;

  /// Tooltip for body fat statistics
  ///
  /// In en, this message translates to:
  /// **'Body fat percentage helps track your body composition beyond just weight.'**
  String get bodyFatStatsTip;

  /// Tooltip for calorie statistics
  ///
  /// In en, this message translates to:
  /// **'Compare your daily calorie intake to your maintenance calories. Green indicates maintenance, blue is cutting phase, orange is bulking phase.'**
  String get calorieStatsTip;

  /// Title when insufficient data for statistics
  ///
  /// In en, this message translates to:
  /// **'Not Enough Data'**
  String get notEnoughDataTitle;

  /// Description when insufficient data for statistics
  ///
  /// In en, this message translates to:
  /// **'We need at least a week of data to show meaningful statistics. Keep tracking your metrics to see trends over time.'**
  String get statisticsEmptyDescription;

  /// Button to update metrics
  ///
  /// In en, this message translates to:
  /// **'Update Metrics Now'**
  String get updateMetricsNow;

  /// Time range selector label
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get timeRange;

  /// Week time range option
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Month time range option
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Three months time range option
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// Six months time range option
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get sixMonths;

  /// Year time range option
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// All time range option
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Bulking phase label
  ///
  /// In en, this message translates to:
  /// **'Bulking'**
  String get bulking;

  /// Cutting phase label
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get cutting;

  /// Maintenance phase label
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// Warning for very low calorie intake
  ///
  /// In en, this message translates to:
  /// **'Extreme Low Calorie Warning'**
  String get extremeLowCalorieWarning;

  /// Warning for very high calorie intake
  ///
  /// In en, this message translates to:
  /// **'Extreme High Calorie Warning'**
  String get extremeHighCalorieWarning;

  /// Message for too low calorie intake
  ///
  /// In en, this message translates to:
  /// **'Your calorie intake is significantly below recommendations. This may affect your health and metabolism.'**
  String get caloriesTooLowMessage;

  /// Message for too high calorie intake
  ///
  /// In en, this message translates to:
  /// **'Your calorie intake is significantly above recommendations. Consider adjusting your portions.'**
  String get caloriesTooHighMessage;

  /// Weekly calorie deficit label
  ///
  /// In en, this message translates to:
  /// **'Weekly Deficit'**
  String get weeklyDeficit;

  /// Weekly calorie surplus label
  ///
  /// In en, this message translates to:
  /// **'Weekly Surplus'**
  String get weeklySurplus;

  /// Phase analysis section title
  ///
  /// In en, this message translates to:
  /// **'Phase Analysis'**
  String get phaseAnalysis;

  /// Weekly average label
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get weeklyAverage;

  /// Last week time range option
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// Last month time range option
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// Last three months time range option
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get lastThreeMonths;

  /// Last six months time range option
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get lastSixMonths;

  /// Last year time range option
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// Generate test data button
  ///
  /// In en, this message translates to:
  /// **'Generate Test Data'**
  String get generateTestData;

  /// Test data description text
  ///
  /// In en, this message translates to:
  /// **'For demonstration purposes, you can generate sample data to see how the statistics look.'**
  String get testDataDescription;

  /// Error message when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Refresh button tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Real data button text
  ///
  /// In en, this message translates to:
  /// **'Real Data'**
  String get realData;

  /// Message when no weight data is available
  ///
  /// In en, this message translates to:
  /// **'No weight data available'**
  String get noWeightDataAvailable;

  /// Message when no BMI data is available
  ///
  /// In en, this message translates to:
  /// **'No BMI data available'**
  String get noBmiDataAvailable;

  /// Message when BMI cannot be calculated from available data
  ///
  /// In en, this message translates to:
  /// **'Cannot calculate BMI from available data'**
  String get cannotCalculateBmiFromData;

  /// Message when no body fat data is available
  ///
  /// In en, this message translates to:
  /// **'No body fat data available'**
  String get noBodyFatDataAvailable;

  /// Message when no calorie data is available
  ///
  /// In en, this message translates to:
  /// **'No calorie data available'**
  String get noCalorieDataAvailable;

  /// BMI category: Underweight
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// BMI category: Normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiNormal;

  /// BMI category: Overweight
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// BMI category: Obese
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// Health data integration title
  ///
  /// In en, this message translates to:
  /// **'Health Data Integration'**
  String get healthDataIntegration;

  /// Health data coverage information
  ///
  /// In en, this message translates to:
  /// **'Calorie expenditure data coverage: {coverage}% ({healthDataDays}/{totalDays} days)'**
  String healthDataCoverage(String coverage, String healthDataDays, String totalDays);

  /// Health data active message
  ///
  /// In en, this message translates to:
  /// **'Using your health app data to provide more accurate deficit/surplus analysis.'**
  String get healthDataActive;

  /// Health data inactive message
  ///
  /// In en, this message translates to:
  /// **'Enable health data sync in Profile Settings for more accurate analysis.'**
  String get healthDataInactive;

  /// Calorie balance chart title with health data
  ///
  /// In en, this message translates to:
  /// **'Calorie Balance (Intake vs Expenditure)'**
  String get calorieBalanceTitle;

  /// Calorie balance tooltip with health data
  ///
  /// In en, this message translates to:
  /// **'Track your actual calorie balance using health data. Green = maintenance, Blue = deficit, Orange = surplus.'**
  String get calorieBalanceTip;

  /// Estimated balance label
  ///
  /// In en, this message translates to:
  /// **'Estimated Balance'**
  String get estimatedBalance;

  /// Actual balance label
  ///
  /// In en, this message translates to:
  /// **'Actual Balance'**
  String get actualBalance;

  /// vs expenditure text
  ///
  /// In en, this message translates to:
  /// **'vs expenditure'**
  String get vsExpenditure;

  /// Health data alert message
  ///
  /// In en, this message translates to:
  /// **'Health Data Alert: {days} day(s) with very large calorie deficits (>1000 cal) based on actual expenditure.'**
  String healthDataAlert(String days);

  /// Inconsistent deficit warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: Your calorie deficit varies significantly day-to-day (variance: {variance} cal). Consider more consistent intake.'**
  String inconsistentDeficitWarning(String variance);

  /// Very low calorie warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: {days} day(s) with extremely low calorie intake (<1000 cal). This may be unhealthy.'**
  String veryLowCalorieWarning(String days);

  /// Very high calorie notice message
  ///
  /// In en, this message translates to:
  /// **'Notice: {days} day(s) with very high calorie intake (>1000 cal above maintenance).'**
  String veryHighCalorieNotice(String days);

  /// Extreme deficit warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: Frequent extreme calorie deficits may slow metabolism and cause muscle loss.'**
  String get extremeDeficitWarning;

  /// Maintenance label for chart
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenanceLabel;

  /// Body fat field label
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get bodyFat;

  /// Button to reset the entire application
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get resetApp;

  /// Title for reset app confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset Application Data'**
  String get resetAppTitle;

  /// Description of what will be deleted when resetting the app
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete ALL your data including:\n\n• Your profile information\n• All meal logs and nutrition data\n• All preferences and settings\n• All stored information\n\nThis action cannot be undone. Are you sure you want to continue?'**
  String get resetAppDescription;

  /// Confirmation button for app reset
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete Everything'**
  String get resetAppConfirm;

  /// Cancel button for app reset dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get resetAppCancel;

  /// Success message after app reset
  ///
  /// In en, this message translates to:
  /// **'Application data has been reset successfully'**
  String get resetAppSuccess;

  /// Error message when app reset fails
  ///
  /// In en, this message translates to:
  /// **'Failed to reset application data'**
  String get resetAppError;

  /// Section title for dangerous operations
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get dangerZone;

  /// Title for chat agent settings screen
  ///
  /// In en, this message translates to:
  /// **'Chat Agent Settings'**
  String get chatAgentSettingsTitle;

  /// Switch title for enabling agent mode
  ///
  /// In en, this message translates to:
  /// **'Enable Agent Mode'**
  String get chatAgentEnableTitle;

  /// Switch subtitle for enabling agent mode
  ///
  /// In en, this message translates to:
  /// **'Use the multi-step agent pipeline for chat'**
  String get chatAgentEnableSubtitle;

  /// Switch title for enabling deep search
  ///
  /// In en, this message translates to:
  /// **'Enable Deep Search'**
  String get chatAgentDeepSearchTitle;

  /// Switch subtitle for enabling deep search
  ///
  /// In en, this message translates to:
  /// **'Allow the agent to use deep search for more accurate answers'**
  String get chatAgentDeepSearchSubtitle;

  /// Card title for agent mode explanation
  ///
  /// In en, this message translates to:
  /// **'What is Agent Mode?'**
  String get chatAgentInfoTitle;

  /// Card description for agent mode explanation
  ///
  /// In en, this message translates to:
  /// **'Agent mode enables PlatePal\'s advanced multi-step reasoning pipeline for chat. This allows the assistant to analyze your query, gather context, and provide more accurate, explainable answers. Deep Search lets the agent use more data for even better results.'**
  String get chatAgentInfoDescription;

  /// Snackbar message when chat settings are saved
  ///
  /// In en, this message translates to:
  /// **'Chat settings saved successfully'**
  String get chatSettingsSaved;

  /// Label for yesterday in date formatting
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Section title for basic dish information
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// Validation message for empty dish name
  ///
  /// In en, this message translates to:
  /// **'Please enter a dish name'**
  String get pleaseEnterDishName;

  /// Label for image URL field
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrl;

  /// Helper text indicating field is optional
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// Section title for nutrition information
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get nutritionInfo;

  /// Validation message for required fields
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Validation message for invalid number input
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// Button text to add ingredient
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// Empty state text for ingredients list
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet'**
  String get noIngredientsAdded;

  /// Label for added ingredients preview in chat
  ///
  /// In en, this message translates to:
  /// **'Ingredients Added'**
  String get ingredientsAdded;

  /// Section title for dish options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// Description for favorite toggle
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite dish'**
  String get markAsFavorite;

  /// Title for editing dish screen
  ///
  /// In en, this message translates to:
  /// **'Edit Dish'**
  String get editDish;

  /// Success message for dish update
  ///
  /// In en, this message translates to:
  /// **'Dish updated successfully'**
  String get dishUpdatedSuccessfully;

  /// Success message for dish creation
  ///
  /// In en, this message translates to:
  /// **'Dish created successfully'**
  String get dishCreatedSuccessfully;

  /// Error message for dish save failure
  ///
  /// In en, this message translates to:
  /// **'Error saving dish'**
  String get errorSavingDish;

  /// Label for ingredient name field
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get ingredientName;

  /// Validation message for empty ingredient name
  ///
  /// In en, this message translates to:
  /// **'Please enter an ingredient name'**
  String get pleaseEnterIngredientName;

  /// Label for ingredient amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for ingredient unit field
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Button text to add item
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Menu item text to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Warning for dish logging errors
  ///
  /// In en, this message translates to:
  /// **'There was an error logging the dish'**
  String get errorLoggingDish;

  /// Filter option to show all categories
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// Placeholder text for dish search field
  ///
  /// In en, this message translates to:
  /// **'Search dishes...'**
  String get searchDishes;

  /// Button text to create new dish
  ///
  /// In en, this message translates to:
  /// **'Create Dish'**
  String get createDish;

  /// Empty state title when no dishes exist
  ///
  /// In en, this message translates to:
  /// **'No dishes created yet'**
  String get noDishesCreated;

  /// Empty state subtitle encouraging dish creation
  ///
  /// In en, this message translates to:
  /// **'Create your first dish to get started'**
  String get createFirstDish;

  /// Error message when dishes fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading dishes'**
  String get errorLoadingDishes;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No dishes found'**
  String get noDishesFound;

  /// Suggestion when no search results found
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get tryAdjustingSearch;

  /// Dialog title for dish deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Dish'**
  String get deleteDish;

  /// Confirmation message for dish deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{dishName}\"?'**
  String deleteDishConfirmation(String dishName);

  /// Success message after dish deletion
  ///
  /// In en, this message translates to:
  /// **'Dish deleted successfully'**
  String get dishDeletedSuccessfully;

  /// Error message when dish deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete dish'**
  String get failedToDeleteDish;

  /// Success message when dish added to favorites
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// Success message when dish removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// Error message when dish update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating dish'**
  String get errorUpdatingDish;

  /// Menu item to add dish to favorites
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// Menu item to remove dish from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// Fiber nutrition label
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// Favorite toggle label
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @createNewDish.
  ///
  /// In en, this message translates to:
  /// **'Create New Dish'**
  String get createNewDish;

  /// No description provided for @errorCreatingDish.
  ///
  /// In en, this message translates to:
  /// **'Error creating dish'**
  String get errorCreatingDish;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @pleaseEnterValidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get pleaseEnterValidUrl;

  /// No description provided for @pleaseEnterIngredient.
  ///
  /// In en, this message translates to:
  /// **'Please enter an ingredient'**
  String get pleaseEnterIngredient;

  /// No description provided for @errorDeletingDish.
  ///
  /// In en, this message translates to:
  /// **'Error deleting dish'**
  String get errorDeletingDish;

  /// No description provided for @confirmDeleteDish.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this dish?'**
  String get confirmDeleteDish;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @caloriesPer100g.
  ///
  /// In en, this message translates to:
  /// **'Calories per 100g'**
  String get caloriesPer100g;

  /// No description provided for @proteinPer100g.
  ///
  /// In en, this message translates to:
  /// **'Protein per 100g'**
  String get proteinPer100g;

  /// No description provided for @carbsPer100g.
  ///
  /// In en, this message translates to:
  /// **'Carbs per 100g'**
  String get carbsPer100g;

  /// No description provided for @fatPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fat per 100g'**
  String get fatPer100g;

  /// No description provided for @fiberPer100g.
  ///
  /// In en, this message translates to:
  /// **'Fiber per 100g'**
  String get fiberPer100g;

  /// No description provided for @invalidImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid image URL'**
  String get invalidImageUrl;

  /// No description provided for @enterIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredient name'**
  String get enterIngredientName;

  /// No description provided for @toggleFavorite.
  ///
  /// In en, this message translates to:
  /// **'Toggle Favorite'**
  String get toggleFavorite;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @dishNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter dish name'**
  String get dishNamePlaceholder;

  /// No description provided for @descriptionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get descriptionPlaceholder;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from Gallery'**
  String get pickFromGallery;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @nutritionalInformation.
  ///
  /// In en, this message translates to:
  /// **'Nutritional Information'**
  String get nutritionalInformation;

  /// No description provided for @per100g.
  ///
  /// In en, this message translates to:
  /// **'per 100g'**
  String get per100g;

  /// No description provided for @recalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get recalculate;

  /// No description provided for @recalculateNutrition.
  ///
  /// In en, this message translates to:
  /// **'Recalculate Nutrition'**
  String get recalculateNutrition;

  /// No description provided for @nutritionRecalculated.
  ///
  /// In en, this message translates to:
  /// **'Nutrition recalculated from ingredients'**
  String get nutritionRecalculated;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get addManually;

  /// No description provided for @saveDish.
  ///
  /// In en, this message translates to:
  /// **'Save Dish'**
  String get saveDish;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @mg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get mg;

  /// No description provided for @mcg.
  ///
  /// In en, this message translates to:
  /// **'μg'**
  String get mcg;

  /// No description provided for @iu.
  ///
  /// In en, this message translates to:
  /// **'IU'**
  String get iu;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @cup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get cup;

  /// No description provided for @tbsp.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get tbsp;

  /// No description provided for @tsp.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get tsp;

  /// No description provided for @oz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get oz;

  /// No description provided for @piece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get piece;

  /// No description provided for @slice.
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get slice;

  /// No description provided for @tablespoon.
  ///
  /// In en, this message translates to:
  /// **'tablespoon'**
  String get tablespoon;

  /// No description provided for @teaspoon.
  ///
  /// In en, this message translates to:
  /// **'teaspoon'**
  String get teaspoon;

  /// No description provided for @ounce.
  ///
  /// In en, this message translates to:
  /// **'ounce'**
  String get ounce;

  /// No description provided for @pound.
  ///
  /// In en, this message translates to:
  /// **'pound'**
  String get pound;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'gram'**
  String get gram;

  /// No description provided for @kilogram.
  ///
  /// In en, this message translates to:
  /// **'kilogram'**
  String get kilogram;

  /// No description provided for @milliliter.
  ///
  /// In en, this message translates to:
  /// **'milliliter'**
  String get milliliter;

  /// No description provided for @liter.
  ///
  /// In en, this message translates to:
  /// **'liter'**
  String get liter;

  /// No description provided for @editIngredient.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredient;

  /// No description provided for @deleteIngredient.
  ///
  /// In en, this message translates to:
  /// **'Delete Ingredient'**
  String get deleteIngredient;

  /// No description provided for @confirmDeleteIngredient.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ingredient?'**
  String get confirmDeleteIngredient;

  /// No description provided for @ingredientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Ingredient deleted'**
  String get ingredientDeleted;

  /// No description provided for @ingredientAdded.
  ///
  /// In en, this message translates to:
  /// **'Ingredient added'**
  String get ingredientAdded;

  /// No description provided for @ingredientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Ingredient updated'**
  String get ingredientUpdated;

  /// No description provided for @errorAddingIngredient.
  ///
  /// In en, this message translates to:
  /// **'Error adding ingredient'**
  String get errorAddingIngredient;

  /// No description provided for @errorUpdatingIngredient.
  ///
  /// In en, this message translates to:
  /// **'Error updating ingredient'**
  String get errorUpdatingIngredient;

  /// No description provided for @errorDeletingIngredient.
  ///
  /// In en, this message translates to:
  /// **'Error deleting ingredient'**
  String get errorDeletingIngredient;

  /// No description provided for @noNutritionData.
  ///
  /// In en, this message translates to:
  /// **'No nutrition data available'**
  String get noNutritionData;

  /// No description provided for @ingredientNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter ingredient name'**
  String get ingredientNamePlaceholder;

  /// Product quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get quantityPlaceholder;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get pleaseEnterQuantity;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @unitPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., g, cup, piece'**
  String get unitPlaceholder;

  /// No description provided for @pleaseEnterUnit.
  ///
  /// In en, this message translates to:
  /// **'Please enter a unit'**
  String get pleaseEnterUnit;

  /// No description provided for @nutritionInformation.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get nutritionInformation;

  /// Nutrition information per 100g label
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100g'**
  String get nutritionPer100g;

  /// No description provided for @caloriesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter calories'**
  String get caloriesPlaceholder;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// Button text to log a dish
  ///
  /// In en, this message translates to:
  /// **'Log Dish'**
  String get logDish;

  /// Title for the log dish modal
  ///
  /// In en, this message translates to:
  /// **'Log Dish'**
  String get logDishTitle;

  /// Button text to select date
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Label for meal type selection
  ///
  /// In en, this message translates to:
  /// **'Select Meal Type'**
  String get selectMealType;

  /// Label for portion size
  ///
  /// In en, this message translates to:
  /// **'Portion Size'**
  String get portionSize;

  /// Label for notes field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Placeholder text for notes field
  ///
  /// In en, this message translates to:
  /// **'Add notes (optional)'**
  String get addNotes;

  /// Label for calculated nutrition section
  ///
  /// In en, this message translates to:
  /// **'Calculated Nutrition'**
  String get calculatedNutrition;

  /// Success message when dish is logged
  ///
  /// In en, this message translates to:
  /// **'Dish logged successfully!'**
  String get dishLoggedSuccessfully;

  /// Generic select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Error message when dish screen fails to open
  ///
  /// In en, this message translates to:
  /// **'Error opening dish screen: {error}'**
  String errorOpeningDishScreen(Object error);

  /// Error message when image picker fails
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// Title for agent steps modal
  ///
  /// In en, this message translates to:
  /// **'Agent Processing Steps'**
  String get agentProcessingSteps;

  /// Button text to copy all
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get copyAll;

  /// Button text to view full data
  ///
  /// In en, this message translates to:
  /// **'View Full Data'**
  String get viewFullData;

  /// Button text to view full prompt
  ///
  /// In en, this message translates to:
  /// **'View Full Prompt'**
  String get viewFullPrompt;

  /// Snack bar text after copying
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Placeholder snackbar for barcode
  ///
  /// In en, this message translates to:
  /// **'Barcode scanning coming soon!'**
  String get barcodeScanningComingSoon;

  /// Placeholder snackbar for search
  ///
  /// In en, this message translates to:
  /// **'Product search coming soon!'**
  String get productSearchComingSoon;

  /// Prompt to configure API key for AI tips
  ///
  /// In en, this message translates to:
  /// **'Please configure your OpenAI API key in settings to use AI tips'**
  String get configureApiKeyForAiTips;

  /// Error getting AI tip
  ///
  /// In en, this message translates to:
  /// **'Failed to get AI tip. Please try again.'**
  String get failedToGetAiTip;

  /// Title for AI nutrition tips
  ///
  /// In en, this message translates to:
  /// **'AI Nutrition Tip'**
  String get aiNutritionTip;

  /// Link availability true
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Link availability false
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// Chat and AI settings section title
  ///
  /// In en, this message translates to:
  /// **'Chat & AI Settings'**
  String get chatAndAiSettings;

  /// Chat agent options title
  ///
  /// In en, this message translates to:
  /// **'Chat Agent Options'**
  String get chatAgentOptions;

  /// Chat agent options subtitle
  ///
  /// In en, this message translates to:
  /// **'Enable agent mode, deep search, and more'**
  String get enableAgentModeDeepSearch;

  /// Chat profiles section title
  ///
  /// In en, this message translates to:
  /// **'Chat Profiles'**
  String get chatProfiles;

  /// User chat profile section
  ///
  /// In en, this message translates to:
  /// **'Your Profile'**
  String get userChatProfile;

  /// Bot chat profile section
  ///
  /// In en, this message translates to:
  /// **'Bot Profile'**
  String get botChatProfile;

  /// Subtitle for user profile customization
  ///
  /// In en, this message translates to:
  /// **'Customize your chat profile'**
  String get customizeUserProfile;

  /// Subtitle for bot profile customization
  ///
  /// In en, this message translates to:
  /// **'Customize the bot\'s personality and appearance'**
  String get customizeBotProfile;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Bot name field label
  ///
  /// In en, this message translates to:
  /// **'Bot Name'**
  String get botName;

  /// Avatar field label
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// Change avatar button text
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get changeAvatar;

  /// Remove avatar button text
  ///
  /// In en, this message translates to:
  /// **'Remove Avatar'**
  String get removeAvatar;

  /// Personality field label
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get personality;

  /// Select personality dropdown title
  ///
  /// In en, this message translates to:
  /// **'Select Personality'**
  String get selectPersonality;

  /// Professional nutritionist personality type
  ///
  /// In en, this message translates to:
  /// **'Professional Nutritionist'**
  String get professionalNutritionist;

  /// Casual gym bro personality type
  ///
  /// In en, this message translates to:
  /// **'Casual Gym Bro'**
  String get casualGymBro;

  /// Angry Greg personality type
  ///
  /// In en, this message translates to:
  /// **'Angry Greg'**
  String get angryGreg;

  /// Very angry bro personality type
  ///
  /// In en, this message translates to:
  /// **'Very Angry Bro'**
  String get veryAngryBro;

  /// Fitness coach personality type
  ///
  /// In en, this message translates to:
  /// **'Fitness Coach'**
  String get fitnessCoach;

  /// Nice and friendly personality type
  ///
  /// In en, this message translates to:
  /// **'Nice & Friendly'**
  String get niceAndFriendly;

  /// Select image button text
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// Profile save success message
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get profileSaved;

  /// Profile save error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get profileSaveFailed;

  /// Edit user profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit User Profile'**
  String get editUserProfile;

  /// Edit bot profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Bot Profile'**
  String get editBotProfile;

  /// Connect to health button text
  ///
  /// In en, this message translates to:
  /// **'Connect to Health'**
  String get connectToHealth;

  /// Health data sync section title
  ///
  /// In en, this message translates to:
  /// **'Health Data Sync'**
  String get healthDataSync;

  /// Health data connected status message
  ///
  /// In en, this message translates to:
  /// **'Health data connected'**
  String get healthConnected;

  /// Health data disconnected status message
  ///
  /// In en, this message translates to:
  /// **'Health data not connected'**
  String get healthDisconnected;

  /// Sync health data button text
  ///
  /// In en, this message translates to:
  /// **'Sync Health Data'**
  String get syncHealthData;

  /// Health permission required message
  ///
  /// In en, this message translates to:
  /// **'Health permissions are required to sync your data'**
  String get healthPermissionRequired;

  /// Health sync success message
  ///
  /// In en, this message translates to:
  /// **'Health data synced successfully'**
  String get healthSyncSuccess;

  /// Health sync failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to sync health data'**
  String get healthSyncFailed;

  /// Last synced timestamp
  ///
  /// In en, this message translates to:
  /// **'Last synced: {date}'**
  String lastSynced(String date);

  /// Health permission denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Health Permission Denied'**
  String get healthPermissionDenied;

  /// Health permission denied dialog message
  ///
  /// In en, this message translates to:
  /// **'To sync your health data, PlatePal needs access to your health information. You can grant permissions in your phone\'s settings.'**
  String get healthPermissionDeniedMessage;

  /// Open settings button text
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// Health data not available dialog title
  ///
  /// In en, this message translates to:
  /// **'Health Data Not Available'**
  String get healthNotAvailable;

  /// Health data not available dialog message
  ///
  /// In en, this message translates to:
  /// **'Health data is not available on this device. Make sure you have Health Connect (Android) or Health app (iOS) installed and configured.'**
  String get healthNotAvailableMessage;

  /// Instruction text for barcode scanning
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode to quickly add products'**
  String get scanBarcodeToAddProduct;

  /// Instruction text for product search
  ///
  /// In en, this message translates to:
  /// **'Search for products by name'**
  String get searchForProducts;

  /// Message when product is not found
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// Success message when product is added
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get productAddedSuccessfully;

  /// Error message for barcode scanning
  ///
  /// In en, this message translates to:
  /// **'Error scanning barcode: {error}'**
  String errorScanningBarcode(String error);

  /// Error message for product search
  ///
  /// In en, this message translates to:
  /// **'Error searching for product: {error}'**
  String errorSearchingProduct(String error);

  /// Barcode scanner title
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanner'**
  String get barcodeScanner;

  /// Product search title
  ///
  /// In en, this message translates to:
  /// **'Product Search'**
  String get productSearch;

  /// Instruction to tap to scan
  ///
  /// In en, this message translates to:
  /// **'Tap to scan a barcode'**
  String get tapToScan;

  /// Status message while scanning
  ///
  /// In en, this message translates to:
  /// **'Scanning barcode...'**
  String get scanningBarcode;

  /// Placeholder text for product search
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// Message when no products are found in search
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Button to add product to ingredients
  ///
  /// In en, this message translates to:
  /// **'Add to Ingredients'**
  String get addToIngredients;

  /// Product details title
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// Product brand label
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// Message when camera permission is needed
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required for barcode scanning'**
  String get cameraPermissionRequired;

  /// Button to grant camera permission
  ///
  /// In en, this message translates to:
  /// **'Grant Camera Permission'**
  String get grantCameraPermission;

  /// Error message when product is not found for scanned barcode
  ///
  /// In en, this message translates to:
  /// **'Product not found for this barcode'**
  String get barcodeNotFound;

  /// Hint text for product search input
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enterProductName;

  /// Suggestion when no products are found
  ///
  /// In en, this message translates to:
  /// **'Try different keywords'**
  String get tryDifferentKeywords;

  /// Title for serving size selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Serving Size'**
  String get selectServingSize;

  /// Instructions to enable camera permission
  ///
  /// In en, this message translates to:
  /// **'Please enable camera permission in settings to scan barcodes'**
  String get enableCameraPermission;

  /// Title for macro customization screen
  ///
  /// In en, this message translates to:
  /// **'Macro Customization'**
  String get macroCustomization;

  /// Information text explaining macro customization
  ///
  /// In en, this message translates to:
  /// **'Customize your macro targets. All percentages must add up to 100%.'**
  String get macroCustomizationInfo;

  /// Success message when macro targets are saved
  ///
  /// In en, this message translates to:
  /// **'Macro targets updated successfully'**
  String get macroTargetsUpdated;

  /// Reset to default values button text
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// Title for health data info dialog
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthDataTitle;

  /// Title for health data info dialog when viewing today's partial data
  ///
  /// In en, this message translates to:
  /// **'Health Data (Today - Partial)'**
  String get healthDataTodayPartial;

  /// Title for estimated calories info dialog for today
  ///
  /// In en, this message translates to:
  /// **'Estimated Calories (Today)'**
  String get estimatedCaloriesToday;

  /// Title for estimated calories info dialog
  ///
  /// In en, this message translates to:
  /// **'Estimated Calories'**
  String get estimatedCalories;

  /// Message explaining health data source for complete days
  ///
  /// In en, this message translates to:
  /// **'This data was gathered from health data on your phone, providing accurate calories burned information from your fitness activities for this complete day.'**
  String get healthDataMessage;

  /// Message explaining health data source for today's partial data
  ///
  /// In en, this message translates to:
  /// **'This data was gathered from health data on your phone. Since today isn\'t complete yet, this represents calories burned so far today. Your total may increase as you continue activities throughout the day.'**
  String get healthDataTodayMessage;

  /// Message explaining estimated calories for today
  ///
  /// In en, this message translates to:
  /// **'This is your estimated calorie expenditure for today based on your activity level. Since the day isn\'t complete yet, this represents your base metabolic rate plus estimated activity. Your actual calories burned may be higher if you do more activities today.'**
  String get estimatedCaloriesTodayMessage;

  /// Message explaining estimated calories for past dates
  ///
  /// In en, this message translates to:
  /// **'This data is estimated based on your profile settings and activity level since health data wasn\'t available for this date.'**
  String get estimatedCaloriesMessage;

  /// Button text to analyze calorie targets
  ///
  /// In en, this message translates to:
  /// **'Analyze Targets'**
  String get analyzeTargets;

  /// Button text for debugging health data
  ///
  /// In en, this message translates to:
  /// **'Debug Health Data'**
  String get debugHealthData;

  /// Button text to disconnect from health services
  ///
  /// In en, this message translates to:
  /// **'Disconnect Health'**
  String get disconnectHealth;

  /// Title for calorie target analysis dialog
  ///
  /// In en, this message translates to:
  /// **'Calorie Target Analysis'**
  String get calorieTargetAnalysis;

  /// Label for number of days analyzed
  ///
  /// In en, this message translates to:
  /// **'Days Analyzed'**
  String get daysAnalyzed;

  /// Label for current calorie target
  ///
  /// In en, this message translates to:
  /// **'Current Target'**
  String get currentTarget;

  /// Label for average calorie expenditure
  ///
  /// In en, this message translates to:
  /// **'Average Expenditure'**
  String get averageExpenditure;

  /// Label for suggested calorie target
  ///
  /// In en, this message translates to:
  /// **'Suggested Target'**
  String get suggestedTarget;

  /// Button text to apply suggested calorie target
  ///
  /// In en, this message translates to:
  /// **'Apply Suggestion'**
  String get applySuggestion;

  /// Success message for calorie target updates
  ///
  /// In en, this message translates to:
  /// **'Calorie targets updated successfully!'**
  String get calorieTargetsUpdated;

  /// Error message for failed calorie target updates
  ///
  /// In en, this message translates to:
  /// **'Failed to update calorie targets'**
  String get failedToUpdateTargets;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Loard more'**
  String get loadMore;

  /// No description provided for @localDishes.
  ///
  /// In en, this message translates to:
  /// **'Local Dishes'**
  String get localDishes;

  /// No description provided for @localIngredients.
  ///
  /// In en, this message translates to:
  /// **'Local ingredients'**
  String get localIngredients;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
