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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// Appended to a calendar day's accessible date when meals are logged
  ///
  /// In en, this message translates to:
  /// **'has meals logged'**
  String get screensCalendarHasMealsLogged;

  /// Error loading meal markers for the visible week
  ///
  /// In en, this message translates to:
  /// **'Could not load calendar dates'**
  String get screensCalendarFailedToLoadDates;

  /// Error loading the selected day's nutrition summary
  ///
  /// In en, this message translates to:
  /// **'Could not load nutrition summary'**
  String get screensCalendarFailedToLoadSummary;

  /// Calendar prompt shown when there is no calorie target
  ///
  /// In en, this message translates to:
  /// **'Set up your profile to get daily targets'**
  String get screensCalendarProfileNudge;

  /// Opens profile settings from the calendar
  ///
  /// In en, this message translates to:
  /// **'Set up profile'**
  String get screensCalendarSetUpProfile;

  /// Opens the calendar quick-log dish picker
  ///
  /// In en, this message translates to:
  /// **'Log meal'**
  String get screensCalendarLogMeal;

  /// Calories in a dish serving in the calendar picker
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal per serving'**
  String screensCalendarCaloriesPerServing(int calories);

  /// Error shown when the selected day's meal logs cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'Could not load meals for this day'**
  String get componentsCalendarCalendarDayDetailErrorLoadingMeals;

  /// Message shown when no meals are logged for selected day
  ///
  /// In en, this message translates to:
  /// **'No meals logged for this day'**
  String get componentsCalendarCalendarDayDetailNoMealsLoggedForDay;

  /// Label for dish when name is not available
  ///
  /// In en, this message translates to:
  /// **'Unknown Dish'**
  String get componentsCalendarCalendarDayDetailUnknownDish;

  /// Calories label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get componentsCalendarMacroSummaryCalories;

  /// Carbs label
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get componentsCalendarMacroSummaryCarbs;

  /// Title for estimated calories info dialog
  ///
  /// In en, this message translates to:
  /// **'Estimated Calories'**
  String get componentsCalendarMacroSummaryEstimatedCalories;

  /// Message explaining estimated calories for past dates
  ///
  /// In en, this message translates to:
  /// **'This data is estimated based on your profile settings and activity level since health data wasn\'t available for this date.'**
  String get componentsCalendarMacroSummaryEstimatedCaloriesMessage;

  /// Title for estimated calories info dialog for today
  ///
  /// In en, this message translates to:
  /// **'Estimated Calories (Today)'**
  String get componentsCalendarMacroSummaryEstimatedCaloriesToday;

  /// Message explaining estimated calories for today
  ///
  /// In en, this message translates to:
  /// **'This is your estimated calorie expenditure for today based on your activity level. Since the day isn\'t complete yet, this represents your base metabolic rate plus estimated activity. Your actual calories burned may be higher if you do more activities today.'**
  String get componentsCalendarMacroSummaryEstimatedCaloriesTodayMessage;

  /// Fat label
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get componentsCalendarMacroSummaryFat;

  /// Fiber nutrition label
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get componentsCalendarMacroSummaryFiber;

  /// Button text to get AI nutrition tip
  ///
  /// In en, this message translates to:
  /// **'Get AI Tip'**
  String get componentsCalendarMacroSummaryGetAiTip;

  /// Progress toward a daily nutrition goal
  ///
  /// In en, this message translates to:
  /// **'{percent}% of goal'**
  String componentsCalendarMacroSummaryPercentOfGoal(int percent);

  /// Nutrition amount above a daily goal
  ///
  /// In en, this message translates to:
  /// **'Over goal by {amount} {unit}'**
  String componentsCalendarMacroSummaryOverBy(String amount, String unit);

  /// Message explaining health data source for complete days
  ///
  /// In en, this message translates to:
  /// **'This data was gathered from health data on your phone, providing accurate calories burned information from your fitness activities for this complete day.'**
  String get componentsCalendarMacroSummaryHealthDataMessage;

  /// Title for health data info dialog
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get componentsCalendarMacroSummaryHealthDataTitle;

  /// Message explaining health data source for today's partial data
  ///
  /// In en, this message translates to:
  /// **'This data was gathered from health data on your phone. Since today isn\'t complete yet, this represents calories burned so far today. Your total may increase as you continue activities throughout the day.'**
  String get componentsCalendarMacroSummaryHealthDataTodayMessage;

  /// Title for health data info dialog when viewing today's partial data
  ///
  /// In en, this message translates to:
  /// **'Health Data (Today - Partial)'**
  String get componentsCalendarMacroSummaryHealthDataTodayPartial;

  /// Title for nutrition summary section
  ///
  /// In en, this message translates to:
  /// **'Nutrition Summary'**
  String get componentsCalendarMacroSummaryNutritionSummary;

  /// Protein label
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get componentsCalendarMacroSummaryProtein;

  /// Short label for protein used in compact macro view
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get componentsCalendarMacroSummaryCompactProtein;

  /// Short label for carbs used in compact macro view
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get componentsCalendarMacroSummaryCompactCarbs;

  /// Short label for fat used in compact macro view
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get componentsCalendarMacroSummaryCompactFat;

  /// Common OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get componentsCommonOk;

  /// Title for agent steps modal
  ///
  /// In en, this message translates to:
  /// **'Agent Processing Steps'**
  String get componentsChatAgentStepsModalAgentProcessingSteps;

  /// Snack bar text after copying
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get componentsChatAgentStepsModalCopiedToClipboard;

  /// Button text to copy all
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get componentsChatAgentStepsModalCopyAll;

  /// Button text to view full data
  ///
  /// In en, this message translates to:
  /// **'View Full Data'**
  String get componentsChatAgentStepsModalViewFullData;

  /// Button text to view full prompt
  ///
  /// In en, this message translates to:
  /// **'View Full Prompt'**
  String get componentsChatAgentStepsModalViewFullPrompt;

  /// Title for thinking process section
  ///
  /// In en, this message translates to:
  /// **'🧠 Thinking Process'**
  String get componentsChatAgentStepsModalThinkingProcessTitle;

  /// Subtitle for thinking process section
  ///
  /// In en, this message translates to:
  /// **'Real-time agent thinking steps'**
  String get componentsChatAgentStepsModalThinkingProcessSubtitle;

  /// Title for processing steps section
  ///
  /// In en, this message translates to:
  /// **'⚙️ Processing Steps'**
  String get componentsChatAgentStepsModalProcessingStepsTitle;

  /// Subtitle for processing steps section
  ///
  /// In en, this message translates to:
  /// **'Detailed step-by-step execution'**
  String get componentsChatAgentStepsModalProcessingStepsSubtitle;

  /// Title for processing summary card
  ///
  /// In en, this message translates to:
  /// **'Processing Summary'**
  String get componentsChatAgentStepsModalProcessingSummary;

  /// Tooltip for copying summary
  ///
  /// In en, this message translates to:
  /// **'Copy summary data'**
  String get componentsChatAgentStepsModalCopySummaryTooltip;

  /// Label for processing time
  ///
  /// In en, this message translates to:
  /// **'Processing Time'**
  String get componentsChatAgentStepsModalProcessingTime;

  /// Label for bot type
  ///
  /// In en, this message translates to:
  /// **'Bot Type'**
  String get componentsChatAgentStepsModalBotType;

  /// Label for total steps
  ///
  /// In en, this message translates to:
  /// **'Total Steps'**
  String get componentsChatAgentStepsModalTotalSteps;

  /// Label for skipped steps
  ///
  /// In en, this message translates to:
  /// **'Skipped Steps'**
  String get componentsChatAgentStepsModalSkippedSteps;

  /// Label for failed steps
  ///
  /// In en, this message translates to:
  /// **'Failed Steps'**
  String get componentsChatAgentStepsModalFailedSteps;

  /// Label for error recovery stats
  ///
  /// In en, this message translates to:
  /// **'Error Recovery'**
  String get componentsChatAgentStepsModalErrorRecovery;

  /// Label for completed steps
  ///
  /// In en, this message translates to:
  /// **'Completed Steps'**
  String get componentsChatAgentStepsModalCompletedSteps;

  /// Label for deep search setting
  ///
  /// In en, this message translates to:
  /// **'Deep Search'**
  String get componentsChatAgentStepsModalDeepSearch;

  /// Enabled label
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get componentsChatAgentStepsModalEnabled;

  /// Disabled label
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get componentsChatAgentStepsModalDisabled;

  /// Label for modifications section
  ///
  /// In en, this message translates to:
  /// **'Modifications'**
  String get componentsChatAgentStepsModalModifications;

  /// Text when no modifications were needed
  ///
  /// In en, this message translates to:
  /// **'None needed ✨'**
  String get componentsChatAgentStepsModalNoModifications;

  /// Detailed text when no modifications were needed
  ///
  /// In en, this message translates to:
  /// **'Perfect processing! No corrections or modifications were needed.'**
  String get componentsChatAgentStepsModalPerfectProcessing;

  /// Title for pipeline modifications section
  ///
  /// In en, this message translates to:
  /// **'✨ Pipeline Modifications'**
  String get componentsChatAgentStepsModalPipelineModificationsTitle;

  /// Subtitle for pipeline modifications when none
  ///
  /// In en, this message translates to:
  /// **'No modifications were needed - your request was processed smoothly!'**
  String get componentsChatAgentStepsModalPipelineModificationsSubtitle;

  /// Title for step-level modifications
  ///
  /// In en, this message translates to:
  /// **'🔧 Step Modifications'**
  String get componentsChatAgentStepsModalStepModifications;

  /// Tooltip to copy modifications
  ///
  /// In en, this message translates to:
  /// **'Copy modifications'**
  String get componentsChatAgentStepsModalCopyModifications;

  /// Summary label with placeholder
  ///
  /// In en, this message translates to:
  /// **'Summary: {summary}'**
  String componentsChatAgentStepsModalSummaryLabel(String summary);

  /// Title for enhanced system prompt
  ///
  /// In en, this message translates to:
  /// **'🤖 Enhanced System Prompt'**
  String get componentsChatAgentStepsModalEnhancedSystemPrompt;

  /// Tooltip to copy enhanced system prompt
  ///
  /// In en, this message translates to:
  /// **'Copy enhanced system prompt'**
  String get componentsChatAgentStepsModalCopyEnhancedPrompt;

  /// Title for high protein dish
  ///
  /// In en, this message translates to:
  /// **'High protein dish'**
  String get componentsChatDishSuggestionCardHighProtein;

  /// Title for high carb dish
  ///
  /// In en, this message translates to:
  /// **'High carb dish'**
  String get componentsChatDishSuggestionCardHighCarb;

  /// Title for high fat dish
  ///
  /// In en, this message translates to:
  /// **'High fat dish'**
  String get componentsChatDishSuggestionCardHighFat;

  /// Title for balanced dish
  ///
  /// In en, this message translates to:
  /// **'Balanced dish'**
  String get componentsChatDishSuggestionCardBalanced;

  /// Title for unbalanced dish
  ///
  /// In en, this message translates to:
  /// **'Unbalanced dish'**
  String get componentsChatDishSuggestionCardUnbalanced;

  /// Protein label for nutrition bar
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get componentsChatDishSuggestionCardProtein;

  /// Carbs label for nutrition bar
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get componentsChatDishSuggestionCardCarbs;

  /// Fat label for nutrition bar
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get componentsChatDishSuggestionCardFat;

  /// Calories label for nutrition bar
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get componentsChatDishSuggestionCardCalories;

  /// Button text for dish details
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get componentsChatDishSuggestionCardInspect;

  /// Label for the user in the message bubble
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get componentsChatMessageBubbleYou;

  /// Label for the assistant in the message bubble
  ///
  /// In en, this message translates to:
  /// **'PlatePal Assistant'**
  String get componentsChatMessageBubbleAssistant;

  /// Tag to identify the bot in the message bubble
  ///
  /// In en, this message translates to:
  /// **'(bot)'**
  String get componentsChatMessageBubbleBotTag;

  /// Text shown while a message is being sent
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get componentsChatMessageBubbleSending;

  /// Title for the suggested dishes section
  ///
  /// In en, this message translates to:
  /// **'Suggested Dishes'**
  String get componentsChatMessageBubbleSuggestedDishes;

  /// Label for a recommendation in the message bubble
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get componentsChatMessageBubbleRecommendation;

  /// Text shown when no recommendations are available
  ///
  /// In en, this message translates to:
  /// **'No recommendations available.'**
  String get componentsChatMessageBubbleNoRecommendationsAvailable;

  /// Length label with placeholder
  ///
  /// In en, this message translates to:
  /// **'Length: {count} characters'**
  String componentsChatAgentStepsModalLengthLabel(int count);

  /// Header for technical details in modification item
  ///
  /// In en, this message translates to:
  /// **'Technical Details'**
  String get componentsChatAgentStepsModalTechnicalDetails;

  /// Header for before/after data changes
  ///
  /// In en, this message translates to:
  /// **'Data Changes'**
  String get componentsChatAgentStepsModalDataChanges;

  /// Label for before data column
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get componentsChatAgentStepsModalBefore;

  /// Label for after data column
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get componentsChatAgentStepsModalAfter;

  /// Status label for skipped steps
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get componentsChatAgentStepsModalStatusSkipped;

  /// Status label when an error was recovered
  ///
  /// In en, this message translates to:
  /// **'Error recovered'**
  String get componentsChatAgentStepsModalStatusErrorRecovered;

  /// Status label when error handling failed
  ///
  /// In en, this message translates to:
  /// **'Error handling failed'**
  String get componentsChatAgentStepsModalStatusErrorHandlingFailed;

  /// Status label for successful completion
  ///
  /// In en, this message translates to:
  /// **'Completed successfully'**
  String get componentsChatAgentStepsModalStatusCompletedSuccessfully;

  /// Generic failed label
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get componentsChatAgentStepsModalFailed;

  /// Low severity label for agent modifications
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get componentsChatAgentStepsModalSeverityLow;

  /// Medium severity label for agent modifications
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get componentsChatAgentStepsModalSeverityMedium;

  /// High severity label for agent modifications
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get componentsChatAgentStepsModalSeverityHigh;

  /// Critical severity label for agent modifications
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get componentsChatAgentStepsModalSeverityCritical;

  /// Label for emergency override badge
  ///
  /// In en, this message translates to:
  /// **'Emergency overrides'**
  String get componentsChatAgentStepsModalBadgeEmergencyOverrides;

  /// Label for AI validations badge
  ///
  /// In en, this message translates to:
  /// **'AI validations'**
  String get componentsChatAgentStepsModalBadgeAiValidations;

  /// Label for automatic fixes badge
  ///
  /// In en, this message translates to:
  /// **'Automatic fixes'**
  String get componentsChatAgentStepsModalBadgeAutomaticFixes;

  /// Total modifications text with placeholder
  ///
  /// In en, this message translates to:
  /// **'Total modifications: {count}'**
  String componentsChatAgentStepsModalTotalModifications(int count);

  /// Header for skip details section
  ///
  /// In en, this message translates to:
  /// **'⏭️ Skip Details'**
  String get componentsChatAgentStepsModalSkipDetails;

  /// Header for metadata section
  ///
  /// In en, this message translates to:
  /// **'📊 Metadata'**
  String get componentsChatAgentStepsModalMetadata;

  /// Header for data output section
  ///
  /// In en, this message translates to:
  /// **'📤 Data Output'**
  String get componentsChatAgentStepsModalDataOutput;

  /// Header for error details section
  ///
  /// In en, this message translates to:
  /// **'❌ Error Details'**
  String get componentsChatAgentStepsModalErrorDetails;

  /// Header for raw step data section
  ///
  /// In en, this message translates to:
  /// **'🔍 Raw Step Data'**
  String get componentsChatAgentStepsModalRawStepData;

  /// ID label with placeholder
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String componentsChatAgentStepsModalIdLabel(String id);

  /// Time label with placeholder
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String componentsChatAgentStepsModalTimeLabel(String time);

  /// Fallback label when a processing step has no name
  ///
  /// In en, this message translates to:
  /// **'Unknown Step'**
  String get componentsChatAgentStepsModalUnknownStep;

  /// Fallback explanation for a skipped processing step
  ///
  /// In en, this message translates to:
  /// **'No reason provided'**
  String get componentsChatAgentStepsModalNoReasonProvided;

  /// Fallback when a processing step has no modification summary
  ///
  /// In en, this message translates to:
  /// **'No summary available'**
  String get componentsChatAgentStepsModalNoSummaryAvailable;

  /// Summary of a list value in agent data
  ///
  /// In en, this message translates to:
  /// **'List with {count} items'**
  String componentsChatAgentStepsModalListItems(int count);

  /// Summary of a map value in agent data
  ///
  /// In en, this message translates to:
  /// **'Map with {count} keys'**
  String componentsChatAgentStepsModalMapKeys(int count);

  /// Summary of additional hidden agent data entries
  ///
  /// In en, this message translates to:
  /// **'... and {count} more items'**
  String componentsChatAgentStepsModalMoreItems(int count);

  /// Common tooltip for copy to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get componentsCommonCopyToClipboard;

  /// Angry Greg personality type
  ///
  /// In en, this message translates to:
  /// **'Angry Greg'**
  String get componentsChatBotProfileCustomizationDialogAngryGreg;

  /// Bot name field label
  ///
  /// In en, this message translates to:
  /// **'Bot Name'**
  String get componentsChatBotProfileCustomizationDialogBotName;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get componentsChatBotProfileCustomizationDialogCancel;

  /// Casual gym bro personality type
  ///
  /// In en, this message translates to:
  /// **'Casual Gym Bro'**
  String get componentsChatBotProfileCustomizationDialogCasualGymBro;

  /// Change avatar button text
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get componentsChatBotProfileCustomizationDialogChangeAvatar;

  /// Choose from gallery option
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get componentsChatBotProfileCustomizationDialogChooseFromGallery;

  /// Edit bot profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Bot Profile'**
  String get componentsChatBotProfileCustomizationDialogEditBotProfile;

  /// Fitness coach personality type
  ///
  /// In en, this message translates to:
  /// **'Fitness Coach'**
  String get componentsChatBotProfileCustomizationDialogFitnessCoach;

  /// Nice and friendly personality type
  ///
  /// In en, this message translates to:
  /// **'Nice & Friendly'**
  String get componentsChatBotProfileCustomizationDialogNiceAndFriendly;

  /// Personality field label
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get componentsChatBotProfileCustomizationDialogPersonality;

  /// Professional nutritionist personality type
  ///
  /// In en, this message translates to:
  /// **'Professional Nutritionist'**
  String
  get componentsChatBotProfileCustomizationDialogProfessionalNutritionist;

  /// Profile save success message
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully'**
  String get componentsChatBotProfileCustomizationDialogProfileSaved;

  /// Profile save error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile'**
  String get componentsChatBotProfileCustomizationDialogProfileSaveFailed;

  /// Remove avatar button text
  ///
  /// In en, this message translates to:
  /// **'Remove Avatar'**
  String get componentsChatBotProfileCustomizationDialogRemoveAvatar;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get componentsChatBotProfileCustomizationDialogRequiredField;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get componentsChatBotProfileCustomizationDialogSave;

  /// Take photo option
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get componentsChatBotProfileCustomizationDialogTakePhoto;

  /// Very angry bro personality type
  ///
  /// In en, this message translates to:
  /// **'Very Angry Bro'**
  String get componentsChatBotProfileCustomizationDialogVeryAngryBro;

  /// Personality description for nutritionist bot
  ///
  /// In en, this message translates to:
  /// **'Professional & Evidence-based'**
  String get componentsChatBotPersonalityDescriptionNutritionist;

  /// Personality description for casual gymbro
  ///
  /// In en, this message translates to:
  /// **'Casual & Motivational'**
  String get componentsChatBotPersonalityDescriptionCasualGymbro;

  /// Personality description for angry Greg
  ///
  /// In en, this message translates to:
  /// **'Intense & Supplement-focused'**
  String get componentsChatBotPersonalityDescriptionAngryGreg;

  /// Personality description for very angry bro
  ///
  /// In en, this message translates to:
  /// **'Extremely Intense'**
  String get componentsChatBotPersonalityDescriptionVeryAngryBro;

  /// Personality description for fitness coach
  ///
  /// In en, this message translates to:
  /// **'Encouraging & Supportive'**
  String get componentsChatBotPersonalityDescriptionFitnessCoach;

  /// Personality description for nice bot
  ///
  /// In en, this message translates to:
  /// **'Friendly & Helpful'**
  String get componentsChatBotPersonalityDescriptionNice;

  /// Tooltip for edit bot profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Bot Profile'**
  String get componentsChatEditBotProfileTooltip;

  /// Error message when image picker fails
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String componentsChatChatInputErrorPickingImage(Object error);

  /// Message bubble hint for emergency modifications
  ///
  /// In en, this message translates to:
  /// **'{count} emergency fixes applied'**
  String componentsChatMessageBubbleModificationEmergency(int count);

  /// Message bubble hint for AI modifications
  ///
  /// In en, this message translates to:
  /// **'{count} AI enhancements applied'**
  String componentsChatMessageBubbleModificationAi(int count);

  /// Message bubble hint for automatic modifications
  ///
  /// In en, this message translates to:
  /// **'{count} automatic improvements applied'**
  String componentsChatMessageBubbleModificationAutomatic(int count);

  /// Image attached confirmation
  ///
  /// In en, this message translates to:
  /// **'Image attached'**
  String get componentsChatChatInputImageAttached;

  /// Label for added ingredients preview in chat
  ///
  /// In en, this message translates to:
  /// **'Ingredients Added'**
  String get componentsChatChatInputIngredientsAdded;

  /// Tooltip for removing an attached chat ingredient
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String componentsChatChatInputRemoveIngredient(String name);

  /// Confirmation after adding a product as a chat ingredient
  ///
  /// In en, this message translates to:
  /// **'Ingredient added to chat'**
  String get componentsChatChatInputIngredientAdded;

  /// Accessibility label for opening the chat attachment menu
  ///
  /// In en, this message translates to:
  /// **'Add attachments'**
  String get componentsChatChatInputAttachments;

  /// Scan barcode button text
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get componentsChatChatInputScanBarcode;

  /// Search product button text
  ///
  /// In en, this message translates to:
  /// **'Search Product'**
  String get componentsChatChatInputSearchProduct;

  /// Send message button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get componentsChatChatInputSendMessage;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get componentsChatChatInputTypeMessage;

  /// Analyze nutrition quick action
  ///
  /// In en, this message translates to:
  /// **'Analyze nutrition'**
  String get componentsChatChatWelcomeAnalyzeNutrition;

  /// Calculate macros quick action
  ///
  /// In en, this message translates to:
  /// **'Calculate macros'**
  String get componentsChatChatWelcomeCalculateMacros;

  /// Chat welcome screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Your AI nutrition assistant is here to help'**
  String get componentsChatChatWelcomeChatWelcomeSubtitle;

  /// Chat welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlatePal'**
  String get componentsChatChatWelcomeChatWelcomeTitle;

  /// Find alternatives quick action
  ///
  /// In en, this message translates to:
  /// **'Find alternatives'**
  String get componentsChatChatWelcomeFindAlternatives;

  /// Get started section title
  ///
  /// In en, this message translates to:
  /// **'Get started today'**
  String get componentsChatChatWelcomeGetStartedToday;

  /// Ingredient info quick action
  ///
  /// In en, this message translates to:
  /// **'Ingredient info'**
  String get componentsChatChatWelcomeIngredientInfo;

  /// Meal plan help quick action
  ///
  /// In en, this message translates to:
  /// **'Meal plan help'**
  String get componentsChatChatWelcomeMealPlan;

  /// Suggest meal quick action
  ///
  /// In en, this message translates to:
  /// **'Suggest a meal'**
  String get componentsChatChatWelcomeSuggestMeal;

  /// Subtitle for suggest a meal
  ///
  /// In en, this message translates to:
  /// **'Get personalized meal recommendations'**
  String get componentsChatChatWelcomeSuggestMealSubtitle;

  /// Message when tapping on suggest a meal
  ///
  /// In en, this message translates to:
  /// **'Suggest a healthy meal based on my fitness goals'**
  String get componentsChatChatWelcomeSuggestMealMessage;

  /// Subtitle for nutrition analysis
  ///
  /// In en, this message translates to:
  /// **'Analyze the nutritional values of your meals'**
  String get componentsChatChatWelcomeAnalyzeNutritionSubtitle;

  /// Message when tapping on nutrition analysis
  ///
  /// In en, this message translates to:
  /// **'Help me analyze the nutritional values in my meal'**
  String get componentsChatChatWelcomeAnalyzeNutritionMessage;

  /// Subtitle for find alternatives
  ///
  /// In en, this message translates to:
  /// **'Discover healthy food alternatives'**
  String get componentsChatChatWelcomeFindAlternativesSubtitle;

  /// Message when tapping on find alternatives
  ///
  /// In en, this message translates to:
  /// **'Find healthy alternatives to my current meal'**
  String get componentsChatChatWelcomeFindAlternativesMessage;

  /// Subtitle for calculate macros
  ///
  /// In en, this message translates to:
  /// **'Calculate macros for your meals'**
  String get componentsChatChatWelcomeCalculateMacrosSubtitle;

  /// Message when tapping on calculate macros
  ///
  /// In en, this message translates to:
  /// **'Help me calculate the macros for my meals'**
  String get componentsChatChatWelcomeCalculateMacrosMessage;

  /// Subtitle for meal plan
  ///
  /// In en, this message translates to:
  /// **'Create weekly meal plans'**
  String get componentsChatChatWelcomeMealPlanSubtitle;

  /// Message when tapping on meal plan
  ///
  /// In en, this message translates to:
  /// **'Help me create a weekly meal plan'**
  String get componentsChatChatWelcomeMealPlanMessage;

  /// Subtitle for ingredient info
  ///
  /// In en, this message translates to:
  /// **'Learn more about ingredients and their benefits'**
  String get componentsChatChatWelcomeIngredientInfoSubtitle;

  /// Message when tapping on ingredient info
  ///
  /// In en, this message translates to:
  /// **'Tell me about the nutritional benefits of ingredients'**
  String get componentsChatChatWelcomeIngredientInfoMessage;

  /// Help options question
  ///
  /// In en, this message translates to:
  /// **'What can I help you with?'**
  String get componentsChatChatWelcomeWhatCanIHelpWith;

  /// Details button text
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get componentsChatDishSuggestionCardDetails;

  /// Error message when dish screen fails to open
  ///
  /// In en, this message translates to:
  /// **'Error opening dish screen: {error}'**
  String componentsChatDishSuggestionCardErrorOpeningDishScreen(Object error);

  /// Button text to log a dish
  ///
  /// In en, this message translates to:
  /// **'Log Dish'**
  String get componentsChatDishSuggestionCardLogDish;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get componentsChatMessageBubbleClose;

  /// Ingredients data type
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get componentsChatMessageBubbleIngredients;

  /// Message copied success message
  ///
  /// In en, this message translates to:
  /// **'Message copied to clipboard'**
  String get componentsChatMessageBubbleMessageCopied;

  /// Retry message button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get componentsChatMessageBubbleRetryMessage;

  /// Generic select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get componentsChatMessageBubbleSelect;

  /// Agent steps tap instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to view agent steps'**
  String get componentsChatMessageBubbleTapToViewAgentSteps;

  /// Label for yesterday in date formatting
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get componentsChatMessageBubbleYesterday;

  /// Dish name label
  ///
  /// In en, this message translates to:
  /// **'Dish Name'**
  String get componentsChatNutritionAnalysisCardDishName;

  /// Nutrition analysis section title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get componentsChatNutritionAnalysisCardNutritionAnalysis;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get componentsChatQuickActionsQuickActions;

  /// Edit user profile dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit User Profile'**
  String get componentsChatUserProfileCustomizationDialogEditUserProfile;

  /// Username field label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get componentsChatUserProfileCustomizationDialogUsername;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get componentsDishesDishCardDelete;

  /// Menu item text to edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get componentsDishesDishCardEdit;

  /// Button text to add ingredient
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get componentsDishesDishFormIngredientFormModalAddIngredient;

  /// Edit Ingredient
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get componentsDishesDishFormIngredientFormModalEditIngredient;

  /// g
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get componentsDishesDishFormIngredientFormModalGrams;

  /// Label for ingredient name field
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name'**
  String get componentsDishesDishFormIngredientFormModalIngredientName;

  /// Enter ingredient name
  ///
  /// In en, this message translates to:
  /// **'Enter ingredient name'**
  String
  get componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder;

  /// kcal
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get componentsDishesDishFormIngredientFormModalKcal;

  /// Nutrition Information
  ///
  /// In en, this message translates to:
  /// **'Nutrition Information'**
  String get componentsDishesDishFormIngredientFormModalNutritionInformation;

  /// Nutrition information per 100g label
  ///
  /// In en, this message translates to:
  /// **'Nutrition per 100g'**
  String get componentsDishesDishFormIngredientFormModalNutritionPer100g;

  /// Validation message for empty ingredient name
  ///
  /// In en, this message translates to:
  /// **'Please enter an ingredient name'**
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName;

  /// Please enter a quantity
  ///
  /// In en, this message translates to:
  /// **'Please enter a quantity'**
  String get componentsDishesDishFormIngredientFormModalPleaseEnterQuantity;

  /// Please enter a valid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber;

  /// Product quantity label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get componentsDishesDishFormIngredientFormModalQuantity;

  /// Enter quantity
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get componentsDishesDishFormIngredientFormModalQuantityPlaceholder;

  /// Nutritional Information
  ///
  /// In en, this message translates to:
  /// **'Nutritional Information'**
  String get componentsDishesDishFormSmartNutritionCardNutritionalInformation;

  /// Placeholder text for notes field
  ///
  /// In en, this message translates to:
  /// **'Add notes (optional)'**
  String get componentsModalsDishLogModalAddNotes;

  /// Breakfast meal type
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get componentsModalsDishLogModalBreakfast;

  /// Label for calculated nutrition section
  ///
  /// In en, this message translates to:
  /// **'Calculated Nutrition'**
  String get componentsModalsDishLogModalCalculatedNutrition;

  /// Dinner meal type
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get componentsModalsDishLogModalDinner;

  /// Success message when dish is logged
  ///
  /// In en, this message translates to:
  /// **'Dish logged successfully!'**
  String get componentsModalsDishLogModalDishLoggedSuccessfully;

  /// Warning for dish logging errors
  ///
  /// In en, this message translates to:
  /// **'There was an error logging the dish'**
  String get componentsModalsDishLogModalErrorLoggingDish;

  /// Title for the log dish modal
  ///
  /// In en, this message translates to:
  /// **'Log Dish'**
  String get componentsModalsDishLogModalLogDishTitle;

  /// Lunch meal type
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get componentsModalsDishLogModalLunch;

  /// Label for notes field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get componentsModalsDishLogModalNotes;

  /// Label for portion size
  ///
  /// In en, this message translates to:
  /// **'Portion Size'**
  String get componentsModalsDishLogModalPortionSize;

  /// Button text to select date
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get componentsModalsDishLogModalSelectDate;

  /// Label for meal type selection
  ///
  /// In en, this message translates to:
  /// **'Select Meal Type'**
  String get componentsModalsDishLogModalSelectMealType;

  /// Label for selecting the time of a dish log
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get componentsModalsDishLogModalSelectTime;

  /// Snack meal type
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get componentsModalsDishLogModalSnack;

  /// Barcode scanner title
  ///
  /// In en, this message translates to:
  /// **'Barcode Scanner'**
  String get componentsScannerBarcodeScannerBarcodeScanner;

  /// Error message for barcode scanning
  ///
  /// In en, this message translates to:
  /// **'Error scanning barcode: {error}'**
  String componentsScannerBarcodeScannerErrorScanningBarcode(String error);

  /// Open settings button text
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get componentsScannerBarcodeScannerOpenSettings;

  /// Message when product is not found
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get componentsScannerBarcodeScannerProductNotFound;

  /// Instruction text for barcode scanning
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode to quickly add products'**
  String get componentsScannerBarcodeScannerScanBarcodeToAddProduct;

  /// Status message while scanning
  ///
  /// In en, this message translates to:
  /// **'Scanning barcode...'**
  String get componentsScannerBarcodeScannerScanningBarcode;

  /// Close scanner after camera permission is denied
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get componentsScannerBarcodeScannerClose;

  /// Instructions when camera permission is denied
  ///
  /// In en, this message translates to:
  /// **'Allow camera access for this app in system settings.'**
  String get componentsScannerBarcodeScannerPermissionHint;

  /// Camera scanner error
  ///
  /// In en, this message translates to:
  /// **'Scanner error: {errorCode}'**
  String componentsScannerBarcodeScannerScannerError(String errorCode);

  /// Barcode product service failed
  ///
  /// In en, this message translates to:
  /// **'Food data is unavailable. Try again.'**
  String get componentsScannerBarcodeScannerServiceUnavailable;

  /// Turn on the scanner flashlight
  ///
  /// In en, this message translates to:
  /// **'Turn flashlight on'**
  String get componentsScannerBarcodeScannerTorchOn;

  /// Turn off the scanner flashlight
  ///
  /// In en, this message translates to:
  /// **'Turn flashlight off'**
  String get componentsScannerBarcodeScannerTorchOff;

  /// Error message for product search
  ///
  /// In en, this message translates to:
  /// **'Error searching for product: {error}'**
  String componentsScannerProductSearchErrorSearchingProduct(String error);

  /// Loard more
  ///
  /// In en, this message translates to:
  /// **'Loard more'**
  String get componentsScannerProductSearchLoadMore;

  /// Local Dishes
  ///
  /// In en, this message translates to:
  /// **'Local Dishes'**
  String get componentsScannerProductSearchLocalDishes;

  /// Local ingredients
  ///
  /// In en, this message translates to:
  /// **'Local ingredients'**
  String get componentsScannerProductSearchLocalIngredients;

  /// Message when no products are found in search
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get componentsScannerProductSearchNoProductsFound;

  /// Product search title
  ///
  /// In en, this message translates to:
  /// **'Product Search'**
  String get componentsScannerProductSearchProductSearch;

  /// Placeholder text for product search
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get componentsScannerProductSearchSearchProducts;

  /// Open product filters and sorting
  ///
  /// In en, this message translates to:
  /// **'Filters & Sort'**
  String get componentsScannerProductSearchFiltersAndSort;

  /// Nutrition grade filter heading
  ///
  /// In en, this message translates to:
  /// **'NUTRI-SCORE'**
  String get componentsScannerProductSearchNutriScore;

  /// Any nutrition grade
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get componentsScannerProductSearchAny;

  /// Sorting heading
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get componentsScannerProductSearchSortBy;

  /// Popular products section
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get componentsScannerProductSearchPopular;

  /// Search results heading
  ///
  /// In en, this message translates to:
  /// **'Results for \"{query}\"'**
  String componentsScannerProductSearchResultsFor(String query);

  /// Locally saved items section
  ///
  /// In en, this message translates to:
  /// **'My database'**
  String get componentsScannerProductSearchMyDatabase;

  /// Open Food Facts products section
  ///
  /// In en, this message translates to:
  /// **'Global feed'**
  String get componentsScannerProductSearchGlobalFeed;

  /// Last page of search results
  ///
  /// In en, this message translates to:
  /// **'End of results'**
  String get componentsScannerProductSearchEndOfResults;

  /// Empty browse screen prompt
  ///
  /// In en, this message translates to:
  /// **'Select a category or type to search'**
  String get componentsScannerProductSearchSelectCategoryOrSearch;

  /// Empty search results prompt
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String componentsScannerProductSearchNoResultsFor(String query);

  /// Unnamed product
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get componentsScannerProductSearchUnknown;

  /// Calories unit
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get componentsScannerProductSearchKcal;

  /// Protein abbreviation in result summaries
  ///
  /// In en, this message translates to:
  /// **'P:'**
  String get componentsScannerProductSearchProteinAbbreviation;

  /// Carbohydrate abbreviation in result summaries
  ///
  /// In en, this message translates to:
  /// **'C:'**
  String get componentsScannerProductSearchCarbsAbbreviation;

  /// Fat abbreviation in result summaries
  ///
  /// In en, this message translates to:
  /// **'F:'**
  String get componentsScannerProductSearchFatAbbreviation;

  /// Gram unit in result summaries
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get componentsScannerProductSearchGramsAbbreviation;

  /// Local ingredient result type
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get componentsScannerProductSearchIngredient;

  /// Number of ingredients in a local dish result
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ingredient — dish} other{{count} ingredients — dish}}'**
  String componentsScannerProductSearchDishIngredients(int count);

  /// Failed to load browse results
  ///
  /// In en, this message translates to:
  /// **'Products are unavailable. Try again.'**
  String get componentsScannerProductSearchBrowseUnavailable;

  /// Name of a product with no identifying data
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get componentsScannerProductSearchUnknownProduct;

  /// All product categories
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get componentsScannerProductSearchCategoryAll;

  /// Fruit category
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get componentsScannerProductSearchCategoryFruits;

  /// Vegetable category
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get componentsScannerProductSearchCategoryVegetables;

  /// Dairy category
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get componentsScannerProductSearchCategoryDairy;

  /// Meat category
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get componentsScannerProductSearchCategoryMeat;

  /// Seafood category
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get componentsScannerProductSearchCategorySeafood;

  /// Beverage category
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get componentsScannerProductSearchCategoryBeverages;

  /// Cereal category
  ///
  /// In en, this message translates to:
  /// **'Cereals'**
  String get componentsScannerProductSearchCategoryCereals;

  /// Bread category
  ///
  /// In en, this message translates to:
  /// **'Breads'**
  String get componentsScannerProductSearchCategoryBreads;

  /// Snack category
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get componentsScannerProductSearchCategorySnacks;

  /// Sweets category
  ///
  /// In en, this message translates to:
  /// **'Sweets'**
  String get componentsScannerProductSearchCategorySweets;

  /// Legume category
  ///
  /// In en, this message translates to:
  /// **'Legumes'**
  String get componentsScannerProductSearchCategoryLegumes;

  /// Nut category
  ///
  /// In en, this message translates to:
  /// **'Nuts'**
  String get componentsScannerProductSearchCategoryNuts;

  /// Condiment category
  ///
  /// In en, this message translates to:
  /// **'Condiments'**
  String get componentsScannerProductSearchCategoryCondiments;

  /// Oil and fat category
  ///
  /// In en, this message translates to:
  /// **'Oils & Fats'**
  String get componentsScannerProductSearchCategoryOilsAndFats;

  /// Frozen foods category
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get componentsScannerProductSearchCategoryFrozen;

  /// Prepared meals category
  ///
  /// In en, this message translates to:
  /// **'Ready Meals'**
  String get componentsScannerProductSearchCategoryReadyMeals;

  /// Baby food category
  ///
  /// In en, this message translates to:
  /// **'Baby Foods'**
  String get componentsScannerProductSearchCategoryBabyFoods;

  /// Sort by popularity
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get componentsScannerProductSearchSortPopularity;

  /// Sort by name
  ///
  /// In en, this message translates to:
  /// **'Name A–Z'**
  String get componentsScannerProductSearchSortName;

  /// Sort by date
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get componentsScannerProductSearchSortNewest;

  /// Sort by completeness
  ///
  /// In en, this message translates to:
  /// **'Most Complete'**
  String get componentsScannerProductSearchSortCompleteness;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get componentsSharedErrorDisplayRetry;

  /// Calendar label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get componentsUiCustomTabBarCalendar;

  /// Chat label
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get componentsUiCustomTabBarChat;

  /// Meals label
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get componentsUiCustomTabBarMeals;

  /// Menu label
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get componentsUiCustomTabBarMenu;

  /// AI thinking status message
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get providersChatProviderAiThinking;

  /// Default chat message when only ingredients are attached
  ///
  /// In en, this message translates to:
  /// **'What can I make with these ingredients?'**
  String get providersChatProviderIngredientsPrompt;

  /// Test response message when no API key is configured
  ///
  /// In en, this message translates to:
  /// **'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.'**
  String get providersChatProviderTestChatResponse;

  /// Welcome message for test chat mode
  ///
  /// In en, this message translates to:
  /// **'This is test mode! I can help you explore PlatePal\'s features. Try asking me about nutrition, meal planning, or food recommendations.'**
  String get providersChatProviderTestChatWelcome;

  /// Welcome message for chat
  ///
  /// In en, this message translates to:
  /// **'Welcome to your AI nutrition assistant! Ask me anything about meals, nutrition, or your fitness goals.'**
  String get providersChatProviderWelcomeToChat;

  /// Title for AI nutrition tips
  ///
  /// In en, this message translates to:
  /// **'AI Nutrition Tip'**
  String get screensCalendarAiNutritionTip;

  /// Prompt to configure API key for AI tips
  ///
  /// In en, this message translates to:
  /// **'Please configure your OpenAI API key in settings to use AI tips'**
  String get screensCalendarConfigureApiKeyForAiTips;

  /// Title for delete log dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Log'**
  String get screensCalendarDeleteLog;

  /// Confirmation message for deleting a meal log
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this logged meal?'**
  String get screensCalendarDeleteLogConfirmation;

  /// Error message when meal log deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete meal log'**
  String get screensCalendarFailedToDeleteMealLog;

  /// Error getting AI tip
  ///
  /// In en, this message translates to:
  /// **'Failed to get AI tip. Please try again.'**
  String get screensCalendarFailedToGetAiTip;

  /// Success message after deleting a meal log
  ///
  /// In en, this message translates to:
  /// **'Meal log deleted successfully'**
  String get screensCalendarMealLogDeletedSuccessfully;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get screensCalendarOk;

  /// Chat assistant title
  ///
  /// In en, this message translates to:
  /// **'AI Chat Assistant'**
  String get screensChatChatAssistant;

  /// Header for the chat processing indicator
  ///
  /// In en, this message translates to:
  /// **'SYSTEM ANALYZING ::'**
  String get screensChatSystemAnalyzing;

  /// Chat cleared success message
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared'**
  String get screensChatChatCleared;

  /// Clear chat button text
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get screensChatClearChat;

  /// Clear chat confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the chat history? This action cannot be undone.'**
  String get screensChatClearChatConfirmation;

  /// Configure API key button text
  ///
  /// In en, this message translates to:
  /// **'Configure API Key'**
  String get screensChatConfigureApiKeyButton;

  /// No API key error message
  ///
  /// In en, this message translates to:
  /// **'Please configure your OpenAI API key in settings to use the AI chat assistant.'**
  String get screensChatConfigureApiKeyToUseChat;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get screensChatLoading;

  /// No API key error title
  ///
  /// In en, this message translates to:
  /// **'No API key configured'**
  String get screensChatNoApiKeyConfigured;

  /// Basic Information
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get screensDishCreateBasicInfo;

  /// Camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get screensDishCreateCamera;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get screensDishCreateCategory;

  /// Are you sure you want to delete this ingredient?
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this ingredient?'**
  String get screensDishCreateConfirmDeleteIngredient;

  /// Button text to create new dish
  ///
  /// In en, this message translates to:
  /// **'Create Dish'**
  String get screensDishCreateCreateDish;

  /// Delete Ingredient
  ///
  /// In en, this message translates to:
  /// **'Delete Ingredient'**
  String get screensDishCreateDeleteIngredient;

  /// Description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get screensDishCreateDescription;

  /// Enter description (optional)
  ///
  /// In en, this message translates to:
  /// **'Enter description (optional)'**
  String get screensDishCreateDescriptionPlaceholder;

  /// Success message for dish creation
  ///
  /// In en, this message translates to:
  /// **'Dish created successfully'**
  String get screensDishCreateDishCreatedSuccessfully;

  /// Enter dish name
  ///
  /// In en, this message translates to:
  /// **'Enter dish name'**
  String get screensDishCreateDishNamePlaceholder;

  /// Success message for dish update
  ///
  /// In en, this message translates to:
  /// **'Dish updated successfully'**
  String get screensDishCreateDishUpdatedSuccessfully;

  /// Title for editing dish screen
  ///
  /// In en, this message translates to:
  /// **'Edit Dish'**
  String get screensDishCreateEditDish;

  /// Error message for dish save failure
  ///
  /// In en, this message translates to:
  /// **'Error saving dish'**
  String get screensDishCreateErrorSavingDish;

  /// Favorite toggle label
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get screensDishCreateFavorite;

  /// Gallery
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get screensDishCreateGallery;

  /// Ingredient deleted
  ///
  /// In en, this message translates to:
  /// **'Ingredient deleted'**
  String get screensDishCreateIngredientDeleted;

  /// Description for favorite toggle
  ///
  /// In en, this message translates to:
  /// **'Mark as favorite dish'**
  String get screensDishCreateMarkAsFavorite;

  /// Empty state text for ingredients list
  ///
  /// In en, this message translates to:
  /// **'No ingredients added yet'**
  String get screensDishCreateNoIngredientsAdded;

  /// Nutrition recalculated from ingredients
  ///
  /// In en, this message translates to:
  /// **'Nutrition recalculated from ingredients'**
  String get screensDishCreateNutritionRecalculated;

  /// Section title for dish options
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get screensDishCreateOptions;

  /// Validation message for empty dish name
  ///
  /// In en, this message translates to:
  /// **'Please enter a dish name'**
  String get screensDishCreatePleaseEnterDishName;

  /// Success message when product is added
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get screensDishCreateProductAddedSuccessfully;

  /// Remove image button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get screensDishCreateRemoveImage;

  /// Save Dish
  ///
  /// In en, this message translates to:
  /// **'Save Dish'**
  String get screensDishCreateSaveDish;

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker'**
  String get screensHomeAppTitle;

  /// Message when local data storage fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Unable to load your data.'**
  String get providersStorageError;

  /// Button to retry initializing local data storage
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get providersStorageRetry;

  /// Success message when dish added to favorites
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get screensMealsAddedToFavorites;

  /// Add meal button text
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get screensMealsAddMeal;

  /// Menu item to add dish to favorites
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get screensMealsAddToFavorites;

  /// Filter option to show all categories
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get screensMealsAllCategories;

  /// Empty state subtitle encouraging dish creation
  ///
  /// In en, this message translates to:
  /// **'Create your first dish to get started'**
  String get screensMealsCreateFirstDish;

  /// Dialog title for dish deletion
  ///
  /// In en, this message translates to:
  /// **'Delete Dish'**
  String get screensMealsDeleteDish;

  /// Confirmation message for dish deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{dishName}\"?'**
  String screensMealsDeleteDishConfirmation(String dishName);

  /// Success message after dish deletion
  ///
  /// In en, this message translates to:
  /// **'Dish deleted successfully'**
  String get screensMealsDishDeletedSuccessfully;

  /// Error message when dishes fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading dishes'**
  String get screensMealsErrorLoadingDishes;

  /// Advice shown after a meal list load error
  ///
  /// In en, this message translates to:
  /// **'Could not load your dishes. Please try again.'**
  String get screensMealsLoadFailedHint;

  /// Error message when dish update fails
  ///
  /// In en, this message translates to:
  /// **'Error updating dish'**
  String get screensMealsErrorUpdatingDish;

  /// Error message when dish deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete dish'**
  String get screensMealsFailedToDeleteDish;

  /// Empty state title when no dishes exist
  ///
  /// In en, this message translates to:
  /// **'No dishes created yet'**
  String get screensMealsNoDishesCreated;

  /// Message when search returns no results
  ///
  /// In en, this message translates to:
  /// **'No dishes found'**
  String get screensMealsNoDishesFound;

  /// Dish category shown when no meal category is assigned
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get screensMealsOtherCategory;

  /// Success message when dish removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get screensMealsRemovedFromFavorites;

  /// Menu item to remove dish from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get screensMealsRemoveFromFavorites;

  /// Placeholder text for dish search field
  ///
  /// In en, this message translates to:
  /// **'Search dishes...'**
  String get screensMealsSearchDishes;

  /// Suggestion when no search results found
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms'**
  String get screensMealsTryAdjustingSearch;

  /// About option
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get screensMenuAbout;

  /// AI and features settings section
  ///
  /// In en, this message translates to:
  /// **'AI & Features'**
  String get screensMenuAiFeatures;

  /// API key settings
  ///
  /// In en, this message translates to:
  /// **'API Key Settings'**
  String get screensMenuApiKeySettings;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get screensMenuAppearance;

  /// Chat agent options title
  ///
  /// In en, this message translates to:
  /// **'Chat Agent Options'**
  String get screensMenuChatAgentOptions;

  /// Subtitle for API key settings
  ///
  /// In en, this message translates to:
  /// **'Configure your OpenAI API key'**
  String get screensMenuConfigureApiKey;

  /// Contributors option
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get screensMenuContributors;

  /// Current stats section title
  ///
  /// In en, this message translates to:
  /// **'Current Stats'**
  String get screensMenuCurrentStats;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get screensMenuDark;

  /// Data management settings section
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get screensMenuDataManagement;

  /// Subtitle for user profile settings
  ///
  /// In en, this message translates to:
  /// **'Edit your personal information'**
  String get screensMenuEditPersonalInfo;

  /// Chat agent options subtitle
  ///
  /// In en, this message translates to:
  /// **'Enable agent mode, deep search, and more'**
  String get screensMenuEnableAgentModeDeepSearch;

  /// Export data option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get screensMenuExportData;

  /// Subtitle for export data option
  ///
  /// In en, this message translates to:
  /// **'Export your meal data'**
  String get screensMenuExportMealData;

  /// Import data option
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get screensMenuImportData;

  /// Subtitle for import data option
  ///
  /// In en, this message translates to:
  /// **'Import meal data from backup'**
  String get screensMenuImportMealDataBackup;

  /// Information settings section
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get screensMenuInformation;

  /// Language selector label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get screensMenuLanguage;

  /// Language choice that follows the device language
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get screensMenuSystemDefault;

  /// Subtitle for about option
  ///
  /// In en, this message translates to:
  /// **'Learn more about PlatePal'**
  String get screensMenuLearnMorePlatePal;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get screensMenuLight;

  /// App creator credit
  ///
  /// In en, this message translates to:
  /// **'Made by MrLappes'**
  String get screensMenuMadeBy;

  /// Nutrition goals settings
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get screensMenuNutritionGoals;

  /// Display name of the Oceanic color theme
  ///
  /// In en, this message translates to:
  /// **'Oceanic'**
  String get screensMenuOceanic;

  /// Display name of the Forest color theme
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get screensMenuForest;

  /// Display name of the PlatePal color theme
  ///
  /// In en, this message translates to:
  /// **'PlatePal'**
  String get screensMenuPlatePal;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get screensMenuProfile;

  /// Subtitle for nutrition goals settings
  ///
  /// In en, this message translates to:
  /// **'Set your daily nutrition targets'**
  String get screensMenuSetNutritionTargets;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get screensMenuSystem;

  /// Theme selector label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get screensMenuTheme;

  /// User profile settings
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get screensMenuUserProfile;

  /// Subtitle for contributors option
  ///
  /// In en, this message translates to:
  /// **'View project contributors'**
  String get screensMenuViewContributors;

  /// View statistics button text
  ///
  /// In en, this message translates to:
  /// **'View Statistics'**
  String get screensMenuViewStatistics;

  /// Title of the in-app privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get screensPrivacyTitle;

  /// Effective date of the privacy policy
  ///
  /// In en, this message translates to:
  /// **'Effective date: 2026-09-30'**
  String get screensPrivacyEffectiveDate;

  /// Privacy policy overview heading
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get screensPrivacyOverviewTitle;

  /// Privacy policy overview
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker is an offline-first nutrition tracker. We do not run servers for your app data or require an account, and the app has no analytics, advertising, or tracking SDKs. The optional network features below contact their providers when used.'**
  String get screensPrivacyOverviewBody;

  /// Local storage section heading
  ///
  /// In en, this message translates to:
  /// **'Data on your device'**
  String get screensPrivacyStorageTitle;

  /// Local storage and API key handling
  ///
  /// In en, this message translates to:
  /// **'Dishes, meal logs, profile information (including body measurements), goals, chat history, and settings are stored on your device in SQLite or SharedPreferences. Saved food photos may also be kept in app storage. The API key you enter is stored using the platform\'s secure storage; legacy keys in SharedPreferences are migrated when possible.'**
  String get screensPrivacyStorageBody;

  /// Optional AI chat section heading
  ///
  /// In en, this message translates to:
  /// **'AI chat'**
  String get screensPrivacyAiTitle;

  /// AI provider data sharing
  ///
  /// In en, this message translates to:
  /// **'AI chat is optional and requires your own API key. When used, your chat messages, attached images, and, when relevant, conversation history, your profile, meal logs or nutrition summaries, and saved dishes are sent to OpenAI or the OpenAI-compatible endpoint you configured. The key is sent to that provider for authentication. That provider handles this information under its own privacy policy; choose an endpoint you trust. We do not receive these requests.'**
  String get screensPrivacyAiBody;

  /// Open Food Facts section heading
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts'**
  String get screensPrivacyFoodFactsTitle;

  /// Food lookup data sharing
  ///
  /// In en, this message translates to:
  /// **'When you search for food or scan a barcode, the app sends your search text or barcode number and selected filters to world.openfoodfacts.org. Product information and images can be downloaded from Open Food Facts.'**
  String get screensPrivacyFoodFactsBody;

  /// Health integration section heading
  ///
  /// In en, this message translates to:
  /// **'Health Connect and Apple Health'**
  String get screensPrivacyHealthTitle;

  /// Health access and local use
  ///
  /// In en, this message translates to:
  /// **'With your permission, the app reads calories burned (total and active on Android, active and basal on iOS) from Health Connect or Apple Health and writes nutrition for meals you log to that service. Readings are cached on this device and used for in-app energy and goal calculations; the app does not include Health readings in AI requests or send them to a developer server. Health Connect and Apple Health control their own stored records.'**
  String get screensPrivacyHealthBody;

  /// External content section heading
  ///
  /// In en, this message translates to:
  /// **'External links and images'**
  String get screensPrivacyExternalTitle;

  /// Third-party images and links
  ///
  /// In en, this message translates to:
  /// **'The Contributors screen loads avatar images from GitHub\'s avatars.githubusercontent.com. Opening GitHub, the online policy, other external websites, or remote product images contacts those services, which may see your IP address and process requests under their own policies.'**
  String get screensPrivacyExternalBody;

  /// Manual export and import section heading
  ///
  /// In en, this message translates to:
  /// **'Export and import'**
  String get screensPrivacyExportTitle;

  /// Export, import, and pre-import backups
  ///
  /// In en, this message translates to:
  /// **'Export files (JSON or CSV) are created locally when you choose to export; you can share them using your device. Import reads a file you choose and creates a local pre-import backup first, unless you explicitly continue when backup creation fails. Nothing is uploaded to us.'**
  String get screensPrivacyExportBody;

  /// Android operating system backup section heading
  ///
  /// In en, this message translates to:
  /// **'Android backup'**
  String get screensPrivacyBackupTitle;

  /// Possible Google backup of app data and Health cache
  ///
  /// In en, this message translates to:
  /// **'Android\'s system backup may copy the app\'s database and preferences, including cached Health calorie readings and chat history, to your Google account or transfer them to another device. The backup rules exclude secure-storage preference files, but a legacy API key may be present in other preferences until migration. Check your Android backup settings to control this.'**
  String get screensPrivacyBackupBody;

  /// Data deletion section heading
  ///
  /// In en, this message translates to:
  /// **'Delete your data'**
  String get screensPrivacyDeletionTitle;

  /// Reset, uninstall, and remaining copies
  ///
  /// In en, this message translates to:
  /// **'In Profile, Reset App deletes the SQLite database, SharedPreferences, and saved API key on this device. Uninstalling removes app-private data. Reset does not remove saved images, exported or pre-import backup files, copies shared elsewhere, Health Connect or Apple Health records already written, or system backups; remove those separately where applicable.'**
  String get screensPrivacyDeletionBody;

  /// Children's privacy section heading
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get screensPrivacyChildrenTitle;

  /// Children's privacy notice
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker is not intended for children. The app has no age verification; a parent or guardian should supervise use, especially before enabling external services or sharing sensitive information.'**
  String get screensPrivacyChildrenBody;

  /// Policy changes section heading
  ///
  /// In en, this message translates to:
  /// **'Changes to this policy'**
  String get screensPrivacyChangesTitle;

  /// How changes to the policy are announced
  ///
  /// In en, this message translates to:
  /// **'We may update this policy when the app changes. The effective date above shows when this version took effect; review the current policy in the app or GitHub repository.'**
  String get screensPrivacyChangesBody;

  /// Privacy contact section heading
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get screensPrivacyContactTitle;

  /// How to contact the project about privacy
  ///
  /// In en, this message translates to:
  /// **'For privacy questions, open a GitHub issue at github.com/MrLappes/platepal-tracker-flutter/issues. We cannot access data kept only on your device; use the app and platform controls above to delete it.'**
  String get screensPrivacyContactBody;

  /// Privacy policy menu subtitle
  ///
  /// In en, this message translates to:
  /// **'What leaves the device and how to control your data'**
  String get screensPrivacyMenuSubtitle;

  /// Button to open the privacy policy on GitHub
  ///
  /// In en, this message translates to:
  /// **'View online'**
  String get screensPrivacyViewOnline;

  /// Error shown when the online privacy policy cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the privacy policy.'**
  String get screensPrivacyLinkError;

  /// About the app title
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get screensSettingsAboutAboutAppTitle;

  /// App description
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker was created to provide a privacy-focused, open-source alternative to expensive nutrition tracking apps. We believe in putting control in your hands with no subscriptions, no ads, and no data collection.'**
  String get screensSettingsAboutAboutDescription;

  /// App motto
  ///
  /// In en, this message translates to:
  /// **'Made by gym guys for gym guys that hate paid apps'**
  String get screensSettingsAboutAppMotto;

  /// Message for coders
  ///
  /// In en, this message translates to:
  /// **'Coders shouldn\'t have to pay'**
  String get screensSettingsAboutCodersMessage;

  /// Privacy feature
  ///
  /// In en, this message translates to:
  /// **'Your data stays on your device'**
  String get screensSettingsAboutDataStaysOnDevice;

  /// Open source feature
  ///
  /// In en, this message translates to:
  /// **'100% free and open source'**
  String get screensSettingsAboutFreeOpenSource;

  /// GitHub repository URL
  ///
  /// In en, this message translates to:
  /// **'github.com/MrLappes/platepal-tracker'**
  String get screensSettingsAboutGithubRepository;

  /// AI key feature
  ///
  /// In en, this message translates to:
  /// **'Use your own AI key for full control'**
  String get screensSettingsAboutUseOwnAiKey;

  /// Website URL
  ///
  /// In en, this message translates to:
  /// **'plate-pal.de'**
  String get screensSettingsAboutWebsite;

  /// Why PlatePal section title
  ///
  /// In en, this message translates to:
  /// **'Why PlatePal?'**
  String get screensSettingsAboutWhyPlatePal;

  /// Section title for API key information
  ///
  /// In en, this message translates to:
  /// **'About OpenAI API Key'**
  String get screensSettingsApiKeySettingsAboutOpenAiApiKey;

  /// Status message when AI features are available
  ///
  /// In en, this message translates to:
  /// **'AI features are enabled'**
  String get screensSettingsApiKeySettingsAiFeaturesEnabled;

  /// Bullet points explaining API key usage
  ///
  /// In en, this message translates to:
  /// **'• Get your API key from platform.openai.com\n• Your key is stored locally on your device\n• Usage charges apply directly to your OpenAI account'**
  String get screensSettingsApiKeySettingsApiKeyBulletPoints;

  /// Status message when API key is set up
  ///
  /// In en, this message translates to:
  /// **'API Key Configured'**
  String get screensSettingsApiKeySettingsApiKeyConfigured;

  /// Description of what the API key is used for
  ///
  /// In en, this message translates to:
  /// **'To use AI features like meal analysis and suggestions, you need to provide your own OpenAI API key. This ensures your data stays private and you have full control.'**
  String get screensSettingsApiKeySettingsApiKeyDescription;

  /// Helper text for API key input field
  ///
  /// In en, this message translates to:
  /// **'Enter your OpenAI API key or leave empty to disable AI features'**
  String get screensSettingsApiKeySettingsApiKeyHelperText;

  /// Validation error for invalid API key format
  ///
  /// In en, this message translates to:
  /// **'API key must start with \"sk-\"'**
  String get screensSettingsApiKeySettingsApiKeyMustStartWith;

  /// Placeholder text for API key input
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get screensSettingsApiKeySettingsApiKeyPlaceholder;

  /// Success message for removing API key
  ///
  /// In en, this message translates to:
  /// **'API key removed successfully'**
  String get screensSettingsApiKeySettingsApiKeyRemovedSuccessfully;

  /// Success message for saving API key
  ///
  /// In en, this message translates to:
  /// **'API key saved successfully'**
  String get screensSettingsApiKeySettingsApiKeySavedSuccessfully;

  /// Warning message about API key testing
  ///
  /// In en, this message translates to:
  /// **'Your API key will be tested with a small request to verify it works. The key is only stored on your device and never sent to our servers'**
  String get screensSettingsApiKeySettingsApiKeyTestWarning;

  /// Validation error for API key length
  ///
  /// In en, this message translates to:
  /// **'API key appears to be too short'**
  String get screensSettingsApiKeySettingsApiKeyTooShort;

  /// Error message when clipboard is empty
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get screensSettingsApiKeySettingsClipboardEmpty;

  /// Error message when model loading fails
  ///
  /// In en, this message translates to:
  /// **'Could not load available models. Using default model list'**
  String get screensSettingsApiKeySettingsCouldNotLoadModels;

  /// Error message when clipboard access fails
  ///
  /// In en, this message translates to:
  /// **'Failed to access clipboard'**
  String get screensSettingsApiKeySettingsFailedToAccessClipboard;

  /// Error message for loading API key
  ///
  /// In en, this message translates to:
  /// **'Failed to load API key'**
  String get screensSettingsApiKeySettingsFailedToLoadApiKey;

  /// Error message for removing API key
  ///
  /// In en, this message translates to:
  /// **'Failed to remove API key'**
  String get screensSettingsApiKeySettingsFailedToRemoveApiKey;

  /// Error message for an insecure or invalid base URL
  ///
  /// In en, this message translates to:
  /// **'Base URL must start with https:// (http:// is only allowed for localhost)'**
  String get screensSettingsApiKeySettingsInvalidBaseUrl;

  /// Button text for opening OpenAI platform
  ///
  /// In en, this message translates to:
  /// **'Get API Key from OpenAI'**
  String get screensSettingsApiKeySettingsGetApiKeyFromOpenAi;

  /// Information about GPT-3.5 models
  ///
  /// In en, this message translates to:
  /// **'GPT-3.5 models are more cost-effective for basic analysis'**
  String get screensSettingsApiKeySettingsGpt35ModelsInfo;

  /// Information about GPT-4 models
  ///
  /// In en, this message translates to:
  /// **'GPT-4 models provide the best analysis but cost more'**
  String get screensSettingsApiKeySettingsGpt4ModelsInfo;

  /// Error message for link opening failure
  ///
  /// In en, this message translates to:
  /// **'An error occurred opening the link'**
  String get screensSettingsApiKeySettingsLinkError;

  /// Label for API key input field
  ///
  /// In en, this message translates to:
  /// **'OpenAI API Key'**
  String get screensSettingsApiKeySettingsOpenAiApiKey;

  /// Success message when pasting from clipboard
  ///
  /// In en, this message translates to:
  /// **'Pasted from clipboard'**
  String get screensSettingsApiKeySettingsPastedFromClipboard;

  /// Button text for pasting API key from clipboard
  ///
  /// In en, this message translates to:
  /// **'Paste from Clipboard'**
  String get screensSettingsApiKeySettingsPasteFromClipboard;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get screensSettingsApiKeySettingsRemove;

  /// Title for remove API key confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Remove API Key'**
  String get screensSettingsApiKeySettingsRemoveApiKey;

  /// Tooltip for revealing the API key
  ///
  /// In en, this message translates to:
  /// **'Show API key'**
  String get screensSettingsApiKeySettingsShowKey;

  /// Tooltip for concealing the API key
  ///
  /// In en, this message translates to:
  /// **'Hide API key'**
  String get screensSettingsApiKeySettingsHideKey;

  /// Tooltip for deleting the saved API key
  ///
  /// In en, this message translates to:
  /// **'Delete API key'**
  String get screensSettingsApiKeySettingsDeleteKey;

  /// Confirmation message for removing API key
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove your API key? This will disable AI features.'**
  String get screensSettingsApiKeySettingsRemoveApiKeyConfirmation;

  /// Label for model selection dropdown
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get screensSettingsApiKeySettingsSelectModel;

  /// Button text for testing and saving API key
  ///
  /// In en, this message translates to:
  /// **'Test & Save API Key'**
  String get screensSettingsApiKeySettingsTestAndSaveApiKey;

  /// Loading message while testing API key
  ///
  /// In en, this message translates to:
  /// **'Testing API key...'**
  String get screensSettingsApiKeySettingsTestingApiKey;

  /// Button text for updating existing API key
  ///
  /// In en, this message translates to:
  /// **'Update API Key'**
  String get screensSettingsApiKeySettingsUpdateApiKey;

  /// API mode section title
  ///
  /// In en, this message translates to:
  /// **'API Mode'**
  String get screensSettingsApiKeySettingsApiMode;

  /// Compatibility mode toggle label
  ///
  /// In en, this message translates to:
  /// **'OpenAI Compatible API'**
  String get screensSettingsApiKeySettingsCompatibleApi;

  /// Compatibility mode enabled description
  ///
  /// In en, this message translates to:
  /// **'Using custom OpenAI-compatible API endpoint'**
  String get screensSettingsApiKeySettingsUsingCustomEndpoint;

  /// Compatibility mode disabled description
  ///
  /// In en, this message translates to:
  /// **'Using official OpenAI API'**
  String get screensSettingsApiKeySettingsUsingOfficialApi;

  /// Custom API base URL label
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get screensSettingsApiKeySettingsBaseUrl;

  /// Custom API base URL helper
  ///
  /// In en, this message translates to:
  /// **'Enter the base URL for your OpenAI-compatible API'**
  String get screensSettingsApiKeySettingsBaseUrlHelper;

  /// Custom API base URL required error
  ///
  /// In en, this message translates to:
  /// **'Base URL is required for compatibility mode'**
  String get screensSettingsApiKeySettingsBaseUrlRequired;

  /// Generic API key label for compatible endpoints
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get screensSettingsApiKeySettingsApiKeyGeneric;

  /// Compatible API key helper
  ///
  /// In en, this message translates to:
  /// **'Enter your API key or leave empty to disable AI features'**
  String get screensSettingsApiKeySettingsCompatibilityKeyHelper;

  /// Compatible API key required error
  ///
  /// In en, this message translates to:
  /// **'API key is required for compatibility mode'**
  String get screensSettingsApiKeySettingsCompatibilityKeyRequired;

  /// Compatible API key length error
  ///
  /// In en, this message translates to:
  /// **'API key seems too short'**
  String get screensSettingsApiKeySettingsCompatibilityKeyTooShort;

  /// Custom API model name label
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get screensSettingsApiKeySettingsModelName;

  /// Custom API model name helper
  ///
  /// In en, this message translates to:
  /// **'Enter the exact model name supported by your API'**
  String get screensSettingsApiKeySettingsModelNameHelper;

  /// Custom API model required error
  ///
  /// In en, this message translates to:
  /// **'Model name is required for compatibility mode'**
  String get screensSettingsApiKeySettingsModelNameRequired;

  /// Switch subtitle for enabling deep search
  ///
  /// In en, this message translates to:
  /// **'Allow the agent to use deep search for more accurate answers'**
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchSubtitle;

  /// Switch title for enabling deep search
  ///
  /// In en, this message translates to:
  /// **'Enable Deep Search'**
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchTitle;

  /// Switch subtitle for enabling agent mode
  ///
  /// In en, this message translates to:
  /// **'Use the multi-step agent pipeline for chat'**
  String get screensSettingsChatAgentSettingsChatAgentEnableSubtitle;

  /// Switch title for enabling agent mode
  ///
  /// In en, this message translates to:
  /// **'Enable Agent Mode'**
  String get screensSettingsChatAgentSettingsChatAgentEnableTitle;

  /// Card description for agent mode explanation
  ///
  /// In en, this message translates to:
  /// **'Agent mode enables PlatePal\'s advanced multi-step reasoning pipeline for chat. This allows the assistant to analyze your query, gather context, and provide more accurate, explainable answers. Deep Search lets the agent use more data for even better results.'**
  String get screensSettingsChatAgentSettingsChatAgentInfoDescription;

  /// Card title for agent mode explanation
  ///
  /// In en, this message translates to:
  /// **'What is Agent Mode?'**
  String get screensSettingsChatAgentSettingsChatAgentInfoTitle;

  /// Title for chat agent settings screen
  ///
  /// In en, this message translates to:
  /// **'Chat Agent Settings'**
  String get screensSettingsChatAgentSettingsChatAgentSettingsTitle;

  /// Snackbar message when chat settings are saved
  ///
  /// In en, this message translates to:
  /// **'Chat settings saved successfully'**
  String get screensSettingsChatAgentSettingsChatSettingsSaved;

  /// Snackbar message when saving chat settings fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save chat settings'**
  String get screensSettingsChatAgentSettingsSaveFailed;

  /// Buy me creatine button text
  ///
  /// In en, this message translates to:
  /// **'Buy Me Creatine'**
  String get screensSettingsContributorsBuyMeCreatine;

  /// GitHub repository button text
  ///
  /// In en, this message translates to:
  /// **'Check Out Our GitHub Repository'**
  String get screensSettingsContributorsCheckGitHub;

  /// Tooltip on a contributor profile link
  ///
  /// In en, this message translates to:
  /// **'Open {name} on GitHub'**
  String screensSettingsContributorsOpenGitHubProfile(String name);

  /// Plural form for contributor count
  ///
  /// In en, this message translates to:
  /// **'Contributors'**
  String get screensSettingsContributorsContributorPlural;

  /// Singular form for contributor count
  ///
  /// In en, this message translates to:
  /// **'Contributor'**
  String get screensSettingsContributorsContributorSingular;

  /// Thank you message for contributors
  ///
  /// In en, this message translates to:
  /// **'Thanks to everyone who has contributed to making PlatePal Tracker possible!'**
  String get screensSettingsContributorsContributorsThankYou;

  /// Open source invitation message
  ///
  /// In en, this message translates to:
  /// **'PlatePal Tracker is open source - join us on GitHub!'**
  String get screensSettingsContributorsOpenSourceMessage;

  /// Support development section title
  ///
  /// In en, this message translates to:
  /// **'Support Development'**
  String get screensSettingsContributorsSupportDevelopment;

  /// Support development message
  ///
  /// In en, this message translates to:
  /// **'You want to buy me my creatine? Your support is greatly appreciated but not at all mandatory.'**
  String get screensSettingsContributorsSupportMessage;

  /// Want to contribute section title
  ///
  /// In en, this message translates to:
  /// **'Want to Contribute?'**
  String get screensSettingsContributorsWantToContribute;

  /// All data option
  ///
  /// In en, this message translates to:
  /// **'All Data'**
  String get screensSettingsExportDataAllData;

  /// Dishes data type
  ///
  /// In en, this message translates to:
  /// **'Dishes'**
  String get screensSettingsExportDataDishes;

  /// Export as CSV option
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get screensSettingsExportDataExportAsCsv;

  /// Export as JSON option
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get screensSettingsExportDataExportAsJson;

  /// Shows how many items were exported
  ///
  /// In en, this message translates to:
  /// **'Exported {count} items'**
  String screensSettingsExportDataExportedItemsCount(int count);

  /// Export progress message
  ///
  /// In en, this message translates to:
  /// **'Exporting data...'**
  String get screensSettingsExportDataExportProgress;

  /// Meal logs data type
  ///
  /// In en, this message translates to:
  /// **'Meal Logs'**
  String get screensSettingsExportDataMealLogs;

  /// Nutrition goals data type
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get screensSettingsExportDataNutritionGoalsData;

  /// Title for export data selection
  ///
  /// In en, this message translates to:
  /// **'Select data to export'**
  String get screensSettingsExportDataSelectDataToExport;

  /// Supplements data type
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get screensSettingsExportDataSupplements;

  /// User profiles data type
  ///
  /// In en, this message translates to:
  /// **'User Profiles'**
  String get screensSettingsExportDataUserProfiles;

  /// Question about handling duplicate items
  ///
  /// In en, this message translates to:
  /// **'How to handle duplicates?'**
  String get screensSettingsImportDataHowToHandleDuplicates;

  /// Shows how many items were imported
  ///
  /// In en, this message translates to:
  /// **'Imported {count} items'**
  String screensSettingsImportDataImportedItemsCount(int count);

  /// Import failed message
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get screensSettingsImportDataImportFailed;

  /// Import from file option
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get screensSettingsImportDataImportFromFile;

  /// Import progress message
  ///
  /// In en, this message translates to:
  /// **'Importing data...'**
  String get screensSettingsImportDataImportProgress;

  /// Merge duplicates option
  ///
  /// In en, this message translates to:
  /// **'Merge Duplicates'**
  String get screensSettingsImportDataMergeDuplicates;

  /// Overwrite duplicates option
  ///
  /// In en, this message translates to:
  /// **'Overwrite Duplicates'**
  String get screensSettingsImportDataOverwriteDuplicates;

  /// Title for import data selection
  ///
  /// In en, this message translates to:
  /// **'Select data to import'**
  String get screensSettingsImportDataSelectDataToImport;

  /// Button text to select a file
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get screensSettingsImportDataSelectFile;

  /// Skip duplicates option
  ///
  /// In en, this message translates to:
  /// **'Skip Duplicates'**
  String get screensSettingsImportDataSkipDuplicates;

  /// Export preparation status
  ///
  /// In en, this message translates to:
  /// **'Preparing your data...'**
  String get screensSettingsExportDataPreparing;

  /// Export preview heading
  ///
  /// In en, this message translates to:
  /// **'Export preview'**
  String get screensSettingsExportDataPreview;

  /// Selected export format
  ///
  /// In en, this message translates to:
  /// **'Format: {format}'**
  String screensSettingsExportDataFormatLabel(String format);

  /// Number of selected export sections
  ///
  /// In en, this message translates to:
  /// **'Selected data types: {count, plural, =1{1 type} other{{count} types}}'**
  String screensSettingsExportDataTypesSelected(int count);

  /// Export preview status
  ///
  /// In en, this message translates to:
  /// **'Ready to export'**
  String get screensSettingsExportDataReady;

  /// Dishes section description
  ///
  /// In en, this message translates to:
  /// **'Your saved recipes and dishes'**
  String get screensSettingsExportDataDishesDescription;

  /// Meal logs section description
  ///
  /// In en, this message translates to:
  /// **'Your meal history and nutrition logs'**
  String get screensSettingsExportDataMealLogsDescription;

  /// User profiles section description
  ///
  /// In en, this message translates to:
  /// **'User profile and preferences'**
  String get screensSettingsExportDataUserProfilesDescription;

  /// Ingredients section description
  ///
  /// In en, this message translates to:
  /// **'Ingredient database'**
  String get screensSettingsExportDataIngredientsDescription;

  /// Supplements section description
  ///
  /// In en, this message translates to:
  /// **'Supplement tracking data'**
  String get screensSettingsExportDataSupplementsDescription;

  /// Goals section description
  ///
  /// In en, this message translates to:
  /// **'Fitness and nutrition goals'**
  String get screensSettingsExportDataFitnessGoalsDescription;

  /// All data export description
  ///
  /// In en, this message translates to:
  /// **'Export all your data'**
  String get screensSettingsExportDataAllDataDescription;

  /// Format selection heading
  ///
  /// In en, this message translates to:
  /// **'Export format'**
  String get screensSettingsExportDataFormatTitle;

  /// JSON format description
  ///
  /// In en, this message translates to:
  /// **'Structured format, best for backups'**
  String get screensSettingsExportDataJsonDescription;

  /// CSV format description
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet format, good for analysis'**
  String get screensSettingsExportDataCsvDescription;

  /// Export error heading
  ///
  /// In en, this message translates to:
  /// **'Export error'**
  String get screensSettingsExportDataError;

  /// Export results heading
  ///
  /// In en, this message translates to:
  /// **'Export results'**
  String get screensSettingsExportDataResults;

  /// Export or import file name
  ///
  /// In en, this message translates to:
  /// **'File: {fileName}'**
  String screensSettingsExportDataFileLabel(String fileName);

  /// Export file path
  ///
  /// In en, this message translates to:
  /// **'Location: {path}'**
  String screensSettingsExportDataLocationLabel(String path);

  /// Export results count label
  ///
  /// In en, this message translates to:
  /// **'Items exported:'**
  String get screensSettingsExportDataItemsExported;

  /// Share exported file button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get screensSettingsExportDataShare;

  /// Show export path button
  ///
  /// In en, this message translates to:
  /// **'Show file location'**
  String get screensSettingsExportDataShowFileLocation;

  /// Export path dialog title
  ///
  /// In en, this message translates to:
  /// **'Export location'**
  String get screensSettingsExportDataLocationTitle;

  /// Export path dialog description
  ///
  /// In en, this message translates to:
  /// **'Your exported file is located at:'**
  String get screensSettingsExportDataLocationDescription;

  /// Sharing before an export exists
  ///
  /// In en, this message translates to:
  /// **'No file to share. Export your data first.'**
  String get screensSettingsExportDataNoFileToShare;

  /// Missing exported file message
  ///
  /// In en, this message translates to:
  /// **'Export file not found. Export your data again.'**
  String get screensSettingsExportDataFileNotFound;

  /// Sharing error
  ///
  /// In en, this message translates to:
  /// **'Could not share file: {error}'**
  String screensSettingsExportDataShareFailed(String error);

  /// Shared export text
  ///
  /// In en, this message translates to:
  /// **'PlatePal data export - {fileName}'**
  String screensSettingsExportDataShareText(String fileName);

  /// Shared export subject
  ///
  /// In en, this message translates to:
  /// **'PlatePal data export'**
  String get screensSettingsExportDataShareSubject;

  /// Export failure with technical details
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String screensSettingsExportDataFailedDetail(String error);

  /// Export stopped when a selected section cannot be read
  ///
  /// In en, this message translates to:
  /// **'Could not export the selected data. No file was created. Please try again.'**
  String get screensSettingsExportDataSectionFailed;

  /// Export file write failed
  ///
  /// In en, this message translates to:
  /// **'Could not save the export file. Please try again.'**
  String get screensSettingsExportDataWriteFailed;

  /// Failure when sharing the exported file
  ///
  /// In en, this message translates to:
  /// **'Could not share the file. Please try again.'**
  String get screensSettingsExportDataShareProblem;

  /// Restore progress heading
  ///
  /// In en, this message translates to:
  /// **'Restoring from backup...'**
  String get screensSettingsImportDataRestoring;

  /// Import progress count
  ///
  /// In en, this message translates to:
  /// **'Processing {current} of {total} items'**
  String screensSettingsImportDataProcessingItems(int current, int total);

  /// Currently imported data section
  ///
  /// In en, this message translates to:
  /// **'Current: {type}'**
  String screensSettingsImportDataCurrentType(String type);

  /// Restore progress detail
  ///
  /// In en, this message translates to:
  /// **'Undoing the last import...'**
  String get screensSettingsImportDataUndoing;

  /// File picker section heading
  ///
  /// In en, this message translates to:
  /// **'File selection'**
  String get screensSettingsImportDataFileSelection;

  /// Tooltip for clearing the selected import file
  ///
  /// In en, this message translates to:
  /// **'Remove selected file'**
  String get screensSettingsImportDataRemoveFile;

  /// Replace selected import file
  ///
  /// In en, this message translates to:
  /// **'Change file'**
  String get screensSettingsImportDataChangeFile;

  /// Accepted import file formats
  ///
  /// In en, this message translates to:
  /// **'Supported formats: JSON, CSV'**
  String get screensSettingsImportDataSupportedFormats;

  /// All data import description
  ///
  /// In en, this message translates to:
  /// **'Import everything from the file'**
  String get screensSettingsImportDataAllDataDescription;

  /// Skip duplicates description
  ///
  /// In en, this message translates to:
  /// **'Keep existing data; skip imported duplicates'**
  String get screensSettingsImportDataSkipDescription;

  /// Overwrite duplicates description
  ///
  /// In en, this message translates to:
  /// **'Replace existing data with imported data'**
  String get screensSettingsImportDataOverwriteDescription;

  /// Import advanced options heading
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get screensSettingsImportDataAdvancedOptions;

  /// Always-enabled import validation setting
  ///
  /// In en, this message translates to:
  /// **'Validate data before import'**
  String get screensSettingsImportDataValidateBeforeImport;

  /// Import validation description
  ///
  /// In en, this message translates to:
  /// **'Check data integrity and show warnings'**
  String get screensSettingsImportDataValidateDescription;

  /// Always-enabled backup setting
  ///
  /// In en, this message translates to:
  /// **'Create backup before import'**
  String get screensSettingsImportDataBackupBeforeImport;

  /// Import backup description
  ///
  /// In en, this message translates to:
  /// **'Automatically back up existing data'**
  String get screensSettingsImportDataBackupDescription;

  /// Import error heading
  ///
  /// In en, this message translates to:
  /// **'Import issues'**
  String get screensSettingsImportDataIssues;

  /// Import error list heading
  ///
  /// In en, this message translates to:
  /// **'Detailed errors:'**
  String get screensSettingsImportDataDetailedErrors;

  /// Introduces untranslated details from an imported file
  ///
  /// In en, this message translates to:
  /// **'File and row details (may appear in English):'**
  String get screensSettingsImportDataTechnicalDetails;

  /// Successful import results heading
  ///
  /// In en, this message translates to:
  /// **'Import results'**
  String get screensSettingsImportDataResults;

  /// Partial import warning heading
  ///
  /// In en, this message translates to:
  /// **'Import completed with skipped items'**
  String get screensSettingsImportDataPartialResults;

  /// Partial import totals
  ///
  /// In en, this message translates to:
  /// **'Imported {imported}, skipped {skipped}'**
  String screensSettingsImportDataImportedSkipped(int imported, int skipped);

  /// Expand skipped item reasons
  ///
  /// In en, this message translates to:
  /// **'Show reasons'**
  String get screensSettingsImportDataShowReasons;

  /// Count of import errors left out of the reasons list
  ///
  /// In en, this message translates to:
  /// **'…and {count} more'**
  String screensSettingsImportDataMoreReasons(int count);

  /// Section that could not be imported
  ///
  /// In en, this message translates to:
  /// **'Failed section: {section}'**
  String screensSettingsImportDataFailedSection(String section);

  /// Import confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm import'**
  String get screensSettingsImportDataConfirmTitle;

  /// Import confirmation section list label
  ///
  /// In en, this message translates to:
  /// **'Selected sections:'**
  String get screensSettingsImportDataSelectedSections;

  /// Import confirmation duplicate handling
  ///
  /// In en, this message translates to:
  /// **'Duplicates: {strategy}'**
  String screensSettingsImportDataDuplicatesLabel(String strategy);

  /// Confirm import button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get screensSettingsImportDataConfirmAction;

  /// Failed safety backup dialog title
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get screensSettingsImportDataBackupFailedTitle;

  /// Failed safety backup warning
  ///
  /// In en, this message translates to:
  /// **'The automatic backup could not be created. Continue importing without a backup?'**
  String get screensSettingsImportDataBackupFailedDescription;

  /// Explicit unsafe import action
  ///
  /// In en, this message translates to:
  /// **'Continue without backup'**
  String get screensSettingsImportDataContinueWithoutBackup;

  /// File picker error
  ///
  /// In en, this message translates to:
  /// **'Error selecting file: {error}'**
  String screensSettingsImportDataFileSelectionFailed(String error);

  /// Import failure count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import completed with 1 error} other{Import completed with {count} errors}}'**
  String screensSettingsImportDataCompletedWithErrors(int count);

  /// Import failure with technical details
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String screensSettingsImportDataFailedDetail(String error);

  /// Last import backup heading
  ///
  /// In en, this message translates to:
  /// **'Backup available'**
  String get screensSettingsImportDataBackupAvailable;

  /// Last import backup description
  ///
  /// In en, this message translates to:
  /// **'A backup from your last import is available.'**
  String get screensSettingsImportDataBackupAvailableDescription;

  /// Backup creation time
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String screensSettingsImportDataBackupCreated(String date);

  /// Backup size in kilobytes
  ///
  /// In en, this message translates to:
  /// **'Size: {size} KB'**
  String screensSettingsImportDataBackupSize(String size);

  /// Restore backup button
  ///
  /// In en, this message translates to:
  /// **'Undo last import'**
  String get screensSettingsImportDataUndoLastImport;

  /// Minutes since backup
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String screensSettingsImportDataMinutesAgo(int count);

  /// Hours since backup
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String screensSettingsImportDataHoursAgo(int count);

  /// Days since backup
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String screensSettingsImportDataDaysAgo(int count);

  /// Restore confirmation title
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get screensSettingsImportDataRestoreTitle;

  /// Restore confirmation warning
  ///
  /// In en, this message translates to:
  /// **'This will restore your data to the state before the last import. All changes made since then will be lost. Are you sure?'**
  String get screensSettingsImportDataRestoreWarning;

  /// Confirm restore button
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get screensSettingsImportDataRestoreAction;

  /// Successful restore message
  ///
  /// In en, this message translates to:
  /// **'Successfully restored from backup!'**
  String get screensSettingsImportDataRestoreSuccess;

  /// Restore error details
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String screensSettingsImportDataRestoreFailedDetail(String error);

  /// Selected import file has disappeared
  ///
  /// In en, this message translates to:
  /// **'Import file not found. Select it again.'**
  String get screensSettingsImportDataFileMissing;

  /// Import file size limit
  ///
  /// In en, this message translates to:
  /// **'This file is too large. Select a file of at most {maxSize} MB.'**
  String screensSettingsImportDataFileTooLarge(int maxSize);

  /// Invalid JSON import file
  ///
  /// In en, this message translates to:
  /// **'This file is not valid JSON. Check it and try again.'**
  String get screensSettingsImportDataInvalidJson;

  /// Import requires a supported file extension
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format. Select a JSON or CSV file.'**
  String get screensSettingsImportDataUnsupportedFormat;

  /// Import failed validation before writing any data
  ///
  /// In en, this message translates to:
  /// **'The file contains invalid data. Check the details and try again.'**
  String get screensSettingsImportDataInvalidData;

  /// File picker failure without technical details
  ///
  /// In en, this message translates to:
  /// **'Could not select a file. Please try again.'**
  String get screensSettingsImportDataFileSelectionProblem;

  /// Last import backup unavailable
  ///
  /// In en, this message translates to:
  /// **'No backup was found to restore.'**
  String get screensSettingsImportDataBackupMissing;

  /// Restore stopped before changing data
  ///
  /// In en, this message translates to:
  /// **'The backup could not be read. Nothing was changed.'**
  String get screensSettingsImportDataBackupUnreadable;

  /// Restore stopped when a safety snapshot failed
  ///
  /// In en, this message translates to:
  /// **'Could not protect your current data. Nothing was changed.'**
  String get screensSettingsImportDataSnapshotFailed;

  /// Generic restore failure without exposing exception details
  ///
  /// In en, this message translates to:
  /// **'Could not restore your backup. Check your data before trying again.'**
  String get screensSettingsImportDataRestoreProblem;

  /// Restore failed and the safety rollback succeeded
  ///
  /// In en, this message translates to:
  /// **'Restore failed, but your previous data was left unchanged.'**
  String get screensSettingsImportDataRestoreRolledBack;

  /// Restore and rollback failed; location of safety copy
  ///
  /// In en, this message translates to:
  /// **'Restore failed and your previous data may be incomplete. A recovery copy is saved at {path}.'**
  String screensSettingsImportDataRestoreCopySaved(String path);

  /// Activity level field label
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get screensSettingsImportProfileCompletionActivityLevel;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get screensSettingsImportProfileCompletionAge;

  /// Age range validation message
  ///
  /// In en, this message translates to:
  /// **'Age must be between 13 and 120'**
  String get screensSettingsImportProfileCompletionAgeRange;

  /// Build muscle fitness goal
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get screensSettingsImportProfileCompletionBuildMuscle;

  /// Extra active activity level
  ///
  /// In en, this message translates to:
  /// **'Extra Active'**
  String get screensSettingsImportProfileCompletionExtraActive;

  /// Female gender option
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get screensSettingsImportProfileCompletionFemale;

  /// Fitness goal field label
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get screensSettingsImportProfileCompletionFitnessGoal;

  /// Gain weight fitness goal
  ///
  /// In en, this message translates to:
  /// **'Gain Weight'**
  String get screensSettingsImportProfileCompletionGainWeight;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get screensSettingsImportProfileCompletionGender;

  /// Height field label
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get screensSettingsImportProfileCompletionHeight;

  /// Height range validation message
  ///
  /// In en, this message translates to:
  /// **'Height must be between 100-250 cm'**
  String get screensSettingsImportProfileCompletionHeightRange;

  /// Imperial unit system option
  ///
  /// In en, this message translates to:
  /// **'Imperial (lb, ft)'**
  String get screensSettingsImportProfileCompletionImperial;

  /// Lightly active activity level
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get screensSettingsImportProfileCompletionLightlyActive;

  /// Lose weight fitness goal
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get screensSettingsImportProfileCompletionLoseWeight;

  /// Maintain weight fitness goal
  ///
  /// In en, this message translates to:
  /// **'Maintain Weight'**
  String get screensSettingsImportProfileCompletionMaintainWeight;

  /// Male gender option
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get screensSettingsImportProfileCompletionMale;

  /// Metric unit system option
  ///
  /// In en, this message translates to:
  /// **'Metric (kg, cm)'**
  String get screensSettingsImportProfileCompletionMetric;

  /// Moderately active activity level
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get screensSettingsImportProfileCompletionModeratelyActive;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get screensSettingsImportProfileCompletionName;

  /// Other gender option
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get screensSettingsImportProfileCompletionOther;

  /// Personal information section title
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get screensSettingsImportProfileCompletionPersonalInformation;

  /// Preferences section title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get screensSettingsImportProfileCompletionPreferences;

  /// Sedentary activity level
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get screensSettingsImportProfileCompletionSedentary;

  /// Unit system field label
  ///
  /// In en, this message translates to:
  /// **'Unit System'**
  String get screensSettingsImportProfileCompletionUnitSystem;

  /// Very active activity level
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get screensSettingsImportProfileCompletionVeryActive;

  /// Weight field label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get screensSettingsImportProfileCompletionWeight;

  /// Weight range validation message
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 30-300 kg'**
  String get screensSettingsImportProfileCompletionWeightRange;

  /// Discard changes button text
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get screensSettingsMacroCustomizationDiscardChanges;

  /// Title for macro customization screen
  ///
  /// In en, this message translates to:
  /// **'Macro Customization'**
  String get screensSettingsMacroCustomizationMacroCustomization;

  /// Information text explaining macro customization
  ///
  /// In en, this message translates to:
  /// **'Customize your macro targets. All percentages must add up to 100%.'**
  String get screensSettingsMacroCustomizationMacroCustomizationInfo;

  /// Success message when macro targets are saved
  ///
  /// In en, this message translates to:
  /// **'Macro targets updated successfully'**
  String get screensSettingsMacroCustomizationMacroTargetsUpdated;

  /// Reset to default values button text
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get screensSettingsMacroCustomizationResetToDefaults;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get screensSettingsMacroCustomizationSaveChanges;

  /// Unsaved changes dialog title
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get screensSettingsMacroCustomizationUnsavedChanges;

  /// Unsaved changes dialog message
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them before leaving?'**
  String get screensSettingsMacroCustomizationUnsavedChangesMessage;

  /// Button text to analyze calorie targets
  ///
  /// In en, this message translates to:
  /// **'Analyze Targets'**
  String get screensSettingsProfileSettingsAnalyzeTargets;

  /// BMI label
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get screensSettingsProfileSettingsBmi;

  /// Connect to health button text
  ///
  /// In en, this message translates to:
  /// **'Connect to Health'**
  String get screensSettingsProfileSettingsConnectToHealth;

  /// Section title for dangerous operations
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get screensSettingsProfileSettingsDangerZone;

  /// Button text for debugging health data
  ///
  /// In en, this message translates to:
  /// **'Debug Health Data'**
  String get screensSettingsProfileSettingsDebugHealthData;

  /// Button text to disconnect from health services
  ///
  /// In en, this message translates to:
  /// **'Disconnect Health'**
  String get screensSettingsProfileSettingsDisconnectHealth;

  /// Fitness goals section title
  ///
  /// In en, this message translates to:
  /// **'Fitness Goals'**
  String get screensSettingsProfileSettingsFitnessGoals;

  /// Health data connected status message
  ///
  /// In en, this message translates to:
  /// **'Health data connected'**
  String get screensSettingsProfileSettingsHealthConnected;

  /// Health data sync section title
  ///
  /// In en, this message translates to:
  /// **'Health Data Sync'**
  String get screensSettingsProfileSettingsHealthDataSync;

  /// Health data disconnected status message
  ///
  /// In en, this message translates to:
  /// **'Health data not connected'**
  String get screensSettingsProfileSettingsHealthDisconnected;

  /// Health data not available dialog title
  ///
  /// In en, this message translates to:
  /// **'Health Data Not Available'**
  String get screensSettingsProfileSettingsHealthNotAvailable;

  /// Health data not available dialog message
  ///
  /// In en, this message translates to:
  /// **'Health data is not available on this device. Make sure you have Health Connect (Android) or Health app (iOS) installed and configured.'**
  String get screensSettingsProfileSettingsHealthNotAvailableMessage;

  /// Health permission denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Health Permission Denied'**
  String get screensSettingsProfileSettingsHealthPermissionDenied;

  /// Health permission denied dialog message
  ///
  /// In en, this message translates to:
  /// **'To sync your health data, PlatePal needs access to your health information. You can grant permissions in your phone\'s settings.'**
  String get screensSettingsProfileSettingsHealthPermissionDeniedMessage;

  /// Health sync failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to sync health data'**
  String get screensSettingsProfileSettingsHealthSyncFailed;

  /// Health sync success message
  ///
  /// In en, this message translates to:
  /// **'Health data synced successfully'**
  String get screensSettingsProfileSettingsHealthSyncSuccess;

  /// Profile settings screen title
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get screensSettingsProfileSettingsProfileSettings;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get screensSettingsProfileSettingsProfileUpdated;

  /// Button to reset the entire application
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get screensSettingsProfileSettingsResetApp;

  /// Cancel button for app reset dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get screensSettingsProfileSettingsResetAppCancel;

  /// Confirmation button for app reset
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete Everything'**
  String get screensSettingsProfileSettingsResetAppConfirm;

  /// Description of what will be deleted when resetting the app
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete ALL your data including:\n\n• Your profile information\n• All meal logs and nutrition data\n• All preferences and settings\n• All stored information\n\nThis action cannot be undone. Are you sure you want to continue?'**
  String get screensSettingsProfileSettingsResetAppDescription;

  /// Error message when app reset fails
  ///
  /// In en, this message translates to:
  /// **'Failed to reset application data'**
  String get screensSettingsProfileSettingsResetAppError;

  /// Success message after app reset
  ///
  /// In en, this message translates to:
  /// **'Application data has been reset successfully'**
  String get screensSettingsProfileSettingsResetAppSuccess;

  /// Title for reset app confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset Application Data'**
  String get screensSettingsProfileSettingsResetAppTitle;

  /// Sync health data button text
  ///
  /// In en, this message translates to:
  /// **'Sync Health Data'**
  String get screensSettingsProfileSettingsSyncHealthData;

  /// Target weight field label
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get screensSettingsProfileSettingsTargetWeight;

  /// All time range option
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get screensSettingsStatisticsAllTime;

  /// BMI history chart title
  ///
  /// In en, this message translates to:
  /// **'BMI History'**
  String get screensSettingsStatisticsBmiHistory;

  /// BMI category: Normal
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get screensSettingsStatisticsBmiNormal;

  /// BMI category: Obese
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get screensSettingsStatisticsBmiObese;

  /// BMI category: Overweight
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get screensSettingsStatisticsBmiOverweight;

  /// Tooltip for BMI statistics
  ///
  /// In en, this message translates to:
  /// **'Body Mass Index (BMI) is calculated from your weight and height measurements.'**
  String get screensSettingsStatisticsBmiStatsTip;

  /// BMI category: Underweight
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get screensSettingsStatisticsBmiUnderweight;

  /// Body fat field label
  ///
  /// In en, this message translates to:
  /// **'Body Fat'**
  String get screensSettingsStatisticsBodyFat;

  /// Body fat history chart title
  ///
  /// In en, this message translates to:
  /// **'Body Fat History'**
  String get screensSettingsStatisticsBodyFatHistory;

  /// Tooltip for body fat statistics
  ///
  /// In en, this message translates to:
  /// **'Body fat percentage helps track your body composition beyond just weight.'**
  String get screensSettingsStatisticsBodyFatStatsTip;

  /// Bulking phase label
  ///
  /// In en, this message translates to:
  /// **'Bulking'**
  String get screensSettingsStatisticsBulking;

  /// Calorie balance tooltip with health data
  ///
  /// In en, this message translates to:
  /// **'Track your actual calorie balance using health data. Green = maintenance, Blue = deficit, Orange = surplus.'**
  String get screensSettingsStatisticsCalorieBalanceTip;

  /// Calorie balance chart title with health data
  ///
  /// In en, this message translates to:
  /// **'Calorie Balance (Intake vs Expenditure)'**
  String get screensSettingsStatisticsCalorieBalanceTitle;

  /// Calorie intake history chart title
  ///
  /// In en, this message translates to:
  /// **'Calorie Intake vs Maintenance'**
  String get screensSettingsStatisticsCalorieIntakeHistory;

  /// Tooltip for calorie statistics
  ///
  /// In en, this message translates to:
  /// **'Compare your daily calorie intake to your maintenance calories. Green indicates maintenance, blue is cutting phase, orange is bulking phase.'**
  String get screensSettingsStatisticsCalorieStatsTip;

  /// Message when BMI cannot be calculated from available data
  ///
  /// In en, this message translates to:
  /// **'Cannot calculate BMI from available data'**
  String get screensSettingsStatisticsCannotCalculateBmiFromData;

  /// Cutting phase label
  ///
  /// In en, this message translates to:
  /// **'Cutting'**
  String get screensSettingsStatisticsCutting;

  /// Error message when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get screensSettingsStatisticsErrorLoadingData;

  /// Retry guidance after statistics load fails
  ///
  /// In en, this message translates to:
  /// **'Could not load your statistics. Please try again.'**
  String get screensSettingsStatisticsLoadFailedHint;

  /// Estimated balance label
  ///
  /// In en, this message translates to:
  /// **'Estimated Balance'**
  String get screensSettingsStatisticsEstimatedBalance;

  /// Extreme deficit warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: Frequent extreme calorie deficits may slow metabolism and cause muscle loss.'**
  String get screensSettingsStatisticsExtremeDeficitWarning;

  /// Generate test data button
  ///
  /// In en, this message translates to:
  /// **'Generate Test Data'**
  String get screensSettingsStatisticsGenerateTestData;

  /// Health data active message
  ///
  /// In en, this message translates to:
  /// **'Using your health app data to provide more accurate deficit/surplus analysis.'**
  String get screensSettingsStatisticsHealthDataActive;

  /// Health data alert message
  ///
  /// In en, this message translates to:
  /// **'Health Data Alert: {days} day(s) with very large calorie deficits (>1000 cal) based on actual expenditure.'**
  String screensSettingsStatisticsHealthDataAlert(String days);

  /// Health data inactive message
  ///
  /// In en, this message translates to:
  /// **'Enable health data sync in Profile Settings for more accurate analysis.'**
  String get screensSettingsStatisticsHealthDataInactive;

  /// Health data integration title
  ///
  /// In en, this message translates to:
  /// **'Health Data Integration'**
  String get screensSettingsStatisticsHealthDataIntegration;

  /// Inconsistent deficit warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: Your calorie deficit varies significantly day-to-day (variance: {variance} cal). Consider more consistent intake.'**
  String screensSettingsStatisticsInconsistentDeficitWarning(String variance);

  /// Last month time range option
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get screensSettingsStatisticsLastMonth;

  /// Last six months time range option
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get screensSettingsStatisticsLastSixMonths;

  /// Last three months time range option
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get screensSettingsStatisticsLastThreeMonths;

  /// Last week time range option
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get screensSettingsStatisticsLastWeek;

  /// Last year time range option
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get screensSettingsStatisticsLastYear;

  /// Maintenance phase label
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get screensSettingsStatisticsMaintenance;

  /// Message when no BMI data is available
  ///
  /// In en, this message translates to:
  /// **'No BMI data available'**
  String get screensSettingsStatisticsNoBmiDataAvailable;

  /// Message when no body fat data is available
  ///
  /// In en, this message translates to:
  /// **'No body fat data available'**
  String get screensSettingsStatisticsNoBodyFatDataAvailable;

  /// Message when no calorie data is available
  ///
  /// In en, this message translates to:
  /// **'No calorie data available'**
  String get screensSettingsStatisticsNoCalorieDataAvailable;

  /// Title when insufficient data for statistics
  ///
  /// In en, this message translates to:
  /// **'Not Enough Data'**
  String get screensSettingsStatisticsNotEnoughDataTitle;

  /// Message when no weight data is available
  ///
  /// In en, this message translates to:
  /// **'No weight data available'**
  String get screensSettingsStatisticsNoWeightDataAvailable;

  /// Phase analysis section title
  ///
  /// In en, this message translates to:
  /// **'Phase Analysis'**
  String get screensSettingsStatisticsPhaseAnalysis;

  /// Real data button text
  ///
  /// In en, this message translates to:
  /// **'Real Data'**
  String get screensSettingsStatisticsRealData;

  /// Refresh button tooltip
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get screensSettingsStatisticsRefresh;

  /// Statistics page title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get screensSettingsStatisticsStatistics;

  /// Description when insufficient data for statistics
  ///
  /// In en, this message translates to:
  /// **'We need at least a week of data to show meaningful statistics. Keep tracking your metrics to see trends over time.'**
  String get screensSettingsStatisticsStatisticsEmptyDescription;

  /// Test data description text
  ///
  /// In en, this message translates to:
  /// **'For demonstration purposes, you can generate sample data to see how the statistics look.'**
  String get screensSettingsStatisticsTestDataDescription;

  /// Time range selector label
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get screensSettingsStatisticsTimeRange;

  /// Try again button text
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get screensSettingsStatisticsTryAgain;

  /// Button to update metrics
  ///
  /// In en, this message translates to:
  /// **'Update Metrics Now'**
  String get screensSettingsStatisticsUpdateMetricsNow;

  /// Very high calorie notice message
  ///
  /// In en, this message translates to:
  /// **'Notice: {days} day(s) with very high calorie intake (>1000 cal above maintenance).'**
  String screensSettingsStatisticsVeryHighCalorieNotice(String days);

  /// Very low calorie warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: {days} day(s) with extremely low calorie intake (<1000 cal). This may be unhealthy.'**
  String screensSettingsStatisticsVeryLowCalorieWarning(String days);

  /// vs expenditure text
  ///
  /// In en, this message translates to:
  /// **'vs expenditure'**
  String get screensSettingsStatisticsVsExpenditure;

  /// Weekly average label
  ///
  /// In en, this message translates to:
  /// **'Weekly Average'**
  String get screensSettingsStatisticsWeeklyAverage;

  /// Weight history chart title
  ///
  /// In en, this message translates to:
  /// **'Weight History'**
  String get screensSettingsStatisticsWeightHistory;

  /// Tooltip for weight statistics
  ///
  /// In en, this message translates to:
  /// **'The graph shows median weekly weight to account for daily fluctuations due to water weight.'**
  String get screensSettingsStatisticsWeightStatsTip;

  /// Link availability true
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get utilsLinkHandlerAvailable;

  /// Error message when URL cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String utilsLinkHandlerCouldNotOpenUrl(String url);

  /// Link availability false
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get utilsLinkHandlerNotAvailable;

  /// Loading message for opening external link
  ///
  /// In en, this message translates to:
  /// **'Opening Buy Me Creatine page...'**
  String get utilsLinkHandlerOpeningLink;

  /// No description provided for @screensSettingsIndustrialSystemInfo.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM INFO //'**
  String get screensSettingsIndustrialSystemInfo;

  /// No description provided for @screensSettingsIndustrialProjectSchematics.
  ///
  /// In en, this message translates to:
  /// **'PROJECT SCHEMATICS'**
  String get screensSettingsIndustrialProjectSchematics;

  /// No description provided for @screensSettingsIndustrialCoreDirectives.
  ///
  /// In en, this message translates to:
  /// **'CORE_DIRECTIVES'**
  String get screensSettingsIndustrialCoreDirectives;

  /// No description provided for @screensSettingsIndustrialNetworkLinks.
  ///
  /// In en, this message translates to:
  /// **'NETWORK_LINKS'**
  String get screensSettingsIndustrialNetworkLinks;

  /// No description provided for @screensSettingsIndustrialNetworkOperatives.
  ///
  /// In en, this message translates to:
  /// **'NETWORK OPERATIVES'**
  String get screensSettingsIndustrialNetworkOperatives;

  /// No description provided for @screensSettingsIndustrialSourceRepository.
  ///
  /// In en, this message translates to:
  /// **'SOURCE REPOSITORY'**
  String get screensSettingsIndustrialSourceRepository;

  /// No description provided for @screensSettingsIndustrialOfficialDomain.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL DOMAIN'**
  String get screensSettingsIndustrialOfficialDomain;

  /// No description provided for @screensSettingsIndustrialWantToContribute.
  ///
  /// In en, this message translates to:
  /// **'WANT TO CONTRIBUTE?'**
  String get screensSettingsIndustrialWantToContribute;

  /// No description provided for @screensSettingsIndustrialSourceCode.
  ///
  /// In en, this message translates to:
  /// **'SOURCE_CODE'**
  String get screensSettingsIndustrialSourceCode;

  /// Label for build version
  ///
  /// In en, this message translates to:
  /// **'STABLE_BUILD_{version}'**
  String screensSettingsIndustrialStableBuild(Object version);

  /// No description provided for @screensSettingsContributorsHansRole.
  ///
  /// In en, this message translates to:
  /// **'AI Co-pilot & Resident Hacker'**
  String get screensSettingsContributorsHansRole;

  /// No description provided for @screensSettingsContributorsHansDesc.
  ///
  /// In en, this message translates to:
  /// **'Automating the grind and keeping the telemetry crisp. Cyber-minimalism architect.'**
  String get screensSettingsContributorsHansDesc;

  /// No description provided for @screensSettingsContributorsMrLappesRole.
  ///
  /// In en, this message translates to:
  /// **'Creator & Developer'**
  String get screensSettingsContributorsMrLappesRole;

  /// No description provided for @screensSettingsContributorsMrLappesDesc.
  ///
  /// In en, this message translates to:
  /// **'Created PlatePal Tracker with the vision of making a free, privacy-focused nutrition app for everyone.'**
  String get screensSettingsContributorsMrLappesDesc;

  /// No description provided for @screensSettingsHealthSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'HEALTH CONNECT //'**
  String get screensSettingsHealthSettingsTitle;

  /// No description provided for @screensSettingsHealthSettingsConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get screensSettingsHealthSettingsConnected;

  /// No description provided for @screensSettingsHealthSettingsNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Not Connected'**
  String get screensSettingsHealthSettingsNotConnected;

  /// No description provided for @screensSettingsHealthSettingsLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String screensSettingsHealthSettingsLastSynced(String time);

  /// No description provided for @screensSettingsHealthSettingsNotAvailableOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Health Connect is not available on this device.'**
  String get screensSettingsHealthSettingsNotAvailableOnDevice;

  /// No description provided for @screensSettingsHealthSettingsDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Health'**
  String get screensSettingsHealthSettingsDisconnectTitle;

  /// No description provided for @screensSettingsHealthSettingsDisconnectMessage.
  ///
  /// In en, this message translates to:
  /// **'This will stop syncing calories burned from Health Connect and stop writing meal data. Your existing data will be preserved.'**
  String get screensSettingsHealthSettingsDisconnectMessage;

  /// No description provided for @screensSettingsHealthSettingsDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get screensSettingsHealthSettingsDisconnect;

  /// No description provided for @screensSettingsHealthSettingsDataOverview.
  ///
  /// In en, this message translates to:
  /// **'DATA OVERVIEW'**
  String get screensSettingsHealthSettingsDataOverview;

  /// No description provided for @screensSettingsHealthSettingsTodaysBurned.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Burned'**
  String get screensSettingsHealthSettingsTodaysBurned;

  /// No description provided for @screensSettingsHealthSettingsNoDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get screensSettingsHealthSettingsNoDataYet;

  /// No description provided for @screensSettingsHealthSettingsDaysCached.
  ///
  /// In en, this message translates to:
  /// **'{count} days of data cached'**
  String screensSettingsHealthSettingsDaysCached(int count);

  /// No description provided for @screensSettingsHealthSettingsSyncControls.
  ///
  /// In en, this message translates to:
  /// **'SYNC CONTROLS'**
  String get screensSettingsHealthSettingsSyncControls;

  /// No description provided for @screensSettingsHealthSettingsSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Pulls the latest calories burned data from Health Connect for the past 7 days.'**
  String get screensSettingsHealthSettingsSyncDescription;

  /// No description provided for @screensSettingsHealthSettingsOpenHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Open Health Connect'**
  String get screensSettingsHealthSettingsOpenHealthConnect;

  /// No description provided for @screensSettingsHealthSettingsWriteBehavior.
  ///
  /// In en, this message translates to:
  /// **'WRITE BEHAVIOR'**
  String get screensSettingsHealthSettingsWriteBehavior;

  /// No description provided for @screensSettingsHealthSettingsWriteMeals.
  ///
  /// In en, this message translates to:
  /// **'Write meals to Health Connect'**
  String get screensSettingsHealthSettingsWriteMeals;

  /// No description provided for @screensSettingsHealthSettingsWriteMealsDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically log nutrition when you save a meal'**
  String get screensSettingsHealthSettingsWriteMealsDescription;

  /// No description provided for @screensSettingsHealthSettingsTargetAnalysis.
  ///
  /// In en, this message translates to:
  /// **'TARGET ANALYSIS'**
  String get screensSettingsHealthSettingsTargetAnalysis;

  /// No description provided for @screensSettingsHealthSettingsTargetAnalysisDescription.
  ///
  /// In en, this message translates to:
  /// **'Compare your calorie expenditure from Health Connect with your current calorie targets to see if adjustments are needed.'**
  String get screensSettingsHealthSettingsTargetAnalysisDescription;

  /// No description provided for @screensSettingsHealthSettingsCurrentTarget.
  ///
  /// In en, this message translates to:
  /// **'Current Target'**
  String get screensSettingsHealthSettingsCurrentTarget;

  /// No description provided for @screensSettingsHealthSettingsAvgExpenditure.
  ///
  /// In en, this message translates to:
  /// **'Avg. Expenditure'**
  String get screensSettingsHealthSettingsAvgExpenditure;

  /// No description provided for @screensSettingsHealthSettingsSuggestedTarget.
  ///
  /// In en, this message translates to:
  /// **'Suggested Target'**
  String get screensSettingsHealthSettingsSuggestedTarget;

  /// No description provided for @screensSettingsHealthSettingsDaysAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'Days Analyzed'**
  String get screensSettingsHealthSettingsDaysAnalyzed;

  /// No description provided for @screensSettingsHealthSettingsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get screensSettingsHealthSettingsApply;

  /// No description provided for @screensSettingsHealthSettingsCalorieTargetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Calorie target updated to {target} kcal'**
  String screensSettingsHealthSettingsCalorieTargetUpdated(String target);

  /// No description provided for @screensSettingsHealthSettingsCalorieTargetUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update calorie target'**
  String get screensSettingsHealthSettingsCalorieTargetUpdateFailed;

  /// No description provided for @screensSettingsHealthSettingsAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed: {error}'**
  String screensSettingsHealthSettingsAnalysisFailed(String error);

  /// No description provided for @screensSettingsHealthSettingsAboutHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'ABOUT HEALTH CONNECT'**
  String get screensSettingsHealthSettingsAboutHealthConnect;

  /// No description provided for @screensSettingsHealthSettingsAboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect PlatePal to Health Connect (Google Fit) to:'**
  String get screensSettingsHealthSettingsAboutDescription;

  /// No description provided for @screensSettingsHealthSettingsFeatureReadCalories.
  ///
  /// In en, this message translates to:
  /// **'Read your actual calories burned from fitness tracking'**
  String get screensSettingsHealthSettingsFeatureReadCalories;

  /// No description provided for @screensSettingsHealthSettingsFeatureWriteMeals.
  ///
  /// In en, this message translates to:
  /// **'Automatically write meal nutrition data to Health Connect'**
  String get screensSettingsHealthSettingsFeatureWriteMeals;

  /// No description provided for @screensSettingsHealthSettingsFeatureNetBalance.
  ///
  /// In en, this message translates to:
  /// **'See accurate net calorie balance (consumed vs burned)'**
  String get screensSettingsHealthSettingsFeatureNetBalance;

  /// No description provided for @screensSettingsHealthSettingsFeatureRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Get calorie target recommendations based on real expenditure'**
  String get screensSettingsHealthSettingsFeatureRecommendations;

  /// No description provided for @screensSettingsHealthSettingsAboutNote.
  ///
  /// In en, this message translates to:
  /// **'When connected, Health Connect becomes the single source of truth for calories burned — no estimated values.'**
  String get screensSettingsHealthSettingsAboutNote;

  /// No description provided for @screensSettingsHealthSettingsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get screensSettingsHealthSettingsJustNow;

  /// No description provided for @screensSettingsHealthSettingsMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String screensSettingsHealthSettingsMinutesAgo(int minutes);

  /// No description provided for @screensSettingsHealthSettingsHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String screensSettingsHealthSettingsHoursAgo(int hours);

  /// No description provided for @screensSettingsHealthSettingsDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String screensSettingsHealthSettingsDaysAgo(int days);

  /// No description provided for @screensMenuHealthAndFitness.
  ///
  /// In en, this message translates to:
  /// **'Health & Fitness'**
  String get screensMenuHealthAndFitness;

  /// No description provided for @screensMenuHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'HEALTH CONNECT'**
  String get screensMenuHealthConnect;

  /// No description provided for @screensMenuHealthConnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connected — syncing with Google Fit'**
  String get screensMenuHealthConnectedSubtitle;

  /// No description provided for @screensMenuHealthDisconnectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with Google Fit & Health Connect'**
  String get screensMenuHealthDisconnectedSubtitle;

  /// No description provided for @componentsCalendarMacroSummaryBurned.
  ///
  /// In en, this message translates to:
  /// **'{calories} burned'**
  String componentsCalendarMacroSummaryBurned(String calories);

  /// No description provided for @componentsCalendarMacroSummaryNetCalories.
  ///
  /// In en, this message translates to:
  /// **'Net: {value}'**
  String componentsCalendarMacroSummaryNetCalories(String value);

  /// No description provided for @componentsCalendarMacroSummaryNoBurnData.
  ///
  /// In en, this message translates to:
  /// **'No burn data for this day'**
  String get componentsCalendarMacroSummaryNoBurnData;

  /// No description provided for @screensCalendarHealthDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'The nutrition entry in Health Connect will not be removed. You can delete it manually in the Health Connect app.'**
  String get screensCalendarHealthDeleteWarning;

  /// No description provided for @screensSettingsProfileSettingsManageHealthConnect.
  ///
  /// In en, this message translates to:
  /// **'Manage Health Connect'**
  String get screensSettingsProfileSettingsManageHealthConnect;

  /// No description provided for @screensSettingsProfileSettingsLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String screensSettingsProfileSettingsLastSynced(String time);

  /// Fallback reply shown when the agent fails to parse the user request
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I\'m having trouble processing your request right now. Could you please try rephrasing your question?'**
  String get servicesChatAgentFallbackParsing;

  /// Fallback reply shown on critical agent error
  ///
  /// In en, this message translates to:
  /// **'I\'m experiencing some technical difficulties at the moment. Please try again in a few moments.'**
  String get servicesChatAgentFallbackCritical;

  /// Fallback reply shown on network error
  ///
  /// In en, this message translates to:
  /// **'I\'m having trouble connecting to my knowledge base right now. Please check your internet connection and try again.'**
  String get servicesChatAgentFallbackNetwork;

  /// Fallback reply shown when context is too long
  ///
  /// In en, this message translates to:
  /// **'Your request contains a lot of information. Could you please break it down into smaller, more specific questions?'**
  String get servicesChatAgentFallbackContext;

  /// Generic fallback reply for unknown agent errors
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I encountered an unexpected issue. Please try again.'**
  String get servicesChatAgentFallbackGeneric;

  /// Fallback reply when response generation fails
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I encountered an issue generating a response. Please try again.'**
  String get servicesChatAgentFallbackGenerateResponse;

  /// Fallback reply for transient agent step failure
  ///
  /// In en, this message translates to:
  /// **'I encountered a temporary issue processing your request. Please try again.'**
  String get servicesChatAgentFallbackTemporaryIssue;

  /// Fallback reply asking user to rephrase
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I\'m having trouble with that request. Could you try rephrasing it?'**
  String get servicesChatAgentFallbackRephrase;

  /// Prefix shown when the AI returns dish data without a reply text
  ///
  /// In en, this message translates to:
  /// **'Here is the dish information:'**
  String get servicesChatAgentFallbackDishInfo;

  /// Reply when the model returned JSON without response text
  ///
  /// In en, this message translates to:
  /// **'No response text found.'**
  String get servicesChatAgentFallbackNoResponse;

  /// Reply when the model response has an invalid format
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t process my response. Please try again.'**
  String get servicesChatAgentFallbackFormatting;

  /// Title of the dish image section
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get screensDishCreateImage;

  /// Placeholder for a dish without an image
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get screensDishCreateNoImageSelected;

  /// Button for replacing a dish image
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get screensDishCreateChangeImage;

  /// Button for choosing a dish image
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get screensDishCreateAddImage;

  /// Confirmation before leaving an edited dish
  ///
  /// In en, this message translates to:
  /// **'Discard your unsaved changes?'**
  String get screensDishCreateConfirmDiscardChanges;

  /// Compact protein label on an ingredient
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get screensDishCreateProteinAbbreviation;

  /// Compact carbohydrate label on an ingredient
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get screensDishCreateCarbsAbbreviation;

  /// Compact fat label on an ingredient
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get screensDishCreateFatAbbreviation;

  /// Label for an ingredient unit selector
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get componentsDishesDishFormIngredientFormModalUnit;

  /// Nutrition basis for ingredients counted in pieces
  ///
  /// In en, this message translates to:
  /// **'Nutrition per piece'**
  String get componentsDishesDishFormIngredientFormModalNutritionPerPiece;

  /// Nutrition basis for ingredients counted in slices
  ///
  /// In en, this message translates to:
  /// **'Nutrition per slice'**
  String get componentsDishesDishFormIngredientFormModalNutritionPerSlice;

  /// Confirmation after filling the ingredient form from a product
  ///
  /// In en, this message translates to:
  /// **'Product information loaded. Adjust quantity and save.'**
  String
  get componentsDishesDishFormIngredientFormModalProductInformationLoaded;

  /// Tooltip for dish nutrition recalculation
  ///
  /// In en, this message translates to:
  /// **'Recalculate from ingredients'**
  String
  get componentsDishesDishFormSmartNutritionCardRecalculateFromIngredients;

  /// Title for a protein-rich dish
  ///
  /// In en, this message translates to:
  /// **'High Protein'**
  String get componentsDishesDishFormSmartNutritionCardHighProtein;

  /// Title for a carbohydrate-rich dish
  ///
  /// In en, this message translates to:
  /// **'High Carb'**
  String get componentsDishesDishFormSmartNutritionCardHighCarb;

  /// Title for a fat-rich dish
  ///
  /// In en, this message translates to:
  /// **'High Fat'**
  String get componentsDishesDishFormSmartNutritionCardHighFat;

  /// Title for a balanced dish
  ///
  /// In en, this message translates to:
  /// **'Well Balanced'**
  String get componentsDishesDishFormSmartNutritionCardWellBalanced;

  /// Feedback for a protein-rich dish
  ///
  /// In en, this message translates to:
  /// **'Excellent! High protein content supports muscle building and satiety.'**
  String get componentsDishesDishFormSmartNutritionCardHighProteinFeedback;

  /// Feedback for a carbohydrate-rich dish
  ///
  /// In en, this message translates to:
  /// **'Great for energy! Perfect pre-workout or active days.'**
  String get componentsDishesDishFormSmartNutritionCardHighCarbFeedback;

  /// Feedback for a fat-rich dish
  ///
  /// In en, this message translates to:
  /// **'High in fats. Enjoy in moderation and balance with other meals.'**
  String get componentsDishesDishFormSmartNutritionCardHighFatFeedback;

  /// Feedback for a balanced dish
  ///
  /// In en, this message translates to:
  /// **'Perfect balance! This dish provides well-rounded nutrition.'**
  String get componentsDishesDishFormSmartNutritionCardBalancedFeedback;

  /// Feedback when dish nutrition needs more data
  ///
  /// In en, this message translates to:
  /// **'Enter nutrition values to see smart analysis and recommendations.'**
  String get componentsDishesDishFormSmartNutritionCardUnbalancedFeedback;

  /// No description provided for @screensSettingsProfileSettingsPhysicalStats.
  ///
  /// In en, this message translates to:
  /// **'Physical Stats'**
  String get screensSettingsProfileSettingsPhysicalStats;

  /// No description provided for @screensSettingsProfileSettingsBodyFatOptional.
  ///
  /// In en, this message translates to:
  /// **'Body Fat % (optional)'**
  String get screensSettingsProfileSettingsBodyFatOptional;

  /// No description provided for @screensSettingsProfileSettingsOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get screensSettingsProfileSettingsOptional;

  /// No description provided for @screensSettingsProfileSettingsNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get screensSettingsProfileSettingsNameHint;

  /// No description provided for @screensSettingsProfileSettingsCustomizeMacroRatios.
  ///
  /// In en, this message translates to:
  /// **'Customize Macro Ratios'**
  String get screensSettingsProfileSettingsCustomizeMacroRatios;

  /// No description provided for @screensSettingsProfileSettingsImperialHeightRange.
  ///
  /// In en, this message translates to:
  /// **'Height must be between 39 and 98 inches'**
  String get screensSettingsProfileSettingsImperialHeightRange;

  /// No description provided for @screensSettingsProfileSettingsImperialWeightRange.
  ///
  /// In en, this message translates to:
  /// **'Weight must be between 66 and 660 lbs'**
  String get screensSettingsProfileSettingsImperialWeightRange;

  /// No description provided for @screensSettingsProfileSettingsValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get screensSettingsProfileSettingsValidNumber;

  /// No description provided for @screensSettingsProfileSettingsBodyFatRange.
  ///
  /// In en, this message translates to:
  /// **'Body fat must be between 3% and 50%'**
  String get screensSettingsProfileSettingsBodyFatRange;

  /// No description provided for @screensSettingsProfileSettingsBaseMetabolicRate.
  ///
  /// In en, this message translates to:
  /// **'Base Metabolic Rate'**
  String get screensSettingsProfileSettingsBaseMetabolicRate;

  /// No description provided for @screensSettingsProfileSettingsTotalDailyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Energy'**
  String get screensSettingsProfileSettingsTotalDailyEnergy;

  /// No description provided for @screensSettingsProfileSettingsResettingAppData.
  ///
  /// In en, this message translates to:
  /// **'Resetting application data...'**
  String get screensSettingsProfileSettingsResettingAppData;

  /// No description provided for @screensSettingsProfileSettingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile data: {error}'**
  String screensSettingsProfileSettingsLoadFailed(String error);

  /// No description provided for @screensSettingsProfileSettingsUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String screensSettingsProfileSettingsUpdateFailed(String error);

  /// No description provided for @screensSettingsMacroCustomizationDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories: {calories} kcal'**
  String screensSettingsMacroCustomizationDailyCalories(String calories);

  /// No description provided for @screensSettingsMacroCustomizationMacroRatios.
  ///
  /// In en, this message translates to:
  /// **'Macro Ratios'**
  String get screensSettingsMacroCustomizationMacroRatios;

  /// No description provided for @screensSettingsMacroCustomizationFiberTarget.
  ///
  /// In en, this message translates to:
  /// **'Fiber Target'**
  String get screensSettingsMacroCustomizationFiberTarget;

  /// No description provided for @screensSettingsMacroCustomizationTargetPreview.
  ///
  /// In en, this message translates to:
  /// **'Target Preview'**
  String get screensSettingsMacroCustomizationTargetPreview;

  /// No description provided for @screensSettingsMacroCustomizationQuickPresets.
  ///
  /// In en, this message translates to:
  /// **'Quick Presets'**
  String get screensSettingsMacroCustomizationQuickPresets;

  /// No description provided for @screensSettingsMacroCustomizationTotalRatio.
  ///
  /// In en, this message translates to:
  /// **'Total: {value}%'**
  String screensSettingsMacroCustomizationTotalRatio(String value);

  /// No description provided for @screensSettingsMacroCustomizationPinMacro.
  ///
  /// In en, this message translates to:
  /// **'Pin {macro}'**
  String screensSettingsMacroCustomizationPinMacro(String macro);

  /// No description provided for @screensSettingsMacroCustomizationUnpinMacro.
  ///
  /// In en, this message translates to:
  /// **'Unpin {macro}'**
  String screensSettingsMacroCustomizationUnpinMacro(String macro);

  /// No description provided for @screensSettingsMacroCustomizationPinnedValue.
  ///
  /// In en, this message translates to:
  /// **'Pinned - value locked'**
  String get screensSettingsMacroCustomizationPinnedValue;

  /// No description provided for @screensSettingsMacroCustomizationTooManyPins.
  ///
  /// In en, this message translates to:
  /// **'Cannot adjust - too many pins active'**
  String get screensSettingsMacroCustomizationTooManyPins;

  /// No description provided for @screensSettingsMacroCustomizationFiberTotal.
  ///
  /// In en, this message translates to:
  /// **'{grams} g total'**
  String screensSettingsMacroCustomizationFiberTotal(String grams);

  /// No description provided for @screensSettingsMacroCustomizationFiberPer1000Calories.
  ///
  /// In en, this message translates to:
  /// **'{grams} g per 1000 calories'**
  String screensSettingsMacroCustomizationFiberPer1000Calories(String grams);

  /// No description provided for @screensSettingsMacroCustomizationFiberGuidance.
  ///
  /// In en, this message translates to:
  /// **'Recommended: 14 g per 1000 calories (FDA guideline). Range: 5-35 g per 1000 calories'**
  String get screensSettingsMacroCustomizationFiberGuidance;

  /// No description provided for @screensSettingsMacroCustomizationDailyMacroTargets.
  ///
  /// In en, this message translates to:
  /// **'Daily Macro Targets'**
  String get screensSettingsMacroCustomizationDailyMacroTargets;

  /// No description provided for @screensSettingsMacroCustomizationPresetDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose from common macro distributions'**
  String get screensSettingsMacroCustomizationPresetDescription;

  /// No description provided for @screensSettingsMacroCustomizationBalancedPreset.
  ///
  /// In en, this message translates to:
  /// **'Balanced (30P / 40C / 30F)'**
  String get screensSettingsMacroCustomizationBalancedPreset;

  /// No description provided for @screensSettingsMacroCustomizationHighProteinPreset.
  ///
  /// In en, this message translates to:
  /// **'High Protein (40P / 30C / 30F)'**
  String get screensSettingsMacroCustomizationHighProteinPreset;

  /// No description provided for @screensSettingsMacroCustomizationProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'User profile not found. Please set up your profile.'**
  String get screensSettingsMacroCustomizationProfileNotFound;

  /// No description provided for @screensSettingsMacroCustomizationLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String screensSettingsMacroCustomizationLoadFailed(String error);

  /// No description provided for @screensSettingsMacroCustomizationSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save macro targets: {error}'**
  String screensSettingsMacroCustomizationSaveFailed(String error);

  /// Statistics missing profile error
  ///
  /// In en, this message translates to:
  /// **'User profile not found'**
  String get screensSettingsStatisticsProfileNotFound;

  /// Test data error
  ///
  /// In en, this message translates to:
  /// **'Failed to generate test data: {error}'**
  String screensSettingsStatisticsTestDataFailed(String error);

  /// Number of days in a calorie phase
  ///
  /// In en, this message translates to:
  /// **'({count, plural, =1{1 day} other{{count} days}})'**
  String screensSettingsStatisticsPhaseDays(int count);

  /// Daily calorie difference
  ///
  /// In en, this message translates to:
  /// **'{value} cal/day'**
  String screensSettingsStatisticsCalPerDay(String value);

  /// Calorie value
  ///
  /// In en, this message translates to:
  /// **'{value} cal'**
  String screensSettingsStatisticsCalValue(String value);

  /// Calorie expenditure coverage
  ///
  /// In en, this message translates to:
  /// **'Calorie expenditure data coverage: {percent}% ({healthDays}/{totalDays} {totalDays, plural, =1{day} other{days}})'**
  String screensSettingsStatisticsCoverage(
    String percent,
    int healthDays,
    int totalDays,
  );

  /// Measured calorie balance label
  ///
  /// In en, this message translates to:
  /// **'Actual Balance'**
  String get screensSettingsStatisticsActualBalance;

  /// Accessible summary of a statistics chart
  ///
  /// In en, this message translates to:
  /// **'{chart}: {count} data points, chart scale {minimum} to {maximum}'**
  String screensSettingsStatisticsChartSummary(
    String chart,
    int count,
    String minimum,
    String maximum,
  );

  /// Analysis requires a saved profile
  ///
  /// In en, this message translates to:
  /// **'User profile not found'**
  String get screensSettingsHealthSettingsAnalysisProfileNotFound;

  /// Analysis has no expenditure data
  ///
  /// In en, this message translates to:
  /// **'No calorie expenditure data available for analysis'**
  String get screensSettingsHealthSettingsAnalysisNoData;

  /// Recommendation when target is too low
  ///
  /// In en, this message translates to:
  /// **'Your calorie expenditure is significantly higher than your current target suggests. Consider increasing your calorie intake.'**
  String get screensSettingsHealthSettingsAnalysisIncreaseIntake;

  /// Recommendation when target is too high
  ///
  /// In en, this message translates to:
  /// **'Your calorie expenditure is lower than your current target suggests. Consider adjusting your calorie intake or increasing activity.'**
  String get screensSettingsHealthSettingsAnalysisDecreaseIntake;

  /// Recommendation when target matches activity
  ///
  /// In en, this message translates to:
  /// **'Your current calorie targets seem well-aligned with your activity level.'**
  String get screensSettingsHealthSettingsAnalysisOnTarget;

  /// Analysis error with details
  ///
  /// In en, this message translates to:
  /// **'Error occurred during analysis: {error}'**
  String screensSettingsHealthSettingsAnalysisError(String error);

  /// Thinking step progress
  ///
  /// In en, this message translates to:
  /// **'Analyzing your request and planning approach...'**
  String get servicesChatAgentThinking;

  /// Thinking step detail
  ///
  /// In en, this message translates to:
  /// **'Breaking down your request and determining the best approach'**
  String get servicesChatAgentThinkingDetail;

  /// Context gathering progress
  ///
  /// In en, this message translates to:
  /// **'Gathering relevant context and user data...'**
  String get servicesChatAgentContext;

  /// Context gathering detail
  ///
  /// In en, this message translates to:
  /// **'Collecting your profile, preferences, and relevant meal history'**
  String get servicesChatAgentContextDetail;

  /// Response generation progress
  ///
  /// In en, this message translates to:
  /// **'Crafting your personalized response...'**
  String get servicesChatAgentResponse;

  /// Response generation detail
  ///
  /// In en, this message translates to:
  /// **'Combining all information to create a helpful and personalized answer'**
  String get servicesChatAgentResponseDetail;

  /// Dish processing progress
  ///
  /// In en, this message translates to:
  /// **'Processing and analyzing dishes...'**
  String get servicesChatAgentDish;

  /// Dish processing detail
  ///
  /// In en, this message translates to:
  /// **'Calculating nutrition values, ingredients, and meal details'**
  String get servicesChatAgentDishDetail;

  /// Dish validation progress
  ///
  /// In en, this message translates to:
  /// **'Validating and refining dishes...'**
  String get servicesChatAgentDishValidation;

  /// Dish validation detail
  ///
  /// In en, this message translates to:
  /// **'Ensuring dishes have accurate nutrition and ingredient data'**
  String get servicesChatAgentDishValidationDetail;

  /// Error handling progress
  ///
  /// In en, this message translates to:
  /// **'Handling unexpected error...'**
  String get servicesChatAgentError;

  /// Error handling detail
  ///
  /// In en, this message translates to:
  /// **'Attempting to recover from error and provide a helpful response'**
  String get servicesChatAgentErrorDetail;

  /// Deep verification progress
  ///
  /// In en, this message translates to:
  /// **'Validating context sufficiency for optimal response...'**
  String get servicesChatAgentVerify;

  /// Deep verification detail
  ///
  /// In en, this message translates to:
  /// **'Analyzing gathered context to ensure we can provide the best possible answer'**
  String get servicesChatAgentVerifyDetail;

  /// Image processing progress
  ///
  /// In en, this message translates to:
  /// **'Analyzing your uploaded image...'**
  String get servicesChatAgentImage;

  /// Image processing detail
  ///
  /// In en, this message translates to:
  /// **'Extracting food items, ingredients, and portion sizes from your image'**
  String get servicesChatAgentImageDetail;

  /// Unknown step progress
  ///
  /// In en, this message translates to:
  /// **'Processing step: {step}...'**
  String servicesChatAgentUnknownStep(String step);

  /// Unknown step detail
  ///
  /// In en, this message translates to:
  /// **'Processing information for step: {step}'**
  String servicesChatAgentUnknownDetail(String step);

  /// Agent restart progress
  ///
  /// In en, this message translates to:
  /// **'Restarting with enhanced strategy (attempt {attempt}/3)...'**
  String servicesChatAgentRestart(int attempt);

  /// Failed step progress
  ///
  /// In en, this message translates to:
  /// **'Step \"{step}\" encountered an issue, attempting recovery...'**
  String servicesChatAgentFailedStep(String step);

  /// Failed chat message: the provider rejected the API key (401/403)
  ///
  /// In en, this message translates to:
  /// **'Your API key was rejected. Check it in the API key settings.'**
  String get componentsChatMessageBubbleErrorAuth;

  /// Failed chat message: rate limit or quota reached (429)
  ///
  /// In en, this message translates to:
  /// **'Your AI provider\'s rate limit or quota was reached. Wait a moment or check your plan and credit, then try again.'**
  String get componentsChatMessageBubbleErrorRateLimit;

  /// Failed chat message: network error or timeout
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the AI provider or the request timed out. Check your internet connection and try again.'**
  String get componentsChatMessageBubbleErrorNetwork;

  /// Failed chat message: provider server error (5xx)
  ///
  /// In en, this message translates to:
  /// **'The AI provider is currently unavailable. Please try again in a moment.'**
  String get componentsChatMessageBubbleErrorServer;

  /// Failed chat message: the stored API key could not be read
  ///
  /// In en, this message translates to:
  /// **'Your API key couldn\'t be read on this device. Enter it again in the API key settings.'**
  String get componentsChatMessageBubbleErrorKeyUnreadable;

  /// Failed chat message: unknown cause
  ///
  /// In en, this message translates to:
  /// **'The message couldn\'t be sent. Please try again.'**
  String get componentsChatMessageBubbleErrorUnknown;

  /// Button on a failed message that opens the API key settings
  ///
  /// In en, this message translates to:
  /// **'API key settings'**
  String get componentsChatMessageBubbleOpenApiKeySettings;

  /// Note under an AI answer when profile, dish or meal data failed to load
  ///
  /// In en, this message translates to:
  /// **'Some of your data couldn\'t be loaded; the answer may be less personal.'**
  String get componentsChatMessageBubbleNoteContextIncomplete;

  /// Note under an AI answer when the attached image could not be processed
  ///
  /// In en, this message translates to:
  /// **'The image couldn\'t be analyzed.'**
  String get componentsChatMessageBubbleNoteImageNotAnalyzed;

  /// Snackbar when saved chat messages could not be read
  ///
  /// In en, this message translates to:
  /// **'Some of your chat history couldn\'t be loaded.'**
  String get screensChatHistoryLoadFailed;

  /// Snackbar when chat messages could not be saved
  ///
  /// In en, this message translates to:
  /// **'Your chat history couldn\'t be saved on this device.'**
  String get screensChatHistorySaveFailed;

  /// Snackbar when agent mode settings could not be read or written
  ///
  /// In en, this message translates to:
  /// **'Chat settings couldn\'t be loaded or saved. Defaults are used for now.'**
  String get screensChatSettingsFailed;

  /// Snackbar when chat profiles could not be read
  ///
  /// In en, this message translates to:
  /// **'Chat profiles couldn\'t be loaded. Defaults are shown; your saved profiles were not changed.'**
  String get screensChatProfilesLoadFailed;

  /// Snackbar when a chat profile change could not be saved
  ///
  /// In en, this message translates to:
  /// **'Your profile changes couldn\'t be saved.'**
  String get screensChatProfileSaveFailed;

  /// Chat screen title when the stored API key could not be read
  ///
  /// In en, this message translates to:
  /// **'Your API key couldn\'t be read'**
  String get screensChatApiKeyReadFailedTitle;

  /// Chat screen explanation when the stored API key could not be read
  ///
  /// In en, this message translates to:
  /// **'The key stored on this device couldn\'t be accessed. Reload to try again, or enter it again in the API key settings.'**
  String get screensChatApiKeyReadFailedMessage;

  /// Banner when health or calorie history failed to load
  ///
  /// In en, this message translates to:
  /// **'Some health or calorie data couldn\'t be loaded, so the charts may be incomplete.'**
  String get screensSettingsStatisticsPartialLoadFailed;

  /// Snackbar when today's health data failed to load
  ///
  /// In en, this message translates to:
  /// **'Today\'s health data couldn\'t be loaded.'**
  String get screensSettingsHealthSettingsLoadDataFailed;

  /// Snackbar when Health Connect settings could not be opened
  ///
  /// In en, this message translates to:
  /// **'Health Connect settings couldn\'t be opened.'**
  String get screensSettingsHealthSettingsOpenSettingsFailed;

  /// Calendar message when the user profile failed to load
  ///
  /// In en, this message translates to:
  /// **'Your profile couldn\'t be loaded, so daily targets aren\'t shown.'**
  String get screensCalendarProfileLoadFailed;

  /// Title of the warning shown when a daily calorie target is below 1200 kcal
  ///
  /// In en, this message translates to:
  /// **'Very low calorie target'**
  String get componentsLowCalorieWarningTitle;

  /// Warning shown when a daily calorie target is below the low-calorie threshold
  ///
  /// In en, this message translates to:
  /// **'A daily calorie target of {calories} kcal is below {threshold} kcal. Something may be wrong: please check your profile values such as weight, height, age and activity level. Very low calorie intakes should only be followed under medical supervision.'**
  String componentsLowCalorieWarningMessage(String calories, String threshold);

  /// Error when the profile values give a calorie target of 0 kcal or less, so the profile is not saved
  ///
  /// In en, this message translates to:
  /// **'No calorie target can be calculated from these values. Please check your weight, height and age.'**
  String get screensSettingsProfileSettingsInvalidCalorieTarget;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
