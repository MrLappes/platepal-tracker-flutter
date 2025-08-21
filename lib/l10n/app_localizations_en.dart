// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PlatePal Tracker';

  @override
  String get welcome => 'Welcome to PlatePal';

  @override
  String get meals => 'Meals';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get addMeal => 'Add Meal';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get noMealsLogged => 'No meals logged yet';

  @override
  String get startTrackingMeals => 'Start tracking your meals to see them here';

  @override
  String get todaysMeals => 'Today\'s Meals';

  @override
  String get allMeals => 'All Meals';

  @override
  String get mealHistory => 'Meal History';

  @override
  String get filterByMealType => 'Filter by meal type';

  @override
  String get logMeal => 'Log Meal';

  @override
  String mealLoggedAt(String time) {
    return 'Logged at $time';
  }

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get calendar => 'Calendar';

  @override
  String get unknownDish => 'Unknown Dish';

  @override
  String get noMealsLoggedForDay => 'No meals logged for this day';

  @override
  String get nutritionSummary => 'Nutrition Summary';

  @override
  String get getAiTip => 'Get AI Tip';

  @override
  String get deleteLog => 'Delete Log';

  @override
  String get deleteLogConfirmation => 'Are you sure you want to delete this logged meal?';

  @override
  String get delete => 'Delete';

  @override
  String get mealLogDeletedSuccessfully => 'Meal log deleted successfully';

  @override
  String get failedToDeleteMealLog => 'Failed to delete meal log';

  @override
  String get chat => 'Chat';

  @override
  String get menu => 'Menu';

  @override
  String get userProfile => 'User Profile';

  @override
  String get nutritionGoals => 'Nutrition Goals';

  @override
  String get appearance => 'Appearance';

  @override
  String get aiFeatures => 'AI & Features';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get information => 'Information';

  @override
  String get apiKeySettings => 'API Key Settings';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get selectFile => 'Select File';

  @override
  String get selectFilesToImport => 'Select files to import';

  @override
  String get importFromFile => 'Import from File';

  @override
  String get importJson => 'Import JSON';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get exportAsJson => 'Export as JSON';

  @override
  String get exportAsCsv => 'Export as CSV';

  @override
  String get selectDataToExport => 'Select data to export';

  @override
  String get selectDataToImport => 'Select data to import';

  @override
  String get userProfiles => 'User Profiles';

  @override
  String get mealLogs => 'Meal Logs';

  @override
  String get dishes => 'Dishes';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get supplements => 'Supplements';

  @override
  String get nutritionGoalsData => 'Nutrition Goals';

  @override
  String get allData => 'All Data';

  @override
  String get importProgress => 'Importing data...';

  @override
  String get exportProgress => 'Exporting data...';

  @override
  String get importSuccessful => 'Data imported successfully';

  @override
  String get exportSuccessful => 'Data exported successfully';

  @override
  String get importFailed => 'Import failed';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get invalidFileFormat => 'Invalid file format';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get dataValidationFailed => 'Data validation failed';

  @override
  String importedItemsCount(int count) {
    return 'Imported $count items';
  }

  @override
  String exportedItemsCount(int count) {
    return 'Exported $count items';
  }

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get backupCreatedSuccessfully => 'Backup created successfully';

  @override
  String get restoreSuccessful => 'Restore completed successfully';

  @override
  String get warningDataWillBeReplaced => 'Warning: Existing data will be replaced';

  @override
  String get confirmRestore => 'Are you sure you want to restore? This will replace all existing data.';

  @override
  String fileSize(String size) {
    return 'File size: $size';
  }

  @override
  String duplicateItemsFound(int count) {
    return 'Duplicate items found: $count';
  }

  @override
  String get howToHandleDuplicates => 'How to handle duplicates?';

  @override
  String get skipDuplicates => 'Skip Duplicates';

  @override
  String get overwriteDuplicates => 'Overwrite Duplicates';

  @override
  String get mergeDuplicates => 'Merge Duplicates';

  @override
  String formatNotSupported(String format) {
    return 'Format not supported: $format';
  }

  @override
  String get about => 'About';

  @override
  String get aboutAppTitle => 'About the App';

  @override
  String get madeBy => 'Made by MrLappes';

  @override
  String get website => 'plate-pal.de';

  @override
  String get githubRepository => 'github.com/MrLappes/platepal-tracker';

  @override
  String get appMotto => 'Made by gym guys for gym guys that hate paid apps';

  @override
  String get codersMessage => 'Coders shouldn\'t have to pay';

  @override
  String get whyPlatePal => 'Why PlatePal?';

  @override
  String get aboutDescription => 'PlatePal Tracker was created to provide a privacy-focused, open-source alternative to expensive nutrition tracking apps. We believe in putting control in your hands with no subscriptions, no ads, and no data collection.';

  @override
  String get dataStaysOnDevice => 'Your data stays on your device';

  @override
  String get useOwnAiKey => 'Use your own AI key for full control';

  @override
  String get freeOpenSource => '100% free and open source';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get linkError => 'An error occurred opening the link';

  @override
  String get contributors => 'Contributors';

  @override
  String get editPersonalInfo => 'Edit your personal information';

  @override
  String get setNutritionTargets => 'Set your daily nutrition targets';

  @override
  String get configureApiKey => 'Configure your OpenAI API key';

  @override
  String get exportMealData => 'Export your meal data';

  @override
  String get importMealDataBackup => 'Import meal data from backup';

  @override
  String get learnMorePlatePal => 'Learn more about PlatePal';

  @override
  String get viewContributors => 'View project contributors';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get german => 'German';

  @override
  String get contributorSingular => 'Contributor';

  @override
  String get contributorPlural => 'Contributors';

  @override
  String get contributorsThankYou => 'Thanks to everyone who has contributed to making PlatePal Tracker possible!';

  @override
  String get wantToContribute => 'Want to Contribute?';

  @override
  String get openSourceMessage => 'PlatePal Tracker is open source - join us on GitHub!';

  @override
  String get checkGitHub => 'Check Out Our GitHub Repository';

  @override
  String get supportDevelopment => 'Support Development';

  @override
  String get supportMessage => 'You want to buy me my creatine? Your support is greatly appreciated but not at all mandatory.';

  @override
  String get buyMeCreatine => 'Buy Me Creatine';

  @override
  String get openingLink => 'Opening Buy Me Creatine page...';

  @override
  String get aboutOpenAiApiKey => 'About OpenAI API Key';

  @override
  String get apiKeyDescription => 'To use AI features like meal analysis and suggestions, you need to provide your own OpenAI API key. This ensures your data stays private and you have full control.';

  @override
  String get apiKeyBulletPoints => '• Get your API key from platform.openai.com\n• Your key is stored locally on your device\n• Usage charges apply directly to your OpenAI account';

  @override
  String get apiKeyConfigured => 'API Key Configured';

  @override
  String get aiFeaturesEnabled => 'AI features are enabled';

  @override
  String get openAiApiKey => 'OpenAI API Key';

  @override
  String get apiKeyPlaceholder => 'sk-...';

  @override
  String get apiKeyHelperText => 'Enter your OpenAI API key or leave empty to disable AI features';

  @override
  String get updateApiKey => 'Update API Key';

  @override
  String get saveApiKey => 'Save API Key';

  @override
  String get getApiKeyFromOpenAi => 'Get API Key from OpenAI';

  @override
  String get removeApiKey => 'Remove API Key';

  @override
  String get removeApiKeyConfirmation => 'Are you sure you want to remove your API key? This will disable AI features.';

  @override
  String get cancel => 'Cancel';

  @override
  String get remove => 'Remove';

  @override
  String get apiKeyMustStartWith => 'API key must start with \"sk-\"';

  @override
  String get apiKeyTooShort => 'API key appears to be too short';

  @override
  String get apiKeyRemovedSuccessfully => 'API key removed successfully';

  @override
  String get apiKeySavedSuccessfully => 'API key saved successfully';

  @override
  String get failedToLoadApiKey => 'Failed to load API key';

  @override
  String get failedToSaveApiKey => 'Failed to save API key';

  @override
  String get failedToRemoveApiKey => 'Failed to remove API key';

  @override
  String get visitOpenAiPlatform => 'Visit platform.openai.com to get your API key';

  @override
  String get pasteFromClipboard => 'Paste from Clipboard';

  @override
  String get clipboardEmpty => 'Clipboard is empty';

  @override
  String get pastedFromClipboard => 'Pasted from clipboard';

  @override
  String get failedToAccessClipboard => 'Failed to access clipboard';

  @override
  String get selectModel => 'Select Model';

  @override
  String get testAndSaveApiKey => 'Test & Save API Key';

  @override
  String get testingApiKey => 'Testing API key...';

  @override
  String get gpt4ModelsInfo => 'GPT-4 models provide the best analysis but cost more';

  @override
  String get gpt35ModelsInfo => 'GPT-3.5 models are more cost-effective for basic analysis';

  @override
  String get loadingModels => 'Loading available models...';

  @override
  String get couldNotLoadModels => 'Could not load available models. Using default model list';

  @override
  String get apiKeyTestWarning => 'Your API key will be tested with a small request to verify it works. The key is only stored on your device and never sent to our servers';

  @override
  String get ok => 'OK';

  @override
  String get welcomeToPlatePalTracker => 'Welcome to PlatePal Tracker';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get targetWeight => 'Target Weight';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get lightlyActive => 'Lightly Active';

  @override
  String get moderatelyActive => 'Moderately Active';

  @override
  String get veryActive => 'Very Active';

  @override
  String get extraActive => 'Extra Active';

  @override
  String get fitnessGoals => 'Fitness Goals';

  @override
  String get fitnessGoal => 'Fitness Goal';

  @override
  String get loseWeight => 'Lose Weight';

  @override
  String get maintainWeight => 'Maintain Weight';

  @override
  String get gainWeight => 'Gain Weight';

  @override
  String get buildMuscle => 'Build Muscle';

  @override
  String get preferences => 'Preferences';

  @override
  String get unitSystem => 'Unit System';

  @override
  String get metric => 'Metric (kg, cm)';

  @override
  String get imperial => 'Imperial (lb, ft)';

  @override
  String get save => 'Save';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get discardChanges => 'Discard Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get profileUpdateFailed => 'Failed to update profile';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get unsavedChangesMessage => 'You have unsaved changes. Do you want to save them before leaving?';

  @override
  String get deleteProfile => 'Delete Profile';

  @override
  String get deleteProfileConfirmation => 'Are you sure you want to delete your profile? This action cannot be undone.';

  @override
  String get loading => 'Loading...';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get ageRange => 'Age must be between 13 and 120';

  @override
  String get heightRange => 'Height must be between 100-250 cm';

  @override
  String get weightRange => 'Weight must be between 30-300 kg';

  @override
  String get currentStats => 'Current Stats';

  @override
  String get bmi => 'BMI';

  @override
  String get bmr => 'BMR';

  @override
  String get tdee => 'TDEE';

  @override
  String get years => 'years';

  @override
  String get cm => 'cm';

  @override
  String get kg => 'kg';

  @override
  String get lb => 'lb';

  @override
  String get ft => 'ft';

  @override
  String get inches => 'in';

  @override
  String get chatAssistant => 'AI Chat Assistant';

  @override
  String get chatSubtitle => 'Get personalized meal suggestions and nutrition advice';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get sendMessage => 'Send message';

  @override
  String get analyzeDish => 'Analyze Dish';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get searchProduct => 'Search Product';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get suggestMeal => 'Suggest a meal';

  @override
  String get analyzeNutrition => 'Analyze nutrition';

  @override
  String get findAlternatives => 'Find alternatives';

  @override
  String get calculateMacros => 'Calculate macros';

  @override
  String get mealPlan => 'Meal plan help';

  @override
  String get ingredientInfo => 'Ingredient info';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get clearChatConfirmation => 'Are you sure you want to clear the chat history? This action cannot be undone.';

  @override
  String get chatCleared => 'Chat history cleared';

  @override
  String get messageFailedToSend => 'Failed to send message';

  @override
  String get retryMessage => 'Retry';

  @override
  String get copyMessage => 'Copy message';

  @override
  String get messageCopied => 'Message copied to clipboard';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get noApiKeyConfigured => 'No API key configured';

  @override
  String get configureApiKeyToUseChat => 'Please configure your OpenAI API key in settings to use the AI chat assistant.';

  @override
  String get configureApiKeyButton => 'Configure API Key';

  @override
  String get reloadApiKeyButton => 'Reload API Key';

  @override
  String get welcomeToChat => 'Welcome to your AI nutrition assistant! Ask me anything about meals, nutrition, or your fitness goals.';

  @override
  String get attachImage => 'Attach image';

  @override
  String get imageAttached => 'Image attached';

  @override
  String get removeImage => 'Remove image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get imageSourceSelection => 'Select Image Source';

  @override
  String get nutritionAnalysis => 'Nutrition Analysis';

  @override
  String get addToMeals => 'Add to Meals';

  @override
  String get details => 'Details';

  @override
  String get tapToViewAgentSteps => 'Tap to view agent steps';

  @override
  String addedToMealsSuccess(String dishName) {
    return 'Added $dishName to meals';
  }

  @override
  String get close => 'Close';

  @override
  String get servingSize => 'Serving Size';

  @override
  String get perServing => 'per serving';

  @override
  String get dishName => 'Dish Name';

  @override
  String get cookingInstructions => 'Cooking Instructions';

  @override
  String get mealType => 'Meal Type';

  @override
  String get addedToMeals => 'Added to meals successfully';

  @override
  String get failedToAddMeal => 'Failed to add meal';

  @override
  String get testChatWelcome => 'This is test mode! I can help you explore PlatePal\'s features. Try asking me about nutrition, meal planning, or food recommendations.';

  @override
  String get testChatResponse => 'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.';

  @override
  String get chatWelcomeTitle => 'Welcome to PlatePal';

  @override
  String get chatWelcomeSubtitle => 'Your AI nutrition assistant is here to help';

  @override
  String get getStartedToday => 'Get started today';

  @override
  String get whatCanIHelpWith => 'What can I help you with?';

  @override
  String get featureComingSoon => 'This feature is coming soon!';

  @override
  String get statistics => 'Statistics';

  @override
  String get viewStatistics => 'View Statistics';

  @override
  String get weightHistory => 'Weight History';

  @override
  String get bmiHistory => 'BMI History';

  @override
  String get bodyFatHistory => 'Body Fat History';

  @override
  String get calorieIntakeHistory => 'Calorie Intake vs Maintenance';

  @override
  String get weightStatsTip => 'The graph shows median weekly weight to account for daily fluctuations due to water weight.';

  @override
  String get bmiStatsTip => 'Body Mass Index (BMI) is calculated from your weight and height measurements.';

  @override
  String get bodyFatStatsTip => 'Body fat percentage helps track your body composition beyond just weight.';

  @override
  String get calorieStatsTip => 'Compare your daily calorie intake to your maintenance calories. Green indicates maintenance, blue is cutting phase, orange is bulking phase.';

  @override
  String get notEnoughDataTitle => 'Not Enough Data';

  @override
  String get statisticsEmptyDescription => 'We need at least a week of data to show meaningful statistics. Keep tracking your metrics to see trends over time.';

  @override
  String get updateMetricsNow => 'Update Metrics Now';

  @override
  String get timeRange => 'Time Range';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get threeMonths => '3 Months';

  @override
  String get sixMonths => '6 Months';

  @override
  String get year => 'Year';

  @override
  String get allTime => 'All Time';

  @override
  String get bulking => 'Bulking';

  @override
  String get cutting => 'Cutting';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get extremeLowCalorieWarning => 'Extreme Low Calorie Warning';

  @override
  String get extremeHighCalorieWarning => 'Extreme High Calorie Warning';

  @override
  String get caloriesTooLowMessage => 'Your calorie intake is significantly below recommendations. This may affect your health and metabolism.';

  @override
  String get caloriesTooHighMessage => 'Your calorie intake is significantly above recommendations. Consider adjusting your portions.';

  @override
  String get weeklyDeficit => 'Weekly Deficit';

  @override
  String get weeklySurplus => 'Weekly Surplus';

  @override
  String get phaseAnalysis => 'Phase Analysis';

  @override
  String get weeklyAverage => 'Weekly Average';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get lastThreeMonths => 'Last 3 Months';

  @override
  String get lastSixMonths => 'Last 6 Months';

  @override
  String get lastYear => 'Last Year';

  @override
  String get generateTestData => 'Generate Test Data';

  @override
  String get testDataDescription => 'For demonstration purposes, you can generate sample data to see how the statistics look.';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get refresh => 'Refresh';

  @override
  String get realData => 'Real Data';

  @override
  String get noWeightDataAvailable => 'No weight data available';

  @override
  String get noBmiDataAvailable => 'No BMI data available';

  @override
  String get cannotCalculateBmiFromData => 'Cannot calculate BMI from available data';

  @override
  String get noBodyFatDataAvailable => 'No body fat data available';

  @override
  String get noCalorieDataAvailable => 'No calorie data available';

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObese => 'Obese';

  @override
  String get healthDataIntegration => 'Health Data Integration';

  @override
  String healthDataCoverage(String coverage, String healthDataDays, String totalDays) {
    return 'Calorie expenditure data coverage: $coverage% ($healthDataDays/$totalDays days)';
  }

  @override
  String get healthDataActive => 'Using your health app data to provide more accurate deficit/surplus analysis.';

  @override
  String get healthDataInactive => 'Enable health data sync in Profile Settings for more accurate analysis.';

  @override
  String get calorieBalanceTitle => 'Calorie Balance (Intake vs Expenditure)';

  @override
  String get calorieBalanceTip => 'Track your actual calorie balance using health data. Green = maintenance, Blue = deficit, Orange = surplus.';

  @override
  String get estimatedBalance => 'Estimated Balance';

  @override
  String get actualBalance => 'Actual Balance';

  @override
  String get vsExpenditure => 'vs expenditure';

  @override
  String healthDataAlert(String days) {
    return 'Health Data Alert: $days day(s) with very large calorie deficits (>1000 cal) based on actual expenditure.';
  }

  @override
  String inconsistentDeficitWarning(String variance) {
    return 'Warning: Your calorie deficit varies significantly day-to-day (variance: $variance cal). Consider more consistent intake.';
  }

  @override
  String veryLowCalorieWarning(String days) {
    return 'Warning: $days day(s) with extremely low calorie intake (<1000 cal). This may be unhealthy.';
  }

  @override
  String veryHighCalorieNotice(String days) {
    return 'Notice: $days day(s) with very high calorie intake (>1000 cal above maintenance).';
  }

  @override
  String get extremeDeficitWarning => 'Warning: Frequent extreme calorie deficits may slow metabolism and cause muscle loss.';

  @override
  String get maintenanceLabel => 'Maintenance';

  @override
  String get bodyFat => 'Body Fat';

  @override
  String get resetApp => 'Reset App';

  @override
  String get resetAppTitle => 'Reset Application Data';

  @override
  String get resetAppDescription => 'This will permanently delete ALL your data including:\n\n• Your profile information\n• All meal logs and nutrition data\n• All preferences and settings\n• All stored information\n\nThis action cannot be undone. Are you sure you want to continue?';

  @override
  String get resetAppConfirm => 'Yes, Delete Everything';

  @override
  String get resetAppCancel => 'Cancel';

  @override
  String get resetAppSuccess => 'Application data has been reset successfully';

  @override
  String get resetAppError => 'Failed to reset application data';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get chatAgentSettingsTitle => 'Chat Agent Settings';

  @override
  String get chatAgentEnableTitle => 'Enable Agent Mode';

  @override
  String get chatAgentEnableSubtitle => 'Use the multi-step agent pipeline for chat';

  @override
  String get chatAgentDeepSearchTitle => 'Enable Deep Search';

  @override
  String get chatAgentDeepSearchSubtitle => 'Allow the agent to use deep search for more accurate answers';

  @override
  String get chatAgentInfoTitle => 'What is Agent Mode?';

  @override
  String get chatAgentInfoDescription => 'Agent mode enables PlatePal\'s advanced multi-step reasoning pipeline for chat. This allows the assistant to analyze your query, gather context, and provide more accurate, explainable answers. Deep Search lets the agent use more data for even better results.';

  @override
  String get chatSettingsSaved => 'Chat settings saved successfully';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get pleaseEnterDishName => 'Please enter a dish name';

  @override
  String get imageUrl => 'Image URL';

  @override
  String get optional => 'Optional';

  @override
  String get nutritionInfo => 'Nutrition Information';

  @override
  String get required => 'Required';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get noIngredientsAdded => 'No ingredients added yet';

  @override
  String get ingredientsAdded => 'Ingredients Added';

  @override
  String get options => 'Options';

  @override
  String get markAsFavorite => 'Mark as favorite dish';

  @override
  String get editDish => 'Edit Dish';

  @override
  String get dishUpdatedSuccessfully => 'Dish updated successfully';

  @override
  String get dishCreatedSuccessfully => 'Dish created successfully';

  @override
  String get errorSavingDish => 'Error saving dish';

  @override
  String get ingredientName => 'Ingredient Name';

  @override
  String get pleaseEnterIngredientName => 'Please enter an ingredient name';

  @override
  String get amount => 'Amount';

  @override
  String get unit => 'Unit';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get retry => 'Retry';

  @override
  String get errorLoggingDish => 'There was an error logging the dish';

  @override
  String get allCategories => 'All Categories';

  @override
  String get searchDishes => 'Search dishes...';

  @override
  String get createDish => 'Create Dish';

  @override
  String get noDishesCreated => 'No dishes created yet';

  @override
  String get createFirstDish => 'Create your first dish to get started';

  @override
  String get errorLoadingDishes => 'Error loading dishes';

  @override
  String get noDishesFound => 'No dishes found';

  @override
  String get tryAdjustingSearch => 'Try adjusting your search terms';

  @override
  String get deleteDish => 'Delete Dish';

  @override
  String deleteDishConfirmation(String dishName) {
    return 'Are you sure you want to delete \"$dishName\"?';
  }

  @override
  String get dishDeletedSuccessfully => 'Dish deleted successfully';

  @override
  String get failedToDeleteDish => 'Failed to delete dish';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get errorUpdatingDish => 'Error updating dish';

  @override
  String get addToFavorites => 'Add to Favorites';

  @override
  String get removeFromFavorites => 'Remove from Favorites';

  @override
  String get fiber => 'Fiber';

  @override
  String get favorite => 'Favorite';

  @override
  String get createNewDish => 'Create New Dish';

  @override
  String get errorCreatingDish => 'Error creating dish';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String get pleaseEnterValidUrl => 'Please enter a valid URL';

  @override
  String get pleaseEnterIngredient => 'Please enter an ingredient';

  @override
  String get errorDeletingDish => 'Error deleting dish';

  @override
  String get confirmDeleteDish => 'Are you sure you want to delete this dish?';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get caloriesPer100g => 'Calories per 100g';

  @override
  String get proteinPer100g => 'Protein per 100g';

  @override
  String get carbsPer100g => 'Carbs per 100g';

  @override
  String get fatPer100g => 'Fat per 100g';

  @override
  String get fiberPer100g => 'Fiber per 100g';

  @override
  String get invalidImageUrl => 'Invalid image URL';

  @override
  String get enterIngredientName => 'Enter ingredient name';

  @override
  String get toggleFavorite => 'Toggle Favorite';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get dishNamePlaceholder => 'Enter dish name';

  @override
  String get descriptionPlaceholder => 'Enter description (optional)';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get nutritionalInformation => 'Nutritional Information';

  @override
  String get per100g => 'per 100g';

  @override
  String get recalculate => 'Recalculate';

  @override
  String get recalculateNutrition => 'Recalculate Nutrition';

  @override
  String get nutritionRecalculated => 'Nutrition recalculated from ingredients';

  @override
  String get addManually => 'Add Manually';

  @override
  String get saveDish => 'Save Dish';

  @override
  String get saving => 'Saving...';

  @override
  String get mg => 'mg';

  @override
  String get mcg => 'μg';

  @override
  String get iu => 'IU';

  @override
  String get g => 'g';

  @override
  String get ml => 'ml';

  @override
  String get cup => 'cup';

  @override
  String get tbsp => 'tbsp';

  @override
  String get tsp => 'tsp';

  @override
  String get oz => 'oz';

  @override
  String get piece => 'piece';

  @override
  String get slice => 'slice';

  @override
  String get tablespoon => 'tablespoon';

  @override
  String get teaspoon => 'teaspoon';

  @override
  String get ounce => 'ounce';

  @override
  String get pound => 'pound';

  @override
  String get gram => 'gram';

  @override
  String get kilogram => 'kilogram';

  @override
  String get milliliter => 'milliliter';

  @override
  String get liter => 'liter';

  @override
  String get editIngredient => 'Edit Ingredient';

  @override
  String get deleteIngredient => 'Delete Ingredient';

  @override
  String get confirmDeleteIngredient => 'Are you sure you want to delete this ingredient?';

  @override
  String get ingredientDeleted => 'Ingredient deleted';

  @override
  String get ingredientAdded => 'Ingredient added';

  @override
  String get ingredientUpdated => 'Ingredient updated';

  @override
  String get errorAddingIngredient => 'Error adding ingredient';

  @override
  String get errorUpdatingIngredient => 'Error updating ingredient';

  @override
  String get errorDeletingIngredient => 'Error deleting ingredient';

  @override
  String get noNutritionData => 'No nutrition data available';

  @override
  String get ingredientNamePlaceholder => 'Enter ingredient name';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityPlaceholder => 'Enter quantity';

  @override
  String get pleaseEnterQuantity => 'Please enter a quantity';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get unitPlaceholder => 'e.g., g, cup, piece';

  @override
  String get pleaseEnterUnit => 'Please enter a unit';

  @override
  String get nutritionInformation => 'Nutrition Information';

  @override
  String get nutritionPer100g => 'Nutrition per 100g';

  @override
  String get caloriesPlaceholder => 'Enter calories';

  @override
  String get kcal => 'kcal';

  @override
  String get grams => 'g';

  @override
  String get logDish => 'Log Dish';

  @override
  String get logDishTitle => 'Log Dish';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectMealType => 'Select Meal Type';

  @override
  String get portionSize => 'Portion Size';

  @override
  String get notes => 'Notes';

  @override
  String get addNotes => 'Add notes (optional)';

  @override
  String get calculatedNutrition => 'Calculated Nutrition';

  @override
  String get dishLoggedSuccessfully => 'Dish logged successfully!';

  @override
  String get select => 'Select';

  @override
  String errorOpeningDishScreen(Object error) {
    return 'Error opening dish screen: $error';
  }

  @override
  String errorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String get agentProcessingSteps => 'Agent Processing Steps';

  @override
  String get copyAll => 'Copy All';

  @override
  String get viewFullData => 'View Full Data';

  @override
  String get viewFullPrompt => 'View Full Prompt';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get barcodeScanningComingSoon => 'Barcode scanning coming soon!';

  @override
  String get productSearchComingSoon => 'Product search coming soon!';

  @override
  String get configureApiKeyForAiTips => 'Please configure your OpenAI API key in settings to use AI tips';

  @override
  String get failedToGetAiTip => 'Failed to get AI tip. Please try again.';

  @override
  String get aiNutritionTip => 'AI Nutrition Tip';

  @override
  String get available => 'Available';

  @override
  String get notAvailable => 'Not available';

  @override
  String get chatAndAiSettings => 'Chat & AI Settings';

  @override
  String get chatAgentOptions => 'Chat Agent Options';

  @override
  String get enableAgentModeDeepSearch => 'Enable agent mode, deep search, and more';

  @override
  String get chatProfiles => 'Chat Profiles';

  @override
  String get userChatProfile => 'Your Profile';

  @override
  String get botChatProfile => 'Bot Profile';

  @override
  String get customizeUserProfile => 'Customize your chat profile';

  @override
  String get customizeBotProfile => 'Customize the bot\'s personality and appearance';

  @override
  String get username => 'Username';

  @override
  String get botName => 'Bot Name';

  @override
  String get avatar => 'Avatar';

  @override
  String get changeAvatar => 'Change Avatar';

  @override
  String get removeAvatar => 'Remove Avatar';

  @override
  String get personality => 'Personality';

  @override
  String get selectPersonality => 'Select Personality';

  @override
  String get professionalNutritionist => 'Professional Nutritionist';

  @override
  String get casualGymBro => 'Casual Gym Bro';

  @override
  String get angryGreg => 'Angry Greg';

  @override
  String get veryAngryBro => 'Very Angry Bro';

  @override
  String get fitnessCoach => 'Fitness Coach';

  @override
  String get niceAndFriendly => 'Nice & Friendly';

  @override
  String get selectImage => 'Select Image';

  @override
  String get profileSaved => 'Profile saved successfully';

  @override
  String get profileSaveFailed => 'Failed to save profile';

  @override
  String get editUserProfile => 'Edit User Profile';

  @override
  String get editBotProfile => 'Edit Bot Profile';

  @override
  String get connectToHealth => 'Connect to Health';

  @override
  String get healthDataSync => 'Health Data Sync';

  @override
  String get healthConnected => 'Health data connected';

  @override
  String get healthDisconnected => 'Health data not connected';

  @override
  String get syncHealthData => 'Sync Health Data';

  @override
  String get healthPermissionRequired => 'Health permissions are required to sync your data';

  @override
  String get healthSyncSuccess => 'Health data synced successfully';

  @override
  String get healthSyncFailed => 'Failed to sync health data';

  @override
  String lastSynced(String date) {
    return 'Last synced: $date';
  }

  @override
  String get healthPermissionDenied => 'Health Permission Denied';

  @override
  String get healthPermissionDeniedMessage => 'To sync your health data, PlatePal needs access to your health information. You can grant permissions in your phone\'s settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get healthNotAvailable => 'Health Data Not Available';

  @override
  String get healthNotAvailableMessage => 'Health data is not available on this device. Make sure you have Health Connect (Android) or Health app (iOS) installed and configured.';

  @override
  String get scanBarcodeToAddProduct => 'Scan a barcode to quickly add products';

  @override
  String get searchForProducts => 'Search for products by name';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get productAddedSuccessfully => 'Product added successfully';

  @override
  String errorScanningBarcode(String error) {
    return 'Error scanning barcode: $error';
  }

  @override
  String errorSearchingProduct(String error) {
    return 'Error searching for product: $error';
  }

  @override
  String get barcodeScanner => 'Barcode Scanner';

  @override
  String get productSearch => 'Product Search';

  @override
  String get tapToScan => 'Tap to scan a barcode';

  @override
  String get scanningBarcode => 'Scanning barcode...';

  @override
  String get searchProducts => 'Search products...';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get addToIngredients => 'Add to Ingredients';

  @override
  String get productDetails => 'Product Details';

  @override
  String get brand => 'Brand';

  @override
  String get cameraPermissionRequired => 'Camera permission is required for barcode scanning';

  @override
  String get grantCameraPermission => 'Grant Camera Permission';

  @override
  String get barcodeNotFound => 'Product not found for this barcode';

  @override
  String get enterProductName => 'Enter product name';

  @override
  String get tryDifferentKeywords => 'Try different keywords';

  @override
  String get selectServingSize => 'Select Serving Size';

  @override
  String get enableCameraPermission => 'Please enable camera permission in settings to scan barcodes';

  @override
  String get macroCustomization => 'Macro Customization';

  @override
  String get macroCustomizationInfo => 'Customize your macro targets. All percentages must add up to 100%.';

  @override
  String get macroTargetsUpdated => 'Macro targets updated successfully';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get healthDataTitle => 'Health Data';

  @override
  String get healthDataTodayPartial => 'Health Data (Today - Partial)';

  @override
  String get estimatedCaloriesToday => 'Estimated Calories (Today)';

  @override
  String get estimatedCalories => 'Estimated Calories';

  @override
  String get healthDataMessage => 'This data was gathered from health data on your phone, providing accurate calories burned information from your fitness activities for this complete day.';

  @override
  String get healthDataTodayMessage => 'This data was gathered from health data on your phone. Since today isn\'t complete yet, this represents calories burned so far today. Your total may increase as you continue activities throughout the day.';

  @override
  String get estimatedCaloriesTodayMessage => 'This is your estimated calorie expenditure for today based on your activity level. Since the day isn\'t complete yet, this represents your base metabolic rate plus estimated activity. Your actual calories burned may be higher if you do more activities today.';

  @override
  String get estimatedCaloriesMessage => 'This data is estimated based on your profile settings and activity level since health data wasn\'t available for this date.';

  @override
  String get analyzeTargets => 'Analyze Targets';

  @override
  String get debugHealthData => 'Debug Health Data';

  @override
  String get disconnectHealth => 'Disconnect Health';

  @override
  String get calorieTargetAnalysis => 'Calorie Target Analysis';

  @override
  String get daysAnalyzed => 'Days Analyzed';

  @override
  String get currentTarget => 'Current Target';

  @override
  String get averageExpenditure => 'Average Expenditure';

  @override
  String get suggestedTarget => 'Suggested Target';

  @override
  String get applySuggestion => 'Apply Suggestion';

  @override
  String get calorieTargetsUpdated => 'Calorie targets updated successfully!';

  @override
  String get failedToUpdateTargets => 'Failed to update calorie targets';

  @override
  String get loadMore => 'Loard more';

  @override
  String get localDishes => 'Local Dishes';

  @override
  String get localIngredients => 'Local ingredients';
}
