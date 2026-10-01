// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get screensCalendarHasMealsLogged => 'has meals logged';

  @override
  String get screensCalendarFailedToLoadDates =>
      'Could not load calendar dates';

  @override
  String get screensCalendarFailedToLoadSummary =>
      'Could not load nutrition summary';

  @override
  String get screensCalendarProfileNudge =>
      'Set up your profile to get daily targets';

  @override
  String get screensCalendarSetUpProfile => 'Set up profile';

  @override
  String get screensCalendarLogMeal => 'Log meal';

  @override
  String screensCalendarCaloriesPerServing(int calories) {
    return '$calories kcal per serving';
  }

  @override
  String get componentsCalendarCalendarDayDetailErrorLoadingMeals =>
      'Could not load meals for this day';

  @override
  String get componentsCalendarCalendarDayDetailNoMealsLoggedForDay =>
      'No meals logged for this day';

  @override
  String get componentsCalendarCalendarDayDetailUnknownDish => 'Unknown Dish';

  @override
  String get componentsCalendarMacroSummaryCalories => 'Calories';

  @override
  String get componentsCalendarMacroSummaryCarbs => 'Carbs';

  @override
  String get componentsCalendarMacroSummaryEstimatedCalories =>
      'Estimated Calories';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesMessage =>
      'This data is estimated based on your profile settings and activity level since health data wasn\'t available for this date.';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesToday =>
      'Estimated Calories (Today)';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesTodayMessage =>
      'This is your estimated calorie expenditure for today based on your activity level. Since the day isn\'t complete yet, this represents your base metabolic rate plus estimated activity. Your actual calories burned may be higher if you do more activities today.';

  @override
  String get componentsCalendarMacroSummaryFat => 'Fat';

  @override
  String get componentsCalendarMacroSummaryFiber => 'Fiber';

  @override
  String get componentsCalendarMacroSummaryGetAiTip => 'Get AI Tip';

  @override
  String componentsCalendarMacroSummaryPercentOfGoal(int percent) {
    return '$percent% of goal';
  }

  @override
  String componentsCalendarMacroSummaryOverBy(String amount, String unit) {
    return 'Over goal by $amount $unit';
  }

  @override
  String get componentsCalendarMacroSummaryHealthDataMessage =>
      'This data was gathered from health data on your phone, providing accurate calories burned information from your fitness activities for this complete day.';

  @override
  String get componentsCalendarMacroSummaryHealthDataTitle => 'Health Data';

  @override
  String get componentsCalendarMacroSummaryHealthDataTodayMessage =>
      'This data was gathered from health data on your phone. Since today isn\'t complete yet, this represents calories burned so far today. Your total may increase as you continue activities throughout the day.';

  @override
  String get componentsCalendarMacroSummaryHealthDataTodayPartial =>
      'Health Data (Today - Partial)';

  @override
  String get componentsCalendarMacroSummaryNutritionSummary =>
      'Nutrition Summary';

  @override
  String get componentsCalendarMacroSummaryProtein => 'Protein';

  @override
  String get componentsCalendarMacroSummaryCompactProtein => 'Protein';

  @override
  String get componentsCalendarMacroSummaryCompactCarbs => 'Carbs';

  @override
  String get componentsCalendarMacroSummaryCompactFat => 'Fat';

  @override
  String get componentsCommonOk => 'OK';

  @override
  String get componentsChatAgentStepsModalAgentProcessingSteps =>
      'Agent Processing Steps';

  @override
  String get componentsChatAgentStepsModalCopiedToClipboard =>
      'Copied to clipboard';

  @override
  String get componentsChatAgentStepsModalCopyAll => 'Copy All';

  @override
  String get componentsChatAgentStepsModalViewFullData => 'View Full Data';

  @override
  String get componentsChatAgentStepsModalViewFullPrompt => 'View Full Prompt';

  @override
  String get componentsChatAgentStepsModalThinkingProcessTitle =>
      '🧠 Thinking Process';

  @override
  String get componentsChatAgentStepsModalThinkingProcessSubtitle =>
      'Real-time agent thinking steps';

  @override
  String get componentsChatAgentStepsModalProcessingStepsTitle =>
      '⚙️ Processing Steps';

  @override
  String get componentsChatAgentStepsModalProcessingStepsSubtitle =>
      'Detailed step-by-step execution';

  @override
  String get componentsChatAgentStepsModalProcessingSummary =>
      'Processing Summary';

  @override
  String get componentsChatAgentStepsModalCopySummaryTooltip =>
      'Copy summary data';

  @override
  String get componentsChatAgentStepsModalProcessingTime => 'Processing Time';

  @override
  String get componentsChatAgentStepsModalBotType => 'Bot Type';

  @override
  String get componentsChatAgentStepsModalTotalSteps => 'Total Steps';

  @override
  String get componentsChatAgentStepsModalSkippedSteps => 'Skipped Steps';

  @override
  String get componentsChatAgentStepsModalFailedSteps => 'Failed Steps';

  @override
  String get componentsChatAgentStepsModalErrorRecovery => 'Error Recovery';

  @override
  String get componentsChatAgentStepsModalCompletedSteps => 'Completed Steps';

  @override
  String get componentsChatAgentStepsModalDeepSearch => 'Deep Search';

  @override
  String get componentsChatAgentStepsModalEnabled => 'Enabled';

  @override
  String get componentsChatAgentStepsModalDisabled => 'Disabled';

  @override
  String get componentsChatAgentStepsModalModifications => 'Modifications';

  @override
  String get componentsChatAgentStepsModalNoModifications => 'None needed ✨';

  @override
  String get componentsChatAgentStepsModalPerfectProcessing =>
      'Perfect processing! No corrections or modifications were needed.';

  @override
  String get componentsChatAgentStepsModalPipelineModificationsTitle =>
      '✨ Pipeline Modifications';

  @override
  String get componentsChatAgentStepsModalPipelineModificationsSubtitle =>
      'No modifications were needed - your request was processed smoothly!';

  @override
  String get componentsChatAgentStepsModalStepModifications =>
      '🔧 Step Modifications';

  @override
  String get componentsChatAgentStepsModalCopyModifications =>
      'Copy modifications';

  @override
  String componentsChatAgentStepsModalSummaryLabel(String summary) {
    return 'Summary: $summary';
  }

  @override
  String get componentsChatAgentStepsModalEnhancedSystemPrompt =>
      '🤖 Enhanced System Prompt';

  @override
  String get componentsChatAgentStepsModalCopyEnhancedPrompt =>
      'Copy enhanced system prompt';

  @override
  String get componentsChatDishSuggestionCardHighProtein => 'High protein dish';

  @override
  String get componentsChatDishSuggestionCardHighCarb => 'High carb dish';

  @override
  String get componentsChatDishSuggestionCardHighFat => 'High fat dish';

  @override
  String get componentsChatDishSuggestionCardBalanced => 'Balanced dish';

  @override
  String get componentsChatDishSuggestionCardUnbalanced => 'Unbalanced dish';

  @override
  String get componentsChatDishSuggestionCardProtein => 'Protein';

  @override
  String get componentsChatDishSuggestionCardCarbs => 'Carbs';

  @override
  String get componentsChatDishSuggestionCardFat => 'Fat';

  @override
  String get componentsChatDishSuggestionCardCalories => 'Calories';

  @override
  String get componentsChatDishSuggestionCardInspect => 'Details';

  @override
  String get componentsChatMessageBubbleYou => 'You';

  @override
  String get componentsChatMessageBubbleAssistant => 'PlatePal Assistant';

  @override
  String get componentsChatMessageBubbleBotTag => '(bot)';

  @override
  String get componentsChatMessageBubbleSending => 'Sending...';

  @override
  String get componentsChatMessageBubbleSuggestedDishes => 'Suggested Dishes';

  @override
  String get componentsChatMessageBubbleRecommendation => 'Recommendation';

  @override
  String get componentsChatMessageBubbleNoRecommendationsAvailable =>
      'No recommendations available.';

  @override
  String componentsChatAgentStepsModalLengthLabel(int count) {
    return 'Length: $count characters';
  }

  @override
  String get componentsChatAgentStepsModalTechnicalDetails =>
      'Technical Details';

  @override
  String get componentsChatAgentStepsModalDataChanges => 'Data Changes';

  @override
  String get componentsChatAgentStepsModalBefore => 'Before';

  @override
  String get componentsChatAgentStepsModalAfter => 'After';

  @override
  String get componentsChatAgentStepsModalStatusSkipped => 'Skipped';

  @override
  String get componentsChatAgentStepsModalStatusErrorRecovered =>
      'Error recovered';

  @override
  String get componentsChatAgentStepsModalStatusErrorHandlingFailed =>
      'Error handling failed';

  @override
  String get componentsChatAgentStepsModalStatusCompletedSuccessfully =>
      'Completed successfully';

  @override
  String get componentsChatAgentStepsModalFailed => 'Failed';

  @override
  String get componentsChatAgentStepsModalSeverityLow => 'Low';

  @override
  String get componentsChatAgentStepsModalSeverityMedium => 'Medium';

  @override
  String get componentsChatAgentStepsModalSeverityHigh => 'High';

  @override
  String get componentsChatAgentStepsModalSeverityCritical => 'Critical';

  @override
  String get componentsChatAgentStepsModalBadgeEmergencyOverrides =>
      'Emergency overrides';

  @override
  String get componentsChatAgentStepsModalBadgeAiValidations =>
      'AI validations';

  @override
  String get componentsChatAgentStepsModalBadgeAutomaticFixes =>
      'Automatic fixes';

  @override
  String componentsChatAgentStepsModalTotalModifications(int count) {
    return 'Total modifications: $count';
  }

  @override
  String get componentsChatAgentStepsModalSkipDetails => '⏭️ Skip Details';

  @override
  String get componentsChatAgentStepsModalMetadata => '📊 Metadata';

  @override
  String get componentsChatAgentStepsModalDataOutput => '📤 Data Output';

  @override
  String get componentsChatAgentStepsModalErrorDetails => '❌ Error Details';

  @override
  String get componentsChatAgentStepsModalRawStepData => '🔍 Raw Step Data';

  @override
  String componentsChatAgentStepsModalIdLabel(String id) {
    return 'ID: $id';
  }

  @override
  String componentsChatAgentStepsModalTimeLabel(String time) {
    return 'Time: $time';
  }

  @override
  String get componentsChatAgentStepsModalUnknownStep => 'Unknown Step';

  @override
  String get componentsChatAgentStepsModalNoReasonProvided =>
      'No reason provided';

  @override
  String get componentsChatAgentStepsModalNoSummaryAvailable =>
      'No summary available';

  @override
  String componentsChatAgentStepsModalListItems(int count) {
    return 'List with $count items';
  }

  @override
  String componentsChatAgentStepsModalMapKeys(int count) {
    return 'Map with $count keys';
  }

  @override
  String componentsChatAgentStepsModalMoreItems(int count) {
    return '... and $count more items';
  }

  @override
  String get componentsCommonCopyToClipboard => 'Copy to clipboard';

  @override
  String get componentsChatBotProfileCustomizationDialogAngryGreg =>
      'Angry Greg';

  @override
  String get componentsChatBotProfileCustomizationDialogBotName => 'Bot Name';

  @override
  String get componentsChatBotProfileCustomizationDialogCancel => 'Cancel';

  @override
  String get componentsChatBotProfileCustomizationDialogCasualGymBro =>
      'Casual Gym Bro';

  @override
  String get componentsChatBotProfileCustomizationDialogChangeAvatar =>
      'Change Avatar';

  @override
  String get componentsChatBotProfileCustomizationDialogChooseFromGallery =>
      'Choose from Gallery';

  @override
  String get componentsChatBotProfileCustomizationDialogEditBotProfile =>
      'Edit Bot Profile';

  @override
  String get componentsChatBotProfileCustomizationDialogFitnessCoach =>
      'Fitness Coach';

  @override
  String get componentsChatBotProfileCustomizationDialogNiceAndFriendly =>
      'Nice & Friendly';

  @override
  String get componentsChatBotProfileCustomizationDialogPersonality =>
      'Personality';

  @override
  String
  get componentsChatBotProfileCustomizationDialogProfessionalNutritionist =>
      'Professional Nutritionist';

  @override
  String get componentsChatBotProfileCustomizationDialogProfileSaved =>
      'Profile saved successfully';

  @override
  String get componentsChatBotProfileCustomizationDialogProfileSaveFailed =>
      'Failed to save profile';

  @override
  String get componentsChatBotProfileCustomizationDialogRemoveAvatar =>
      'Remove Avatar';

  @override
  String get componentsChatBotProfileCustomizationDialogRequiredField =>
      'This field is required';

  @override
  String get componentsChatBotProfileCustomizationDialogSave => 'Save';

  @override
  String get componentsChatBotProfileCustomizationDialogTakePhoto =>
      'Take Photo';

  @override
  String get componentsChatBotProfileCustomizationDialogVeryAngryBro =>
      'Very Angry Bro';

  @override
  String get componentsChatBotPersonalityDescriptionNutritionist =>
      'Professional & Evidence-based';

  @override
  String get componentsChatBotPersonalityDescriptionCasualGymbro =>
      'Casual & Motivational';

  @override
  String get componentsChatBotPersonalityDescriptionAngryGreg =>
      'Intense & Supplement-focused';

  @override
  String get componentsChatBotPersonalityDescriptionVeryAngryBro =>
      'Extremely Intense';

  @override
  String get componentsChatBotPersonalityDescriptionFitnessCoach =>
      'Encouraging & Supportive';

  @override
  String get componentsChatBotPersonalityDescriptionNice =>
      'Friendly & Helpful';

  @override
  String get componentsChatEditBotProfileTooltip => 'Edit Bot Profile';

  @override
  String componentsChatChatInputErrorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String componentsChatMessageBubbleModificationEmergency(int count) {
    return '$count emergency fixes applied';
  }

  @override
  String componentsChatMessageBubbleModificationAi(int count) {
    return '$count AI enhancements applied';
  }

  @override
  String componentsChatMessageBubbleModificationAutomatic(int count) {
    return '$count automatic improvements applied';
  }

  @override
  String get componentsChatChatInputImageAttached => 'Image attached';

  @override
  String get componentsChatChatInputIngredientsAdded => 'Ingredients Added';

  @override
  String componentsChatChatInputRemoveIngredient(String name) {
    return 'Remove $name';
  }

  @override
  String get componentsChatChatInputIngredientAdded =>
      'Ingredient added to chat';

  @override
  String get componentsChatChatInputAttachments => 'Add attachments';

  @override
  String get componentsChatChatInputScanBarcode => 'Scan Barcode';

  @override
  String get componentsChatChatInputSearchProduct => 'Search Product';

  @override
  String get componentsChatChatInputSendMessage => 'Send message';

  @override
  String get componentsChatChatInputTypeMessage => 'Type a message...';

  @override
  String get componentsChatChatWelcomeAnalyzeNutrition => 'Analyze nutrition';

  @override
  String get componentsChatChatWelcomeCalculateMacros => 'Calculate macros';

  @override
  String get componentsChatChatWelcomeChatWelcomeSubtitle =>
      'Your AI nutrition assistant is here to help';

  @override
  String get componentsChatChatWelcomeChatWelcomeTitle => 'Welcome to PlatePal';

  @override
  String get componentsChatChatWelcomeFindAlternatives => 'Find alternatives';

  @override
  String get componentsChatChatWelcomeGetStartedToday => 'Get started today';

  @override
  String get componentsChatChatWelcomeIngredientInfo => 'Ingredient info';

  @override
  String get componentsChatChatWelcomeMealPlan => 'Meal plan help';

  @override
  String get componentsChatChatWelcomeSuggestMeal => 'Suggest a meal';

  @override
  String get componentsChatChatWelcomeSuggestMealSubtitle =>
      'Get personalized meal recommendations';

  @override
  String get componentsChatChatWelcomeSuggestMealMessage =>
      'Suggest a healthy meal based on my fitness goals';

  @override
  String get componentsChatChatWelcomeAnalyzeNutritionSubtitle =>
      'Analyze the nutritional values of your meals';

  @override
  String get componentsChatChatWelcomeAnalyzeNutritionMessage =>
      'Help me analyze the nutritional values in my meal';

  @override
  String get componentsChatChatWelcomeFindAlternativesSubtitle =>
      'Discover healthy food alternatives';

  @override
  String get componentsChatChatWelcomeFindAlternativesMessage =>
      'Find healthy alternatives to my current meal';

  @override
  String get componentsChatChatWelcomeCalculateMacrosSubtitle =>
      'Calculate macros for your meals';

  @override
  String get componentsChatChatWelcomeCalculateMacrosMessage =>
      'Help me calculate the macros for my meals';

  @override
  String get componentsChatChatWelcomeMealPlanSubtitle =>
      'Create weekly meal plans';

  @override
  String get componentsChatChatWelcomeMealPlanMessage =>
      'Help me create a weekly meal plan';

  @override
  String get componentsChatChatWelcomeIngredientInfoSubtitle =>
      'Learn more about ingredients and their benefits';

  @override
  String get componentsChatChatWelcomeIngredientInfoMessage =>
      'Tell me about the nutritional benefits of ingredients';

  @override
  String get componentsChatChatWelcomeWhatCanIHelpWith =>
      'What can I help you with?';

  @override
  String get componentsChatDishSuggestionCardDetails => 'Details';

  @override
  String componentsChatDishSuggestionCardErrorOpeningDishScreen(Object error) {
    return 'Error opening dish screen: $error';
  }

  @override
  String get componentsChatDishSuggestionCardLogDish => 'Log Dish';

  @override
  String get componentsChatMessageBubbleClose => 'Close';

  @override
  String get componentsChatMessageBubbleIngredients => 'Ingredients';

  @override
  String get componentsChatMessageBubbleMessageCopied =>
      'Message copied to clipboard';

  @override
  String get componentsChatMessageBubbleRetryMessage => 'Retry';

  @override
  String get componentsChatMessageBubbleSelect => 'Select';

  @override
  String get componentsChatMessageBubbleTapToViewAgentSteps =>
      'Tap to view agent steps';

  @override
  String get componentsChatMessageBubbleYesterday => 'Yesterday';

  @override
  String get componentsChatNutritionAnalysisCardDishName => 'Dish Name';

  @override
  String get componentsChatNutritionAnalysisCardNutritionAnalysis =>
      'Nutrition Analysis';

  @override
  String get componentsChatQuickActionsQuickActions => 'Quick Actions';

  @override
  String get componentsChatUserProfileCustomizationDialogEditUserProfile =>
      'Edit User Profile';

  @override
  String get componentsChatUserProfileCustomizationDialogUsername => 'Username';

  @override
  String get componentsDishesDishCardDelete => 'Delete';

  @override
  String get componentsDishesDishCardEdit => 'Edit';

  @override
  String get componentsDishesDishFormIngredientFormModalAddIngredient =>
      'Add Ingredient';

  @override
  String get componentsDishesDishFormIngredientFormModalEditIngredient =>
      'Edit Ingredient';

  @override
  String get componentsDishesDishFormIngredientFormModalGrams => 'g';

  @override
  String get componentsDishesDishFormIngredientFormModalIngredientName =>
      'Ingredient Name';

  @override
  String
  get componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder =>
      'Enter ingredient name';

  @override
  String get componentsDishesDishFormIngredientFormModalKcal => 'kcal';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionInformation =>
      'Nutrition Information';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPer100g =>
      'Nutrition per 100g';

  @override
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName =>
      'Please enter an ingredient name';

  @override
  String get componentsDishesDishFormIngredientFormModalPleaseEnterQuantity =>
      'Please enter a quantity';

  @override
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber =>
      'Please enter a valid number';

  @override
  String get componentsDishesDishFormIngredientFormModalQuantity => 'Quantity';

  @override
  String get componentsDishesDishFormIngredientFormModalQuantityPlaceholder =>
      'Enter quantity';

  @override
  String get componentsDishesDishFormSmartNutritionCardNutritionalInformation =>
      'Nutritional Information';

  @override
  String get componentsModalsDishLogModalAddNotes => 'Add notes (optional)';

  @override
  String get componentsModalsDishLogModalBreakfast => 'Breakfast';

  @override
  String get componentsModalsDishLogModalCalculatedNutrition =>
      'Calculated Nutrition';

  @override
  String get componentsModalsDishLogModalDinner => 'Dinner';

  @override
  String get componentsModalsDishLogModalDishLoggedSuccessfully =>
      'Dish logged successfully!';

  @override
  String get componentsModalsDishLogModalErrorLoggingDish =>
      'There was an error logging the dish';

  @override
  String get componentsModalsDishLogModalLogDishTitle => 'Log Dish';

  @override
  String get componentsModalsDishLogModalLunch => 'Lunch';

  @override
  String get componentsModalsDishLogModalNotes => 'Notes';

  @override
  String get componentsModalsDishLogModalPortionSize => 'Portion Size';

  @override
  String get componentsModalsDishLogModalSelectDate => 'Select Date';

  @override
  String get componentsModalsDishLogModalSelectMealType => 'Select Meal Type';

  @override
  String get componentsModalsDishLogModalSelectTime => 'Select Time';

  @override
  String get componentsModalsDishLogModalSnack => 'Snack';

  @override
  String get componentsScannerBarcodeScannerBarcodeScanner => 'Barcode Scanner';

  @override
  String componentsScannerBarcodeScannerErrorScanningBarcode(String error) {
    return 'Error scanning barcode: $error';
  }

  @override
  String get componentsScannerBarcodeScannerOpenSettings => 'Open Settings';

  @override
  String get componentsScannerBarcodeScannerProductNotFound =>
      'Product not found';

  @override
  String get componentsScannerBarcodeScannerScanBarcodeToAddProduct =>
      'Scan a barcode to quickly add products';

  @override
  String get componentsScannerBarcodeScannerScanningBarcode =>
      'Scanning barcode...';

  @override
  String get componentsScannerBarcodeScannerClose => 'Close';

  @override
  String get componentsScannerBarcodeScannerPermissionHint =>
      'Allow camera access for this app in system settings.';

  @override
  String componentsScannerBarcodeScannerScannerError(String errorCode) {
    return 'Scanner error: $errorCode';
  }

  @override
  String get componentsScannerBarcodeScannerServiceUnavailable =>
      'Food data is unavailable. Try again.';

  @override
  String get componentsScannerBarcodeScannerTorchOn => 'Turn flashlight on';

  @override
  String get componentsScannerBarcodeScannerTorchOff => 'Turn flashlight off';

  @override
  String componentsScannerProductSearchErrorSearchingProduct(String error) {
    return 'Error searching for product: $error';
  }

  @override
  String get componentsScannerProductSearchLoadMore => 'Loard more';

  @override
  String get componentsScannerProductSearchLocalDishes => 'Local Dishes';

  @override
  String get componentsScannerProductSearchLocalIngredients =>
      'Local ingredients';

  @override
  String get componentsScannerProductSearchNoProductsFound =>
      'No products found';

  @override
  String get componentsScannerProductSearchProductSearch => 'Product Search';

  @override
  String get componentsScannerProductSearchSearchProducts =>
      'Search products...';

  @override
  String get componentsScannerProductSearchFiltersAndSort => 'Filters & Sort';

  @override
  String get componentsScannerProductSearchNutriScore => 'NUTRI-SCORE';

  @override
  String get componentsScannerProductSearchAny => 'Any';

  @override
  String get componentsScannerProductSearchSortBy => 'Sort by';

  @override
  String get componentsScannerProductSearchPopular => 'Popular';

  @override
  String componentsScannerProductSearchResultsFor(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get componentsScannerProductSearchMyDatabase => 'My database';

  @override
  String get componentsScannerProductSearchGlobalFeed => 'Global feed';

  @override
  String get componentsScannerProductSearchEndOfResults => 'End of results';

  @override
  String get componentsScannerProductSearchSelectCategoryOrSearch =>
      'Select a category or type to search';

  @override
  String componentsScannerProductSearchNoResultsFor(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get componentsScannerProductSearchUnknown => 'Unknown';

  @override
  String get componentsScannerProductSearchKcal => 'kcal';

  @override
  String get componentsScannerProductSearchProteinAbbreviation => 'P:';

  @override
  String get componentsScannerProductSearchCarbsAbbreviation => 'C:';

  @override
  String get componentsScannerProductSearchFatAbbreviation => 'F:';

  @override
  String get componentsScannerProductSearchGramsAbbreviation => 'g';

  @override
  String get componentsScannerProductSearchIngredient => 'Ingredient';

  @override
  String componentsScannerProductSearchDishIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients — dish',
      one: '1 ingredient — dish',
    );
    return '$_temp0';
  }

  @override
  String get componentsScannerProductSearchBrowseUnavailable =>
      'Products are unavailable. Try again.';

  @override
  String get componentsScannerProductSearchUnknownProduct => 'Unknown product';

  @override
  String get componentsScannerProductSearchCategoryAll => 'All';

  @override
  String get componentsScannerProductSearchCategoryFruits => 'Fruits';

  @override
  String get componentsScannerProductSearchCategoryVegetables => 'Vegetables';

  @override
  String get componentsScannerProductSearchCategoryDairy => 'Dairy';

  @override
  String get componentsScannerProductSearchCategoryMeat => 'Meat';

  @override
  String get componentsScannerProductSearchCategorySeafood => 'Seafood';

  @override
  String get componentsScannerProductSearchCategoryBeverages => 'Beverages';

  @override
  String get componentsScannerProductSearchCategoryCereals => 'Cereals';

  @override
  String get componentsScannerProductSearchCategoryBreads => 'Breads';

  @override
  String get componentsScannerProductSearchCategorySnacks => 'Snacks';

  @override
  String get componentsScannerProductSearchCategorySweets => 'Sweets';

  @override
  String get componentsScannerProductSearchCategoryLegumes => 'Legumes';

  @override
  String get componentsScannerProductSearchCategoryNuts => 'Nuts';

  @override
  String get componentsScannerProductSearchCategoryCondiments => 'Condiments';

  @override
  String get componentsScannerProductSearchCategoryOilsAndFats => 'Oils & Fats';

  @override
  String get componentsScannerProductSearchCategoryFrozen => 'Frozen';

  @override
  String get componentsScannerProductSearchCategoryReadyMeals => 'Ready Meals';

  @override
  String get componentsScannerProductSearchCategoryBabyFoods => 'Baby Foods';

  @override
  String get componentsScannerProductSearchSortPopularity => 'Most Popular';

  @override
  String get componentsScannerProductSearchSortName => 'Name A–Z';

  @override
  String get componentsScannerProductSearchSortNewest => 'Newest';

  @override
  String get componentsScannerProductSearchSortCompleteness => 'Most Complete';

  @override
  String get componentsSharedErrorDisplayRetry => 'Retry';

  @override
  String get componentsUiCustomTabBarCalendar => 'Calendar';

  @override
  String get componentsUiCustomTabBarChat => 'Chat';

  @override
  String get componentsUiCustomTabBarMeals => 'Meals';

  @override
  String get componentsUiCustomTabBarMenu => 'Menu';

  @override
  String get providersChatProviderAiThinking => 'AI is thinking...';

  @override
  String get providersChatProviderIngredientsPrompt =>
      'What can I make with these ingredients?';

  @override
  String get providersChatProviderTestChatResponse =>
      'Thanks for trying PlatePal! This is a test response to show you how our AI assistant works. To get real nutrition advice and meal suggestions, please configure your OpenAI API key in settings.';

  @override
  String get providersChatProviderTestChatWelcome =>
      'This is test mode! I can help you explore PlatePal\'s features. Try asking me about nutrition, meal planning, or food recommendations.';

  @override
  String get providersChatProviderWelcomeToChat =>
      'Welcome to your AI nutrition assistant! Ask me anything about meals, nutrition, or your fitness goals.';

  @override
  String get screensCalendarAiNutritionTip => 'AI Nutrition Tip';

  @override
  String get screensCalendarConfigureApiKeyForAiTips =>
      'Please configure your OpenAI API key in settings to use AI tips';

  @override
  String get screensCalendarDeleteLog => 'Delete Log';

  @override
  String get screensCalendarDeleteLogConfirmation =>
      'Are you sure you want to delete this logged meal?';

  @override
  String get screensCalendarFailedToDeleteMealLog =>
      'Failed to delete meal log';

  @override
  String get screensCalendarFailedToGetAiTip =>
      'Failed to get AI tip. Please try again.';

  @override
  String get screensCalendarMealLogDeletedSuccessfully =>
      'Meal log deleted successfully';

  @override
  String get screensCalendarOk => 'OK';

  @override
  String get screensChatChatAssistant => 'AI Chat Assistant';

  @override
  String get screensChatSystemAnalyzing => 'SYSTEM ANALYZING ::';

  @override
  String get screensChatChatCleared => 'Chat history cleared';

  @override
  String get screensChatClearChat => 'Clear Chat';

  @override
  String get screensChatClearChatConfirmation =>
      'Are you sure you want to clear the chat history? This action cannot be undone.';

  @override
  String get screensChatConfigureApiKeyButton => 'Configure API Key';

  @override
  String get screensChatConfigureApiKeyToUseChat =>
      'Please configure your OpenAI API key in settings to use the AI chat assistant.';

  @override
  String get screensChatLoading => 'Loading...';

  @override
  String get screensChatNoApiKeyConfigured => 'No API key configured';

  @override
  String get screensDishCreateBasicInfo => 'Basic Information';

  @override
  String get screensDishCreateCamera => 'Camera';

  @override
  String get screensDishCreateCategory => 'Category';

  @override
  String get screensDishCreateConfirmDeleteIngredient =>
      'Are you sure you want to delete this ingredient?';

  @override
  String get screensDishCreateCreateDish => 'Create Dish';

  @override
  String get screensDishCreateDeleteIngredient => 'Delete Ingredient';

  @override
  String get screensDishCreateDescription => 'Description';

  @override
  String get screensDishCreateDescriptionPlaceholder =>
      'Enter description (optional)';

  @override
  String get screensDishCreateDishCreatedSuccessfully =>
      'Dish created successfully';

  @override
  String get screensDishCreateDishNamePlaceholder => 'Enter dish name';

  @override
  String get screensDishCreateDishUpdatedSuccessfully =>
      'Dish updated successfully';

  @override
  String get screensDishCreateEditDish => 'Edit Dish';

  @override
  String get screensDishCreateErrorSavingDish => 'Error saving dish';

  @override
  String get screensDishCreateFavorite => 'Favorite';

  @override
  String get screensDishCreateGallery => 'Gallery';

  @override
  String get screensDishCreateIngredientDeleted => 'Ingredient deleted';

  @override
  String get screensDishCreateMarkAsFavorite => 'Mark as favorite dish';

  @override
  String get screensDishCreateNoIngredientsAdded => 'No ingredients added yet';

  @override
  String get screensDishCreateNutritionRecalculated =>
      'Nutrition recalculated from ingredients';

  @override
  String get screensDishCreateOptions => 'Options';

  @override
  String get screensDishCreatePleaseEnterDishName => 'Please enter a dish name';

  @override
  String get screensDishCreateProductAddedSuccessfully =>
      'Product added successfully';

  @override
  String get screensDishCreateRemoveImage => 'Remove image';

  @override
  String get screensDishCreateSaveDish => 'Save Dish';

  @override
  String get screensHomeAppTitle => 'PlatePal Tracker';

  @override
  String get providersStorageError => 'Unable to load your data.';

  @override
  String get providersStorageRetry => 'Retry';

  @override
  String get screensMealsAddedToFavorites => 'Added to favorites';

  @override
  String get screensMealsAddMeal => 'Add Meal';

  @override
  String get screensMealsAddToFavorites => 'Add to Favorites';

  @override
  String get screensMealsAllCategories => 'All Categories';

  @override
  String get screensMealsCreateFirstDish =>
      'Create your first dish to get started';

  @override
  String get screensMealsDeleteDish => 'Delete Dish';

  @override
  String screensMealsDeleteDishConfirmation(String dishName) {
    return 'Are you sure you want to delete \"$dishName\"?';
  }

  @override
  String get screensMealsDishDeletedSuccessfully => 'Dish deleted successfully';

  @override
  String get screensMealsErrorLoadingDishes => 'Error loading dishes';

  @override
  String get screensMealsLoadFailedHint =>
      'Could not load your dishes. Please try again.';

  @override
  String get screensMealsErrorUpdatingDish => 'Error updating dish';

  @override
  String get screensMealsFailedToDeleteDish => 'Failed to delete dish';

  @override
  String get screensMealsNoDishesCreated => 'No dishes created yet';

  @override
  String get screensMealsNoDishesFound => 'No dishes found';

  @override
  String get screensMealsOtherCategory => 'Other';

  @override
  String get screensMealsRemovedFromFavorites => 'Removed from favorites';

  @override
  String get screensMealsRemoveFromFavorites => 'Remove from Favorites';

  @override
  String get screensMealsSearchDishes => 'Search dishes...';

  @override
  String get screensMealsTryAdjustingSearch =>
      'Try adjusting your search terms';

  @override
  String get screensMenuAbout => 'About';

  @override
  String get screensMenuAiFeatures => 'AI & Features';

  @override
  String get screensMenuApiKeySettings => 'API Key Settings';

  @override
  String get screensMenuAppearance => 'Appearance';

  @override
  String get screensMenuChatAgentOptions => 'Chat Agent Options';

  @override
  String get screensMenuConfigureApiKey => 'Configure your OpenAI API key';

  @override
  String get screensMenuContributors => 'Contributors';

  @override
  String get screensMenuCurrentStats => 'Current Stats';

  @override
  String get screensMenuDark => 'Dark';

  @override
  String get screensMenuDataManagement => 'Data Management';

  @override
  String get screensMenuEditPersonalInfo => 'Edit your personal information';

  @override
  String get screensMenuEnableAgentModeDeepSearch =>
      'Enable agent mode, deep search, and more';

  @override
  String get screensMenuExportData => 'Export Data';

  @override
  String get screensMenuExportMealData => 'Export your meal data';

  @override
  String get screensMenuImportData => 'Import Data';

  @override
  String get screensMenuImportMealDataBackup => 'Import meal data from backup';

  @override
  String get screensMenuInformation => 'Information';

  @override
  String get screensMenuLanguage => 'Language';

  @override
  String get screensMenuSystemDefault => 'System default';

  @override
  String get screensMenuLearnMorePlatePal => 'Learn more about PlatePal';

  @override
  String get screensMenuLight => 'Light';

  @override
  String get screensMenuMadeBy => 'Made by MrLappes';

  @override
  String get screensMenuNutritionGoals => 'Nutrition Goals';

  @override
  String get screensMenuOceanic => 'Oceanic';

  @override
  String get screensMenuForest => 'Forest';

  @override
  String get screensMenuPlatePal => 'PlatePal';

  @override
  String get screensMenuProfile => 'Profile';

  @override
  String get screensMenuSetNutritionTargets =>
      'Set your daily nutrition targets';

  @override
  String get screensMenuSystem => 'System';

  @override
  String get screensMenuTheme => 'Theme';

  @override
  String get screensMenuUserProfile => 'User Profile';

  @override
  String get screensMenuViewContributors => 'View project contributors';

  @override
  String get screensMenuViewStatistics => 'View Statistics';

  @override
  String get screensPrivacyTitle => 'Privacy policy';

  @override
  String get screensPrivacyEffectiveDate => 'Effective date: 2026-09-30';

  @override
  String get screensPrivacyOverviewTitle => 'At a glance';

  @override
  String get screensPrivacyOverviewBody =>
      'PlatePal Tracker is an offline-first nutrition tracker. We do not run servers for your app data or require an account, and the app has no analytics, advertising, or tracking SDKs. The optional network features below contact their providers when used.';

  @override
  String get screensPrivacyStorageTitle => 'Data on your device';

  @override
  String get screensPrivacyStorageBody =>
      'Dishes, meal logs, profile information (including body measurements), goals, chat history, and settings are stored on your device in SQLite or SharedPreferences. Saved food photos may also be kept in app storage. The API key you enter is stored using the platform\'s secure storage; legacy keys in SharedPreferences are migrated when possible.';

  @override
  String get screensPrivacyAiTitle => 'AI chat';

  @override
  String get screensPrivacyAiBody =>
      'AI chat is optional and requires your own API key. When used, your chat messages, attached images, and, when relevant, conversation history, your profile, meal logs or nutrition summaries, and saved dishes are sent to OpenAI or the OpenAI-compatible endpoint you configured. The key is sent to that provider for authentication. That provider handles this information under its own privacy policy; choose an endpoint you trust. We do not receive these requests.';

  @override
  String get screensPrivacyFoodFactsTitle => 'Open Food Facts';

  @override
  String get screensPrivacyFoodFactsBody =>
      'When you search for food or scan a barcode, the app sends your search text or barcode number and selected filters to world.openfoodfacts.org. Product information and images can be downloaded from Open Food Facts.';

  @override
  String get screensPrivacyHealthTitle => 'Health Connect and Apple Health';

  @override
  String get screensPrivacyHealthBody =>
      'With your permission, the app reads calories burned (total and active on Android, active and basal on iOS) from Health Connect or Apple Health and writes nutrition for meals you log to that service. Readings are cached on this device and used for in-app energy and goal calculations; the app does not include Health readings in AI requests or send them to a developer server. Health Connect and Apple Health control their own stored records.';

  @override
  String get screensPrivacyExternalTitle => 'External links and images';

  @override
  String get screensPrivacyExternalBody =>
      'The Contributors screen loads avatar images from GitHub\'s avatars.githubusercontent.com. Opening GitHub, the online policy, other external websites, or remote product images contacts those services, which may see your IP address and process requests under their own policies.';

  @override
  String get screensPrivacyExportTitle => 'Export and import';

  @override
  String get screensPrivacyExportBody =>
      'Export files (JSON or CSV) are created locally when you choose to export; you can share them using your device. Import reads a file you choose and creates a local pre-import backup first, unless you explicitly continue when backup creation fails. Nothing is uploaded to us.';

  @override
  String get screensPrivacyBackupTitle => 'Android backup';

  @override
  String get screensPrivacyBackupBody =>
      'Android\'s system backup may copy the app\'s database and preferences, including cached Health calorie readings and chat history, to your Google account or transfer them to another device. The backup rules exclude secure-storage preference files, but a legacy API key may be present in other preferences until migration. Check your Android backup settings to control this.';

  @override
  String get screensPrivacyDeletionTitle => 'Delete your data';

  @override
  String get screensPrivacyDeletionBody =>
      'In Profile, Reset App deletes the SQLite database, SharedPreferences, and saved API key on this device. Uninstalling removes app-private data. Reset does not remove saved images, exported or pre-import backup files, copies shared elsewhere, Health Connect or Apple Health records already written, or system backups; remove those separately where applicable.';

  @override
  String get screensPrivacyChildrenTitle => 'Children';

  @override
  String get screensPrivacyChildrenBody =>
      'PlatePal Tracker is not intended for children. The app has no age verification; a parent or guardian should supervise use, especially before enabling external services or sharing sensitive information.';

  @override
  String get screensPrivacyChangesTitle => 'Changes to this policy';

  @override
  String get screensPrivacyChangesBody =>
      'We may update this policy when the app changes. The effective date above shows when this version took effect; review the current policy in the app or GitHub repository.';

  @override
  String get screensPrivacyContactTitle => 'Contact';

  @override
  String get screensPrivacyContactBody =>
      'For privacy questions, open a GitHub issue at github.com/MrLappes/platepal-tracker-flutter/issues. We cannot access data kept only on your device; use the app and platform controls above to delete it.';

  @override
  String get screensPrivacyMenuSubtitle =>
      'What leaves the device and how to control your data';

  @override
  String get screensPrivacyViewOnline => 'View online';

  @override
  String get screensPrivacyLinkError => 'Could not open the privacy policy.';

  @override
  String get screensSettingsAboutAboutAppTitle => 'About the App';

  @override
  String get screensSettingsAboutAboutDescription =>
      'PlatePal Tracker was created to provide a privacy-focused, open-source alternative to expensive nutrition tracking apps. We believe in putting control in your hands with no subscriptions, no ads, and no data collection.';

  @override
  String get screensSettingsAboutAppMotto =>
      'Made by gym guys for gym guys that hate paid apps';

  @override
  String get screensSettingsAboutCodersMessage =>
      'Coders shouldn\'t have to pay';

  @override
  String get screensSettingsAboutDataStaysOnDevice =>
      'Your data stays on your device';

  @override
  String get screensSettingsAboutFreeOpenSource => '100% free and open source';

  @override
  String get screensSettingsAboutGithubRepository =>
      'github.com/MrLappes/platepal-tracker';

  @override
  String get screensSettingsAboutUseOwnAiKey =>
      'Use your own AI key for full control';

  @override
  String get screensSettingsAboutWebsite => 'plate-pal.de';

  @override
  String get screensSettingsAboutWhyPlatePal => 'Why PlatePal?';

  @override
  String get screensSettingsApiKeySettingsAboutOpenAiApiKey =>
      'About OpenAI API Key';

  @override
  String get screensSettingsApiKeySettingsAiFeaturesEnabled =>
      'AI features are enabled';

  @override
  String get screensSettingsApiKeySettingsApiKeyBulletPoints =>
      '• Get your API key from platform.openai.com\n• Your key is stored locally on your device\n• Usage charges apply directly to your OpenAI account';

  @override
  String get screensSettingsApiKeySettingsApiKeyConfigured =>
      'API Key Configured';

  @override
  String get screensSettingsApiKeySettingsApiKeyDescription =>
      'To use AI features like meal analysis and suggestions, you need to provide your own OpenAI API key. This ensures your data stays private and you have full control.';

  @override
  String get screensSettingsApiKeySettingsApiKeyHelperText =>
      'Enter your OpenAI API key or leave empty to disable AI features';

  @override
  String get screensSettingsApiKeySettingsApiKeyMustStartWith =>
      'API key must start with \"sk-\"';

  @override
  String get screensSettingsApiKeySettingsApiKeyPlaceholder => 'sk-...';

  @override
  String get screensSettingsApiKeySettingsApiKeyRemovedSuccessfully =>
      'API key removed successfully';

  @override
  String get screensSettingsApiKeySettingsApiKeySavedSuccessfully =>
      'API key saved successfully';

  @override
  String get screensSettingsApiKeySettingsApiKeyTestWarning =>
      'Your API key will be tested with a small request to verify it works. The key is only stored on your device and never sent to our servers';

  @override
  String get screensSettingsApiKeySettingsApiKeyTooShort =>
      'API key appears to be too short';

  @override
  String get screensSettingsApiKeySettingsClipboardEmpty =>
      'Clipboard is empty';

  @override
  String get screensSettingsApiKeySettingsCouldNotLoadModels =>
      'Could not load available models. Using default model list';

  @override
  String get screensSettingsApiKeySettingsFailedToAccessClipboard =>
      'Failed to access clipboard';

  @override
  String get screensSettingsApiKeySettingsFailedToLoadApiKey =>
      'Failed to load API key';

  @override
  String get screensSettingsApiKeySettingsFailedToRemoveApiKey =>
      'Failed to remove API key';

  @override
  String get screensSettingsApiKeySettingsInvalidBaseUrl =>
      'Base URL must start with https:// (http:// is only allowed for localhost)';

  @override
  String get screensSettingsApiKeySettingsGetApiKeyFromOpenAi =>
      'Get API Key from OpenAI';

  @override
  String get screensSettingsApiKeySettingsGpt35ModelsInfo =>
      'GPT-3.5 models are more cost-effective for basic analysis';

  @override
  String get screensSettingsApiKeySettingsGpt4ModelsInfo =>
      'GPT-4 models provide the best analysis but cost more';

  @override
  String get screensSettingsApiKeySettingsLinkError =>
      'An error occurred opening the link';

  @override
  String get screensSettingsApiKeySettingsOpenAiApiKey => 'OpenAI API Key';

  @override
  String get screensSettingsApiKeySettingsPastedFromClipboard =>
      'Pasted from clipboard';

  @override
  String get screensSettingsApiKeySettingsPasteFromClipboard =>
      'Paste from Clipboard';

  @override
  String get screensSettingsApiKeySettingsRemove => 'Remove';

  @override
  String get screensSettingsApiKeySettingsRemoveApiKey => 'Remove API Key';

  @override
  String get screensSettingsApiKeySettingsShowKey => 'Show API key';

  @override
  String get screensSettingsApiKeySettingsHideKey => 'Hide API key';

  @override
  String get screensSettingsApiKeySettingsDeleteKey => 'Delete API key';

  @override
  String get screensSettingsApiKeySettingsRemoveApiKeyConfirmation =>
      'Are you sure you want to remove your API key? This will disable AI features.';

  @override
  String get screensSettingsApiKeySettingsSelectModel => 'Select Model';

  @override
  String get screensSettingsApiKeySettingsTestAndSaveApiKey =>
      'Test & Save API Key';

  @override
  String get screensSettingsApiKeySettingsTestingApiKey => 'Testing API key...';

  @override
  String get screensSettingsApiKeySettingsUpdateApiKey => 'Update API Key';

  @override
  String get screensSettingsApiKeySettingsApiMode => 'API Mode';

  @override
  String get screensSettingsApiKeySettingsCompatibleApi =>
      'OpenAI Compatible API';

  @override
  String get screensSettingsApiKeySettingsUsingCustomEndpoint =>
      'Using custom OpenAI-compatible API endpoint';

  @override
  String get screensSettingsApiKeySettingsUsingOfficialApi =>
      'Using official OpenAI API';

  @override
  String get screensSettingsApiKeySettingsBaseUrl => 'Base URL';

  @override
  String get screensSettingsApiKeySettingsBaseUrlHelper =>
      'Enter the base URL for your OpenAI-compatible API';

  @override
  String get screensSettingsApiKeySettingsBaseUrlRequired =>
      'Base URL is required for compatibility mode';

  @override
  String get screensSettingsApiKeySettingsApiKeyGeneric => 'API Key';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyHelper =>
      'Enter your API key or leave empty to disable AI features';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyRequired =>
      'API key is required for compatibility mode';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyTooShort =>
      'API key seems too short';

  @override
  String get screensSettingsApiKeySettingsModelName => 'Model Name';

  @override
  String get screensSettingsApiKeySettingsModelNameHelper =>
      'Enter the exact model name supported by your API';

  @override
  String get screensSettingsApiKeySettingsModelNameRequired =>
      'Model name is required for compatibility mode';

  @override
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchSubtitle =>
      'Allow the agent to use deep search for more accurate answers';

  @override
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchTitle =>
      'Enable Deep Search';

  @override
  String get screensSettingsChatAgentSettingsChatAgentEnableSubtitle =>
      'Use the multi-step agent pipeline for chat';

  @override
  String get screensSettingsChatAgentSettingsChatAgentEnableTitle =>
      'Enable Agent Mode';

  @override
  String get screensSettingsChatAgentSettingsChatAgentInfoDescription =>
      'Agent mode enables PlatePal\'s advanced multi-step reasoning pipeline for chat. This allows the assistant to analyze your query, gather context, and provide more accurate, explainable answers. Deep Search lets the agent use more data for even better results.';

  @override
  String get screensSettingsChatAgentSettingsChatAgentInfoTitle =>
      'What is Agent Mode?';

  @override
  String get screensSettingsChatAgentSettingsChatAgentSettingsTitle =>
      'Chat Agent Settings';

  @override
  String get screensSettingsChatAgentSettingsChatSettingsSaved =>
      'Chat settings saved successfully';

  @override
  String get screensSettingsChatAgentSettingsSaveFailed =>
      'Failed to save chat settings';

  @override
  String get screensSettingsContributorsBuyMeCreatine => 'Buy Me Creatine';

  @override
  String get screensSettingsContributorsCheckGitHub =>
      'Check Out Our GitHub Repository';

  @override
  String screensSettingsContributorsOpenGitHubProfile(String name) {
    return 'Open $name on GitHub';
  }

  @override
  String get screensSettingsContributorsContributorPlural => 'Contributors';

  @override
  String get screensSettingsContributorsContributorSingular => 'Contributor';

  @override
  String get screensSettingsContributorsContributorsThankYou =>
      'Thanks to everyone who has contributed to making PlatePal Tracker possible!';

  @override
  String get screensSettingsContributorsOpenSourceMessage =>
      'PlatePal Tracker is open source - join us on GitHub!';

  @override
  String get screensSettingsContributorsSupportDevelopment =>
      'Support Development';

  @override
  String get screensSettingsContributorsSupportMessage =>
      'You want to buy me my creatine? Your support is greatly appreciated but not at all mandatory.';

  @override
  String get screensSettingsContributorsWantToContribute =>
      'Want to Contribute?';

  @override
  String get screensSettingsExportDataAllData => 'All Data';

  @override
  String get screensSettingsExportDataDishes => 'Dishes';

  @override
  String get screensSettingsExportDataExportAsCsv => 'Export as CSV';

  @override
  String get screensSettingsExportDataExportAsJson => 'Export as JSON';

  @override
  String screensSettingsExportDataExportedItemsCount(int count) {
    return 'Exported $count items';
  }

  @override
  String get screensSettingsExportDataExportProgress => 'Exporting data...';

  @override
  String get screensSettingsExportDataMealLogs => 'Meal Logs';

  @override
  String get screensSettingsExportDataNutritionGoalsData => 'Nutrition Goals';

  @override
  String get screensSettingsExportDataSelectDataToExport =>
      'Select data to export';

  @override
  String get screensSettingsExportDataSupplements => 'Supplements';

  @override
  String get screensSettingsExportDataUserProfiles => 'User Profiles';

  @override
  String get screensSettingsImportDataHowToHandleDuplicates =>
      'How to handle duplicates?';

  @override
  String screensSettingsImportDataImportedItemsCount(int count) {
    return 'Imported $count items';
  }

  @override
  String get screensSettingsImportDataImportFailed => 'Import failed';

  @override
  String get screensSettingsImportDataImportFromFile => 'Import from File';

  @override
  String get screensSettingsImportDataImportProgress => 'Importing data...';

  @override
  String get screensSettingsImportDataMergeDuplicates => 'Merge Duplicates';

  @override
  String get screensSettingsImportDataOverwriteDuplicates =>
      'Overwrite Duplicates';

  @override
  String get screensSettingsImportDataSelectDataToImport =>
      'Select data to import';

  @override
  String get screensSettingsImportDataSelectFile => 'Select File';

  @override
  String get screensSettingsImportDataSkipDuplicates => 'Skip Duplicates';

  @override
  String get screensSettingsExportDataPreparing => 'Preparing your data...';

  @override
  String get screensSettingsExportDataPreview => 'Export preview';

  @override
  String screensSettingsExportDataFormatLabel(String format) {
    return 'Format: $format';
  }

  @override
  String screensSettingsExportDataTypesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count types',
      one: '1 type',
    );
    return 'Selected data types: $_temp0';
  }

  @override
  String get screensSettingsExportDataReady => 'Ready to export';

  @override
  String get screensSettingsExportDataDishesDescription =>
      'Your saved recipes and dishes';

  @override
  String get screensSettingsExportDataMealLogsDescription =>
      'Your meal history and nutrition logs';

  @override
  String get screensSettingsExportDataUserProfilesDescription =>
      'User profile and preferences';

  @override
  String get screensSettingsExportDataIngredientsDescription =>
      'Ingredient database';

  @override
  String get screensSettingsExportDataSupplementsDescription =>
      'Supplement tracking data';

  @override
  String get screensSettingsExportDataFitnessGoalsDescription =>
      'Fitness and nutrition goals';

  @override
  String get screensSettingsExportDataAllDataDescription =>
      'Export all your data';

  @override
  String get screensSettingsExportDataFormatTitle => 'Export format';

  @override
  String get screensSettingsExportDataJsonDescription =>
      'Structured format, best for backups';

  @override
  String get screensSettingsExportDataCsvDescription =>
      'Spreadsheet format, good for analysis';

  @override
  String get screensSettingsExportDataError => 'Export error';

  @override
  String get screensSettingsExportDataResults => 'Export results';

  @override
  String screensSettingsExportDataFileLabel(String fileName) {
    return 'File: $fileName';
  }

  @override
  String screensSettingsExportDataLocationLabel(String path) {
    return 'Location: $path';
  }

  @override
  String get screensSettingsExportDataItemsExported => 'Items exported:';

  @override
  String get screensSettingsExportDataShare => 'Share';

  @override
  String get screensSettingsExportDataShowFileLocation => 'Show file location';

  @override
  String get screensSettingsExportDataLocationTitle => 'Export location';

  @override
  String get screensSettingsExportDataLocationDescription =>
      'Your exported file is located at:';

  @override
  String get screensSettingsExportDataNoFileToShare =>
      'No file to share. Export your data first.';

  @override
  String get screensSettingsExportDataFileNotFound =>
      'Export file not found. Export your data again.';

  @override
  String screensSettingsExportDataShareFailed(String error) {
    return 'Could not share file: $error';
  }

  @override
  String screensSettingsExportDataShareText(String fileName) {
    return 'PlatePal data export - $fileName';
  }

  @override
  String get screensSettingsExportDataShareSubject => 'PlatePal data export';

  @override
  String screensSettingsExportDataFailedDetail(String error) {
    return 'Export failed: $error';
  }

  @override
  String get screensSettingsExportDataSectionFailed =>
      'Could not export the selected data. No file was created. Please try again.';

  @override
  String get screensSettingsExportDataWriteFailed =>
      'Could not save the export file. Please try again.';

  @override
  String get screensSettingsExportDataShareProblem =>
      'Could not share the file. Please try again.';

  @override
  String get screensSettingsImportDataRestoring => 'Restoring from backup...';

  @override
  String screensSettingsImportDataProcessingItems(int current, int total) {
    return 'Processing $current of $total items';
  }

  @override
  String screensSettingsImportDataCurrentType(String type) {
    return 'Current: $type';
  }

  @override
  String get screensSettingsImportDataUndoing => 'Undoing the last import...';

  @override
  String get screensSettingsImportDataFileSelection => 'File selection';

  @override
  String get screensSettingsImportDataRemoveFile => 'Remove selected file';

  @override
  String get screensSettingsImportDataChangeFile => 'Change file';

  @override
  String get screensSettingsImportDataSupportedFormats =>
      'Supported formats: JSON, CSV';

  @override
  String get screensSettingsImportDataAllDataDescription =>
      'Import everything from the file';

  @override
  String get screensSettingsImportDataSkipDescription =>
      'Keep existing data; skip imported duplicates';

  @override
  String get screensSettingsImportDataOverwriteDescription =>
      'Replace existing data with imported data';

  @override
  String get screensSettingsImportDataAdvancedOptions => 'Advanced options';

  @override
  String get screensSettingsImportDataValidateBeforeImport =>
      'Validate data before import';

  @override
  String get screensSettingsImportDataValidateDescription =>
      'Check data integrity and show warnings';

  @override
  String get screensSettingsImportDataBackupBeforeImport =>
      'Create backup before import';

  @override
  String get screensSettingsImportDataBackupDescription =>
      'Automatically back up existing data';

  @override
  String get screensSettingsImportDataIssues => 'Import issues';

  @override
  String get screensSettingsImportDataDetailedErrors => 'Detailed errors:';

  @override
  String get screensSettingsImportDataTechnicalDetails =>
      'File and row details (may appear in English):';

  @override
  String get screensSettingsImportDataResults => 'Import results';

  @override
  String get screensSettingsImportDataPartialResults =>
      'Import completed with skipped items';

  @override
  String screensSettingsImportDataImportedSkipped(int imported, int skipped) {
    return 'Imported $imported, skipped $skipped';
  }

  @override
  String get screensSettingsImportDataShowReasons => 'Show reasons';

  @override
  String screensSettingsImportDataFailedSection(String section) {
    return 'Failed section: $section';
  }

  @override
  String get screensSettingsImportDataConfirmTitle => 'Confirm import';

  @override
  String get screensSettingsImportDataSelectedSections => 'Selected sections:';

  @override
  String screensSettingsImportDataDuplicatesLabel(String strategy) {
    return 'Duplicates: $strategy';
  }

  @override
  String get screensSettingsImportDataConfirmAction => 'Import';

  @override
  String get screensSettingsImportDataBackupFailedTitle => 'Backup failed';

  @override
  String get screensSettingsImportDataBackupFailedDescription =>
      'The automatic backup could not be created. Continue importing without a backup?';

  @override
  String get screensSettingsImportDataContinueWithoutBackup =>
      'Continue without backup';

  @override
  String screensSettingsImportDataFileSelectionFailed(String error) {
    return 'Error selecting file: $error';
  }

  @override
  String screensSettingsImportDataCompletedWithErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import completed with $count errors',
      one: 'Import completed with 1 error',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataFailedDetail(String error) {
    return 'Import failed: $error';
  }

  @override
  String get screensSettingsImportDataBackupAvailable => 'Backup available';

  @override
  String get screensSettingsImportDataBackupAvailableDescription =>
      'A backup from your last import is available.';

  @override
  String screensSettingsImportDataBackupCreated(String date) {
    return 'Created: $date';
  }

  @override
  String screensSettingsImportDataBackupSize(String size) {
    return 'Size: $size KB';
  }

  @override
  String get screensSettingsImportDataUndoLastImport => 'Undo last import';

  @override
  String screensSettingsImportDataMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get screensSettingsImportDataRestoreTitle => 'Restore from backup';

  @override
  String get screensSettingsImportDataRestoreWarning =>
      'This will restore your data to the state before the last import. All changes made since then will be lost. Are you sure?';

  @override
  String get screensSettingsImportDataRestoreAction => 'Restore';

  @override
  String get screensSettingsImportDataRestoreSuccess =>
      'Successfully restored from backup!';

  @override
  String screensSettingsImportDataRestoreFailedDetail(String error) {
    return 'Restore failed: $error';
  }

  @override
  String get screensSettingsImportDataFileMissing =>
      'Import file not found. Select it again.';

  @override
  String screensSettingsImportDataFileTooLarge(int maxSize) {
    return 'This file is too large. Select a file of at most $maxSize MB.';
  }

  @override
  String get screensSettingsImportDataInvalidJson =>
      'This file is not valid JSON. Check it and try again.';

  @override
  String get screensSettingsImportDataUnsupportedFormat =>
      'Unsupported file format. Select a JSON or CSV file.';

  @override
  String get screensSettingsImportDataInvalidData =>
      'The file contains invalid data. Check the details and try again.';

  @override
  String get screensSettingsImportDataFileSelectionProblem =>
      'Could not select a file. Please try again.';

  @override
  String get screensSettingsImportDataBackupMissing =>
      'No backup was found to restore.';

  @override
  String get screensSettingsImportDataBackupUnreadable =>
      'The backup could not be read. Nothing was changed.';

  @override
  String get screensSettingsImportDataSnapshotFailed =>
      'Could not protect your current data. Nothing was changed.';

  @override
  String get screensSettingsImportDataRestoreProblem =>
      'Could not restore your backup. Check your data before trying again.';

  @override
  String get screensSettingsImportDataRestoreRolledBack =>
      'Restore failed, but your previous data was left unchanged.';

  @override
  String screensSettingsImportDataRestoreCopySaved(String path) {
    return 'Restore failed and your previous data may be incomplete. A recovery copy is saved at $path.';
  }

  @override
  String get screensSettingsImportProfileCompletionActivityLevel =>
      'Activity Level';

  @override
  String get screensSettingsImportProfileCompletionAge => 'Age';

  @override
  String get screensSettingsImportProfileCompletionAgeRange =>
      'Age must be between 13 and 120';

  @override
  String get screensSettingsImportProfileCompletionBuildMuscle =>
      'Build Muscle';

  @override
  String get screensSettingsImportProfileCompletionExtraActive =>
      'Extra Active';

  @override
  String get screensSettingsImportProfileCompletionFemale => 'Female';

  @override
  String get screensSettingsImportProfileCompletionFitnessGoal =>
      'Fitness Goal';

  @override
  String get screensSettingsImportProfileCompletionGainWeight => 'Gain Weight';

  @override
  String get screensSettingsImportProfileCompletionGender => 'Gender';

  @override
  String get screensSettingsImportProfileCompletionHeight => 'Height';

  @override
  String get screensSettingsImportProfileCompletionHeightRange =>
      'Height must be between 100-250 cm';

  @override
  String get screensSettingsImportProfileCompletionImperial =>
      'Imperial (lb, ft)';

  @override
  String get screensSettingsImportProfileCompletionLightlyActive =>
      'Lightly Active';

  @override
  String get screensSettingsImportProfileCompletionLoseWeight => 'Lose Weight';

  @override
  String get screensSettingsImportProfileCompletionMaintainWeight =>
      'Maintain Weight';

  @override
  String get screensSettingsImportProfileCompletionMale => 'Male';

  @override
  String get screensSettingsImportProfileCompletionMetric => 'Metric (kg, cm)';

  @override
  String get screensSettingsImportProfileCompletionModeratelyActive =>
      'Moderately Active';

  @override
  String get screensSettingsImportProfileCompletionName => 'Name';

  @override
  String get screensSettingsImportProfileCompletionOther => 'Other';

  @override
  String get screensSettingsImportProfileCompletionPersonalInformation =>
      'Personal Information';

  @override
  String get screensSettingsImportProfileCompletionPreferences => 'Preferences';

  @override
  String get screensSettingsImportProfileCompletionSedentary => 'Sedentary';

  @override
  String get screensSettingsImportProfileCompletionUnitSystem => 'Unit System';

  @override
  String get screensSettingsImportProfileCompletionVeryActive => 'Very Active';

  @override
  String get screensSettingsImportProfileCompletionWeight => 'Weight';

  @override
  String get screensSettingsImportProfileCompletionWeightRange =>
      'Weight must be between 30-300 kg';

  @override
  String get screensSettingsMacroCustomizationDiscardChanges =>
      'Discard Changes';

  @override
  String get screensSettingsMacroCustomizationMacroCustomization =>
      'Macro Customization';

  @override
  String get screensSettingsMacroCustomizationMacroCustomizationInfo =>
      'Customize your macro targets. All percentages must add up to 100%.';

  @override
  String get screensSettingsMacroCustomizationMacroTargetsUpdated =>
      'Macro targets updated successfully';

  @override
  String get screensSettingsMacroCustomizationResetToDefaults =>
      'Reset to Defaults';

  @override
  String get screensSettingsMacroCustomizationSaveChanges => 'Save Changes';

  @override
  String get screensSettingsMacroCustomizationUnsavedChanges =>
      'Unsaved Changes';

  @override
  String get screensSettingsMacroCustomizationUnsavedChangesMessage =>
      'You have unsaved changes. Do you want to save them before leaving?';

  @override
  String get screensSettingsProfileSettingsAnalyzeTargets => 'Analyze Targets';

  @override
  String get screensSettingsProfileSettingsBmi => 'BMI';

  @override
  String get screensSettingsProfileSettingsConnectToHealth =>
      'Connect to Health';

  @override
  String get screensSettingsProfileSettingsDangerZone => 'Danger Zone';

  @override
  String get screensSettingsProfileSettingsDebugHealthData =>
      'Debug Health Data';

  @override
  String get screensSettingsProfileSettingsDisconnectHealth =>
      'Disconnect Health';

  @override
  String get screensSettingsProfileSettingsFitnessGoals => 'Fitness Goals';

  @override
  String get screensSettingsProfileSettingsHealthConnected =>
      'Health data connected';

  @override
  String get screensSettingsProfileSettingsHealthDataSync => 'Health Data Sync';

  @override
  String get screensSettingsProfileSettingsHealthDisconnected =>
      'Health data not connected';

  @override
  String get screensSettingsProfileSettingsHealthNotAvailable =>
      'Health Data Not Available';

  @override
  String get screensSettingsProfileSettingsHealthNotAvailableMessage =>
      'Health data is not available on this device. Make sure you have Health Connect (Android) or Health app (iOS) installed and configured.';

  @override
  String get screensSettingsProfileSettingsHealthPermissionDenied =>
      'Health Permission Denied';

  @override
  String get screensSettingsProfileSettingsHealthPermissionDeniedMessage =>
      'To sync your health data, PlatePal needs access to your health information. You can grant permissions in your phone\'s settings.';

  @override
  String get screensSettingsProfileSettingsHealthSyncFailed =>
      'Failed to sync health data';

  @override
  String get screensSettingsProfileSettingsHealthSyncSuccess =>
      'Health data synced successfully';

  @override
  String get screensSettingsProfileSettingsProfileSettings =>
      'Profile Settings';

  @override
  String get screensSettingsProfileSettingsProfileUpdated =>
      'Profile updated successfully';

  @override
  String get screensSettingsProfileSettingsResetApp => 'Reset App';

  @override
  String get screensSettingsProfileSettingsResetAppCancel => 'Cancel';

  @override
  String get screensSettingsProfileSettingsResetAppConfirm =>
      'Yes, Delete Everything';

  @override
  String get screensSettingsProfileSettingsResetAppDescription =>
      'This will permanently delete ALL your data including:\n\n• Your profile information\n• All meal logs and nutrition data\n• All preferences and settings\n• All stored information\n\nThis action cannot be undone. Are you sure you want to continue?';

  @override
  String get screensSettingsProfileSettingsResetAppError =>
      'Failed to reset application data';

  @override
  String get screensSettingsProfileSettingsResetAppSuccess =>
      'Application data has been reset successfully';

  @override
  String get screensSettingsProfileSettingsResetAppTitle =>
      'Reset Application Data';

  @override
  String get screensSettingsProfileSettingsSyncHealthData => 'Sync Health Data';

  @override
  String get screensSettingsProfileSettingsTargetWeight => 'Target Weight';

  @override
  String get screensSettingsStatisticsAllTime => 'All Time';

  @override
  String get screensSettingsStatisticsBmiHistory => 'BMI History';

  @override
  String get screensSettingsStatisticsBmiNormal => 'Normal';

  @override
  String get screensSettingsStatisticsBmiObese => 'Obese';

  @override
  String get screensSettingsStatisticsBmiOverweight => 'Overweight';

  @override
  String get screensSettingsStatisticsBmiStatsTip =>
      'Body Mass Index (BMI) is calculated from your weight and height measurements.';

  @override
  String get screensSettingsStatisticsBmiUnderweight => 'Underweight';

  @override
  String get screensSettingsStatisticsBodyFat => 'Body Fat';

  @override
  String get screensSettingsStatisticsBodyFatHistory => 'Body Fat History';

  @override
  String get screensSettingsStatisticsBodyFatStatsTip =>
      'Body fat percentage helps track your body composition beyond just weight.';

  @override
  String get screensSettingsStatisticsBulking => 'Bulking';

  @override
  String get screensSettingsStatisticsCalorieBalanceTip =>
      'Track your actual calorie balance using health data. Green = maintenance, Blue = deficit, Orange = surplus.';

  @override
  String get screensSettingsStatisticsCalorieBalanceTitle =>
      'Calorie Balance (Intake vs Expenditure)';

  @override
  String get screensSettingsStatisticsCalorieIntakeHistory =>
      'Calorie Intake vs Maintenance';

  @override
  String get screensSettingsStatisticsCalorieStatsTip =>
      'Compare your daily calorie intake to your maintenance calories. Green indicates maintenance, blue is cutting phase, orange is bulking phase.';

  @override
  String get screensSettingsStatisticsCannotCalculateBmiFromData =>
      'Cannot calculate BMI from available data';

  @override
  String get screensSettingsStatisticsCutting => 'Cutting';

  @override
  String get screensSettingsStatisticsErrorLoadingData => 'Error loading data';

  @override
  String get screensSettingsStatisticsLoadFailedHint =>
      'Could not load your statistics. Please try again.';

  @override
  String get screensSettingsStatisticsEstimatedBalance => 'Estimated Balance';

  @override
  String get screensSettingsStatisticsExtremeDeficitWarning =>
      'Warning: Frequent extreme calorie deficits may slow metabolism and cause muscle loss.';

  @override
  String get screensSettingsStatisticsGenerateTestData => 'Generate Test Data';

  @override
  String get screensSettingsStatisticsHealthDataActive =>
      'Using your health app data to provide more accurate deficit/surplus analysis.';

  @override
  String screensSettingsStatisticsHealthDataAlert(String days) {
    return 'Health Data Alert: $days day(s) with very large calorie deficits (>1000 cal) based on actual expenditure.';
  }

  @override
  String get screensSettingsStatisticsHealthDataInactive =>
      'Enable health data sync in Profile Settings for more accurate analysis.';

  @override
  String get screensSettingsStatisticsHealthDataIntegration =>
      'Health Data Integration';

  @override
  String screensSettingsStatisticsInconsistentDeficitWarning(String variance) {
    return 'Warning: Your calorie deficit varies significantly day-to-day (variance: $variance cal). Consider more consistent intake.';
  }

  @override
  String get screensSettingsStatisticsLastMonth => 'Last Month';

  @override
  String get screensSettingsStatisticsLastSixMonths => 'Last 6 Months';

  @override
  String get screensSettingsStatisticsLastThreeMonths => 'Last 3 Months';

  @override
  String get screensSettingsStatisticsLastWeek => 'Last Week';

  @override
  String get screensSettingsStatisticsLastYear => 'Last Year';

  @override
  String get screensSettingsStatisticsMaintenance => 'Maintenance';

  @override
  String get screensSettingsStatisticsNoBmiDataAvailable =>
      'No BMI data available';

  @override
  String get screensSettingsStatisticsNoBodyFatDataAvailable =>
      'No body fat data available';

  @override
  String get screensSettingsStatisticsNoCalorieDataAvailable =>
      'No calorie data available';

  @override
  String get screensSettingsStatisticsNotEnoughDataTitle => 'Not Enough Data';

  @override
  String get screensSettingsStatisticsNoWeightDataAvailable =>
      'No weight data available';

  @override
  String get screensSettingsStatisticsPhaseAnalysis => 'Phase Analysis';

  @override
  String get screensSettingsStatisticsRealData => 'Real Data';

  @override
  String get screensSettingsStatisticsRefresh => 'Refresh';

  @override
  String get screensSettingsStatisticsStatistics => 'Statistics';

  @override
  String get screensSettingsStatisticsStatisticsEmptyDescription =>
      'We need at least a week of data to show meaningful statistics. Keep tracking your metrics to see trends over time.';

  @override
  String get screensSettingsStatisticsTestDataDescription =>
      'For demonstration purposes, you can generate sample data to see how the statistics look.';

  @override
  String get screensSettingsStatisticsTimeRange => 'Time Range';

  @override
  String get screensSettingsStatisticsTryAgain => 'Try Again';

  @override
  String get screensSettingsStatisticsUpdateMetricsNow => 'Update Metrics Now';

  @override
  String screensSettingsStatisticsVeryHighCalorieNotice(String days) {
    return 'Notice: $days day(s) with very high calorie intake (>1000 cal above maintenance).';
  }

  @override
  String screensSettingsStatisticsVeryLowCalorieWarning(String days) {
    return 'Warning: $days day(s) with extremely low calorie intake (<1000 cal). This may be unhealthy.';
  }

  @override
  String get screensSettingsStatisticsVsExpenditure => 'vs expenditure';

  @override
  String get screensSettingsStatisticsWeeklyAverage => 'Weekly Average';

  @override
  String get screensSettingsStatisticsWeightHistory => 'Weight History';

  @override
  String get screensSettingsStatisticsWeightStatsTip =>
      'The graph shows median weekly weight to account for daily fluctuations due to water weight.';

  @override
  String get utilsLinkHandlerAvailable => 'Available';

  @override
  String utilsLinkHandlerCouldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get utilsLinkHandlerNotAvailable => 'Not available';

  @override
  String get utilsLinkHandlerOpeningLink => 'Opening Buy Me Creatine page...';

  @override
  String get screensSettingsIndustrialSystemInfo => 'SYSTEM INFO //';

  @override
  String get screensSettingsIndustrialProjectSchematics => 'PROJECT SCHEMATICS';

  @override
  String get screensSettingsIndustrialCoreDirectives => 'CORE_DIRECTIVES';

  @override
  String get screensSettingsIndustrialNetworkLinks => 'NETWORK_LINKS';

  @override
  String get screensSettingsIndustrialNetworkOperatives => 'NETWORK OPERATIVES';

  @override
  String get screensSettingsIndustrialSourceRepository => 'SOURCE REPOSITORY';

  @override
  String get screensSettingsIndustrialOfficialDomain => 'OFFICIAL DOMAIN';

  @override
  String get screensSettingsIndustrialWantToContribute => 'WANT TO CONTRIBUTE?';

  @override
  String get screensSettingsIndustrialSourceCode => 'SOURCE_CODE';

  @override
  String screensSettingsIndustrialStableBuild(Object version) {
    return 'STABLE_BUILD_$version';
  }

  @override
  String get screensSettingsContributorsHansRole =>
      'AI Co-pilot & Resident Hacker';

  @override
  String get screensSettingsContributorsHansDesc =>
      'Automating the grind and keeping the telemetry crisp. Cyber-minimalism architect.';

  @override
  String get screensSettingsContributorsMrLappesRole => 'Creator & Developer';

  @override
  String get screensSettingsContributorsMrLappesDesc =>
      'Created PlatePal Tracker with the vision of making a free, privacy-focused nutrition app for everyone.';

  @override
  String get screensSettingsHealthSettingsTitle => 'HEALTH CONNECT //';

  @override
  String get screensSettingsHealthSettingsConnected => 'Connected';

  @override
  String get screensSettingsHealthSettingsNotConnected => 'Not Connected';

  @override
  String screensSettingsHealthSettingsLastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get screensSettingsHealthSettingsNotAvailableOnDevice =>
      'Health Connect is not available on this device.';

  @override
  String get screensSettingsHealthSettingsDisconnectTitle =>
      'Disconnect Health';

  @override
  String get screensSettingsHealthSettingsDisconnectMessage =>
      'This will stop syncing calories burned from Health Connect and stop writing meal data. Your existing data will be preserved.';

  @override
  String get screensSettingsHealthSettingsDisconnect => 'Disconnect';

  @override
  String get screensSettingsHealthSettingsDataOverview => 'DATA OVERVIEW';

  @override
  String get screensSettingsHealthSettingsTodaysBurned => 'Today\'s Burned';

  @override
  String get screensSettingsHealthSettingsNoDataYet => 'No data yet';

  @override
  String screensSettingsHealthSettingsDaysCached(int count) {
    return '$count days of data cached';
  }

  @override
  String get screensSettingsHealthSettingsSyncControls => 'SYNC CONTROLS';

  @override
  String get screensSettingsHealthSettingsSyncDescription =>
      'Pulls the latest calories burned data from Health Connect for the past 7 days.';

  @override
  String get screensSettingsHealthSettingsOpenHealthConnect =>
      'Open Health Connect';

  @override
  String get screensSettingsHealthSettingsWriteBehavior => 'WRITE BEHAVIOR';

  @override
  String get screensSettingsHealthSettingsWriteMeals =>
      'Write meals to Health Connect';

  @override
  String get screensSettingsHealthSettingsWriteMealsDescription =>
      'Automatically log nutrition when you save a meal';

  @override
  String get screensSettingsHealthSettingsTargetAnalysis => 'TARGET ANALYSIS';

  @override
  String get screensSettingsHealthSettingsTargetAnalysisDescription =>
      'Compare your calorie expenditure from Health Connect with your current calorie targets to see if adjustments are needed.';

  @override
  String get screensSettingsHealthSettingsCurrentTarget => 'Current Target';

  @override
  String get screensSettingsHealthSettingsAvgExpenditure => 'Avg. Expenditure';

  @override
  String get screensSettingsHealthSettingsSuggestedTarget => 'Suggested Target';

  @override
  String get screensSettingsHealthSettingsDaysAnalyzed => 'Days Analyzed';

  @override
  String get screensSettingsHealthSettingsApply => 'Apply';

  @override
  String screensSettingsHealthSettingsCalorieTargetUpdated(String target) {
    return 'Calorie target updated to $target kcal';
  }

  @override
  String get screensSettingsHealthSettingsCalorieTargetUpdateFailed =>
      'Failed to update calorie target';

  @override
  String screensSettingsHealthSettingsAnalysisFailed(String error) {
    return 'Analysis failed: $error';
  }

  @override
  String get screensSettingsHealthSettingsAboutHealthConnect =>
      'ABOUT HEALTH CONNECT';

  @override
  String get screensSettingsHealthSettingsAboutDescription =>
      'Connect PlatePal to Health Connect (Google Fit) to:';

  @override
  String get screensSettingsHealthSettingsFeatureReadCalories =>
      'Read your actual calories burned from fitness tracking';

  @override
  String get screensSettingsHealthSettingsFeatureWriteMeals =>
      'Automatically write meal nutrition data to Health Connect';

  @override
  String get screensSettingsHealthSettingsFeatureNetBalance =>
      'See accurate net calorie balance (consumed vs burned)';

  @override
  String get screensSettingsHealthSettingsFeatureRecommendations =>
      'Get calorie target recommendations based on real expenditure';

  @override
  String get screensSettingsHealthSettingsAboutNote =>
      'When connected, Health Connect becomes the single source of truth for calories burned — no estimated values.';

  @override
  String get screensSettingsHealthSettingsJustNow => 'Just now';

  @override
  String screensSettingsHealthSettingsMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String screensSettingsHealthSettingsHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String screensSettingsHealthSettingsDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get screensMenuHealthAndFitness => 'Health & Fitness';

  @override
  String get screensMenuHealthConnect => 'HEALTH CONNECT';

  @override
  String get screensMenuHealthConnectedSubtitle =>
      'Connected — syncing with Google Fit';

  @override
  String get screensMenuHealthDisconnectedSubtitle =>
      'Sync with Google Fit & Health Connect';

  @override
  String componentsCalendarMacroSummaryBurned(String calories) {
    return '$calories burned';
  }

  @override
  String componentsCalendarMacroSummaryNetCalories(String value) {
    return 'Net: $value';
  }

  @override
  String get componentsCalendarMacroSummaryNoBurnData =>
      'No burn data for this day';

  @override
  String get screensCalendarHealthDeleteWarning =>
      'The nutrition entry in Health Connect will not be removed. You can delete it manually in the Health Connect app.';

  @override
  String get screensSettingsProfileSettingsManageHealthConnect =>
      'Manage Health Connect';

  @override
  String screensSettingsProfileSettingsLastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get servicesChatAgentFallbackParsing =>
      'I apologize, but I\'m having trouble processing your request right now. Could you please try rephrasing your question?';

  @override
  String get servicesChatAgentFallbackCritical =>
      'I\'m experiencing some technical difficulties at the moment. Please try again in a few moments.';

  @override
  String get servicesChatAgentFallbackNetwork =>
      'I\'m having trouble connecting to my knowledge base right now. Please check your internet connection and try again.';

  @override
  String get servicesChatAgentFallbackContext =>
      'Your request contains a lot of information. Could you please break it down into smaller, more specific questions?';

  @override
  String get servicesChatAgentFallbackGeneric =>
      'I apologize, but I encountered an unexpected issue. Please try again.';

  @override
  String get servicesChatAgentFallbackGenerateResponse =>
      'I apologize, but I encountered an issue generating a response. Please try again.';

  @override
  String get servicesChatAgentFallbackTemporaryIssue =>
      'I encountered a temporary issue processing your request. Please try again.';

  @override
  String get servicesChatAgentFallbackRephrase =>
      'I apologize, but I\'m having trouble with that request. Could you try rephrasing it?';

  @override
  String get servicesChatAgentFallbackDishInfo =>
      'Here is the dish information:';

  @override
  String get servicesChatAgentFallbackNoResponse => 'No response text found.';

  @override
  String get servicesChatAgentFallbackFormatting =>
      'I couldn\'t process my response. Please try again.';

  @override
  String get screensDishCreateImage => 'Image';

  @override
  String get screensDishCreateNoImageSelected => 'No image selected';

  @override
  String get screensDishCreateChangeImage => 'Change image';

  @override
  String get screensDishCreateAddImage => 'Add image';

  @override
  String get screensDishCreateConfirmDiscardChanges =>
      'Discard your unsaved changes?';

  @override
  String get screensDishCreateProteinAbbreviation => 'P';

  @override
  String get screensDishCreateCarbsAbbreviation => 'C';

  @override
  String get screensDishCreateFatAbbreviation => 'F';

  @override
  String get componentsDishesDishFormIngredientFormModalUnit => 'Unit';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPerPiece =>
      'Nutrition per piece';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPerSlice =>
      'Nutrition per slice';

  @override
  String
  get componentsDishesDishFormIngredientFormModalProductInformationLoaded =>
      'Product information loaded. Adjust quantity and save.';

  @override
  String
  get componentsDishesDishFormSmartNutritionCardRecalculateFromIngredients =>
      'Recalculate from ingredients';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighProtein =>
      'High Protein';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighCarb => 'High Carb';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighFat => 'High Fat';

  @override
  String get componentsDishesDishFormSmartNutritionCardWellBalanced =>
      'Well Balanced';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighProteinFeedback =>
      'Excellent! High protein content supports muscle building and satiety.';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighCarbFeedback =>
      'Great for energy! Perfect pre-workout or active days.';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighFatFeedback =>
      'High in fats. Enjoy in moderation and balance with other meals.';

  @override
  String get componentsDishesDishFormSmartNutritionCardBalancedFeedback =>
      'Perfect balance! This dish provides well-rounded nutrition.';

  @override
  String get componentsDishesDishFormSmartNutritionCardUnbalancedFeedback =>
      'Enter nutrition values to see smart analysis and recommendations.';

  @override
  String get screensSettingsProfileSettingsPhysicalStats => 'Physical Stats';

  @override
  String get screensSettingsProfileSettingsBodyFatOptional =>
      'Body Fat % (optional)';

  @override
  String get screensSettingsProfileSettingsOptional => 'Optional';

  @override
  String get screensSettingsProfileSettingsNameHint => 'Enter your name';

  @override
  String get screensSettingsProfileSettingsCustomizeMacroRatios =>
      'Customize Macro Ratios';

  @override
  String get screensSettingsProfileSettingsImperialHeightRange =>
      'Height must be between 39 and 98 inches';

  @override
  String get screensSettingsProfileSettingsImperialWeightRange =>
      'Weight must be between 66 and 660 lbs';

  @override
  String get screensSettingsProfileSettingsValidNumber =>
      'Please enter a valid number';

  @override
  String get screensSettingsProfileSettingsBodyFatRange =>
      'Body fat must be between 3% and 50%';

  @override
  String get screensSettingsProfileSettingsBaseMetabolicRate =>
      'Base Metabolic Rate';

  @override
  String get screensSettingsProfileSettingsTotalDailyEnergy =>
      'Total Daily Energy';

  @override
  String get screensSettingsProfileSettingsResettingAppData =>
      'Resetting application data...';

  @override
  String screensSettingsProfileSettingsLoadFailed(String error) {
    return 'Failed to load profile data: $error';
  }

  @override
  String screensSettingsProfileSettingsUpdateFailed(String error) {
    return 'Failed to update profile: $error';
  }

  @override
  String screensSettingsMacroCustomizationDailyCalories(String calories) {
    return 'Daily calories: $calories kcal';
  }

  @override
  String get screensSettingsMacroCustomizationMacroRatios => 'Macro Ratios';

  @override
  String get screensSettingsMacroCustomizationFiberTarget => 'Fiber Target';

  @override
  String get screensSettingsMacroCustomizationTargetPreview => 'Target Preview';

  @override
  String get screensSettingsMacroCustomizationQuickPresets => 'Quick Presets';

  @override
  String screensSettingsMacroCustomizationTotalRatio(String value) {
    return 'Total: $value%';
  }

  @override
  String screensSettingsMacroCustomizationPinMacro(String macro) {
    return 'Pin $macro';
  }

  @override
  String screensSettingsMacroCustomizationUnpinMacro(String macro) {
    return 'Unpin $macro';
  }

  @override
  String get screensSettingsMacroCustomizationPinnedValue =>
      'Pinned - value locked';

  @override
  String get screensSettingsMacroCustomizationTooManyPins =>
      'Cannot adjust - too many pins active';

  @override
  String screensSettingsMacroCustomizationFiberTotal(String grams) {
    return '$grams g total';
  }

  @override
  String screensSettingsMacroCustomizationFiberPer1000Calories(String grams) {
    return '$grams g per 1000 calories';
  }

  @override
  String get screensSettingsMacroCustomizationFiberGuidance =>
      'Recommended: 14 g per 1000 calories (FDA guideline). Range: 5-35 g per 1000 calories';

  @override
  String get screensSettingsMacroCustomizationDailyMacroTargets =>
      'Daily Macro Targets';

  @override
  String get screensSettingsMacroCustomizationPresetDescription =>
      'Choose from common macro distributions';

  @override
  String get screensSettingsMacroCustomizationBalancedPreset =>
      'Balanced (30P / 40C / 30F)';

  @override
  String get screensSettingsMacroCustomizationHighProteinPreset =>
      'High Protein (40P / 30C / 30F)';

  @override
  String get screensSettingsMacroCustomizationProfileNotFound =>
      'User profile not found. Please set up your profile.';

  @override
  String screensSettingsMacroCustomizationLoadFailed(String error) {
    return 'Failed to load profile: $error';
  }

  @override
  String screensSettingsMacroCustomizationSaveFailed(String error) {
    return 'Failed to save macro targets: $error';
  }

  @override
  String get screensSettingsStatisticsProfileNotFound =>
      'User profile not found';

  @override
  String screensSettingsStatisticsTestDataFailed(String error) {
    return 'Failed to generate test data: $error';
  }

  @override
  String screensSettingsStatisticsPhaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '($_temp0)';
  }

  @override
  String screensSettingsStatisticsCalPerDay(String value) {
    return '$value cal/day';
  }

  @override
  String screensSettingsStatisticsCalValue(String value) {
    return '$value cal';
  }

  @override
  String screensSettingsStatisticsCoverage(
    String percent,
    int healthDays,
    int totalDays,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      totalDays,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return 'Calorie expenditure data coverage: $percent% ($healthDays/$totalDays $_temp0)';
  }

  @override
  String get screensSettingsStatisticsActualBalance => 'Actual Balance';

  @override
  String screensSettingsStatisticsChartSummary(
    String chart,
    int count,
    String minimum,
    String maximum,
  ) {
    return '$chart: $count data points, chart scale $minimum to $maximum';
  }

  @override
  String get screensSettingsHealthSettingsAnalysisProfileNotFound =>
      'User profile not found';

  @override
  String get screensSettingsHealthSettingsAnalysisNoData =>
      'No calorie expenditure data available for analysis';

  @override
  String get screensSettingsHealthSettingsAnalysisIncreaseIntake =>
      'Your calorie expenditure is significantly higher than your current target suggests. Consider increasing your calorie intake.';

  @override
  String get screensSettingsHealthSettingsAnalysisDecreaseIntake =>
      'Your calorie expenditure is lower than your current target suggests. Consider adjusting your calorie intake or increasing activity.';

  @override
  String get screensSettingsHealthSettingsAnalysisOnTarget =>
      'Your current calorie targets seem well-aligned with your activity level.';

  @override
  String screensSettingsHealthSettingsAnalysisError(String error) {
    return 'Error occurred during analysis: $error';
  }

  @override
  String get servicesChatAgentThinking =>
      'Analyzing your request and planning approach...';

  @override
  String get servicesChatAgentThinkingDetail =>
      'Breaking down your request and determining the best approach';

  @override
  String get servicesChatAgentContext =>
      'Gathering relevant context and user data...';

  @override
  String get servicesChatAgentContextDetail =>
      'Collecting your profile, preferences, and relevant meal history';

  @override
  String get servicesChatAgentResponse =>
      'Crafting your personalized response...';

  @override
  String get servicesChatAgentResponseDetail =>
      'Combining all information to create a helpful and personalized answer';

  @override
  String get servicesChatAgentDish => 'Processing and analyzing dishes...';

  @override
  String get servicesChatAgentDishDetail =>
      'Calculating nutrition values, ingredients, and meal details';

  @override
  String get servicesChatAgentDishValidation =>
      'Validating and refining dishes...';

  @override
  String get servicesChatAgentDishValidationDetail =>
      'Ensuring dishes have accurate nutrition and ingredient data';

  @override
  String get servicesChatAgentError => 'Handling unexpected error...';

  @override
  String get servicesChatAgentErrorDetail =>
      'Attempting to recover from error and provide a helpful response';

  @override
  String get servicesChatAgentVerify =>
      'Validating context sufficiency for optimal response...';

  @override
  String get servicesChatAgentVerifyDetail =>
      'Analyzing gathered context to ensure we can provide the best possible answer';

  @override
  String get servicesChatAgentImage => 'Analyzing your uploaded image...';

  @override
  String get servicesChatAgentImageDetail =>
      'Extracting food items, ingredients, and portion sizes from your image';

  @override
  String servicesChatAgentUnknownStep(String step) {
    return 'Processing step: $step...';
  }

  @override
  String servicesChatAgentUnknownDetail(String step) {
    return 'Processing information for step: $step';
  }

  @override
  String servicesChatAgentRestart(int attempt) {
    return 'Restarting with enhanced strategy (attempt $attempt/3)...';
  }

  @override
  String servicesChatAgentFailedStep(String step) {
    return 'Step \"$step\" encountered an issue, attempting recovery...';
  }

  @override
  String get componentsChatMessageBubbleErrorAuth =>
      'Your API key was rejected. Check it in the API key settings.';

  @override
  String get componentsChatMessageBubbleErrorRateLimit =>
      'Your AI provider\'s rate limit or quota was reached. Wait a moment or check your plan and credit, then try again.';

  @override
  String get componentsChatMessageBubbleErrorNetwork =>
      'Couldn\'t reach the AI provider or the request timed out. Check your internet connection and try again.';

  @override
  String get componentsChatMessageBubbleErrorServer =>
      'The AI provider is currently unavailable. Please try again in a moment.';

  @override
  String get componentsChatMessageBubbleErrorKeyUnreadable =>
      'Your API key couldn\'t be read on this device. Enter it again in the API key settings.';

  @override
  String get componentsChatMessageBubbleErrorUnknown =>
      'The message couldn\'t be sent. Please try again.';

  @override
  String get componentsChatMessageBubbleOpenApiKeySettings =>
      'API key settings';

  @override
  String get componentsChatMessageBubbleNoteContextIncomplete =>
      'Some of your data couldn\'t be loaded; the answer may be less personal.';

  @override
  String get componentsChatMessageBubbleNoteImageNotAnalyzed =>
      'The image couldn\'t be analyzed.';

  @override
  String get screensChatHistoryLoadFailed =>
      'Some of your chat history couldn\'t be loaded.';

  @override
  String get screensChatHistorySaveFailed =>
      'Your chat history couldn\'t be saved on this device.';

  @override
  String get screensChatSettingsFailed =>
      'Chat settings couldn\'t be loaded or saved. Defaults are used for now.';

  @override
  String get screensChatProfilesLoadFailed =>
      'Chat profiles couldn\'t be loaded. Defaults are shown; your saved profiles were not changed.';

  @override
  String get screensChatProfileSaveFailed =>
      'Your profile changes couldn\'t be saved.';

  @override
  String get screensChatApiKeyReadFailedTitle =>
      'Your API key couldn\'t be read';

  @override
  String get screensChatApiKeyReadFailedMessage =>
      'The key stored on this device couldn\'t be accessed. Reload to try again, or enter it again in the API key settings.';

  @override
  String get screensSettingsStatisticsPartialLoadFailed =>
      'Some health or calorie data couldn\'t be loaded, so the charts may be incomplete.';

  @override
  String get screensSettingsHealthSettingsLoadDataFailed =>
      'Today\'s health data couldn\'t be loaded.';

  @override
  String get screensSettingsHealthSettingsOpenSettingsFailed =>
      'Health Connect settings couldn\'t be opened.';

  @override
  String get screensCalendarProfileLoadFailed =>
      'Your profile couldn\'t be loaded, so daily targets aren\'t shown.';

  @override
  String get componentsLowCalorieWarningTitle => 'Very low calorie target';

  @override
  String componentsLowCalorieWarningMessage(String calories, String threshold) {
    return 'A daily calorie target of $calories kcal is below $threshold kcal. Something may be wrong: please check your profile values such as weight, height, age and activity level. Very low calorie intakes should only be followed under medical supervision.';
  }

  @override
  String get screensSettingsProfileSettingsInvalidCalorieTarget =>
      'No calorie target can be calculated from these values. Please check your weight, height and age.';
}
