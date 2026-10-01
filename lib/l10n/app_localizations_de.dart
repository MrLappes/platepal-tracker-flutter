// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get screensCalendarHasMealsLogged => 'Mahlzeiten eingetragen';

  @override
  String get screensCalendarFailedToLoadDates =>
      'Kalenderdaten konnten nicht geladen werden';

  @override
  String get screensCalendarFailedToLoadSummary =>
      'Ernährungsübersicht konnte nicht geladen werden';

  @override
  String get screensCalendarProfileNudge =>
      'Profil einrichten, um Tagesziele zu erhalten';

  @override
  String get screensCalendarSetUpProfile => 'Profil einrichten';

  @override
  String get screensCalendarLogMeal => 'Mahlzeit eintragen';

  @override
  String screensCalendarCaloriesPerServing(int calories) {
    return '$calories kcal pro Portion';
  }

  @override
  String get componentsCalendarCalendarDayDetailErrorLoadingMeals =>
      'Mahlzeiten konnten nicht geladen werden';

  @override
  String get componentsCalendarCalendarDayDetailNoMealsLoggedForDay =>
      'Keine Mahlzeiten für diesen Tag protokolliert';

  @override
  String get componentsCalendarCalendarDayDetailUnknownDish =>
      'Unbekanntes Gericht';

  @override
  String get componentsCalendarMacroSummaryCalories => 'Kalorien';

  @override
  String get componentsCalendarMacroSummaryCarbs => 'Kohlenhydrate';

  @override
  String get componentsCalendarMacroSummaryEstimatedCalories =>
      'Geschätzte Kalorien';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesMessage =>
      'Diese Daten sind basierend auf Ihren Profileinstellungen und Aktivitätslevel geschätzt, da für dieses Datum keine Gesundheitsdaten verfügbar waren.';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesToday =>
      'Geschätzte Kalorien (Heute)';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesTodayMessage =>
      'Dies ist Ihr geschätzter Kalorienverbrauch für heute basierend auf Ihrem Aktivitätslevel. Da der Tag noch nicht abgeschlossen ist, repräsentiert dies Ihren Grundumsatz plus geschätzte Aktivität. Ihre tatsächlich verbrannten Kalorien können höher sein, wenn Sie heute mehr Aktivitäten durchführen.';

  @override
  String get componentsCalendarMacroSummaryFat => 'Fett';

  @override
  String get componentsCalendarMacroSummaryFiber => 'Ballaststoffe';

  @override
  String get componentsCalendarMacroSummaryGetAiTip => 'KI-Tipp';

  @override
  String componentsCalendarMacroSummaryPercentOfGoal(int percent) {
    return '$percent % des Ziels';
  }

  @override
  String componentsCalendarMacroSummaryOverBy(String amount, String unit) {
    return '$amount $unit über dem Ziel';
  }

  @override
  String get componentsCalendarMacroSummaryHealthDataMessage =>
      'Diese Daten wurden von den Gesundheitsdaten auf Ihrem Telefon gesammelt und liefern genaue Informationen über verbrannte Kalorien aus Ihren Fitnessaktivitäten für diesen vollständigen Tag.';

  @override
  String get componentsCalendarMacroSummaryHealthDataTitle =>
      'Gesundheitsdaten';

  @override
  String get componentsCalendarMacroSummaryHealthDataTodayMessage =>
      'Diese Daten wurden von den Gesundheitsdaten auf Ihrem Telefon gesammelt. Da der heutige Tag noch nicht abgeschlossen ist, zeigt dies die bisher heute verbrannten Kalorien an. Ihre Gesamtsumme kann sich erhöhen, wenn Sie den Tag über weitere Aktivitäten durchführen.';

  @override
  String get componentsCalendarMacroSummaryHealthDataTodayPartial =>
      'Gesundheitsdaten (Heute - Teilweise)';

  @override
  String get componentsCalendarMacroSummaryNutritionSummary => 'Nährwerte';

  @override
  String get componentsCalendarMacroSummaryProtein => 'Protein';

  @override
  String get componentsCalendarMacroSummaryCompactProtein => 'Protein';

  @override
  String get componentsCalendarMacroSummaryCompactCarbs => 'Kohlenh.';

  @override
  String get componentsCalendarMacroSummaryCompactFat => 'Fett';

  @override
  String get componentsCommonOk => 'OK';

  @override
  String get componentsChatAgentStepsModalAgentProcessingSteps =>
      'Agenten-Prozessschritte';

  @override
  String get componentsChatAgentStepsModalCopiedToClipboard =>
      'In die Zwischenablage kopiert';

  @override
  String get componentsChatAgentStepsModalCopyAll => 'Alles kopieren';

  @override
  String get componentsChatAgentStepsModalViewFullData =>
      'Gesamte Daten anzeigen';

  @override
  String get componentsChatAgentStepsModalViewFullPrompt =>
      'Gesamtes Prompt anzeigen';

  @override
  String get componentsChatAgentStepsModalThinkingProcessTitle =>
      '🧠 Denkprozess';

  @override
  String get componentsChatAgentStepsModalThinkingProcessSubtitle =>
      'Echtzeit-Denkschritte des Agenten';

  @override
  String get componentsChatAgentStepsModalProcessingStepsTitle =>
      '⚙️ Verarbeitungs-Schritte';

  @override
  String get componentsChatAgentStepsModalProcessingStepsSubtitle =>
      'Detaillierte Schritt-für-Schritt-Ausführung';

  @override
  String get componentsChatAgentStepsModalProcessingSummary =>
      'Verarbeitungszusammenfassung';

  @override
  String get componentsChatAgentStepsModalCopySummaryTooltip =>
      'Zusammenfassungsdaten kopieren';

  @override
  String get componentsChatAgentStepsModalProcessingTime => 'Verarbeitungszeit';

  @override
  String get componentsChatAgentStepsModalBotType => 'Bot-Typ';

  @override
  String get componentsChatAgentStepsModalTotalSteps => 'Gesamtschritte';

  @override
  String get componentsChatAgentStepsModalSkippedSteps =>
      'Übersprungene Schritte';

  @override
  String get componentsChatAgentStepsModalFailedSteps =>
      'Fehlgeschlagene Schritte';

  @override
  String get componentsChatAgentStepsModalErrorRecovery => 'Fehlerbehebung';

  @override
  String get componentsChatAgentStepsModalCompletedSteps =>
      'Abgeschlossene Schritte';

  @override
  String get componentsChatAgentStepsModalDeepSearch => 'Tiefensuche';

  @override
  String get componentsChatAgentStepsModalEnabled => 'Aktiviert';

  @override
  String get componentsChatAgentStepsModalDisabled => 'Deaktiviert';

  @override
  String get componentsChatAgentStepsModalModifications => 'Änderungen';

  @override
  String get componentsChatAgentStepsModalNoModifications => 'Keine nötig ✨';

  @override
  String get componentsChatAgentStepsModalPerfectProcessing =>
      'Perfekte Verarbeitung! Keine Korrekturen oder Modifikationen erforderlich.';

  @override
  String get componentsChatAgentStepsModalPipelineModificationsTitle =>
      '✨ Pipeline-Änderungen';

  @override
  String get componentsChatAgentStepsModalPipelineModificationsSubtitle =>
      'Keine Änderungen erforderlich - Ihre Anfrage wurde problemlos verarbeitet!';

  @override
  String get componentsChatAgentStepsModalStepModifications =>
      '🔧 Schritt-Änderungen';

  @override
  String get componentsChatAgentStepsModalCopyModifications =>
      'Änderungen kopieren';

  @override
  String componentsChatAgentStepsModalSummaryLabel(String summary) {
    return 'Zusammenfassung: $summary';
  }

  @override
  String get componentsChatAgentStepsModalEnhancedSystemPrompt =>
      '🤖 Verbesserter System-Prompt';

  @override
  String get componentsChatAgentStepsModalCopyEnhancedPrompt =>
      'Verbesserten System-Prompt kopieren';

  @override
  String get componentsChatDishSuggestionCardHighProtein =>
      'Proteinreiches Gericht';

  @override
  String get componentsChatDishSuggestionCardHighCarb =>
      'Kohlenhydratreiches Gericht';

  @override
  String get componentsChatDishSuggestionCardHighFat => 'Fettreiches Gericht';

  @override
  String get componentsChatDishSuggestionCardBalanced => 'Ausgewogenes Gericht';

  @override
  String get componentsChatDishSuggestionCardUnbalanced =>
      'Unausgewogenes Gericht';

  @override
  String get componentsChatDishSuggestionCardProtein => 'Protein';

  @override
  String get componentsChatDishSuggestionCardCarbs => 'Kohlenhydrate';

  @override
  String get componentsChatDishSuggestionCardFat => 'Fett';

  @override
  String get componentsChatDishSuggestionCardCalories => 'Kalorien';

  @override
  String get componentsChatDishSuggestionCardInspect => 'Details';

  @override
  String get componentsChatMessageBubbleYou => 'Du';

  @override
  String get componentsChatMessageBubbleAssistant => 'Assistent';

  @override
  String get componentsChatMessageBubbleBotTag => 'Bot';

  @override
  String get componentsChatMessageBubbleSending => 'Wird gesendet...';

  @override
  String get componentsChatMessageBubbleSuggestedDishes =>
      'Vorgeschlagene Gerichte';

  @override
  String get componentsChatMessageBubbleRecommendation => 'Empfehlung';

  @override
  String get componentsChatMessageBubbleNoRecommendationsAvailable =>
      'Keine Empfehlungen verfügbar.';

  @override
  String componentsChatAgentStepsModalLengthLabel(int count) {
    return 'Länge: $count Zeichen';
  }

  @override
  String get componentsChatAgentStepsModalTechnicalDetails =>
      'Technische Details';

  @override
  String get componentsChatAgentStepsModalDataChanges => 'Datenänderungen';

  @override
  String get componentsChatAgentStepsModalBefore => 'Vorher';

  @override
  String get componentsChatAgentStepsModalAfter => 'Nachher';

  @override
  String get componentsChatAgentStepsModalStatusSkipped => 'Übersprungen';

  @override
  String get componentsChatAgentStepsModalStatusErrorRecovered =>
      'Fehler behoben';

  @override
  String get componentsChatAgentStepsModalStatusErrorHandlingFailed =>
      'Fehlerbehandlung fehlgeschlagen';

  @override
  String get componentsChatAgentStepsModalStatusCompletedSuccessfully =>
      'Erfolgreich abgeschlossen';

  @override
  String get componentsChatAgentStepsModalFailed => 'Fehlgeschlagen';

  @override
  String get componentsChatAgentStepsModalSeverityLow => 'Niedrig';

  @override
  String get componentsChatAgentStepsModalSeverityMedium => 'Mittel';

  @override
  String get componentsChatAgentStepsModalSeverityHigh => 'Hoch';

  @override
  String get componentsChatAgentStepsModalSeverityCritical => 'Kritisch';

  @override
  String get componentsChatAgentStepsModalBadgeEmergencyOverrides =>
      'Notfall-Überschreibungen';

  @override
  String get componentsChatAgentStepsModalBadgeAiValidations =>
      'KI-Validierungen';

  @override
  String get componentsChatAgentStepsModalBadgeAutomaticFixes =>
      'Automatische Korrekturen';

  @override
  String componentsChatAgentStepsModalTotalModifications(int count) {
    return 'Gesamtänderungen: $count';
  }

  @override
  String get componentsChatAgentStepsModalSkipDetails =>
      '⏭️ Details überspringen';

  @override
  String get componentsChatAgentStepsModalMetadata => '📊 Metadaten';

  @override
  String get componentsChatAgentStepsModalDataOutput => '📤 Datenausgabe';

  @override
  String get componentsChatAgentStepsModalErrorDetails => '❌ Fehlerdetails';

  @override
  String get componentsChatAgentStepsModalRawStepData =>
      '🔍 Rohdaten der Schritte';

  @override
  String componentsChatAgentStepsModalIdLabel(String id) {
    return 'ID: $id';
  }

  @override
  String componentsChatAgentStepsModalTimeLabel(String time) {
    return 'Zeit: $time';
  }

  @override
  String get componentsChatAgentStepsModalUnknownStep => 'Unbekannter Schritt';

  @override
  String get componentsChatAgentStepsModalNoReasonProvided =>
      'Kein Grund angegeben';

  @override
  String get componentsChatAgentStepsModalNoSummaryAvailable =>
      'Keine Zusammenfassung verfügbar';

  @override
  String componentsChatAgentStepsModalListItems(int count) {
    return 'Listeneinträge: $count';
  }

  @override
  String componentsChatAgentStepsModalMapKeys(int count) {
    return 'Zuordnungseinträge: $count';
  }

  @override
  String componentsChatAgentStepsModalMoreItems(int count) {
    return 'Weitere Einträge: $count';
  }

  @override
  String get componentsCommonCopyToClipboard =>
      'In die Zwischenablage kopieren';

  @override
  String get componentsChatBotProfileCustomizationDialogAngryGreg =>
      'Wütender Greg';

  @override
  String get componentsChatBotProfileCustomizationDialogBotName => 'Bot-Name';

  @override
  String get componentsChatBotProfileCustomizationDialogCancel => 'Abbrechen';

  @override
  String get componentsChatBotProfileCustomizationDialogCasualGymBro =>
      'Entspannter Gym-Bro';

  @override
  String get componentsChatBotProfileCustomizationDialogChangeAvatar =>
      'Avatar ändern';

  @override
  String get componentsChatBotProfileCustomizationDialogChooseFromGallery =>
      'Aus Galerie wählen';

  @override
  String get componentsChatBotProfileCustomizationDialogEditBotProfile =>
      'Bot-Profil bearbeiten';

  @override
  String get componentsChatBotProfileCustomizationDialogFitnessCoach =>
      'Fitness-Trainer';

  @override
  String get componentsChatBotProfileCustomizationDialogNiceAndFriendly =>
      'Nett & freundlich';

  @override
  String get componentsChatBotProfileCustomizationDialogPersonality =>
      'Persönlichkeit';

  @override
  String
  get componentsChatBotProfileCustomizationDialogProfessionalNutritionist =>
      'Professioneller Ernährungsberater';

  @override
  String get componentsChatBotProfileCustomizationDialogProfileSaved =>
      'Profil erfolgreich gespeichert';

  @override
  String get componentsChatBotProfileCustomizationDialogProfileSaveFailed =>
      'Profil speichern fehlgeschlagen';

  @override
  String get componentsChatBotProfileCustomizationDialogRemoveAvatar =>
      'Avatar entfernen';

  @override
  String get componentsChatBotProfileCustomizationDialogRequiredField =>
      'Dieses Feld ist erforderlich';

  @override
  String get componentsChatBotProfileCustomizationDialogSave => 'Speichern';

  @override
  String get componentsChatBotProfileCustomizationDialogTakePhoto =>
      'Foto aufnehmen';

  @override
  String get componentsChatBotProfileCustomizationDialogVeryAngryBro =>
      'Sehr wütender Bro';

  @override
  String get componentsChatBotPersonalityDescriptionNutritionist =>
      'Professionell & Evidenzbasiert';

  @override
  String get componentsChatBotPersonalityDescriptionCasualGymbro =>
      'Lässig & Motivierend';

  @override
  String get componentsChatBotPersonalityDescriptionAngryGreg =>
      'Intensiv & Supplement-fokussiert';

  @override
  String get componentsChatBotPersonalityDescriptionVeryAngryBro =>
      'Extrem Intensiv';

  @override
  String get componentsChatBotPersonalityDescriptionFitnessCoach =>
      'Ermutigend & Unterstützend';

  @override
  String get componentsChatBotPersonalityDescriptionNice =>
      'Freundlich & Hilfsbereit';

  @override
  String get componentsChatEditBotProfileTooltip => 'Bot-Profil bearbeiten';

  @override
  String componentsChatChatInputErrorPickingImage(Object error) {
    return 'Fehler beim Auswählen des Bildes: $error';
  }

  @override
  String componentsChatMessageBubbleModificationEmergency(int count) {
    return '$count Notfallkorrekturen angewendet';
  }

  @override
  String componentsChatMessageBubbleModificationAi(int count) {
    return '$count KI-Verbesserungen angewendet';
  }

  @override
  String componentsChatMessageBubbleModificationAutomatic(int count) {
    return '$count automatische Verbesserungen angewendet';
  }

  @override
  String get componentsChatChatInputImageAttached => 'Bild angehängt';

  @override
  String get componentsChatChatInputIngredientsAdded => 'Zutaten hinzugefügt';

  @override
  String componentsChatChatInputRemoveIngredient(String name) {
    return '$name entfernen';
  }

  @override
  String get componentsChatChatInputIngredientAdded =>
      'Zutat zum Chat hinzugefügt';

  @override
  String get componentsChatChatInputAttachments => 'Anhänge hinzufügen';

  @override
  String get componentsChatChatInputScanBarcode => 'Barcode scannen';

  @override
  String get componentsChatChatInputSearchProduct => 'Produkt suchen';

  @override
  String get componentsChatChatInputSendMessage => 'Nachricht senden';

  @override
  String get componentsChatChatInputTypeMessage => 'Nachricht eingeben...';

  @override
  String get componentsChatChatWelcomeAnalyzeNutrition =>
      'Ernährung analysieren';

  @override
  String get componentsChatChatWelcomeCalculateMacros => 'Makros berechnen';

  @override
  String get componentsChatChatWelcomeChatWelcomeSubtitle =>
      'Ihr KI-Ernährungsassistent ist hier, um zu helfen';

  @override
  String get componentsChatChatWelcomeChatWelcomeTitle =>
      'Willkommen bei PlatePal';

  @override
  String get componentsChatChatWelcomeFindAlternatives => 'Alternativen finden';

  @override
  String get componentsChatChatWelcomeGetStartedToday => 'Heute beginnen';

  @override
  String get componentsChatChatWelcomeIngredientInfo => 'Zutatensinfo';

  @override
  String get componentsChatChatWelcomeMealPlan => 'Ernährungsplan-Hilfe';

  @override
  String get componentsChatChatWelcomeSuggestMeal => 'Mahlzeit vorschlagen';

  @override
  String get componentsChatChatWelcomeSuggestMealSubtitle =>
      'Erhalte personalisierte Mahlzeitenempfehlungen';

  @override
  String get componentsChatChatWelcomeSuggestMealMessage =>
      'Schlag mir eine gesunde Mahlzeit vor, basierend auf meinen Fitnesszielen';

  @override
  String get componentsChatChatWelcomeAnalyzeNutritionSubtitle =>
      'Analysiere die Nährwerte deiner Mahlzeiten';

  @override
  String get componentsChatChatWelcomeAnalyzeNutritionMessage =>
      'Hilf mir, die Nährwerte in meiner Mahlzeit zu analysieren';

  @override
  String get componentsChatChatWelcomeFindAlternativesSubtitle =>
      'Entdecke gesunde Lebensmittelalternativen';

  @override
  String get componentsChatChatWelcomeFindAlternativesMessage =>
      'Finde gesunde Alternativen zu meiner aktuellen Mahlzeit';

  @override
  String get componentsChatChatWelcomeCalculateMacrosSubtitle =>
      'Berechne Makros für deine Mahlzeiten';

  @override
  String get componentsChatChatWelcomeCalculateMacrosMessage =>
      'Hilf mir, die Makros für meine Mahlzeiten zu berechnen';

  @override
  String get componentsChatChatWelcomeMealPlanSubtitle =>
      'Erstelle wöchentliche Essenspläne';

  @override
  String get componentsChatChatWelcomeMealPlanMessage =>
      'Hilf mir, einen wöchentlichen Ernährungsplan zu erstellen';

  @override
  String get componentsChatChatWelcomeIngredientInfoSubtitle =>
      'Erfahre mehr über Zutaten und deren Vorteile';

  @override
  String get componentsChatChatWelcomeIngredientInfoMessage =>
      'Erzähl mir von den ernährungsphysiologischen Vorteilen von Zutaten';

  @override
  String get componentsChatChatWelcomeWhatCanIHelpWith =>
      'Wobei kann ich Ihnen helfen?';

  @override
  String get componentsChatDishSuggestionCardDetails => 'Details';

  @override
  String componentsChatDishSuggestionCardErrorOpeningDishScreen(Object error) {
    return 'Fehler beim Öffnen des Gerichtsbildschirms: $error';
  }

  @override
  String get componentsChatDishSuggestionCardLogDish => 'Gericht eintragen';

  @override
  String get componentsChatMessageBubbleClose => 'Schließen';

  @override
  String get componentsChatMessageBubbleIngredients => 'Zutaten';

  @override
  String get componentsChatMessageBubbleMessageCopied =>
      'Nachricht in Zwischenablage kopiert';

  @override
  String get componentsChatMessageBubbleRetryMessage => 'Wiederholen';

  @override
  String get componentsChatMessageBubbleSelect => 'Auswählen';

  @override
  String get componentsChatMessageBubbleTapToViewAgentSteps =>
      'Agent-Details anzeigen';

  @override
  String get componentsChatMessageBubbleYesterday => 'Gestern';

  @override
  String get componentsChatNutritionAnalysisCardDishName => 'Gerichtname';

  @override
  String get componentsChatNutritionAnalysisCardNutritionAnalysis =>
      'Nährwertanalyse';

  @override
  String get componentsChatQuickActionsQuickActions => 'Schnellaktionen';

  @override
  String get componentsChatUserProfileCustomizationDialogEditUserProfile =>
      'Benutzerprofil bearbeiten';

  @override
  String get componentsChatUserProfileCustomizationDialogUsername =>
      'Benutzername';

  @override
  String get componentsDishesDishCardDelete => 'Löschen';

  @override
  String get componentsDishesDishCardEdit => 'Bearbeiten';

  @override
  String get componentsDishesDishFormIngredientFormModalAddIngredient =>
      'Zutat hinzufügen';

  @override
  String get componentsDishesDishFormIngredientFormModalEditIngredient =>
      'Zutat bearbeiten';

  @override
  String get componentsDishesDishFormIngredientFormModalGrams => 'g';

  @override
  String get componentsDishesDishFormIngredientFormModalIngredientName =>
      'Zutatenname';

  @override
  String
  get componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder =>
      'Zutatennamen eingeben';

  @override
  String get componentsDishesDishFormIngredientFormModalKcal => 'kcal';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionInformation =>
      'Nährwertinformationen';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPer100g =>
      'Nährwerte pro 100g';

  @override
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName =>
      'Bitte geben Sie einen Zutatennamen ein';

  @override
  String get componentsDishesDishFormIngredientFormModalPleaseEnterQuantity =>
      'Bitte geben Sie eine Menge ein';

  @override
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber =>
      'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get componentsDishesDishFormIngredientFormModalQuantity => 'Menge';

  @override
  String get componentsDishesDishFormIngredientFormModalQuantityPlaceholder =>
      '0';

  @override
  String get componentsDishesDishFormSmartNutritionCardNutritionalInformation =>
      'Nährwertinformationen';

  @override
  String get componentsModalsDishLogModalAddNotes =>
      'Notizen hinzufügen (optional)';

  @override
  String get componentsModalsDishLogModalBreakfast => 'Frühstück';

  @override
  String get componentsModalsDishLogModalCalculatedNutrition =>
      'Berechnete Nährwerte';

  @override
  String get componentsModalsDishLogModalDinner => 'Abendessen';

  @override
  String get componentsModalsDishLogModalDishLoggedSuccessfully =>
      'Gericht erfolgreich protokolliert!';

  @override
  String get componentsModalsDishLogModalErrorLoggingDish =>
      'Fehler beim eintragen des Gerichtes';

  @override
  String get componentsModalsDishLogModalLogDishTitle => 'Gericht eintragen';

  @override
  String get componentsModalsDishLogModalLunch => 'Mittagessen';

  @override
  String get componentsModalsDishLogModalNotes => 'Notizen';

  @override
  String get componentsModalsDishLogModalPortionSize => 'Portionsgröße';

  @override
  String get componentsModalsDishLogModalSelectDate => 'Datum auswählen';

  @override
  String get componentsModalsDishLogModalSelectMealType =>
      'Mahlzeitentyp auswählen';

  @override
  String get componentsModalsDishLogModalSelectTime => 'Uhrzeit auswählen';

  @override
  String get componentsModalsDishLogModalSnack => 'Snack';

  @override
  String get componentsScannerBarcodeScannerBarcodeScanner => 'Barcode-Scanner';

  @override
  String componentsScannerBarcodeScannerErrorScanningBarcode(String error) {
    return 'Fehler beim Scannen des Barcodes';
  }

  @override
  String get componentsScannerBarcodeScannerOpenSettings =>
      'Einstellungen Öffnen';

  @override
  String get componentsScannerBarcodeScannerProductNotFound =>
      'Produkt nicht gefunden';

  @override
  String get componentsScannerBarcodeScannerScanBarcodeToAddProduct =>
      'Barcode scannen, um Produkt hinzuzufügen';

  @override
  String get componentsScannerBarcodeScannerScanningBarcode =>
      'Barcode wird gescannt...';

  @override
  String get componentsScannerBarcodeScannerClose => 'Schließen';

  @override
  String get componentsScannerBarcodeScannerPermissionHint =>
      'Erlaube dieser App den Kamerazugriff in den Systemeinstellungen.';

  @override
  String componentsScannerBarcodeScannerScannerError(String errorCode) {
    return 'Scannerfehler: $errorCode';
  }

  @override
  String get componentsScannerBarcodeScannerServiceUnavailable =>
      'Der Lebensmitteldienst ist nicht erreichbar. Bitte versuche es erneut.';

  @override
  String get componentsScannerBarcodeScannerTorchOn =>
      'Taschenlampe einschalten';

  @override
  String get componentsScannerBarcodeScannerTorchOff =>
      'Taschenlampe ausschalten';

  @override
  String get componentsScannerProductSearchLoadMore => 'Mehr laden';

  @override
  String get componentsScannerProductSearchLocalDishes => 'Lokale Gerichte';

  @override
  String get componentsScannerProductSearchLocalIngredients => 'Lokale Zutaten';

  @override
  String get componentsScannerProductSearchNoProductsFound =>
      'Keine Produkte gefunden';

  @override
  String get componentsScannerProductSearchProductSearch => 'Produktsuche';

  @override
  String get componentsScannerProductSearchSearchProducts => 'Produkte suchen';

  @override
  String get componentsScannerProductSearchFiltersAndSort =>
      'Filter und Sortierung';

  @override
  String get componentsScannerProductSearchNutriScore => 'NUTRI-SCORE';

  @override
  String get componentsScannerProductSearchAny => 'Alle';

  @override
  String get componentsScannerProductSearchSortBy => 'Sortieren nach';

  @override
  String get componentsScannerProductSearchPopular => 'Beliebt';

  @override
  String componentsScannerProductSearchResultsFor(String query) {
    return 'Ergebnisse für \"$query\"';
  }

  @override
  String get componentsScannerProductSearchMyDatabase => 'Meine Datenbank';

  @override
  String get componentsScannerProductSearchGlobalFeed => 'Weltweiter Katalog';

  @override
  String get componentsScannerProductSearchEndOfResults =>
      'Ende der Ergebnisse';

  @override
  String get componentsScannerProductSearchSelectCategoryOrSearch =>
      'Kategorie wählen oder Produkt suchen';

  @override
  String componentsScannerProductSearchNoResultsFor(String query) {
    return 'Keine Ergebnisse für \"$query\"';
  }

  @override
  String get componentsScannerProductSearchUnknown => 'Unbekannt';

  @override
  String get componentsScannerProductSearchKcal => 'kcal';

  @override
  String get componentsScannerProductSearchProteinAbbreviation => 'E:';

  @override
  String get componentsScannerProductSearchCarbsAbbreviation => 'KH:';

  @override
  String get componentsScannerProductSearchFatAbbreviation => 'F:';

  @override
  String get componentsScannerProductSearchGramsAbbreviation => 'g';

  @override
  String get componentsScannerProductSearchIngredient => 'Zutat';

  @override
  String componentsScannerProductSearchDishIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zutaten — Gericht',
      one: '1 Zutat — Gericht',
    );
    return '$_temp0';
  }

  @override
  String get componentsScannerProductSearchBrowseUnavailable =>
      'Produkte können nicht geladen werden. Bitte erneut versuchen.';

  @override
  String get componentsScannerProductSearchUnknownProduct =>
      'Unbekanntes Produkt';

  @override
  String get componentsScannerProductSearchCategoryAll => 'Alle';

  @override
  String get componentsScannerProductSearchCategoryFruits => 'Obst';

  @override
  String get componentsScannerProductSearchCategoryVegetables => 'Gemüse';

  @override
  String get componentsScannerProductSearchCategoryDairy => 'Milchprodukte';

  @override
  String get componentsScannerProductSearchCategoryMeat => 'Fleisch';

  @override
  String get componentsScannerProductSearchCategorySeafood =>
      'Fisch und Meeresfrüchte';

  @override
  String get componentsScannerProductSearchCategoryBeverages => 'Getränke';

  @override
  String get componentsScannerProductSearchCategoryCereals => 'Getreide';

  @override
  String get componentsScannerProductSearchCategoryBreads => 'Brot';

  @override
  String get componentsScannerProductSearchCategorySnacks => 'Knabbereien';

  @override
  String get componentsScannerProductSearchCategorySweets => 'Süßwaren';

  @override
  String get componentsScannerProductSearchCategoryLegumes => 'Hülsenfrüchte';

  @override
  String get componentsScannerProductSearchCategoryNuts => 'Nüsse';

  @override
  String get componentsScannerProductSearchCategoryCondiments => 'Würzmittel';

  @override
  String get componentsScannerProductSearchCategoryOilsAndFats =>
      'Öle und Fette';

  @override
  String get componentsScannerProductSearchCategoryFrozen => 'Tiefkühlkost';

  @override
  String get componentsScannerProductSearchCategoryReadyMeals =>
      'Fertiggerichte';

  @override
  String get componentsScannerProductSearchCategoryBabyFoods => 'Babynahrung';

  @override
  String get componentsScannerProductSearchSortPopularity => 'Am beliebtesten';

  @override
  String get componentsScannerProductSearchSortName => 'Name A–Z';

  @override
  String get componentsScannerProductSearchSortNewest => 'Neueste';

  @override
  String get componentsScannerProductSearchSortCompleteness =>
      'Am vollständigsten';

  @override
  String get componentsSharedErrorDisplayRetry => 'Wiederholen';

  @override
  String get componentsUiCustomTabBarCalendar => 'Kalender';

  @override
  String get componentsUiCustomTabBarChat => 'Chat';

  @override
  String get componentsUiCustomTabBarMeals => 'Mahlzeiten';

  @override
  String get componentsUiCustomTabBarMenu => 'Menü';

  @override
  String get providersChatProviderAiThinking => 'KI denkt nach...';

  @override
  String get providersChatProviderIngredientsPrompt =>
      'Was kann ich mit diesen Zutaten zubereiten?';

  @override
  String get providersChatProviderTestChatResponse =>
      'Danke, dass Sie PlatePal ausprobieren! Dies ist eine Testantwort, um Ihnen zu zeigen, wie unser KI-Assistent funktioniert. Um echte Ernährungsberatung und Mahlzeitenvorschläge zu erhalten, konfigurieren Sie bitte Ihren OpenAI API-Schlüssel in den Einstellungen.';

  @override
  String get providersChatProviderTestChatWelcome =>
      'Dies ist der Testmodus! Ich kann Ihnen helfen, die Funktionen von PlatePal zu erkunden. Versuchen Sie, mich nach Ernährung, Essensplanung oder Lebensmittelempfehlungen zu fragen.';

  @override
  String get providersChatProviderWelcomeToChat =>
      'Willkommen bei Ihrem KI-Ernährungsassistenten! Fragen Sie mich alles über Mahlzeiten, Ernährung oder Ihre Fitnessziele.';

  @override
  String get screensCalendarAiNutritionTip => 'KI Ernährungstipp';

  @override
  String get screensCalendarConfigureApiKeyForAiTips =>
      'Bitte OpenAI-API-Schlüssel in den Einstellungen konfigurieren, um KI-Tipps zu nutzen';

  @override
  String get screensCalendarDeleteLog => 'Protokoll löschen';

  @override
  String get screensCalendarDeleteLogConfirmation =>
      'Sind Sie sicher, dass Sie diese protokollierte Mahlzeit löschen möchten?';

  @override
  String get screensCalendarFailedToDeleteMealLog =>
      'Löschen des Mahlzeit-Protokolls fehlgeschlagen';

  @override
  String get screensCalendarFailedToGetAiTip =>
      'Fehler beim Abrufen des KI-Tipps. Bitte erneut versuchen.';

  @override
  String get screensCalendarMealLogDeletedSuccessfully =>
      'Mahlzeit-Protokoll erfolgreich gelöscht';

  @override
  String get screensCalendarOk => 'OK';

  @override
  String get screensChatChatAssistant => 'KI-Chat-Assistent';

  @override
  String get screensChatSystemAnalyzing => 'SYSTEM ANALYSIERT ::';

  @override
  String get screensChatChatCleared => 'Chat-Verlauf gelöscht';

  @override
  String get screensChatClearChat => 'Chat löschen';

  @override
  String get screensChatClearChatConfirmation =>
      'Sind Sie sicher, dass Sie den Chat-Verlauf löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get screensChatConfigureApiKeyButton => 'API-Schlüssel konfigurieren';

  @override
  String get screensChatConfigureApiKeyToUseChat =>
      'Bitte konfigurieren Sie Ihren OpenAI API-Schlüssel in den Einstellungen, um den KI-Chat-Assistenten zu verwenden.';

  @override
  String get screensChatLoading => 'Wird geladen...';

  @override
  String get screensChatNoApiKeyConfigured => 'Kein API-Schlüssel konfiguriert';

  @override
  String get screensDishCreateBasicInfo => 'Grundinformationen';

  @override
  String get screensDishCreateCamera => 'Kamera';

  @override
  String get screensDishCreateCategory => 'Kategorie';

  @override
  String get screensDishCreateConfirmDeleteIngredient =>
      'Sind Sie sicher, dass Sie diese Zutat löschen möchten?';

  @override
  String get screensDishCreateCreateDish => 'Gericht erstellen';

  @override
  String get screensDishCreateDeleteIngredient => 'Zutat löschen';

  @override
  String get screensDishCreateDescription => 'Beschreibung';

  @override
  String get screensDishCreateDescriptionPlaceholder => 'Beschreibung eingeben';

  @override
  String get screensDishCreateDishCreatedSuccessfully =>
      'Gericht erfolgreich erstellt';

  @override
  String get screensDishCreateDishNamePlaceholder => 'Gerichtnamen eingeben';

  @override
  String get screensDishCreateDishUpdatedSuccessfully =>
      'Gericht erfolgreich aktualisiert';

  @override
  String get screensDishCreateEditDish => 'Gericht bearbeiten';

  @override
  String get screensDishCreateErrorSavingDish =>
      'Fehler beim Speichern des Gerichts';

  @override
  String get screensDishCreateFavorite => 'Favorit';

  @override
  String get screensDishCreateGallery => 'Galerie';

  @override
  String get screensDishCreateIngredientDeleted => 'Zutat gelöscht';

  @override
  String get screensDishCreateMarkAsFavorite => 'Als Favorit markieren';

  @override
  String get screensDishCreateNoIngredientsAdded => 'Keine Zutaten hinzugefügt';

  @override
  String get screensDishCreateNutritionRecalculated =>
      'Nährwerte neu berechnet';

  @override
  String get screensDishCreateOptions => 'Optionen';

  @override
  String get screensDishCreatePleaseEnterDishName =>
      'Bitte geben Sie einen Gerichtnamen ein';

  @override
  String get screensDishCreateProductAddedSuccessfully =>
      'Produkt erfolgreich hinzugefügt';

  @override
  String get screensDishCreateRemoveImage => 'Bild entfernen';

  @override
  String get screensDishCreateSaveDish => 'Gericht speichern';

  @override
  String get screensHomeAppTitle => 'PlatePal Tracker';

  @override
  String get providersStorageError =>
      'Deine Daten konnten nicht geladen werden.';

  @override
  String get providersStorageRetry => 'Erneut versuchen';

  @override
  String get screensMealsAddedToFavorites => 'Zu Favoriten hinzugefügt';

  @override
  String get screensMealsAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get screensMealsAddToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get screensMealsAllCategories => 'Alle Kategorien';

  @override
  String get screensMealsCreateFirstDish => 'Erstes Gericht erstellen';

  @override
  String get screensMealsDeleteDish => 'Gericht löschen';

  @override
  String screensMealsDeleteDishConfirmation(String dishName) {
    return 'Sind Sie sicher, dass Sie \"$dishName\" löschen möchten?';
  }

  @override
  String get screensMealsDishDeletedSuccessfully =>
      'Gericht erfolgreich gelöscht';

  @override
  String get screensMealsErrorLoadingDishes => 'Fehler beim Laden der Gerichte';

  @override
  String get screensMealsLoadFailedHint =>
      'Deine Gerichte konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get screensMealsErrorUpdatingDish =>
      'Fehler beim Aktualisieren des Gerichts';

  @override
  String get screensMealsFailedToDeleteDish =>
      'Gericht konnte nicht gelöscht werden';

  @override
  String get screensMealsNoDishesCreated => 'Noch keine Gerichte erstellt';

  @override
  String get screensMealsNoDishesFound => 'Keine Gerichte gefunden';

  @override
  String get screensMealsOtherCategory => 'Sonstiges';

  @override
  String get screensMealsRemovedFromFavorites => 'Aus Favoriten entfernt';

  @override
  String get screensMealsRemoveFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get screensMealsSearchDishes => 'Gerichte suchen';

  @override
  String get screensMealsTryAdjustingSearch =>
      'Versuchen Sie, Ihre Suche anzupassen';

  @override
  String get screensMenuAbout => 'Über uns';

  @override
  String get screensMenuAiFeatures => 'KI & Funktionen';

  @override
  String get screensMenuApiKeySettings => 'API-Schlüssel Einstellungen';

  @override
  String get screensMenuAppearance => 'Erscheinungsbild';

  @override
  String get screensMenuChatAgentOptions => 'Chat-Agent Optionen';

  @override
  String get screensMenuConfigureApiKey =>
      'Konfigurieren Sie Ihren OpenAI API-Schlüssel';

  @override
  String get screensMenuContributors => 'Mitwirkende';

  @override
  String get screensMenuCurrentStats => 'Aktuelle Statistiken';

  @override
  String get screensMenuDark => 'Dunkel';

  @override
  String get screensMenuDataManagement => 'Datenverwaltung';

  @override
  String get screensMenuEditPersonalInfo =>
      'Bearbeiten Sie Ihre persönlichen Informationen';

  @override
  String get screensMenuEnableAgentModeDeepSearch =>
      'Agent-Modus, Deep Search und mehr aktivieren';

  @override
  String get screensMenuExportData => 'Daten exportieren';

  @override
  String get screensMenuExportMealData => 'Exportieren Sie Ihre Mahlzeitdaten';

  @override
  String get screensMenuImportData => 'Daten importieren';

  @override
  String get screensMenuImportMealDataBackup =>
      'Importieren Sie Mahlzeitdaten aus der Sicherung';

  @override
  String get screensMenuInformation => 'Informationen';

  @override
  String get screensMenuLanguage => 'Sprache';

  @override
  String get screensMenuSystemDefault => 'Systemstandard';

  @override
  String get screensMenuLearnMorePlatePal => 'Erfahren Sie mehr über PlatePal';

  @override
  String get screensMenuLight => 'Hell';

  @override
  String get screensMenuMadeBy => 'Erstellt von MrLappes';

  @override
  String get screensMenuNutritionGoals => 'Ernährungsziele';

  @override
  String get screensMenuOceanic => 'Ozeanisch';

  @override
  String get screensMenuForest => 'Wald';

  @override
  String get screensMenuPlatePal => 'PlatePal';

  @override
  String get screensMenuProfile => 'Profil';

  @override
  String get screensMenuSetNutritionTargets =>
      'Legen Sie Ihre täglichen Ernährungsziele fest';

  @override
  String get screensMenuSystem => 'System';

  @override
  String get screensMenuTheme => 'Design';

  @override
  String get screensMenuUserProfile => 'Benutzerprofil';

  @override
  String get screensMenuViewContributors => 'Projektmitwirkende anzeigen';

  @override
  String get screensMenuViewStatistics => 'Statistiken anzeigen';

  @override
  String get screensPrivacyTitle => 'Datenschutzerklärung';

  @override
  String get screensPrivacyEffectiveDate => 'Gültig ab: 2026-10-01';

  @override
  String get screensPrivacyOverviewTitle => 'Auf einen Blick';

  @override
  String get screensPrivacyOverviewBody =>
      'PlatePal Tracker ist ein Ernährungstracker, der überwiegend offline funktioniert. Wir betreiben keine Server für deine App-Daten und verlangen kein Konto; die App enthält weder Analyse- noch Werbe- oder Tracking-SDKs. Die unten genannten optionalen Netzwerkfunktionen kontaktieren bei Nutzung ihre jeweiligen Anbieter.';

  @override
  String get screensPrivacyStorageTitle => 'Daten auf deinem Gerät';

  @override
  String get screensPrivacyStorageBody =>
      'Gerichte, Mahlzeitenprotokolle, Profildaten (einschließlich Körpermaßen), Ziele, Chatverlauf und Einstellungen werden in SQLite oder SharedPreferences auf deinem Gerät gespeichert. Gespeicherte Lebensmittelfotos können ebenfalls im App-Speicher liegen. Deinen API-Schlüssel speichert die App im sicheren Plattformspeicher; ältere Schlüssel aus SharedPreferences werden nach Möglichkeit dorthin übertragen.';

  @override
  String get screensPrivacyAiTitle => 'KI-Chat';

  @override
  String get screensPrivacyAiBody =>
      'Der KI-Chat ist freiwillig und benötigt deinen eigenen API-Schlüssel. Bei der Nutzung werden deine Nachrichten, angehängte Bilder und, falls relevant, frühere Nachrichten, dein Profil, Mahlzeitenprotokolle oder Nährwertzusammenfassungen sowie gespeicherte Gerichte an OpenAI oder den von dir eingerichteten OpenAI-kompatiblen Anbieter gesendet. Der Schlüssel wird dem Anbieter zur Authentifizierung übermittelt. Dieser verarbeitet die Daten nach seiner eigenen Datenschutzerklärung; wähle einen Anbieter, dem du vertraust. Wir erhalten diese Anfragen nicht.';

  @override
  String get screensPrivacyFoodFactsTitle => 'Open Food Facts';

  @override
  String get screensPrivacyFoodFactsBody =>
      'Wenn du nach Lebensmitteln suchst oder einen Barcode scannst, sendet die App den Suchbegriff oder die Barcodenummer und gewählte Filter an world.openfoodfacts.org. Produktinformationen und Bilder können von Open Food Facts heruntergeladen werden.';

  @override
  String get screensPrivacyHealthTitle => 'Health Connect und Apple Health';

  @override
  String get screensPrivacyHealthBody =>
      'Mit deiner Erlaubnis liest die App verbrannte Kalorien (Gesamt- und Aktivkalorien unter Android, Aktiv- und Grundumsatzkalorien unter iOS) aus Health Connect oder Apple Health und schreibt die Nährwerte deiner protokollierten Mahlzeiten dorthin. Die gelesenen Werte werden auf diesem Gerät zwischengespeichert und für Berechnungen zu Energieverbrauch und Zielen in der App genutzt; sie werden weder in KI-Anfragen eingefügt noch an einen Entwickler-Server gesendet. Health Connect und Apple Health verwalten ihre gespeicherten Einträge selbst.';

  @override
  String get screensPrivacyExternalTitle => 'Externe Links und Bilder';

  @override
  String get screensPrivacyExternalBody =>
      'Die Mitwirkendenseite lädt Profilbilder von GitHubs avatars.githubusercontent.com. Wenn du GitHub, die Online-Datenschutzerklärung, andere externe Webseiten oder Produktbilder aus dem Netz öffnest, werden diese Dienste kontaktiert. Sie können dabei deine IP-Adresse sehen und Anfragen nach ihren eigenen Richtlinien verarbeiten.';

  @override
  String get screensPrivacyExportTitle => 'Export und Import';

  @override
  String get screensPrivacyExportBody =>
      'Exportdateien (JSON, CSV oder ein vollständiges ZIP-Backup, das auch deine Gerichtsfotos enthält) werden lokal erstellt, wenn du einen Export auswählst; du kannst sie über dein Gerät teilen. Beim Import liest die App eine von dir ausgewählte Datei und erstellt zuvor eine lokale Sicherung, es sei denn, du entscheidest dich bei fehlgeschlagener Sicherung ausdrücklich für das Fortfahren. Wir laden diese Daten auf keinen eigenen Server hoch.';

  @override
  String get screensPrivacyBackupTitle => 'Android-Sicherung';

  @override
  String get screensPrivacyBackupBody =>
      'Die Android-Systemsicherung kann die Datenbank und Einstellungen der App, einschließlich zwischengespeicherter Gesundheits-Kalorienwerte und des Chatverlaufs, in dein Google-Konto kopieren oder auf ein anderes Gerät übertragen. Die Sicherungsregeln schließen Einstellungsdateien des sicheren Speichers aus; ein älterer API-Schlüssel kann bis zur Übertragung jedoch noch in anderen Einstellungen stehen. Über die Android-Sicherungseinstellungen kannst du das steuern.';

  @override
  String get screensPrivacyDeletionTitle => 'Daten löschen';

  @override
  String get screensPrivacyDeletionBody =>
      'Unter Profil löscht App zurücksetzen die SQLite-Datenbank, SharedPreferences und den gespeicherten API-Schlüssel auf diesem Gerät. Beim Deinstallieren werden private App-Daten entfernt. Das Zurücksetzen entfernt keine gespeicherten Bilder, Exportdateien oder Sicherungen vor Importen, anderweitig geteilte Kopien, bereits in Health Connect oder Apple Health geschriebene Einträge oder Systemsicherungen; lösche sie bei Bedarf separat.';

  @override
  String get screensPrivacyChildrenTitle => 'Kinder';

  @override
  String get screensPrivacyChildrenBody =>
      'PlatePal Tracker ist nicht für Kinder bestimmt. Die App prüft das Alter nicht; Eltern oder Erziehungsberechtigte sollten die Nutzung beaufsichtigen, besonders bevor externe Dienste aktiviert oder sensible Angaben geteilt werden.';

  @override
  String get screensPrivacyChangesTitle => 'Änderungen dieser Richtlinie';

  @override
  String get screensPrivacyChangesBody =>
      'Wir können diese Richtlinie aktualisieren, wenn sich die App ändert. Das oben genannte Gültigkeitsdatum zeigt, wann diese Fassung in Kraft trat; die aktuelle Erklärung findest du in der App oder im GitHub-Repository.';

  @override
  String get screensPrivacyContactTitle => 'Kontakt';

  @override
  String get screensPrivacyContactBody =>
      'Bei Fragen zum Datenschutz schreibe an mike.busam@plate-pal.de oder erstelle ein GitHub-Issue unter github.com/MrLappes/platepal-tracker-flutter/issues. Auf Daten, die nur auf deinem Gerät gespeichert sind, haben wir keinen Zugriff; nutze zum Löschen die oben genannten App- und Systemeinstellungen.';

  @override
  String get screensPrivacyMenuSubtitle =>
      'Welche Daten das Gerät verlassen und wie du sie verwaltest';

  @override
  String get screensPrivacyViewOnline => 'Online ansehen';

  @override
  String get screensPrivacyLinkError =>
      'Datenschutzerklärung konnte nicht geöffnet werden.';

  @override
  String get screensSettingsAboutAboutAppTitle => 'Über uns';

  @override
  String get screensSettingsAboutAboutDescription =>
      'PlatePal Tracker wurde entwickelt, um eine datenschutzorientierte, quelloffene Alternative zu teuren Ernährungs-Tracking-Apps zu bieten. Wir glauben daran, die Kontrolle in Ihre Hände zu legen - ohne Abonnements, ohne Werbung und ohne Datensammlung.';

  @override
  String get screensSettingsAboutAppMotto =>
      'Von Sportlern für Sportler gemacht, die kostenpflichtige Apps hassen';

  @override
  String get screensSettingsAboutCodersMessage =>
      'Programmierer sollten nicht bezahlen müssen';

  @override
  String get screensSettingsAboutDataStaysOnDevice =>
      'Ihre Daten bleiben auf Ihrem Gerät';

  @override
  String get screensSettingsAboutFreeOpenSource =>
      '100% kostenlos und quelloffen';

  @override
  String get screensSettingsAboutGithubRepository =>
      'github.com/MrLappes/platepal-tracker';

  @override
  String get screensSettingsAboutUseOwnAiKey =>
      'Verwenden Sie Ihren eigenen KI-Schlüssel für volle Kontrolle';

  @override
  String get screensSettingsAboutWebsite => 'plate-pal.de';

  @override
  String get screensSettingsAboutWhyPlatePal => 'Warum PlatePal?';

  @override
  String get screensSettingsApiKeySettingsAboutOpenAiApiKey =>
      'Über OpenAI API-Schlüssel';

  @override
  String get screensSettingsApiKeySettingsAiFeaturesEnabled =>
      'KI-Funktionen sind aktiviert';

  @override
  String get screensSettingsApiKeySettingsApiKeyBulletPoints =>
      '• Holen Sie sich Ihren API-Schlüssel von platform.openai.com\n• Ihr Schlüssel wird lokal auf Ihrem Gerät gespeichert\n• Nutzungsgebühren werden direkt Ihrem OpenAI-Konto belastet';

  @override
  String get screensSettingsApiKeySettingsApiKeyConfigured =>
      'API-Schlüssel konfiguriert';

  @override
  String get screensSettingsApiKeySettingsApiKeyDescription =>
      'Um KI-Funktionen wie Mahlzeitanalyse und Vorschläge zu nutzen, müssen Sie Ihren eigenen OpenAI API-Schlüssel bereitstellen. Dies stellt sicher, dass Ihre Daten privat bleiben und Sie die volle Kontrolle haben.';

  @override
  String get screensSettingsApiKeySettingsApiKeyHelperText =>
      'Geben Sie Ihren OpenAI API-Schlüssel ein oder lassen Sie das Feld leer, um KI-Funktionen zu deaktivieren';

  @override
  String get screensSettingsApiKeySettingsApiKeyMustStartWith =>
      'API-Schlüssel muss mit \"sk-\" beginnen';

  @override
  String get screensSettingsApiKeySettingsApiKeyPlaceholder => 'sk-...';

  @override
  String get screensSettingsApiKeySettingsApiKeyRemovedSuccessfully =>
      'API-Schlüssel erfolgreich entfernt';

  @override
  String get screensSettingsApiKeySettingsApiKeySavedSuccessfully =>
      'API-Schlüssel erfolgreich gespeichert';

  @override
  String get screensSettingsApiKeySettingsApiKeyTestWarning =>
      'Ihr API-Schlüssel wird mit einer kleinen Anfrage getestet, um zu überprüfen, ob er funktioniert. Der Schlüssel wird nur auf Ihrem Gerät gespeichert und niemals an unsere Server gesendet';

  @override
  String get screensSettingsApiKeySettingsApiKeyTooShort =>
      'API-Schlüssel scheint zu kurz zu sein';

  @override
  String get screensSettingsApiKeySettingsClipboardEmpty =>
      'Zwischenablage ist leer';

  @override
  String get screensSettingsApiKeySettingsCouldNotLoadModels =>
      'Verfügbare Modelle konnten nicht geladen werden. Verwende Standard-Modellliste';

  @override
  String get screensSettingsApiKeySettingsFailedToAccessClipboard =>
      'Zugriff auf Zwischenablage fehlgeschlagen';

  @override
  String get screensSettingsApiKeySettingsFailedToLoadApiKey =>
      'API-Schlüssel konnte nicht geladen werden';

  @override
  String get screensSettingsApiKeySettingsFailedToRemoveApiKey =>
      'API-Schlüssel konnte nicht entfernt werden';

  @override
  String get screensSettingsApiKeySettingsInvalidBaseUrl =>
      'Die Basis-URL muss mit https:// beginnen (http:// ist nur für localhost erlaubt)';

  @override
  String get screensSettingsApiKeySettingsGetApiKeyFromOpenAi =>
      'API-Schlüssel von OpenAI holen';

  @override
  String get screensSettingsApiKeySettingsGpt35ModelsInfo =>
      'GPT-3.5 Modelle sind kostengünstiger für einfache Analysen';

  @override
  String get screensSettingsApiKeySettingsGpt4ModelsInfo =>
      'GPT-4 Modelle bieten die beste Analyse, kosten aber mehr';

  @override
  String get screensSettingsApiKeySettingsLinkError =>
      'Beim Öffnen des Links ist ein Fehler aufgetreten';

  @override
  String get screensSettingsApiKeySettingsOpenAiApiKey =>
      'OpenAI API-Schlüssel';

  @override
  String get screensSettingsApiKeySettingsPastedFromClipboard =>
      'Aus Zwischenablage eingefügt';

  @override
  String get screensSettingsApiKeySettingsPasteFromClipboard =>
      'Aus Zwischenablage einfügen';

  @override
  String get screensSettingsApiKeySettingsRemove => 'Entfernen';

  @override
  String get screensSettingsApiKeySettingsRemoveApiKey =>
      'API-Schlüssel entfernen';

  @override
  String get screensSettingsApiKeySettingsShowKey => 'API-Schlüssel anzeigen';

  @override
  String get screensSettingsApiKeySettingsHideKey => 'API-Schlüssel verbergen';

  @override
  String get screensSettingsApiKeySettingsDeleteKey => 'API-Schlüssel löschen';

  @override
  String get screensSettingsApiKeySettingsRemoveApiKeyConfirmation =>
      'Sind Sie sicher, dass Sie Ihren API-Schlüssel entfernen möchten? Dies deaktiviert KI-Funktionen.';

  @override
  String get screensSettingsApiKeySettingsSelectModel => 'Modell auswählen';

  @override
  String get screensSettingsApiKeySettingsTestAndSaveApiKey =>
      'API-Schlüssel testen & speichern';

  @override
  String get screensSettingsApiKeySettingsTestingApiKey =>
      'API-Schlüssel wird getestet...';

  @override
  String get screensSettingsApiKeySettingsUpdateApiKey =>
      'API-Schlüssel aktualisieren';

  @override
  String get screensSettingsApiKeySettingsApiMode => 'API-Modus';

  @override
  String get screensSettingsApiKeySettingsCompatibleApi =>
      'OpenAI-kompatible API';

  @override
  String get screensSettingsApiKeySettingsUsingCustomEndpoint =>
      'Benutzerdefinierter OpenAI-kompatibler API-Endpunkt wird verwendet';

  @override
  String get screensSettingsApiKeySettingsUsingOfficialApi =>
      'Offizielle OpenAI-API wird verwendet';

  @override
  String get screensSettingsApiKeySettingsBaseUrl => 'Basis-URL';

  @override
  String get screensSettingsApiKeySettingsBaseUrlHelper =>
      'Geben Sie die Basis-URL Ihrer OpenAI-kompatiblen API ein';

  @override
  String get screensSettingsApiKeySettingsBaseUrlRequired =>
      'Die Basis-URL ist im Kompatibilitätsmodus erforderlich';

  @override
  String get screensSettingsApiKeySettingsApiKeyGeneric => 'API-Schlüssel';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyHelper =>
      'Geben Sie Ihren API-Schlüssel ein oder lassen Sie das Feld leer, um KI-Funktionen zu deaktivieren';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyRequired =>
      'Im Kompatibilitätsmodus ist ein API-Schlüssel erforderlich';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyTooShort =>
      'Der API-Schlüssel scheint zu kurz zu sein';

  @override
  String get screensSettingsApiKeySettingsModelName => 'Modellname';

  @override
  String get screensSettingsApiKeySettingsModelNameHelper =>
      'Geben Sie den genauen Modellnamen ein, den Ihre API unterstützt';

  @override
  String get screensSettingsApiKeySettingsModelNameRequired =>
      'Im Kompatibilitätsmodus ist ein Modellname erforderlich';

  @override
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchSubtitle =>
      'Erlaube dem Agenten, Deep Search für genauere Antworten zu verwenden';

  @override
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchTitle =>
      'Deep Search aktivieren';

  @override
  String get screensSettingsChatAgentSettingsChatAgentEnableSubtitle =>
      'Verwende die mehrstufige Agenten-Pipeline für den Chat';

  @override
  String get screensSettingsChatAgentSettingsChatAgentEnableTitle =>
      'Agent-Modus aktivieren';

  @override
  String get screensSettingsChatAgentSettingsChatAgentInfoDescription =>
      'Der Agent-Modus aktiviert PlatePals fortschrittliche mehrstufige Denk-Pipeline für den Chat. So kann der Assistent deine Anfrage analysieren, Kontext sammeln und genauere, erklärbare Antworten liefern. Deep Search ermöglicht dem Agenten, noch mehr Daten für bessere Ergebnisse zu nutzen.';

  @override
  String get screensSettingsChatAgentSettingsChatAgentInfoTitle =>
      'Was ist der Agent-Modus?';

  @override
  String get screensSettingsChatAgentSettingsChatAgentSettingsTitle =>
      'Chat-Agent Einstellungen';

  @override
  String get screensSettingsChatAgentSettingsChatSettingsSaved =>
      'Chat-Einstellungen erfolgreich gespeichert';

  @override
  String get screensSettingsChatAgentSettingsSaveFailed =>
      'Chat-Einstellungen konnten nicht gespeichert werden';

  @override
  String get screensSettingsContributorsBuyMeCreatine =>
      'Kaufen Sie mir Kreatin';

  @override
  String get screensSettingsContributorsCheckGitHub =>
      'Schauen Sie sich unser GitHub-Repository an';

  @override
  String screensSettingsContributorsOpenGitHubProfile(String name) {
    return 'GitHub-Profil von $name öffnen';
  }

  @override
  String get screensSettingsContributorsContributorPlural => 'Mitwirkende';

  @override
  String get screensSettingsContributorsContributorSingular => 'Mitwirkender';

  @override
  String get screensSettingsContributorsContributorsThankYou =>
      'Danke an alle, die dazu beigetragen haben, PlatePal Tracker möglich zu machen!';

  @override
  String get screensSettingsContributorsOpenSourceMessage =>
      'PlatePal Tracker ist Open Source - treten Sie uns auf GitHub bei!';

  @override
  String get screensSettingsContributorsSupportDevelopment =>
      'Entwicklung unterstützen';

  @override
  String get screensSettingsContributorsSupportMessage =>
      'Möchten Sie mir mein Kreatin kaufen? Ihre Unterstützung wird sehr geschätzt, ist aber keineswegs verpflichtend.';

  @override
  String get screensSettingsContributorsWantToContribute =>
      'Möchten Sie mitwirken?';

  @override
  String get screensSettingsExportDataAllData => 'Alle Daten';

  @override
  String get screensSettingsExportDataDishes => 'Gerichte';

  @override
  String get screensSettingsExportDataExportAsCsv => 'Als CSV exportieren';

  @override
  String get screensSettingsExportDataExportAsJson => 'Als JSON exportieren';

  @override
  String screensSettingsExportDataExportedItemsCount(int count) {
    return '$count Elemente exportiert';
  }

  @override
  String get screensSettingsExportDataExportProgress =>
      'Daten werden exportiert...';

  @override
  String get screensSettingsExportDataMealLogs => 'Mahlzeiten-Protokolle';

  @override
  String get screensSettingsExportDataNutritionGoalsData => 'Ernährungsziele';

  @override
  String get screensSettingsExportDataSelectDataToExport =>
      'Zu exportierende Daten auswählen';

  @override
  String get screensSettingsExportDataSupplements => 'Nahrungsergänzungsmittel';

  @override
  String get screensSettingsExportDataUserProfiles => 'Benutzerprofile';

  @override
  String get screensSettingsImportDataHowToHandleDuplicates =>
      'Wie sollen Duplikate behandelt werden?';

  @override
  String screensSettingsImportDataImportedItemsCount(int count) {
    return '$count Elemente importiert';
  }

  @override
  String get screensSettingsImportDataImportFailed => 'Import fehlgeschlagen';

  @override
  String get screensSettingsImportDataImportFromFile => 'Aus Datei importieren';

  @override
  String get screensSettingsImportDataImportProgress =>
      'Daten werden importiert...';

  @override
  String get screensSettingsImportDataMergeDuplicates =>
      'Duplikate zusammenführen';

  @override
  String get screensSettingsImportDataOverwriteDuplicates =>
      'Duplikate überschreiben';

  @override
  String get screensSettingsImportDataSelectDataToImport =>
      'Zu importierende Daten auswählen';

  @override
  String get screensSettingsImportDataSelectFile => 'Datei auswählen';

  @override
  String get screensSettingsImportDataSkipDuplicates =>
      'Duplikate überspringen';

  @override
  String get screensSettingsExportDataPreparing =>
      'Deine Daten werden vorbereitet...';

  @override
  String get screensSettingsExportDataPreview => 'Exportvorschau';

  @override
  String screensSettingsExportDataFormatLabel(String format) {
    return 'Format: $format';
  }

  @override
  String screensSettingsExportDataTypesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bereiche',
      one: '1 Bereich',
    );
    return 'Ausgewählte Datenbereiche: $_temp0';
  }

  @override
  String get screensSettingsExportDataReady => 'Bereit zum Exportieren';

  @override
  String get screensSettingsExportDataDishesDescription =>
      'Deine gespeicherten Rezepte und Gerichte';

  @override
  String get screensSettingsExportDataMealLogsDescription =>
      'Deine Mahlzeitenhistorie und Ernährungsprotokolle';

  @override
  String get screensSettingsExportDataUserProfilesDescription =>
      'Benutzerprofil und Einstellungen';

  @override
  String get screensSettingsExportDataIngredientsDescription =>
      'Zutatendatenbank';

  @override
  String get screensSettingsExportDataSupplementsDescription =>
      'Daten zur Erfassung von Nahrungsergänzungsmitteln';

  @override
  String get screensSettingsExportDataFitnessGoalsDescription =>
      'Fitness- und Ernährungsziele';

  @override
  String get screensSettingsExportDataAllDataDescription =>
      'Alle deine Daten exportieren';

  @override
  String get screensSettingsExportDataFormatTitle => 'Exportformat';

  @override
  String get screensSettingsExportDataJsonDescription =>
      'Strukturiertes Format, ideal für Sicherungen';

  @override
  String get screensSettingsExportDataCsvDescription =>
      'Tabellenformat, gut für Auswertungen';

  @override
  String get screensSettingsExportDataError => 'Exportfehler';

  @override
  String get screensSettingsExportDataResults => 'Exportergebnis';

  @override
  String screensSettingsExportDataFileLabel(String fileName) {
    return 'Datei: $fileName';
  }

  @override
  String screensSettingsExportDataLocationLabel(String path) {
    return 'Speicherort: $path';
  }

  @override
  String get screensSettingsExportDataItemsExported => 'Exportierte Einträge:';

  @override
  String get screensSettingsExportDataShare => 'Teilen';

  @override
  String get screensSettingsExportDataShowFileLocation =>
      'Dateispeicherort anzeigen';

  @override
  String get screensSettingsExportDataLocationTitle =>
      'Speicherort des Exports';

  @override
  String get screensSettingsExportDataLocationDescription =>
      'Deine exportierte Datei liegt hier:';

  @override
  String get screensSettingsExportDataNoFileToShare =>
      'Keine Datei zum Teilen vorhanden. Exportiere zuerst deine Daten.';

  @override
  String get screensSettingsExportDataFileNotFound =>
      'Exportdatei nicht gefunden. Exportiere deine Daten erneut.';

  @override
  String screensSettingsExportDataShareFailed(String error) {
    return 'Datei konnte nicht geteilt werden: $error';
  }

  @override
  String screensSettingsExportDataShareText(String fileName) {
    return 'PlatePal-Datenexport - $fileName';
  }

  @override
  String get screensSettingsExportDataShareSubject => 'PlatePal-Datenexport';

  @override
  String screensSettingsExportDataFailedDetail(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get screensSettingsExportDataSectionFailed =>
      'Die ausgewählten Daten konnten nicht exportiert werden. Es wurde keine Datei erstellt. Bitte versuche es erneut.';

  @override
  String get screensSettingsExportDataWriteFailed =>
      'Die Exportdatei konnte nicht gespeichert werden. Bitte versuche es erneut.';

  @override
  String get screensSettingsExportDataShareProblem =>
      'Die Datei konnte nicht geteilt werden. Bitte versuche es erneut.';

  @override
  String get screensSettingsImportDataRestoring =>
      'Sicherung wird wiederhergestellt...';

  @override
  String screensSettingsImportDataProcessingItems(int current, int total) {
    return '$current von $total Einträgen werden verarbeitet';
  }

  @override
  String screensSettingsImportDataCurrentType(String type) {
    return 'Aktuell: $type';
  }

  @override
  String get screensSettingsImportDataUndoing =>
      'Letzter Import wird rückgängig gemacht...';

  @override
  String get screensSettingsImportDataFileSelection => 'Dateiauswahl';

  @override
  String get screensSettingsImportDataRemoveFile =>
      'Ausgewählte Datei entfernen';

  @override
  String get screensSettingsImportDataChangeFile => 'Datei wechseln';

  @override
  String get screensSettingsImportDataSupportedFormats =>
      'Unterstützte Formate: JSON, CSV, ZIP (vollständiges Backup)';

  @override
  String get screensSettingsImportDataAllDataDescription =>
      'Alles aus der Datei importieren';

  @override
  String get screensSettingsImportDataSkipDescription =>
      'Vorhandene Daten behalten; importierte Duplikate überspringen';

  @override
  String get screensSettingsImportDataOverwriteDescription =>
      'Vorhandene Daten durch importierte Daten ersetzen';

  @override
  String get screensSettingsImportDataAdvancedOptions => 'Erweiterte Optionen';

  @override
  String get screensSettingsImportDataValidateBeforeImport =>
      'Daten vor dem Import prüfen';

  @override
  String get screensSettingsImportDataValidateDescription =>
      'Datenintegrität prüfen und Warnungen anzeigen';

  @override
  String get screensSettingsImportDataBackupBeforeImport =>
      'Sicherung vor dem Import erstellen';

  @override
  String get screensSettingsImportDataBackupDescription =>
      'Vorhandene Daten automatisch sichern';

  @override
  String get screensSettingsImportDataIssues => 'Importprobleme';

  @override
  String get screensSettingsImportDataDetailedErrors => 'Fehler im Detail:';

  @override
  String get screensSettingsImportDataTechnicalDetails =>
      'Datei- und Zeilendetails (möglicherweise auf Englisch):';

  @override
  String get screensSettingsImportDataResults => 'Importergebnis';

  @override
  String get screensSettingsImportDataPartialResults =>
      'Import mit übersprungenen Einträgen abgeschlossen';

  @override
  String screensSettingsImportDataImportedSkipped(int imported, int skipped) {
    return 'Importiert: $imported, übersprungen: $skipped';
  }

  @override
  String get screensSettingsImportDataShowReasons => 'Gründe anzeigen';

  @override
  String screensSettingsImportDataMoreReasons(int count) {
    return '…und $count weitere';
  }

  @override
  String screensSettingsImportDataFailedSection(String section) {
    return 'Fehlgeschlagener Bereich: $section';
  }

  @override
  String get screensSettingsImportDataConfirmTitle => 'Import bestätigen';

  @override
  String get screensSettingsImportDataSelectedSections =>
      'Ausgewählte Bereiche:';

  @override
  String screensSettingsImportDataDuplicatesLabel(String strategy) {
    return 'Duplikate: $strategy';
  }

  @override
  String get screensSettingsImportDataConfirmAction => 'Importieren';

  @override
  String get screensSettingsImportDataBackupFailedTitle =>
      'Sicherung fehlgeschlagen';

  @override
  String get screensSettingsImportDataBackupFailedDescription =>
      'Die automatische Sicherung konnte nicht erstellt werden. Import ohne Sicherung fortsetzen?';

  @override
  String get screensSettingsImportDataContinueWithoutBackup =>
      'Ohne Sicherung fortfahren';

  @override
  String screensSettingsImportDataFileSelectionFailed(String error) {
    return 'Fehler bei der Dateiauswahl: $error';
  }

  @override
  String screensSettingsImportDataCompletedWithErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import mit $count Fehlern abgeschlossen',
      one: 'Import mit 1 Fehler abgeschlossen',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataFailedDetail(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get screensSettingsImportDataBackupAvailable => 'Sicherung verfügbar';

  @override
  String get screensSettingsImportDataBackupAvailableDescription =>
      'Eine Sicherung deines letzten Imports ist verfügbar.';

  @override
  String screensSettingsImportDataBackupCreated(String date) {
    return 'Erstellt: $date';
  }

  @override
  String screensSettingsImportDataBackupSize(String size) {
    return 'Größe: $size KB';
  }

  @override
  String get screensSettingsImportDataUndoLastImport =>
      'Letzten Import rückgängig machen';

  @override
  String screensSettingsImportDataMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get screensSettingsImportDataRestoreTitle =>
      'Aus Sicherung wiederherstellen';

  @override
  String get screensSettingsImportDataRestoreWarning =>
      'Deine Daten werden auf den Stand vor dem letzten Import zurückgesetzt. Alle Änderungen seitdem gehen verloren. Bist du sicher?';

  @override
  String get screensSettingsImportDataRestoreAction => 'Wiederherstellen';

  @override
  String get screensSettingsImportDataRestoreSuccess =>
      'Sicherung erfolgreich wiederhergestellt!';

  @override
  String screensSettingsImportDataRestoreFailedDetail(String error) {
    return 'Wiederherstellung fehlgeschlagen: $error';
  }

  @override
  String get screensSettingsImportDataFileMissing =>
      'Importdatei nicht gefunden. Wähle sie erneut aus.';

  @override
  String screensSettingsImportDataFileTooLarge(int maxSize) {
    return 'Die Datei ist zu groß. Wähle eine Datei mit höchstens $maxSize MB.';
  }

  @override
  String get screensSettingsImportDataInvalidJson =>
      'Die Datei enthält kein gültiges JSON. Prüfe sie und versuche es erneut.';

  @override
  String get screensSettingsImportDataUnsupportedFormat =>
      'Nicht unterstütztes Dateiformat. Wähle eine JSON-, CSV- oder ZIP-Datei.';

  @override
  String get screensSettingsImportDataInvalidData =>
      'Die Datei enthält ungültige Daten. Prüfe die Details und versuche es erneut.';

  @override
  String get screensSettingsImportDataFileSelectionProblem =>
      'Datei konnte nicht ausgewählt werden. Bitte versuche es erneut.';

  @override
  String get screensSettingsImportDataBackupMissing =>
      'Keine Sicherung zur Wiederherstellung gefunden.';

  @override
  String get screensSettingsImportDataBackupUnreadable =>
      'Die Sicherung konnte nicht gelesen werden. Es wurde nichts geändert.';

  @override
  String get screensSettingsImportDataSnapshotFailed =>
      'Deine aktuellen Daten konnten nicht gesichert werden. Es wurde nichts geändert.';

  @override
  String get screensSettingsImportDataRestoreProblem =>
      'Die Sicherung konnte nicht wiederhergestellt werden. Prüfe deine Daten vor einem erneuten Versuch.';

  @override
  String get screensSettingsImportDataRestoreRolledBack =>
      'Die Wiederherstellung ist fehlgeschlagen, aber deine bisherigen Daten blieben unverändert.';

  @override
  String screensSettingsImportDataRestoreCopySaved(String path) {
    return 'Wiederherstellung fehlgeschlagen; deine bisherigen Daten könnten unvollständig sein. Eine Sicherungskopie liegt unter $path.';
  }

  @override
  String get screensSettingsImportProfileCompletionActivityLevel =>
      'Aktivitätslevel';

  @override
  String get screensSettingsImportProfileCompletionAge => 'Alter';

  @override
  String get screensSettingsImportProfileCompletionAgeRange =>
      'Das Alter muss zwischen 13 und 120 liegen';

  @override
  String get screensSettingsImportProfileCompletionBuildMuscle =>
      'Muskeln aufbauen';

  @override
  String get screensSettingsImportProfileCompletionExtraActive =>
      'Extrem aktiv';

  @override
  String get screensSettingsImportProfileCompletionFemale => 'Weiblich';

  @override
  String get screensSettingsImportProfileCompletionFitnessGoal => 'Fitnessziel';

  @override
  String get screensSettingsImportProfileCompletionGainWeight =>
      'Gewicht zunehmen';

  @override
  String get screensSettingsImportProfileCompletionGender => 'Geschlecht';

  @override
  String get screensSettingsImportProfileCompletionHeight => 'Größe';

  @override
  String get screensSettingsImportProfileCompletionHeightRange =>
      'Die Größe muss zwischen 100-250 cm liegen';

  @override
  String get screensSettingsImportProfileCompletionImperial =>
      'Imperial (lb, ft)';

  @override
  String get screensSettingsImportProfileCompletionLightlyActive =>
      'Leicht aktiv';

  @override
  String get screensSettingsImportProfileCompletionLoseWeight =>
      'Gewicht verlieren';

  @override
  String get screensSettingsImportProfileCompletionMaintainWeight =>
      'Gewicht halten';

  @override
  String get screensSettingsImportProfileCompletionMale => 'Männlich';

  @override
  String get screensSettingsImportProfileCompletionMetric =>
      'Metrisch (kg, cm)';

  @override
  String get screensSettingsImportProfileCompletionModeratelyActive =>
      'Mäßig aktiv';

  @override
  String get screensSettingsImportProfileCompletionName => 'Name';

  @override
  String get screensSettingsImportProfileCompletionOther => 'Andere';

  @override
  String get screensSettingsImportProfileCompletionPersonalInformation =>
      'Persönliche Informationen';

  @override
  String get screensSettingsImportProfileCompletionPreferences =>
      'Einstellungen';

  @override
  String get screensSettingsImportProfileCompletionSedentary => 'Sesshaft';

  @override
  String get screensSettingsImportProfileCompletionUnitSystem =>
      'Einheitensystem';

  @override
  String get screensSettingsImportProfileCompletionVeryActive => 'Sehr aktiv';

  @override
  String get screensSettingsImportProfileCompletionWeight => 'Gewicht';

  @override
  String get screensSettingsImportProfileCompletionWeightRange =>
      'Das Gewicht muss zwischen 30-300 kg liegen';

  @override
  String get screensSettingsMacroCustomizationDiscardChanges =>
      'Änderungen verwerfen';

  @override
  String get screensSettingsMacroCustomizationMacroCustomization =>
      'Makro-Anpassung';

  @override
  String get screensSettingsMacroCustomizationMacroCustomizationInfo =>
      'Passen Sie Ihre Makro-Ziele an. Alle Prozentsätze müssen sich zu 100% addieren.';

  @override
  String get screensSettingsMacroCustomizationMacroTargetsUpdated =>
      'Makro-Ziele erfolgreich aktualisiert';

  @override
  String get screensSettingsMacroCustomizationResetToDefaults =>
      'Auf Standard zurücksetzen';

  @override
  String get screensSettingsMacroCustomizationSaveChanges =>
      'Änderungen speichern';

  @override
  String get screensSettingsMacroCustomizationUnsavedChanges =>
      'Nicht gespeicherte Änderungen';

  @override
  String get screensSettingsMacroCustomizationUnsavedChangesMessage =>
      'Sie haben nicht gespeicherte Änderungen. Möchten Sie sie vor dem Verlassen speichern?';

  @override
  String get screensSettingsProfileSettingsAnalyzeTargets =>
      'Ziele analysieren';

  @override
  String get screensSettingsProfileSettingsBmi => 'BMI';

  @override
  String get screensSettingsProfileSettingsConnectToHealth =>
      'Mit Gesundheitsdaten verbinden';

  @override
  String get screensSettingsProfileSettingsDangerZone => 'Gefahrenzone';

  @override
  String get screensSettingsProfileSettingsDebugHealthData =>
      'Gesundheitsdaten debuggen';

  @override
  String get screensSettingsProfileSettingsDisconnectHealth =>
      'Gesundheit trennen';

  @override
  String get screensSettingsProfileSettingsFitnessGoals => 'Fitnessziele';

  @override
  String get screensSettingsProfileSettingsHealthConnected =>
      'Gesundheitsdaten verbunden';

  @override
  String get screensSettingsProfileSettingsHealthDataSync =>
      'Gesundheitsdaten-Synchronisation';

  @override
  String get screensSettingsProfileSettingsHealthDisconnected =>
      'Gesundheitsdaten nicht verbunden';

  @override
  String get screensSettingsProfileSettingsHealthNotAvailable =>
      'Gesundheitsdaten Nicht Verfügbar';

  @override
  String get screensSettingsProfileSettingsHealthNotAvailableMessage =>
      'Gesundheitsdaten sind auf diesem Gerät nicht verfügbar. Stelle sicher, dass du Health Connect (Android) oder die Health-App (iOS) installiert und konfiguriert hast.';

  @override
  String get screensSettingsProfileSettingsHealthPermissionDenied =>
      'Gesundheitsberechtigung Verweigert';

  @override
  String get screensSettingsProfileSettingsHealthPermissionDeniedMessage =>
      'Um deine Gesundheitsdaten zu synchronisieren, benötigt PlatePal Zugriff auf deine Gesundheitsinformationen. Du kannst Berechtigungen in den Einstellungen deines Telefons erteilen.';

  @override
  String get screensSettingsProfileSettingsHealthSyncFailed =>
      'Synchronisation der Gesundheitsdaten fehlgeschlagen';

  @override
  String get screensSettingsProfileSettingsHealthSyncSuccess =>
      'Gesundheitsdaten erfolgreich synchronisiert';

  @override
  String get screensSettingsProfileSettingsProfileSettings =>
      'Profil-Einstellungen';

  @override
  String get screensSettingsProfileSettingsProfileUpdated =>
      'Profil erfolgreich aktualisiert';

  @override
  String get screensSettingsProfileSettingsResetApp => 'App Zurücksetzen';

  @override
  String get screensSettingsProfileSettingsResetAppCancel => 'Abbrechen';

  @override
  String get screensSettingsProfileSettingsResetAppConfirm =>
      'Ja, Alles Löschen';

  @override
  String get screensSettingsProfileSettingsResetAppDescription =>
      'Dies wird ALLE Ihre Daten dauerhaft löschen, einschließlich:\n\n• Ihre Profilinformationen\n• Alle Mahlzeitenprotokolle und Ernährungsdaten\n• Alle Einstellungen und Präferenzen\n• Alle gespeicherten Informationen\n\nDiese Aktion kann nicht rückgängig gemacht werden. Sind Sie sicher, dass Sie fortfahren möchten?';

  @override
  String get screensSettingsProfileSettingsResetAppError =>
      'Fehler beim Zurücksetzen der Anwendungsdaten';

  @override
  String get screensSettingsProfileSettingsResetAppSuccess =>
      'Anwendungsdaten wurden erfolgreich zurückgesetzt';

  @override
  String get screensSettingsProfileSettingsResetAppTitle =>
      'Anwendungsdaten Zurücksetzen';

  @override
  String get screensSettingsProfileSettingsSyncHealthData =>
      'Gesundheitsdaten synchronisieren';

  @override
  String get screensSettingsProfileSettingsTargetWeight => 'Zielgewicht';

  @override
  String get screensSettingsStatisticsAllTime => 'Alle Zeit';

  @override
  String get screensSettingsStatisticsBmiHistory => 'BMI-Verlauf';

  @override
  String get screensSettingsStatisticsBmiNormal => 'Normal';

  @override
  String get screensSettingsStatisticsBmiObese => 'Adipös';

  @override
  String get screensSettingsStatisticsBmiOverweight => 'Übergewicht';

  @override
  String get screensSettingsStatisticsBmiStatsTip =>
      'Der Body Mass Index (BMI) wird aus Ihren Gewichts- und Größenmessungen berechnet.';

  @override
  String get screensSettingsStatisticsBmiUnderweight => 'Untergewicht';

  @override
  String get screensSettingsStatisticsBodyFat => 'Körperfett';

  @override
  String get screensSettingsStatisticsBodyFatHistory => 'Körperfett-Verlauf';

  @override
  String get screensSettingsStatisticsBodyFatStatsTip =>
      'Der Körperfettanteil hilft dabei, Ihre Körperzusammensetzung über das Gewicht hinaus zu verfolgen.';

  @override
  String get screensSettingsStatisticsBulking => 'Aufbau';

  @override
  String get screensSettingsStatisticsCalorieBalanceTip =>
      'Verfolgen Sie Ihre tatsächliche Kalorienbilanz mit Gesundheitsdaten. Grün = Erhaltung, Blau = Defizit, Orange = Überschuss.';

  @override
  String get screensSettingsStatisticsCalorieBalanceTitle =>
      'Kalorienbilanz (Aufnahme vs. Verbrauch)';

  @override
  String get screensSettingsStatisticsCalorieIntakeHistory =>
      'Kalorienaufnahme vs. Erhaltung';

  @override
  String get screensSettingsStatisticsCalorieStatsTip =>
      'Vergleichen Sie Ihre tägliche Kalorienaufnahme mit Ihren Erhaltungskalorien. Grün zeigt Erhaltung, Blau ist Definitionsphase, Orange ist Aufbauphase.';

  @override
  String get screensSettingsStatisticsCannotCalculateBmiFromData =>
      'BMI kann aus verfügbaren Daten nicht berechnet werden';

  @override
  String get screensSettingsStatisticsCutting => 'Definition';

  @override
  String get screensSettingsStatisticsErrorLoadingData =>
      'Fehler beim Laden der Daten';

  @override
  String get screensSettingsStatisticsLoadFailedHint =>
      'Die Statistik konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get screensSettingsStatisticsEstimatedBalance => 'Geschätzte Bilanz';

  @override
  String get screensSettingsStatisticsExtremeDeficitWarning =>
      'Warnung: Häufige extreme Kaloriendefizite können den Stoffwechsel verlangsamen und Muskelverlust verursachen.';

  @override
  String get screensSettingsStatisticsGenerateTestData =>
      'Testdaten Generieren';

  @override
  String get screensSettingsStatisticsHealthDataActive =>
      'Ihre Gesundheits-App-Daten werden für eine genauere Defizit-/Überschussanalyse verwendet.';

  @override
  String screensSettingsStatisticsHealthDataAlert(String days) {
    return 'Gesundheitsdaten-Warnung: $days Tag(e) mit sehr großen Kaloriendefiziten (>1000 kcal) basierend auf dem tatsächlichen Verbrauch.';
  }

  @override
  String get screensSettingsStatisticsHealthDataInactive =>
      'Aktivieren Sie die Gesundheitsdatensynchronisation in den Profileinstellungen für eine genauere Analyse.';

  @override
  String get screensSettingsStatisticsHealthDataIntegration =>
      'Gesundheitsdaten-Integration';

  @override
  String screensSettingsStatisticsInconsistentDeficitWarning(String variance) {
    return 'Warnung: Ihr Kaloriendefizit variiert erheblich von Tag zu Tag (Varianz: $variance kcal). Erwägen Sie eine konsistentere Aufnahme.';
  }

  @override
  String get screensSettingsStatisticsLastMonth => 'Letzter Monat';

  @override
  String get screensSettingsStatisticsLastSixMonths => 'Letzte 6 Monate';

  @override
  String get screensSettingsStatisticsLastThreeMonths => 'Letzte 3 Monate';

  @override
  String get screensSettingsStatisticsLastWeek => 'Letzte Woche';

  @override
  String get screensSettingsStatisticsLastYear => 'Letztes Jahr';

  @override
  String get screensSettingsStatisticsMaintenance => 'Erhaltung';

  @override
  String get screensSettingsStatisticsNoBmiDataAvailable =>
      'Keine BMI-Daten verfügbar';

  @override
  String get screensSettingsStatisticsNoBodyFatDataAvailable =>
      'Keine Körperfettdaten verfügbar';

  @override
  String get screensSettingsStatisticsNoCalorieDataAvailable =>
      'Keine Kaloriendaten verfügbar';

  @override
  String get screensSettingsStatisticsNotEnoughDataTitle =>
      'Nicht genügend Daten';

  @override
  String get screensSettingsStatisticsNoWeightDataAvailable =>
      'Keine Gewichtsdaten verfügbar';

  @override
  String get screensSettingsStatisticsPhaseAnalysis => 'Phasenanalyse';

  @override
  String get screensSettingsStatisticsRealData => 'Echte Daten';

  @override
  String get screensSettingsStatisticsRefresh => 'Aktualisieren';

  @override
  String get screensSettingsStatisticsStatistics => 'Statistiken';

  @override
  String get screensSettingsStatisticsStatisticsEmptyDescription =>
      'Wir benötigen mindestens eine Woche Daten, um aussagekräftige Statistiken zu zeigen. Verfolgen Sie weiter Ihre Messwerte, um Trends über die Zeit zu sehen.';

  @override
  String get screensSettingsStatisticsTestDataDescription =>
      'Zu Demonstrationszwecken können Sie Beispieldaten generieren, um zu sehen, wie die Statistiken aussehen.';

  @override
  String get screensSettingsStatisticsTimeRange => 'Zeitbereich';

  @override
  String get screensSettingsStatisticsTryAgain => 'Erneut versuchen';

  @override
  String get screensSettingsStatisticsUpdateMetricsNow =>
      'Messwerte jetzt aktualisieren';

  @override
  String screensSettingsStatisticsVeryHighCalorieNotice(String days) {
    return 'Hinweis: $days Tag(e) mit sehr hoher Kalorienaufnahme (>1000 kcal über dem Erhaltungsbedarf).';
  }

  @override
  String screensSettingsStatisticsVeryLowCalorieWarning(String days) {
    return 'Warnung: $days Tag(e) mit extrem niedriger Kalorienaufnahme (<1000 kcal). Dies kann ungesund sein.';
  }

  @override
  String get screensSettingsStatisticsVsExpenditure => 'vs. Verbrauch';

  @override
  String get screensSettingsStatisticsWeeklyAverage =>
      'Wöchentlicher Durchschnitt';

  @override
  String get screensSettingsStatisticsWeightHistory => 'Gewichtsverlauf';

  @override
  String get screensSettingsStatisticsWeightStatsTip =>
      'Das Diagramm zeigt das wöchentliche Mediangewicht, um tägliche Schwankungen durch Wassergewicht zu berücksichtigen.';

  @override
  String get utilsLinkHandlerAvailable => 'Verfügbar';

  @override
  String utilsLinkHandlerCouldNotOpenUrl(String url) {
    return 'Konnte $url nicht öffnen';
  }

  @override
  String get utilsLinkHandlerNotAvailable => 'Nicht verfügbar';

  @override
  String get utilsLinkHandlerOpeningLink => 'Öffne Buy Me Creatine Seite...';

  @override
  String get screensSettingsIndustrialSystemInfo => 'SYSTEM INFO //';

  @override
  String get screensSettingsIndustrialProjectSchematics => 'PROJEKT-SCHEMATA';

  @override
  String get screensSettingsIndustrialCoreDirectives => 'KERN_RICHTLINIEN';

  @override
  String get screensSettingsIndustrialNetworkLinks => 'NETZWERK_LINKS';

  @override
  String get screensSettingsIndustrialNetworkOperatives => 'NETZWERK-AGENTEN';

  @override
  String get screensSettingsIndustrialSourceRepository => 'QUELL-REPOSITORY';

  @override
  String get screensSettingsIndustrialOfficialDomain => 'OFFIZIELLE DOMÄNE';

  @override
  String get screensSettingsIndustrialWantToContribute =>
      'MÖCHTEST DU BEITRAGEN?';

  @override
  String get screensSettingsIndustrialSourceCode => 'QUELLCODE';

  @override
  String screensSettingsIndustrialStableBuild(Object version) {
    return 'STABILER_BUILD_$version';
  }

  @override
  String get screensSettingsContributorsHansRole =>
      'KI-Copilot & Hacker vor Ort';

  @override
  String get screensSettingsContributorsHansDesc =>
      'Automatisiert den Grind und hält die Telemetrie scharf. Cyber-Minimalismus-Architekt.';

  @override
  String get screensSettingsContributorsMrLappesRole => 'Schöpfer & Entwickler';

  @override
  String get screensSettingsContributorsMrLappesDesc =>
      'Hat PlatePal Tracker mit der Vision geschaffen, eine kostenlose, datenschutzorientierte Ernährungs-App für alle zu entwickeln.';

  @override
  String get screensSettingsHealthSettingsTitle => 'HEALTH CONNECT //';

  @override
  String get screensSettingsHealthSettingsConnected => 'Verbunden';

  @override
  String get screensSettingsHealthSettingsNotConnected => 'Nicht verbunden';

  @override
  String screensSettingsHealthSettingsLastSynced(String time) {
    return 'Zuletzt synchronisiert: $time';
  }

  @override
  String get screensSettingsHealthSettingsNotAvailableOnDevice =>
      'Health Connect ist auf diesem Gerät nicht verfügbar.';

  @override
  String get screensSettingsHealthSettingsDisconnectTitle => 'Health trennen';

  @override
  String get screensSettingsHealthSettingsDisconnectMessage =>
      'Dadurch wird die Synchronisierung der verbrannten Kalorien von Health Connect beendet und keine Mahlzeitdaten mehr geschrieben. Ihre bestehenden Daten bleiben erhalten.';

  @override
  String get screensSettingsHealthSettingsDisconnect => 'Trennen';

  @override
  String get screensSettingsHealthSettingsDataOverview => 'DATENÜBERSICHT';

  @override
  String get screensSettingsHealthSettingsTodaysBurned => 'Heute verbrannt';

  @override
  String get screensSettingsHealthSettingsNoDataYet => 'Noch keine Daten';

  @override
  String screensSettingsHealthSettingsDaysCached(int count) {
    return '$count Tage an Daten zwischengespeichert';
  }

  @override
  String get screensSettingsHealthSettingsSyncControls => 'SYNC-STEUERUNG';

  @override
  String get screensSettingsHealthSettingsSyncDescription =>
      'Ruft die neuesten Daten zu verbrannten Kalorien aus Health Connect der letzten 7 Tage ab.';

  @override
  String get screensSettingsHealthSettingsOpenHealthConnect =>
      'Health Connect öffnen';

  @override
  String get screensSettingsHealthSettingsWriteBehavior => 'SCHREIBVERHALTEN';

  @override
  String get screensSettingsHealthSettingsWriteMeals =>
      'Mahlzeiten in Health Connect schreiben';

  @override
  String get screensSettingsHealthSettingsWriteMealsDescription =>
      'Ernährungsdaten automatisch beim Speichern einer Mahlzeit protokollieren';

  @override
  String get screensSettingsHealthSettingsTargetAnalysis => 'ZIELANALYSE';

  @override
  String get screensSettingsHealthSettingsTargetAnalysisDescription =>
      'Vergleichen Sie Ihren Kalorienverbrauch aus Health Connect mit Ihren aktuellen Kalorienzielen, um festzustellen, ob Anpassungen erforderlich sind.';

  @override
  String get screensSettingsHealthSettingsCurrentTarget => 'Aktuelles Ziel';

  @override
  String get screensSettingsHealthSettingsAvgExpenditure =>
      'Durchschn. Verbrauch';

  @override
  String get screensSettingsHealthSettingsSuggestedTarget =>
      'Vorgeschlagenes Ziel';

  @override
  String get screensSettingsHealthSettingsDaysAnalyzed => 'Analysierte Tage';

  @override
  String get screensSettingsHealthSettingsApply => 'Anwenden';

  @override
  String screensSettingsHealthSettingsCalorieTargetUpdated(String target) {
    return 'Kalorienziel auf $target kcal aktualisiert';
  }

  @override
  String get screensSettingsHealthSettingsCalorieTargetUpdateFailed =>
      'Kalorienziel konnte nicht aktualisiert werden';

  @override
  String screensSettingsHealthSettingsAnalysisFailed(String error) {
    return 'Analyse fehlgeschlagen: $error';
  }

  @override
  String get screensSettingsHealthSettingsAboutHealthConnect =>
      'ÜBER HEALTH CONNECT';

  @override
  String get screensSettingsHealthSettingsAboutDescription =>
      'Verbinden Sie PlatePal mit Health Connect (Google Fit) um:';

  @override
  String get screensSettingsHealthSettingsFeatureReadCalories =>
      'Tatsächlich verbrannte Kalorien aus Fitness-Tracking lesen';

  @override
  String get screensSettingsHealthSettingsFeatureWriteMeals =>
      'Ernährungsdaten automatisch in Health Connect schreiben';

  @override
  String get screensSettingsHealthSettingsFeatureNetBalance =>
      'Genaue Netto-Kalorienbilanz sehen (aufgenommen vs. verbrannt)';

  @override
  String get screensSettingsHealthSettingsFeatureRecommendations =>
      'Kalorienziel-Empfehlungen basierend auf tatsächlichem Verbrauch erhalten';

  @override
  String get screensSettingsHealthSettingsAboutNote =>
      'Wenn verbunden, wird Health Connect zur einzigen Quelle der Wahrheit für verbrannte Kalorien — keine geschätzten Werte.';

  @override
  String get screensSettingsHealthSettingsJustNow => 'Gerade eben';

  @override
  String screensSettingsHealthSettingsMinutesAgo(int minutes) {
    return 'vor $minutes Min.';
  }

  @override
  String screensSettingsHealthSettingsHoursAgo(int hours) {
    return 'vor $hours Std.';
  }

  @override
  String screensSettingsHealthSettingsDaysAgo(int days) {
    return 'vor $days T.';
  }

  @override
  String get screensMenuHealthAndFitness => 'Gesundheit & Fitness';

  @override
  String get screensMenuHealthConnect => 'HEALTH CONNECT';

  @override
  String get screensMenuHealthConnectedSubtitle =>
      'Verbunden — synchronisiert mit Google Fit';

  @override
  String get screensMenuHealthDisconnectedSubtitle =>
      'Mit Google Fit & Health Connect synchronisieren';

  @override
  String componentsCalendarMacroSummaryBurned(String calories) {
    return '$calories verbrannt';
  }

  @override
  String componentsCalendarMacroSummaryNetCalories(String value) {
    return 'Netto: $value';
  }

  @override
  String get componentsCalendarMacroSummaryNoBurnData =>
      'Keine Verbrauchsdaten für diesen Tag';

  @override
  String get screensCalendarHealthDeleteWarning =>
      'Der Ernährungseintrag in Health Connect wird nicht entfernt. Sie können ihn manuell in der Health Connect App löschen.';

  @override
  String get screensSettingsProfileSettingsManageHealthConnect =>
      'Health Connect verwalten';

  @override
  String screensSettingsProfileSettingsLastSynced(String time) {
    return 'Zuletzt synchronisiert: $time';
  }

  @override
  String get servicesChatAgentFallbackParsing =>
      'Entschuldigung, ich habe Probleme, deine Anfrage zu verarbeiten. Könntest du sie bitte umformulieren?';

  @override
  String get servicesChatAgentFallbackCritical =>
      'Ich erlebe gerade technische Schwierigkeiten. Bitte versuche es in einem Moment erneut.';

  @override
  String get servicesChatAgentFallbackNetwork =>
      'Ich habe Verbindungsprobleme. Bitte überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get servicesChatAgentFallbackContext =>
      'Deine Anfrage enthält sehr viele Informationen. Könntest du sie in kleinere Fragen aufteilen?';

  @override
  String get servicesChatAgentFallbackGeneric =>
      'Entschuldigung, ein unerwartetes Problem ist aufgetreten. Bitte versuche es erneut.';

  @override
  String get servicesChatAgentFallbackGenerateResponse =>
      'Entschuldigung, beim Generieren einer Antwort ist ein Problem aufgetreten. Bitte versuche es erneut.';

  @override
  String get servicesChatAgentFallbackTemporaryIssue =>
      'Es ist ein vorübergehendes Problem aufgetreten. Bitte versuche es erneut.';

  @override
  String get servicesChatAgentFallbackRephrase =>
      'Entschuldigung, ich habe Schwierigkeiten mit dieser Anfrage. Könntest du sie umformulieren?';

  @override
  String get servicesChatAgentFallbackDishInfo =>
      'Hier sind die Gerichte-Informationen:';

  @override
  String get servicesChatAgentFallbackNoResponse =>
      'Kein Antworttext gefunden.';

  @override
  String get servicesChatAgentFallbackFormatting =>
      'Meine Antwort konnte nicht verarbeitet werden. Bitte versuche es erneut.';

  @override
  String get screensDishCreateImage => 'Bild';

  @override
  String get screensDishCreateNoImageSelected => 'Kein Bild ausgewählt';

  @override
  String get screensDishCreateChangeImage => 'Bild ändern';

  @override
  String get screensDishCreateAddImage => 'Bild hinzufügen';

  @override
  String get screensDishCreateConfirmDiscardChanges =>
      'Ungespeicherte Änderungen verwerfen?';

  @override
  String get screensDishCreateProteinAbbreviation => 'E';

  @override
  String get screensDishCreateCarbsAbbreviation => 'K';

  @override
  String get screensDishCreateFatAbbreviation => 'F';

  @override
  String get componentsDishesDishFormIngredientFormModalUnit => 'Einheit';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPerPiece =>
      'Nährwerte pro Stück';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPerSlice =>
      'Nährwerte pro Scheibe';

  @override
  String
  get componentsDishesDishFormIngredientFormModalProductInformationLoaded =>
      'Produktinformationen geladen. Menge anpassen und speichern.';

  @override
  String
  get componentsDishesDishFormSmartNutritionCardRecalculateFromIngredients =>
      'Aus Zutaten neu berechnen';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighProtein =>
      'Proteinreich';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighCarb =>
      'Kohlenhydratreich';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighFat => 'Fettreich';

  @override
  String get componentsDishesDishFormSmartNutritionCardWellBalanced =>
      'Ausgewogen';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighProteinFeedback =>
      'Ausgezeichnet! Der hohe Proteingehalt unterstützt Muskelaufbau und Sättigung.';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighCarbFeedback =>
      'Gute Energiequelle! Ideal vor dem Training oder an aktiven Tagen.';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighFatFeedback =>
      'Hoher Fettgehalt. In Maßen genießen und mit ausgewogenen Mahlzeiten ergänzen.';

  @override
  String get componentsDishesDishFormSmartNutritionCardBalancedFeedback =>
      'Gut ausgewogen! Dieses Gericht bietet eine vielseitige Nährstoffkombination.';

  @override
  String get componentsDishesDishFormSmartNutritionCardUnbalancedFeedback =>
      'Nährwerte eingeben, um die Analyse und Empfehlungen zu sehen.';

  @override
  String get screensSettingsProfileSettingsPhysicalStats => 'Körperdaten';

  @override
  String get screensSettingsProfileSettingsBodyFatOptional =>
      'Körperfett % (optional)';

  @override
  String get screensSettingsProfileSettingsOptional => 'Optional';

  @override
  String get screensSettingsProfileSettingsNameHint => 'Namen eingeben';

  @override
  String get screensSettingsProfileSettingsCustomizeMacroRatios =>
      'Makronährstoffverteilung anpassen';

  @override
  String get screensSettingsProfileSettingsImperialHeightRange =>
      'Die Größe muss zwischen 39 und 98 Zoll liegen';

  @override
  String get screensSettingsProfileSettingsImperialWeightRange =>
      'Das Gewicht muss zwischen 66 und 660 lb liegen';

  @override
  String get screensSettingsProfileSettingsValidNumber =>
      'Bitte eine gültige Zahl eingeben';

  @override
  String get screensSettingsProfileSettingsBodyFatRange =>
      'Der Körperfettanteil muss zwischen 3 % und 50 % liegen';

  @override
  String get screensSettingsProfileSettingsBaseMetabolicRate => 'Grundumsatz';

  @override
  String get screensSettingsProfileSettingsTotalDailyEnergy =>
      'Täglicher Gesamtenergiebedarf';

  @override
  String get screensSettingsProfileSettingsResettingAppData =>
      'App-Daten werden zurückgesetzt...';

  @override
  String screensSettingsProfileSettingsLoadFailed(String error) {
    return 'Profildaten konnten nicht geladen werden: $error';
  }

  @override
  String screensSettingsProfileSettingsUpdateFailed(String error) {
    return 'Profil konnte nicht aktualisiert werden: $error';
  }

  @override
  String screensSettingsMacroCustomizationDailyCalories(String calories) {
    return 'Tägliche Kalorien: $calories kcal';
  }

  @override
  String get screensSettingsMacroCustomizationMacroRatios =>
      'Makronährstoffverteilung';

  @override
  String get screensSettingsMacroCustomizationFiberTarget => 'Ballaststoffziel';

  @override
  String get screensSettingsMacroCustomizationTargetPreview => 'Zielvorschau';

  @override
  String get screensSettingsMacroCustomizationQuickPresets => 'Schnellvorlagen';

  @override
  String screensSettingsMacroCustomizationTotalRatio(String value) {
    return 'Gesamt: $value %';
  }

  @override
  String screensSettingsMacroCustomizationPinMacro(String macro) {
    return '$macro fixieren';
  }

  @override
  String screensSettingsMacroCustomizationUnpinMacro(String macro) {
    return 'Fixierung aufheben: $macro';
  }

  @override
  String get screensSettingsMacroCustomizationPinnedValue =>
      'Fixiert: Wert gesperrt';

  @override
  String get screensSettingsMacroCustomizationTooManyPins =>
      'Keine Anpassung möglich: zu viele Werte fixiert';

  @override
  String screensSettingsMacroCustomizationFiberTotal(String grams) {
    return 'Insgesamt $grams g';
  }

  @override
  String screensSettingsMacroCustomizationFiberPer1000Calories(String grams) {
    return '$grams g pro 1000 Kalorien';
  }

  @override
  String get screensSettingsMacroCustomizationFiberGuidance =>
      'Empfehlung: 14 g pro 1000 Kalorien (FDA-Richtlinie). Bereich: 5-35 g pro 1000 Kalorien';

  @override
  String get screensSettingsMacroCustomizationDailyMacroTargets =>
      'Tägliche Makronährstoffziele';

  @override
  String get screensSettingsMacroCustomizationPresetDescription =>
      'Wähle eine gängige Makronährstoffverteilung';

  @override
  String get screensSettingsMacroCustomizationBalancedPreset =>
      'Ausgewogen (30P / 40K / 30F)';

  @override
  String get screensSettingsMacroCustomizationHighProteinPreset =>
      'Proteinreich (40P / 30K / 30F)';

  @override
  String get screensSettingsMacroCustomizationProfileNotFound =>
      'Profil nicht gefunden. Bitte richte dein Profil ein.';

  @override
  String screensSettingsMacroCustomizationLoadFailed(String error) {
    return 'Profil konnte nicht geladen werden: $error';
  }

  @override
  String screensSettingsMacroCustomizationSaveFailed(String error) {
    return 'Makronährstoffziele konnten nicht gespeichert werden: $error';
  }

  @override
  String get screensSettingsStatisticsProfileNotFound =>
      'Benutzerprofil nicht gefunden';

  @override
  String screensSettingsStatisticsTestDataFailed(String error) {
    return 'Testdaten konnten nicht erstellt werden: $error';
  }

  @override
  String screensSettingsStatisticsPhaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage',
      one: '1 Tag',
    );
    return '($_temp0)';
  }

  @override
  String screensSettingsStatisticsCalPerDay(String value) {
    return '$value Kalorien/Tag';
  }

  @override
  String screensSettingsStatisticsCalValue(String value) {
    return '$value Kalorien';
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
      other: 'Tage',
      one: 'Tag',
    );
    return 'Abdeckung der Kalorienverbrauchsdaten: $percent% ($healthDays/$totalDays $_temp0)';
  }

  @override
  String get screensSettingsStatisticsActualBalance => 'Tatsächliche Bilanz';

  @override
  String screensSettingsStatisticsChartSummary(
    String chart,
    int count,
    String minimum,
    String maximum,
  ) {
    return 'Diagramm $chart: $count Datenpunkte, Skala von $minimum bis $maximum';
  }

  @override
  String get screensSettingsHealthSettingsAnalysisProfileNotFound =>
      'Benutzerprofil nicht gefunden';

  @override
  String get screensSettingsHealthSettingsAnalysisNoData =>
      'Keine Kalorienverbrauchsdaten für die Analyse verfügbar';

  @override
  String get screensSettingsHealthSettingsAnalysisIncreaseIntake =>
      'Dein Kalorienverbrauch liegt deutlich über deinem aktuellen Ziel. Erwäge, mehr Kalorien zu dir zu nehmen.';

  @override
  String get screensSettingsHealthSettingsAnalysisDecreaseIntake =>
      'Dein Kalorienverbrauch liegt unter deinem aktuellen Ziel. Erwäge, deine Kalorienzufuhr anzupassen oder dich mehr zu bewegen.';

  @override
  String get screensSettingsHealthSettingsAnalysisOnTarget =>
      'Deine aktuellen Kalorienziele passen gut zu deinem Aktivitätsniveau.';

  @override
  String screensSettingsHealthSettingsAnalysisError(String error) {
    return 'Bei der Analyse ist ein Fehler aufgetreten: $error';
  }

  @override
  String get servicesChatAgentThinking =>
      'Deine Anfrage wird analysiert und der Ablauf geplant...';

  @override
  String get servicesChatAgentThinkingDetail =>
      'Deine Anfrage wird aufgeteilt, um den besten Ansatz zu finden';

  @override
  String get servicesChatAgentContext =>
      'Relevanter Kontext und Nutzerdaten werden gesammelt...';

  @override
  String get servicesChatAgentContextDetail =>
      'Profil, Vorlieben und relevante Mahlzeiten werden gesammelt';

  @override
  String get servicesChatAgentResponse =>
      'Deine persönliche Antwort wird erstellt...';

  @override
  String get servicesChatAgentResponseDetail =>
      'Alle Informationen werden zu einer hilfreichen persönlichen Antwort verbunden';

  @override
  String get servicesChatAgentDish =>
      'Gerichte werden verarbeitet und analysiert...';

  @override
  String get servicesChatAgentDishDetail =>
      'Nährwerte, Zutaten und Mahlzeitendetails werden berechnet';

  @override
  String get servicesChatAgentDishValidation =>
      'Gerichte werden geprüft und verfeinert...';

  @override
  String get servicesChatAgentDishValidationDetail =>
      'Nährwerte und Zutaten der Gerichte werden überprüft';

  @override
  String get servicesChatAgentError =>
      'Ein unerwarteter Fehler wird behandelt...';

  @override
  String get servicesChatAgentErrorDetail =>
      'Es wird versucht, den Fehler zu beheben und eine hilfreiche Antwort zu geben';

  @override
  String get servicesChatAgentVerify =>
      'Der Kontext wird für eine optimale Antwort geprüft...';

  @override
  String get servicesChatAgentVerifyDetail =>
      'Der gesammelte Kontext wird für die bestmögliche Antwort analysiert';

  @override
  String get servicesChatAgentImage =>
      'Dein hochgeladenes Bild wird analysiert...';

  @override
  String get servicesChatAgentImageDetail =>
      'Lebensmittel, Zutaten und Portionsgrößen werden im Bild erkannt';

  @override
  String servicesChatAgentUnknownStep(String step) {
    return 'Verarbeitungsschritt: $step...';
  }

  @override
  String servicesChatAgentUnknownDetail(String step) {
    return 'Informationen für den Schritt werden verarbeitet: $step';
  }

  @override
  String servicesChatAgentRestart(int attempt) {
    return 'Neustart mit verbesserter Strategie (Versuch $attempt/3)...';
  }

  @override
  String servicesChatAgentFailedStep(String step) {
    return 'Beim Schritt \"$step\" ist ein Problem aufgetreten; Wiederherstellung läuft...';
  }

  @override
  String get componentsChatMessageBubbleErrorAuth =>
      'Dein API-Schlüssel wurde abgelehnt. Prüfe ihn in den API-Schlüssel-Einstellungen.';

  @override
  String get componentsChatMessageBubbleErrorRateLimit =>
      'Das Anfragelimit oder Kontingent deines KI-Anbieters ist erreicht. Warte kurz oder prüfe Tarif und Guthaben und versuche es dann erneut.';

  @override
  String get componentsChatMessageBubbleErrorNetwork =>
      'Der KI-Anbieter war nicht erreichbar oder die Anfrage hat zu lange gedauert. Prüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get componentsChatMessageBubbleErrorServer =>
      'Der KI-Anbieter ist gerade nicht verfügbar. Bitte versuche es gleich noch einmal.';

  @override
  String get componentsChatMessageBubbleErrorKeyUnreadable =>
      'Dein API-Schlüssel konnte auf diesem Gerät nicht gelesen werden. Gib ihn in den API-Schlüssel-Einstellungen erneut ein.';

  @override
  String get componentsChatMessageBubbleErrorUnknown =>
      'Die Nachricht konnte nicht gesendet werden. Bitte versuche es erneut.';

  @override
  String get componentsChatMessageBubbleOpenApiKeySettings =>
      'API-Schlüssel-Einstellungen';

  @override
  String get componentsChatMessageBubbleNoteContextIncomplete =>
      'Einige deiner Daten konnten nicht geladen werden; die Antwort ist daher eventuell weniger persönlich.';

  @override
  String get componentsChatMessageBubbleNoteImageNotAnalyzed =>
      'Das Bild konnte nicht analysiert werden.';

  @override
  String get screensChatHistoryLoadFailed =>
      'Ein Teil deines Chatverlaufs konnte nicht geladen werden.';

  @override
  String get screensChatHistorySaveFailed =>
      'Dein Chatverlauf konnte auf diesem Gerät nicht gespeichert werden.';

  @override
  String get screensChatSettingsFailed =>
      'Die Chat-Einstellungen konnten nicht geladen oder gespeichert werden. Vorerst werden die Standardwerte verwendet.';

  @override
  String get screensChatProfilesLoadFailed =>
      'Die Chat-Profile konnten nicht geladen werden. Es werden Standardprofile angezeigt; deine gespeicherten Profile bleiben unverändert.';

  @override
  String get screensChatProfileSaveFailed =>
      'Deine Profiländerungen konnten nicht gespeichert werden.';

  @override
  String get screensChatApiKeyReadFailedTitle =>
      'Dein API-Schlüssel konnte nicht gelesen werden';

  @override
  String get screensChatApiKeyReadFailedMessage =>
      'Auf den auf diesem Gerät gespeicherten Schlüssel konnte nicht zugegriffen werden. Lade neu, um es erneut zu versuchen, oder gib ihn in den API-Schlüssel-Einstellungen erneut ein.';

  @override
  String get screensSettingsStatisticsPartialLoadFailed =>
      'Einige Gesundheits- oder Kaloriendaten konnten nicht geladen werden, daher sind die Diagramme eventuell unvollständig.';

  @override
  String get screensSettingsHealthSettingsLoadDataFailed =>
      'Die heutigen Gesundheitsdaten konnten nicht geladen werden.';

  @override
  String get screensSettingsHealthSettingsOpenSettingsFailed =>
      'Die Health-Connect-Einstellungen konnten nicht geöffnet werden.';

  @override
  String get screensCalendarProfileLoadFailed =>
      'Dein Profil konnte nicht geladen werden, daher werden keine Tagesziele angezeigt.';

  @override
  String get componentsLowCalorieWarningTitle => 'Sehr niedriges Kalorienziel';

  @override
  String componentsLowCalorieWarningMessage(String calories, String threshold) {
    return 'Ein tägliches Kalorienziel von $calories kcal liegt unter $threshold kcal. Möglicherweise stimmt etwas nicht: Bitte prüfe deine Profilangaben wie Gewicht, Größe, Alter und Aktivitätslevel. Eine sehr niedrige Kalorienzufuhr sollte nur unter ärztlicher Aufsicht erfolgen.';
  }

  @override
  String get screensSettingsProfileSettingsInvalidCalorieTarget =>
      'Aus diesen Angaben lässt sich kein Kalorienziel berechnen. Bitte prüfe dein Gewicht, deine Größe und dein Alter.';

  @override
  String get screensMenuSupport => 'Hilfe & Feedback';

  @override
  String get screensMenuSendFeedback => 'Feedback senden';

  @override
  String get screensMenuSendFeedbackSubtitle =>
      'Schreibe dem Entwickler eine E-Mail';

  @override
  String get screensMenuReportProblem => 'Problem melden';

  @override
  String get screensMenuReportProblemSubtitle =>
      'Teile das Diagnoseprotokoll mit einer App deiner Wahl';

  @override
  String get screensMenuClearDiagnosticLog => 'Diagnoseprotokoll löschen';

  @override
  String get screensMenuClearDiagnosticLogSubtitle =>
      'Löscht die auf diesem Gerät gespeicherten Fehlereinträge';

  @override
  String get screensMenuDiagnosticsNote =>
      'Es wird nichts automatisch gesendet: Fehler werden in einem kurzen lokalen Protokoll ohne persönliche Daten gespeichert und verlassen dein Gerät nur, wenn du sie teilst.';

  @override
  String screensMenuFeedbackSubject(String version) {
    return 'PlatePal Tracker Feedback (v$version)';
  }

  @override
  String screensMenuNoEmailApp(String email) {
    return 'Keine E-Mail-App gefunden. Du kannst an $email schreiben.';
  }

  @override
  String screensMenuReportProblemSubject(String version) {
    return 'PlatePal Tracker Problembericht (v$version)';
  }

  @override
  String screensMenuReportProblemShareText(String email) {
    return 'PlatePal Tracker Diagnoseprotokoll. Kontakt zum Entwickler: $email';
  }

  @override
  String get screensMenuDiagnosticLogEmpty =>
      'Noch keine Probleme aufgezeichnet. Das Diagnoseprotokoll ist leer.';

  @override
  String get screensMenuDiagnosticLogShareFailed =>
      'Das Diagnoseprotokoll konnte nicht geteilt werden. Versuche es erneut.';

  @override
  String get screensMenuDiagnosticLogCleared => 'Diagnoseprotokoll gelöscht.';

  @override
  String get screensMenuDiagnosticLogClearFailed =>
      'Das Diagnoseprotokoll konnte nicht gelöscht werden. Versuche es erneut.';

  @override
  String get screensPrivacyDiagnosticsTitle => 'Diagnoseprotokoll und Feedback';

  @override
  String get screensPrivacyDiagnosticsBody =>
      'Tritt in der App ein unerwarteter Fehler auf, speichert sie einen kurzen technischen Eintrag auf deinem Gerät: Zeitpunkt, App-Version, Fehlertyp, eine gekürzte Fehlermeldung und die Stelle im Code. Text, der persönliche Daten enthalten kann, etwa Werte in Anführungszeichen, E-Mail-Adressen, Schlüssel und Messwerte, wird entfernt, und nur die letzten 20 Einträge bleiben erhalten. Das Protokoll wird nie automatisch gesendet. Es verlässt dein Gerät nur, wenn du „Problem melden“ wählst und es mit einer App deiner Wahl teilst; „Diagnoseprotokoll löschen“ im Menü entfernt es. „Feedback senden“ öffnet deine E-Mail-App, und es wird erst etwas gesendet, wenn du die E-Mail selbst abschickst.';

  @override
  String get screensSettingsImportDataInvalidArchive =>
      'Diese ZIP-Datei ist kein PlatePal-Tracker-Backup.';

  @override
  String get screensSettingsExportDataExportAsZip =>
      'Vollständiges Backup (.zip)';

  @override
  String get screensSettingsExportDataZipDescription =>
      'Daten und Gerichtsfotos in einer Datei, z. B. für ein neues Gerät';

  @override
  String screensSettingsStatisticsNotEnoughMetrics(int count) {
    return 'Erfasse deine Körperwerte mindestens $count-mal, um dieses Diagramm zu sehen.';
  }

  @override
  String componentsScannerBarcodeScannerNotFoundMessage(String barcode) {
    return 'Der Barcode $barcode ist noch nicht in Open Food Facts. Suche nach dem Namen oder gib das Lebensmittel selbst ein.';
  }

  @override
  String get componentsScannerBarcodeScannerSearchByName => 'Nach Namen suchen';

  @override
  String get componentsScannerBarcodeScannerEnterManually => 'Manuell eingeben';

  @override
  String get componentsScannerBarcodeScannerScanAgain => 'Erneut scannen';

  @override
  String componentsDishesDishFormIngredientFormModalBarcode(String barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get screensMealsScanBarcode => 'Barcode scannen';

  @override
  String get screensMealsSearchFood => 'Lebensmittel suchen';

  @override
  String get componentsScannerProductSearchErrorOffline =>
      'Du bist offline. Prüfe deine Verbindung und versuche es erneut.';

  @override
  String get componentsScannerProductSearchErrorTimeout =>
      'Open Food Facts hat zu lange nicht geantwortet. Versuche es erneut.';

  @override
  String get componentsScannerProductSearchErrorServer =>
      'Open Food Facts ist ausgelastet oder nicht erreichbar. Warte kurz und versuche es erneut.';
}
