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

  /// Short label for calories used in compact macro view
  ///
  /// In en, this message translates to:
  /// **'Cal'**
  String get componentsCalendarMacroSummaryCompactCalories;

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
  String get componentsChatBotProfileCustomizationDialogProfessionalNutritionist;

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

  /// Add to meals button text
  ///
  /// In en, this message translates to:
  /// **'Add to Meals'**
  String get componentsChatNutritionAnalysisCardAddToMeals;

  /// Cooking instructions label
  ///
  /// In en, this message translates to:
  /// **'Cooking Instructions'**
  String get componentsChatNutritionAnalysisCardCookingInstructions;

  /// Dish name label
  ///
  /// In en, this message translates to:
  /// **'Dish Name'**
  String get componentsChatNutritionAnalysisCardDishName;

  /// Meal type label
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get componentsChatNutritionAnalysisCardMealType;

  /// Nutrition analysis section title
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get componentsChatNutritionAnalysisCardNutritionAnalysis;

  /// Serving size label
  ///
  /// In en, this message translates to:
  /// **'Serving Size'**
  String get componentsChatNutritionAnalysisCardServingSize;

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
  String get componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder;

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
  String get componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName;

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

  /// Button text for reloading API key configuration
  ///
  /// In en, this message translates to:
  /// **'Reload API Key'**
  String get screensChatReloadApiKeyButton;

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

  /// Welcome message for PlatePal Tracker
  ///
  /// In en, this message translates to:
  /// **'Welcome to PlatePal Tracker'**
  String get screensHomeWelcomeToPlatePalTracker;

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

  /// Centimeters unit
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get screensSettingsImportProfileCompletionCm;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get screensSettingsImportProfileCompletionEmail;

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

  /// Inches unit
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get screensSettingsImportProfileCompletionInches;

  /// Invalid email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get screensSettingsImportProfileCompletionInvalidEmail;

  /// Kilograms unit
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get screensSettingsImportProfileCompletionKg;

  /// Pounds unit
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get screensSettingsImportProfileCompletionLb;

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

  /// Years unit
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get screensSettingsImportProfileCompletionYears;

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
