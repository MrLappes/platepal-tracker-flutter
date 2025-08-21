// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'PlatePal Tracker';

  @override
  String get welcome => 'Willkommen bei PlatePal';

  @override
  String get meals => 'Mahlzeiten';

  @override
  String get nutrition => 'Ernährung';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get addMeal => 'Mahlzeit hinzufügen';

  @override
  String get breakfast => 'Frühstück';

  @override
  String get lunch => 'Mittagessen';

  @override
  String get dinner => 'Abendessen';

  @override
  String get snack => 'Snack';

  @override
  String get noMealsLogged => 'Noch keine Mahlzeiten protokolliert';

  @override
  String get startTrackingMeals => 'Beginnen Sie mit der Verfolgung Ihrer Mahlzeiten, um sie hier zu sehen';

  @override
  String get todaysMeals => 'Heutige Mahlzeiten';

  @override
  String get allMeals => 'Alle Mahlzeiten';

  @override
  String get mealHistory => 'Mahlzeitenverlauf';

  @override
  String get filterByMealType => 'Nach Mahlzeitentyp filtern';

  @override
  String get logMeal => 'Mahlzeit protokollieren';

  @override
  String mealLoggedAt(String time) {
    return 'Protokolliert um $time';
  }

  @override
  String get calories => 'Kalorien';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Kohlenhydrate';

  @override
  String get fat => 'Fett';

  @override
  String get calendar => 'Kalender';

  @override
  String get unknownDish => 'Unbekanntes Gericht';

  @override
  String get noMealsLoggedForDay => 'Keine Mahlzeiten für diesen Tag protokolliert';

  @override
  String get nutritionSummary => 'Nährwerte';

  @override
  String get getAiTip => 'KI-Tipp';

  @override
  String get deleteLog => 'Protokoll löschen';

  @override
  String get deleteLogConfirmation => 'Sind Sie sicher, dass Sie diese protokollierte Mahlzeit löschen möchten?';

  @override
  String get delete => 'Löschen';

  @override
  String get mealLogDeletedSuccessfully => 'Mahlzeit-Protokoll erfolgreich gelöscht';

  @override
  String get failedToDeleteMealLog => 'Löschen des Mahlzeit-Protokolls fehlgeschlagen';

  @override
  String get chat => 'Chat';

  @override
  String get menu => 'Menü';

  @override
  String get userProfile => 'Benutzerprofil';

  @override
  String get nutritionGoals => 'Ernährungsziele';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get aiFeatures => 'KI & Funktionen';

  @override
  String get dataManagement => 'Datenverwaltung';

  @override
  String get information => 'Informationen';

  @override
  String get apiKeySettings => 'API-Schlüssel Einstellungen';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String get selectFilesToImport => 'Dateien zum Importieren auswählen';

  @override
  String get importFromFile => 'Aus Datei importieren';

  @override
  String get importJson => 'JSON importieren';

  @override
  String get importCsv => 'CSV importieren';

  @override
  String get exportAsJson => 'Als JSON exportieren';

  @override
  String get exportAsCsv => 'Als CSV exportieren';

  @override
  String get selectDataToExport => 'Zu exportierende Daten auswählen';

  @override
  String get selectDataToImport => 'Zu importierende Daten auswählen';

  @override
  String get userProfiles => 'Benutzerprofile';

  @override
  String get mealLogs => 'Mahlzeiten-Protokolle';

  @override
  String get dishes => 'Gerichte';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get supplements => 'Nahrungsergänzungsmittel';

  @override
  String get nutritionGoalsData => 'Ernährungsziele';

  @override
  String get allData => 'Alle Daten';

  @override
  String get importProgress => 'Daten werden importiert...';

  @override
  String get exportProgress => 'Daten werden exportiert...';

  @override
  String get importSuccessful => 'Daten erfolgreich importiert';

  @override
  String get exportSuccessful => 'Daten erfolgreich exportiert';

  @override
  String get importFailed => 'Import fehlgeschlagen';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String get noFileSelected => 'Keine Datei ausgewählt';

  @override
  String get invalidFileFormat => 'Ungültiges Dateiformat';

  @override
  String get fileNotFound => 'Datei nicht gefunden';

  @override
  String get dataValidationFailed => 'Datenvalidierung fehlgeschlagen';

  @override
  String importedItemsCount(int count) {
    return '$count Elemente importiert';
  }

  @override
  String exportedItemsCount(int count) {
    return '$count Elemente exportiert';
  }

  @override
  String get backupAndRestore => 'Sicherung & Wiederherstellung';

  @override
  String get createBackup => 'Sicherung erstellen';

  @override
  String get restoreFromBackup => 'Aus Sicherung wiederherstellen';

  @override
  String get backupCreatedSuccessfully => 'Sicherung erfolgreich erstellt';

  @override
  String get restoreSuccessful => 'Wiederherstellung erfolgreich abgeschlossen';

  @override
  String get warningDataWillBeReplaced => 'Warnung: Vorhandene Daten werden ersetzt';

  @override
  String get confirmRestore => 'Sind Sie sicher, dass Sie wiederherstellen möchten? Dies ersetzt alle vorhandenen Daten.';

  @override
  String fileSize(String size) {
    return 'Dateigröße: $size';
  }

  @override
  String duplicateItemsFound(int count) {
    return 'Doppelte Elemente gefunden: $count';
  }

  @override
  String get howToHandleDuplicates => 'Wie sollen Duplikate behandelt werden?';

  @override
  String get skipDuplicates => 'Duplikate überspringen';

  @override
  String get overwriteDuplicates => 'Duplikate überschreiben';

  @override
  String get mergeDuplicates => 'Duplikate zusammenführen';

  @override
  String formatNotSupported(String format) {
    return 'Format nicht unterstützt: $format';
  }

  @override
  String get about => 'Über uns';

  @override
  String get aboutAppTitle => 'Über uns';

  @override
  String get madeBy => 'Erstellt von MrLappes';

  @override
  String get website => 'plate-pal.de';

  @override
  String get githubRepository => 'github.com/MrLappes/platepal-tracker';

  @override
  String get appMotto => 'Von Sportlern für Sportler gemacht, die kostenpflichtige Apps hassen';

  @override
  String get codersMessage => 'Programmierer sollten nicht bezahlen müssen';

  @override
  String get whyPlatePal => 'Warum PlatePal?';

  @override
  String get aboutDescription => 'PlatePal Tracker wurde entwickelt, um eine datenschutzorientierte, quelloffene Alternative zu teuren Ernährungs-Tracking-Apps zu bieten. Wir glauben daran, die Kontrolle in Ihre Hände zu legen - ohne Abonnements, ohne Werbung und ohne Datensammlung.';

  @override
  String get dataStaysOnDevice => 'Ihre Daten bleiben auf Ihrem Gerät';

  @override
  String get useOwnAiKey => 'Verwenden Sie Ihren eigenen KI-Schlüssel für volle Kontrolle';

  @override
  String get freeOpenSource => '100% kostenlos und quelloffen';

  @override
  String couldNotOpenUrl(String url) {
    return 'Konnte $url nicht öffnen';
  }

  @override
  String get linkError => 'Beim Öffnen des Links ist ein Fehler aufgetreten';

  @override
  String get contributors => 'Mitwirkende';

  @override
  String get editPersonalInfo => 'Bearbeiten Sie Ihre persönlichen Informationen';

  @override
  String get setNutritionTargets => 'Legen Sie Ihre täglichen Ernährungsziele fest';

  @override
  String get configureApiKey => 'Konfigurieren Sie Ihren OpenAI API-Schlüssel';

  @override
  String get exportMealData => 'Exportieren Sie Ihre Mahlzeitdaten';

  @override
  String get importMealDataBackup => 'Importieren Sie Mahlzeitdaten aus der Sicherung';

  @override
  String get learnMorePlatePal => 'Erfahren Sie mehr über PlatePal';

  @override
  String get viewContributors => 'Projektmitwirkende anzeigen';

  @override
  String get theme => 'Design';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get german => 'Deutsch';

  @override
  String get contributorSingular => 'Mitwirkender';

  @override
  String get contributorPlural => 'Mitwirkende';

  @override
  String get contributorsThankYou => 'Danke an alle, die dazu beigetragen haben, PlatePal Tracker möglich zu machen!';

  @override
  String get wantToContribute => 'Möchten Sie mitwirken?';

  @override
  String get openSourceMessage => 'PlatePal Tracker ist Open Source - treten Sie uns auf GitHub bei!';

  @override
  String get checkGitHub => 'Schauen Sie sich unser GitHub-Repository an';

  @override
  String get supportDevelopment => 'Entwicklung unterstützen';

  @override
  String get supportMessage => 'Möchten Sie mir mein Kreatin kaufen? Ihre Unterstützung wird sehr geschätzt, ist aber keineswegs verpflichtend.';

  @override
  String get buyMeCreatine => 'Kaufen Sie mir Kreatin';

  @override
  String get openingLink => 'Öffne Buy Me Creatine Seite...';

  @override
  String get aboutOpenAiApiKey => 'Über OpenAI API-Schlüssel';

  @override
  String get apiKeyDescription => 'Um KI-Funktionen wie Mahlzeitanalyse und Vorschläge zu nutzen, müssen Sie Ihren eigenen OpenAI API-Schlüssel bereitstellen. Dies stellt sicher, dass Ihre Daten privat bleiben und Sie die volle Kontrolle haben.';

  @override
  String get apiKeyBulletPoints => '• Holen Sie sich Ihren API-Schlüssel von platform.openai.com\n• Ihr Schlüssel wird lokal auf Ihrem Gerät gespeichert\n• Nutzungsgebühren werden direkt Ihrem OpenAI-Konto belastet';

  @override
  String get apiKeyConfigured => 'API-Schlüssel konfiguriert';

  @override
  String get aiFeaturesEnabled => 'KI-Funktionen sind aktiviert';

  @override
  String get openAiApiKey => 'OpenAI API-Schlüssel';

  @override
  String get apiKeyPlaceholder => 'sk-...';

  @override
  String get apiKeyHelperText => 'Geben Sie Ihren OpenAI API-Schlüssel ein oder lassen Sie das Feld leer, um KI-Funktionen zu deaktivieren';

  @override
  String get updateApiKey => 'API-Schlüssel aktualisieren';

  @override
  String get saveApiKey => 'API-Schlüssel speichern';

  @override
  String get getApiKeyFromOpenAi => 'API-Schlüssel von OpenAI holen';

  @override
  String get removeApiKey => 'API-Schlüssel entfernen';

  @override
  String get removeApiKeyConfirmation => 'Sind Sie sicher, dass Sie Ihren API-Schlüssel entfernen möchten? Dies deaktiviert KI-Funktionen.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get remove => 'Entfernen';

  @override
  String get apiKeyMustStartWith => 'API-Schlüssel muss mit \"sk-\" beginnen';

  @override
  String get apiKeyTooShort => 'API-Schlüssel scheint zu kurz zu sein';

  @override
  String get apiKeyRemovedSuccessfully => 'API-Schlüssel erfolgreich entfernt';

  @override
  String get apiKeySavedSuccessfully => 'API-Schlüssel erfolgreich gespeichert';

  @override
  String get failedToLoadApiKey => 'API-Schlüssel konnte nicht geladen werden';

  @override
  String get failedToSaveApiKey => 'API-Schlüssel konnte nicht gespeichert werden';

  @override
  String get failedToRemoveApiKey => 'API-Schlüssel konnte nicht entfernt werden';

  @override
  String get visitOpenAiPlatform => 'Besuchen Sie platform.openai.com, um Ihren API-Schlüssel zu erhalten';

  @override
  String get pasteFromClipboard => 'Aus Zwischenablage einfügen';

  @override
  String get clipboardEmpty => 'Zwischenablage ist leer';

  @override
  String get pastedFromClipboard => 'Aus Zwischenablage eingefügt';

  @override
  String get failedToAccessClipboard => 'Zugriff auf Zwischenablage fehlgeschlagen';

  @override
  String get selectModel => 'Modell auswählen';

  @override
  String get testAndSaveApiKey => 'API-Schlüssel testen & speichern';

  @override
  String get testingApiKey => 'API-Schlüssel wird getestet...';

  @override
  String get gpt4ModelsInfo => 'GPT-4 Modelle bieten die beste Analyse, kosten aber mehr';

  @override
  String get gpt35ModelsInfo => 'GPT-3.5 Modelle sind kostengünstiger für einfache Analysen';

  @override
  String get loadingModels => 'Verfügbare Modelle werden geladen...';

  @override
  String get couldNotLoadModels => 'Verfügbare Modelle konnten nicht geladen werden. Verwende Standard-Modellliste';

  @override
  String get apiKeyTestWarning => 'Ihr API-Schlüssel wird mit einer kleinen Anfrage getestet, um zu überprüfen, ob er funktioniert. Der Schlüssel wird nur auf Ihrem Gerät gespeichert und niemals an unsere Server gesendet';

  @override
  String get ok => 'OK';

  @override
  String get welcomeToPlatePalTracker => 'Willkommen bei PlatePal Tracker';

  @override
  String get profileSettings => 'Profil-Einstellungen';

  @override
  String get personalInformation => 'Persönliche Informationen';

  @override
  String get name => 'Name';

  @override
  String get email => 'E-Mail';

  @override
  String get age => 'Alter';

  @override
  String get gender => 'Geschlecht';

  @override
  String get male => 'Männlich';

  @override
  String get female => 'Weiblich';

  @override
  String get other => 'Andere';

  @override
  String get height => 'Größe';

  @override
  String get weight => 'Gewicht';

  @override
  String get targetWeight => 'Zielgewicht';

  @override
  String get activityLevel => 'Aktivitätslevel';

  @override
  String get sedentary => 'Sesshaft';

  @override
  String get lightlyActive => 'Leicht aktiv';

  @override
  String get moderatelyActive => 'Mäßig aktiv';

  @override
  String get veryActive => 'Sehr aktiv';

  @override
  String get extraActive => 'Extrem aktiv';

  @override
  String get fitnessGoals => 'Fitnessziele';

  @override
  String get fitnessGoal => 'Fitnessziel';

  @override
  String get loseWeight => 'Gewicht verlieren';

  @override
  String get maintainWeight => 'Gewicht halten';

  @override
  String get gainWeight => 'Gewicht zunehmen';

  @override
  String get buildMuscle => 'Muskeln aufbauen';

  @override
  String get preferences => 'Einstellungen';

  @override
  String get unitSystem => 'Einheitensystem';

  @override
  String get metric => 'Metrisch (kg, cm)';

  @override
  String get imperial => 'Imperial (lb, ft)';

  @override
  String get save => 'Speichern';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get discardChanges => 'Änderungen verwerfen';

  @override
  String get profileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get profileUpdateFailed => 'Profil konnte nicht aktualisiert werden';

  @override
  String get unsavedChanges => 'Nicht gespeicherte Änderungen';

  @override
  String get unsavedChangesMessage => 'Sie haben nicht gespeicherte Änderungen. Möchten Sie sie vor dem Verlassen speichern?';

  @override
  String get deleteProfile => 'Profil löschen';

  @override
  String get deleteProfileConfirmation => 'Sind Sie sicher, dass Sie Ihr Profil löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get requiredField => 'Dieses Feld ist erforderlich';

  @override
  String get invalidEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get ageRange => 'Das Alter muss zwischen 13 und 120 liegen';

  @override
  String get heightRange => 'Die Größe muss zwischen 100-250 cm liegen';

  @override
  String get weightRange => 'Das Gewicht muss zwischen 30-300 kg liegen';

  @override
  String get currentStats => 'Aktuelle Statistiken';

  @override
  String get bmi => 'BMI';

  @override
  String get bmr => 'BMR';

  @override
  String get tdee => 'TDEE';

  @override
  String get years => 'Jahre';

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
  String get chatAssistant => 'KI-Chat-Assistent';

  @override
  String get chatSubtitle => 'Erhalten Sie personalisierte Mahlzeitenvorschläge und Ernährungsberatung';

  @override
  String get typeMessage => 'Nachricht eingeben...';

  @override
  String get sendMessage => 'Nachricht senden';

  @override
  String get analyzeDish => 'Gericht analysieren';

  @override
  String get scanBarcode => 'Barcode scannen';

  @override
  String get searchProduct => 'Produkt suchen';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get suggestMeal => 'Mahlzeit vorschlagen';

  @override
  String get analyzeNutrition => 'Ernährung analysieren';

  @override
  String get findAlternatives => 'Alternativen finden';

  @override
  String get calculateMacros => 'Makros berechnen';

  @override
  String get mealPlan => 'Ernährungsplan-Hilfe';

  @override
  String get ingredientInfo => 'Zutatensinfo';

  @override
  String get clearChat => 'Chat löschen';

  @override
  String get clearChatConfirmation => 'Sind Sie sicher, dass Sie den Chat-Verlauf löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get chatCleared => 'Chat-Verlauf gelöscht';

  @override
  String get messageFailedToSend => 'Nachricht konnte nicht gesendet werden';

  @override
  String get retryMessage => 'Wiederholen';

  @override
  String get copyMessage => 'Nachricht kopieren';

  @override
  String get messageCopied => 'Nachricht in Zwischenablage kopiert';

  @override
  String get aiThinking => 'KI denkt nach...';

  @override
  String get noApiKeyConfigured => 'Kein API-Schlüssel konfiguriert';

  @override
  String get configureApiKeyToUseChat => 'Bitte konfigurieren Sie Ihren OpenAI API-Schlüssel in den Einstellungen, um den KI-Chat-Assistenten zu verwenden.';

  @override
  String get configureApiKeyButton => 'API-Schlüssel konfigurieren';

  @override
  String get reloadApiKeyButton => 'API-Schlüssel neu laden';

  @override
  String get welcomeToChat => 'Willkommen bei Ihrem KI-Ernährungsassistenten! Fragen Sie mich alles über Mahlzeiten, Ernährung oder Ihre Fitnessziele.';

  @override
  String get attachImage => 'Bild anhängen';

  @override
  String get imageAttached => 'Bild angehängt';

  @override
  String get removeImage => 'Bild entfernen';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get chooseFromGallery => 'Aus Galerie wählen';

  @override
  String get imageSourceSelection => 'Bildquelle auswählen';

  @override
  String get nutritionAnalysis => 'Nährwertanalyse';

  @override
  String get addToMeals => 'Zu Mahlzeiten hinzufügen';

  @override
  String get details => 'Details';

  @override
  String get tapToViewAgentSteps => 'Agent-Details anzeigen';

  @override
  String addedToMealsSuccess(String dishName) {
    return '$dishName zu Mahlzeiten hinzugefügt';
  }

  @override
  String get close => 'Schließen';

  @override
  String get servingSize => 'Portionsgröße';

  @override
  String get perServing => 'pro Portion';

  @override
  String get dishName => 'Gerichtname';

  @override
  String get cookingInstructions => 'Kochanweisungen';

  @override
  String get mealType => 'Mahlzeitentyp';

  @override
  String get addedToMeals => 'Erfolgreich zu Mahlzeiten hinzugefügt';

  @override
  String get failedToAddMeal => 'Fehler beim Hinzufügen der Mahlzeit';

  @override
  String get testChatWelcome => 'Dies ist der Testmodus! Ich kann Ihnen helfen, die Funktionen von PlatePal zu erkunden. Versuchen Sie, mich nach Ernährung, Essensplanung oder Lebensmittelempfehlungen zu fragen.';

  @override
  String get testChatResponse => 'Danke, dass Sie PlatePal ausprobieren! Dies ist eine Testantwort, um Ihnen zu zeigen, wie unser KI-Assistent funktioniert. Um echte Ernährungsberatung und Mahlzeitenvorschläge zu erhalten, konfigurieren Sie bitte Ihren OpenAI API-Schlüssel in den Einstellungen.';

  @override
  String get chatWelcomeTitle => 'Willkommen bei PlatePal';

  @override
  String get chatWelcomeSubtitle => 'Ihr KI-Ernährungsassistent ist hier, um zu helfen';

  @override
  String get getStartedToday => 'Heute beginnen';

  @override
  String get whatCanIHelpWith => 'Wobei kann ich Ihnen helfen?';

  @override
  String get featureComingSoon => 'Diese Funktion wird bald verfügbar sein!';

  @override
  String get statistics => 'Statistiken';

  @override
  String get viewStatistics => 'Statistiken anzeigen';

  @override
  String get weightHistory => 'Gewichtsverlauf';

  @override
  String get bmiHistory => 'BMI-Verlauf';

  @override
  String get bodyFatHistory => 'Körperfett-Verlauf';

  @override
  String get calorieIntakeHistory => 'Kalorienaufnahme vs. Erhaltung';

  @override
  String get weightStatsTip => 'Das Diagramm zeigt das wöchentliche Mediangewicht, um tägliche Schwankungen durch Wassergewicht zu berücksichtigen.';

  @override
  String get bmiStatsTip => 'Der Body Mass Index (BMI) wird aus Ihren Gewichts- und Größenmessungen berechnet.';

  @override
  String get bodyFatStatsTip => 'Der Körperfettanteil hilft dabei, Ihre Körperzusammensetzung über das Gewicht hinaus zu verfolgen.';

  @override
  String get calorieStatsTip => 'Vergleichen Sie Ihre tägliche Kalorienaufnahme mit Ihren Erhaltungskalorien. Grün zeigt Erhaltung, Blau ist Definitionsphase, Orange ist Aufbauphase.';

  @override
  String get notEnoughDataTitle => 'Nicht genügend Daten';

  @override
  String get statisticsEmptyDescription => 'Wir benötigen mindestens eine Woche Daten, um aussagekräftige Statistiken zu zeigen. Verfolgen Sie weiter Ihre Messwerte, um Trends über die Zeit zu sehen.';

  @override
  String get updateMetricsNow => 'Messwerte jetzt aktualisieren';

  @override
  String get timeRange => 'Zeitbereich';

  @override
  String get week => 'Woche';

  @override
  String get month => 'Monat';

  @override
  String get threeMonths => '3 Monate';

  @override
  String get sixMonths => '6 Monate';

  @override
  String get year => 'Jahr';

  @override
  String get allTime => 'Alle Zeit';

  @override
  String get bulking => 'Aufbau';

  @override
  String get cutting => 'Definition';

  @override
  String get maintenance => 'Erhaltung';

  @override
  String get extremeLowCalorieWarning => 'Warnung bei extrem niedrigen Kalorien';

  @override
  String get extremeHighCalorieWarning => 'Warnung bei extrem hohen Kalorien';

  @override
  String get caloriesTooLowMessage => 'Ihre Kalorienaufnahme liegt deutlich unter den Empfehlungen. Dies kann Ihre Gesundheit und den Stoffwechsel beeinträchtigen.';

  @override
  String get caloriesTooHighMessage => 'Ihre Kalorienaufnahme liegt deutlich über den Empfehlungen. Erwägen Sie, Ihre Portionen anzupassen.';

  @override
  String get weeklyDeficit => 'Wöchentliches Defizit';

  @override
  String get weeklySurplus => 'Wöchentlicher Überschuss';

  @override
  String get phaseAnalysis => 'Phasenanalyse';

  @override
  String get weeklyAverage => 'Wöchentlicher Durchschnitt';

  @override
  String get lastWeek => 'Letzte Woche';

  @override
  String get lastMonth => 'Letzter Monat';

  @override
  String get lastThreeMonths => 'Letzte 3 Monate';

  @override
  String get lastSixMonths => 'Letzte 6 Monate';

  @override
  String get lastYear => 'Letztes Jahr';

  @override
  String get generateTestData => 'Testdaten Generieren';

  @override
  String get testDataDescription => 'Zu Demonstrationszwecken können Sie Beispieldaten generieren, um zu sehen, wie die Statistiken aussehen.';

  @override
  String get errorLoadingData => 'Fehler beim Laden der Daten';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get realData => 'Echte Daten';

  @override
  String get noWeightDataAvailable => 'Keine Gewichtsdaten verfügbar';

  @override
  String get noBmiDataAvailable => 'Keine BMI-Daten verfügbar';

  @override
  String get cannotCalculateBmiFromData => 'BMI kann aus verfügbaren Daten nicht berechnet werden';

  @override
  String get noBodyFatDataAvailable => 'Keine Körperfettdaten verfügbar';

  @override
  String get noCalorieDataAvailable => 'Keine Kaloriendaten verfügbar';

  @override
  String get bmiUnderweight => 'Untergewicht';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Übergewicht';

  @override
  String get bmiObese => 'Adipös';

  @override
  String get healthDataIntegration => 'Gesundheitsdaten-Integration';

  @override
  String healthDataCoverage(String coverage, String healthDataDays, String totalDays) {
    return 'Abdeckung der Kalorienverbrauchsdaten: $coverage% ($healthDataDays/$totalDays Tage)';
  }

  @override
  String get healthDataActive => 'Ihre Gesundheits-App-Daten werden für eine genauere Defizit-/Überschussanalyse verwendet.';

  @override
  String get healthDataInactive => 'Aktivieren Sie die Gesundheitsdatensynchronisation in den Profileinstellungen für eine genauere Analyse.';

  @override
  String get calorieBalanceTitle => 'Kalorienbilanz (Aufnahme vs. Verbrauch)';

  @override
  String get calorieBalanceTip => 'Verfolgen Sie Ihre tatsächliche Kalorienbilanz mit Gesundheitsdaten. Grün = Erhaltung, Blau = Defizit, Orange = Überschuss.';

  @override
  String get estimatedBalance => 'Geschätzte Bilanz';

  @override
  String get actualBalance => 'Tatsächliche Bilanz';

  @override
  String get vsExpenditure => 'vs. Verbrauch';

  @override
  String healthDataAlert(String days) {
    return 'Gesundheitsdaten-Warnung: $days Tag(e) mit sehr großen Kaloriendefiziten (>1000 kcal) basierend auf dem tatsächlichen Verbrauch.';
  }

  @override
  String inconsistentDeficitWarning(String variance) {
    return 'Warnung: Ihr Kaloriendefizit variiert erheblich von Tag zu Tag (Varianz: $variance kcal). Erwägen Sie eine konsistentere Aufnahme.';
  }

  @override
  String veryLowCalorieWarning(String days) {
    return 'Warnung: $days Tag(e) mit extrem niedriger Kalorienaufnahme (<1000 kcal). Dies kann ungesund sein.';
  }

  @override
  String veryHighCalorieNotice(String days) {
    return 'Hinweis: $days Tag(e) mit sehr hoher Kalorienaufnahme (>1000 kcal über dem Erhaltungsbedarf).';
  }

  @override
  String get extremeDeficitWarning => 'Warnung: Häufige extreme Kaloriendefizite können den Stoffwechsel verlangsamen und Muskelverlust verursachen.';

  @override
  String get maintenanceLabel => 'Erhaltung';

  @override
  String get bodyFat => 'Körperfett';

  @override
  String get resetApp => 'App Zurücksetzen';

  @override
  String get resetAppTitle => 'Anwendungsdaten Zurücksetzen';

  @override
  String get resetAppDescription => 'Dies wird ALLE Ihre Daten dauerhaft löschen, einschließlich:\n\n• Ihre Profilinformationen\n• Alle Mahlzeitenprotokolle und Ernährungsdaten\n• Alle Einstellungen und Präferenzen\n• Alle gespeicherten Informationen\n\nDiese Aktion kann nicht rückgängig gemacht werden. Sind Sie sicher, dass Sie fortfahren möchten?';

  @override
  String get resetAppConfirm => 'Ja, Alles Löschen';

  @override
  String get resetAppCancel => 'Abbrechen';

  @override
  String get resetAppSuccess => 'Anwendungsdaten wurden erfolgreich zurückgesetzt';

  @override
  String get resetAppError => 'Fehler beim Zurücksetzen der Anwendungsdaten';

  @override
  String get dangerZone => 'Gefahrenzone';

  @override
  String get chatAgentSettingsTitle => 'Chat-Agent Einstellungen';

  @override
  String get chatAgentEnableTitle => 'Agent-Modus aktivieren';

  @override
  String get chatAgentEnableSubtitle => 'Verwende die mehrstufige Agenten-Pipeline für den Chat';

  @override
  String get chatAgentDeepSearchTitle => 'Deep Search aktivieren';

  @override
  String get chatAgentDeepSearchSubtitle => 'Erlaube dem Agenten, Deep Search für genauere Antworten zu verwenden';

  @override
  String get chatAgentInfoTitle => 'Was ist der Agent-Modus?';

  @override
  String get chatAgentInfoDescription => 'Der Agent-Modus aktiviert PlatePals fortschrittliche mehrstufige Denk-Pipeline für den Chat. So kann der Assistent deine Anfrage analysieren, Kontext sammeln und genauere, erklärbare Antworten liefern. Deep Search ermöglicht dem Agenten, noch mehr Daten für bessere Ergebnisse zu nutzen.';

  @override
  String get chatSettingsSaved => 'Chat-Einstellungen erfolgreich gespeichert';

  @override
  String get yesterday => 'Gestern';

  @override
  String get basicInformation => 'Grundinformationen';

  @override
  String get pleaseEnterDishName => 'Bitte geben Sie einen Gerichtnamen ein';

  @override
  String get imageUrl => 'Bild-URL';

  @override
  String get optional => 'Optional';

  @override
  String get nutritionInfo => 'Nährwertinformationen';

  @override
  String get required => 'Erforderlich';

  @override
  String get invalidNumber => 'Ungültige Zahl';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get noIngredientsAdded => 'Keine Zutaten hinzugefügt';

  @override
  String get ingredientsAdded => 'Zutaten hinzugefügt';

  @override
  String get options => 'Optionen';

  @override
  String get markAsFavorite => 'Als Favorit markieren';

  @override
  String get editDish => 'Gericht bearbeiten';

  @override
  String get dishUpdatedSuccessfully => 'Gericht erfolgreich aktualisiert';

  @override
  String get dishCreatedSuccessfully => 'Gericht erfolgreich erstellt';

  @override
  String get errorSavingDish => 'Fehler beim Speichern des Gerichts';

  @override
  String get ingredientName => 'Zutatenname';

  @override
  String get pleaseEnterIngredientName => 'Bitte geben Sie einen Zutatennamen ein';

  @override
  String get amount => 'Menge';

  @override
  String get unit => 'Einheit';

  @override
  String get add => 'Hinzufügen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get retry => 'Wiederholen';

  @override
  String get errorLoggingDish => 'Fehler beim eintragen des Gerichtes';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get searchDishes => 'Gerichte suchen';

  @override
  String get createDish => 'Gericht erstellen';

  @override
  String get noDishesCreated => 'Noch keine Gerichte erstellt';

  @override
  String get createFirstDish => 'Erstes Gericht erstellen';

  @override
  String get errorLoadingDishes => 'Fehler beim Laden der Gerichte';

  @override
  String get noDishesFound => 'Keine Gerichte gefunden';

  @override
  String get tryAdjustingSearch => 'Versuchen Sie, Ihre Suche anzupassen';

  @override
  String get deleteDish => 'Gericht löschen';

  @override
  String deleteDishConfirmation(String dishName) {
    return 'Sind Sie sicher, dass Sie \"$dishName\" löschen möchten?';
  }

  @override
  String get dishDeletedSuccessfully => 'Gericht erfolgreich gelöscht';

  @override
  String get failedToDeleteDish => 'Gericht konnte nicht gelöscht werden';

  @override
  String get addedToFavorites => 'Zu Favoriten hinzugefügt';

  @override
  String get removedFromFavorites => 'Aus Favoriten entfernt';

  @override
  String get errorUpdatingDish => 'Fehler beim Aktualisieren des Gerichts';

  @override
  String get addToFavorites => 'Zu Favoriten hinzufügen';

  @override
  String get removeFromFavorites => 'Aus Favoriten entfernen';

  @override
  String get fiber => 'Ballaststoffe';

  @override
  String get favorite => 'Favorit';

  @override
  String get createNewDish => 'Neues Gericht erstellen';

  @override
  String get errorCreatingDish => 'Fehler beim Erstellen des Gerichts';

  @override
  String get pleaseEnterDescription => 'Bitte geben Sie eine Beschreibung ein';

  @override
  String get pleaseEnterValidUrl => 'Bitte geben Sie eine gültige URL ein';

  @override
  String get pleaseEnterIngredient => 'Bitte geben Sie eine Zutat ein';

  @override
  String get errorDeletingDish => 'Fehler beim Löschen des Gerichts';

  @override
  String get confirmDeleteDish => 'Sind Sie sicher, dass Sie dieses Gericht löschen möchten?';

  @override
  String get description => 'Beschreibung';

  @override
  String get category => 'Kategorie';

  @override
  String get caloriesPer100g => 'Kalorien per 100g';

  @override
  String get proteinPer100g => 'Protein per 100g';

  @override
  String get carbsPer100g => 'Kohlenhydrate per 100g';

  @override
  String get fatPer100g => 'Fett per 100g';

  @override
  String get fiberPer100g => 'Ballaststoffe per 100g';

  @override
  String get invalidImageUrl => 'Ungültige Bild-URL';

  @override
  String get enterIngredientName => 'Zutatennamen eingeben';

  @override
  String get toggleFavorite => 'Favorit umschalten';

  @override
  String get basicInfo => 'Grundinformationen';

  @override
  String get dishNamePlaceholder => 'Gerichtnamen eingeben';

  @override
  String get descriptionPlaceholder => 'Beschreibung eingeben';

  @override
  String get pickFromGallery => 'Aus Galerie auswählen';

  @override
  String get selectImageSource => 'Bildquelle auswählen';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get nutritionalInformation => 'Nährwertinformationen';

  @override
  String get per100g => 'pro 100g';

  @override
  String get recalculate => 'Neu berechnen';

  @override
  String get recalculateNutrition => 'Nährwerte neu berechnen';

  @override
  String get nutritionRecalculated => 'Nährwerte neu berechnet';

  @override
  String get addManually => 'Manuell hinzufügen';

  @override
  String get saveDish => 'Gericht speichern';

  @override
  String get saving => 'Speichern...';

  @override
  String get mg => 'mg';

  @override
  String get mcg => 'mcg';

  @override
  String get iu => 'IE';

  @override
  String get g => 'g';

  @override
  String get ml => 'ml';

  @override
  String get cup => 'Tasse';

  @override
  String get tbsp => 'EL';

  @override
  String get tsp => 'TL';

  @override
  String get oz => 'oz';

  @override
  String get piece => 'Stück';

  @override
  String get slice => 'Scheibe';

  @override
  String get tablespoon => 'Esslöffel';

  @override
  String get teaspoon => 'Teelöffel';

  @override
  String get ounce => 'Unze';

  @override
  String get pound => 'Pfund';

  @override
  String get gram => 'Gramm';

  @override
  String get kilogram => 'Kilogramm';

  @override
  String get milliliter => 'Milliliter';

  @override
  String get liter => 'Liter';

  @override
  String get editIngredient => 'Zutat bearbeiten';

  @override
  String get deleteIngredient => 'Zutat löschen';

  @override
  String get confirmDeleteIngredient => 'Sind Sie sicher, dass Sie diese Zutat löschen möchten?';

  @override
  String get ingredientDeleted => 'Zutat gelöscht';

  @override
  String get ingredientAdded => 'Zutat hinzugefügt';

  @override
  String get ingredientUpdated => 'Zutat aktualisiert';

  @override
  String get errorAddingIngredient => 'Fehler beim Hinzufügen der Zutat';

  @override
  String get errorUpdatingIngredient => 'Fehler beim Aktualisieren der Zutat';

  @override
  String get errorDeletingIngredient => 'Fehler beim Löschen der Zutat';

  @override
  String get noNutritionData => 'Keine Nährwertdaten verfügbar';

  @override
  String get ingredientNamePlaceholder => 'Zutatennamen eingeben';

  @override
  String get quantity => 'Menge';

  @override
  String get quantityPlaceholder => '0';

  @override
  String get pleaseEnterQuantity => 'Bitte geben Sie eine Menge ein';

  @override
  String get pleaseEnterValidNumber => 'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get unitPlaceholder => 'g';

  @override
  String get pleaseEnterUnit => 'Bitte geben Sie eine Einheit ein';

  @override
  String get nutritionInformation => 'Nährwertinformationen';

  @override
  String get nutritionPer100g => 'Nährwerte pro 100g';

  @override
  String get caloriesPlaceholder => '0';

  @override
  String get kcal => 'kcal';

  @override
  String get grams => 'g';

  @override
  String get logDish => 'Gericht eintragen';

  @override
  String get logDishTitle => 'Gericht eintragen';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get selectMealType => 'Mahlzeitentyp auswählen';

  @override
  String get portionSize => 'Portionsgröße';

  @override
  String get notes => 'Notizen';

  @override
  String get addNotes => 'Notizen hinzufügen (optional)';

  @override
  String get calculatedNutrition => 'Berechnete Nährwerte';

  @override
  String get dishLoggedSuccessfully => 'Gericht erfolgreich protokolliert!';

  @override
  String get select => 'Auswählen';

  @override
  String errorOpeningDishScreen(Object error) {
    return 'Fehler beim Öffnen des Gerichtsbildschirms: $error';
  }

  @override
  String errorPickingImage(Object error) {
    return 'Fehler beim Auswählen des Bildes: $error';
  }

  @override
  String get agentProcessingSteps => 'Agenten-Prozessschritte';

  @override
  String get copyAll => 'Alles kopieren';

  @override
  String get viewFullData => 'Gesamte Daten anzeigen';

  @override
  String get viewFullPrompt => 'Gesamtes Prompt anzeigen';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String get barcodeScanningComingSoon => 'Barcode-Scan bald verfügbar!';

  @override
  String get productSearchComingSoon => 'Produktsuche bald verfügbar!';

  @override
  String get configureApiKeyForAiTips => 'Bitte OpenAI-API-Schlüssel in den Einstellungen konfigurieren, um KI-Tipps zu nutzen';

  @override
  String get failedToGetAiTip => 'Fehler beim Abrufen des KI-Tipps. Bitte erneut versuchen.';

  @override
  String get aiNutritionTip => 'KI Ernährungstipp';

  @override
  String get available => 'Verfügbar';

  @override
  String get notAvailable => 'Nicht verfügbar';

  @override
  String get chatAndAiSettings => 'Chat & KI Einstellungen';

  @override
  String get chatAgentOptions => 'Chat-Agent Optionen';

  @override
  String get enableAgentModeDeepSearch => 'Agent-Modus, Deep Search und mehr aktivieren';

  @override
  String get chatProfiles => 'Chat-Profile';

  @override
  String get userChatProfile => 'Ihr Profil';

  @override
  String get botChatProfile => 'Bot-Profil';

  @override
  String get customizeUserProfile => 'Passen Sie Ihr Chat-Profil an';

  @override
  String get customizeBotProfile => 'Passen Sie die Persönlichkeit und das Aussehen des Bots an';

  @override
  String get username => 'Benutzername';

  @override
  String get botName => 'Bot-Name';

  @override
  String get avatar => 'Avatar';

  @override
  String get changeAvatar => 'Avatar ändern';

  @override
  String get removeAvatar => 'Avatar entfernen';

  @override
  String get personality => 'Persönlichkeit';

  @override
  String get selectPersonality => 'Persönlichkeit auswählen';

  @override
  String get professionalNutritionist => 'Professioneller Ernährungsberater';

  @override
  String get casualGymBro => 'Entspannter Gym-Bro';

  @override
  String get angryGreg => 'Wütender Greg';

  @override
  String get veryAngryBro => 'Sehr wütender Bro';

  @override
  String get fitnessCoach => 'Fitness-Trainer';

  @override
  String get niceAndFriendly => 'Nett & freundlich';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get profileSaved => 'Profil erfolgreich gespeichert';

  @override
  String get profileSaveFailed => 'Profil speichern fehlgeschlagen';

  @override
  String get editUserProfile => 'Benutzerprofil bearbeiten';

  @override
  String get editBotProfile => 'Bot-Profil bearbeiten';

  @override
  String get connectToHealth => 'Mit Gesundheitsdaten verbinden';

  @override
  String get healthDataSync => 'Gesundheitsdaten-Synchronisation';

  @override
  String get healthConnected => 'Gesundheitsdaten verbunden';

  @override
  String get healthDisconnected => 'Gesundheitsdaten nicht verbunden';

  @override
  String get syncHealthData => 'Gesundheitsdaten synchronisieren';

  @override
  String get healthPermissionRequired => 'Gesundheitsberechtigungen sind erforderlich, um Ihre Daten zu synchronisieren';

  @override
  String get healthSyncSuccess => 'Gesundheitsdaten erfolgreich synchronisiert';

  @override
  String get healthSyncFailed => 'Synchronisation der Gesundheitsdaten fehlgeschlagen';

  @override
  String lastSynced(String date) {
    return 'Zuletzt synchronisiert: $date';
  }

  @override
  String get healthPermissionDenied => 'Gesundheitsberechtigung Verweigert';

  @override
  String get healthPermissionDeniedMessage => 'Um deine Gesundheitsdaten zu synchronisieren, benötigt PlatePal Zugriff auf deine Gesundheitsinformationen. Du kannst Berechtigungen in den Einstellungen deines Telefons erteilen.';

  @override
  String get openSettings => 'Einstellungen Öffnen';

  @override
  String get healthNotAvailable => 'Gesundheitsdaten Nicht Verfügbar';

  @override
  String get healthNotAvailableMessage => 'Gesundheitsdaten sind auf diesem Gerät nicht verfügbar. Stelle sicher, dass du Health Connect (Android) oder die Health-App (iOS) installiert und konfiguriert hast.';

  @override
  String get scanBarcodeToAddProduct => 'Barcode scannen, um Produkt hinzuzufügen';

  @override
  String get searchForProducts => 'Nach Produkten suchen';

  @override
  String get productNotFound => 'Produkt nicht gefunden';

  @override
  String get productAddedSuccessfully => 'Produkt erfolgreich hinzugefügt';

  @override
  String errorScanningBarcode(String error) {
    return 'Fehler beim Scannen des Barcodes';
  }

  @override
  String errorSearchingProduct(String error) {
    return 'Fehler bei der Produktsuche';
  }

  @override
  String get barcodeScanner => 'Barcode-Scanner';

  @override
  String get productSearch => 'Produktsuche';

  @override
  String get tapToScan => 'Zum Scannen tippen';

  @override
  String get scanningBarcode => 'Barcode wird gescannt...';

  @override
  String get searchProducts => 'Produkte suchen';

  @override
  String get noProductsFound => 'Keine Produkte gefunden';

  @override
  String get addToIngredients => 'Zu Zutaten hinzufügen';

  @override
  String get productDetails => 'Produktdetails';

  @override
  String get brand => 'Marke';

  @override
  String get cameraPermissionRequired => 'Kameraberechtigung erforderlich';

  @override
  String get grantCameraPermission => 'Kameraberechtigung erteilen';

  @override
  String get barcodeNotFound => 'Barcode nicht gefunden';

  @override
  String get enterProductName => 'Produktnamen eingeben';

  @override
  String get tryDifferentKeywords => 'Versuchen Sie andere Suchbegriffe';

  @override
  String get selectServingSize => 'Portionsgröße auswählen';

  @override
  String get enableCameraPermission => 'Kameraberechtigung aktivieren';

  @override
  String get macroCustomization => 'Makro-Anpassung';

  @override
  String get macroCustomizationInfo => 'Passen Sie Ihre Makro-Ziele an. Alle Prozentsätze müssen sich zu 100% addieren.';

  @override
  String get macroTargetsUpdated => 'Makro-Ziele erfolgreich aktualisiert';

  @override
  String get resetToDefaults => 'Auf Standard zurücksetzen';

  @override
  String get healthDataTitle => 'Gesundheitsdaten';

  @override
  String get healthDataTodayPartial => 'Gesundheitsdaten (Heute - Teilweise)';

  @override
  String get estimatedCaloriesToday => 'Geschätzte Kalorien (Heute)';

  @override
  String get estimatedCalories => 'Geschätzte Kalorien';

  @override
  String get healthDataMessage => 'Diese Daten wurden von den Gesundheitsdaten auf Ihrem Telefon gesammelt und liefern genaue Informationen über verbrannte Kalorien aus Ihren Fitnessaktivitäten für diesen vollständigen Tag.';

  @override
  String get healthDataTodayMessage => 'Diese Daten wurden von den Gesundheitsdaten auf Ihrem Telefon gesammelt. Da der heutige Tag noch nicht abgeschlossen ist, zeigt dies die bisher heute verbrannten Kalorien an. Ihre Gesamtsumme kann sich erhöhen, wenn Sie den Tag über weitere Aktivitäten durchführen.';

  @override
  String get estimatedCaloriesTodayMessage => 'Dies ist Ihr geschätzter Kalorienverbrauch für heute basierend auf Ihrem Aktivitätslevel. Da der Tag noch nicht abgeschlossen ist, repräsentiert dies Ihren Grundumsatz plus geschätzte Aktivität. Ihre tatsächlich verbrannten Kalorien können höher sein, wenn Sie heute mehr Aktivitäten durchführen.';

  @override
  String get estimatedCaloriesMessage => 'Diese Daten sind basierend auf Ihren Profileinstellungen und Aktivitätslevel geschätzt, da für dieses Datum keine Gesundheitsdaten verfügbar waren.';

  @override
  String get analyzeTargets => 'Ziele analysieren';

  @override
  String get debugHealthData => 'Gesundheitsdaten debuggen';

  @override
  String get disconnectHealth => 'Gesundheit trennen';

  @override
  String get calorieTargetAnalysis => 'Kalorienziel-Analyse';

  @override
  String get daysAnalyzed => 'Analysierte Tage';

  @override
  String get currentTarget => 'Aktuelles Ziel';

  @override
  String get averageExpenditure => 'Durchschnittlicher Verbrauch';

  @override
  String get suggestedTarget => 'Vorgeschlagenes Ziel';

  @override
  String get applySuggestion => 'Vorschlag anwenden';

  @override
  String get calorieTargetsUpdated => 'Kalorienziele erfolgreich aktualisiert!';

  @override
  String get failedToUpdateTargets => 'Aktualisierung der Kalorienziele fehlgeschlagen';

  @override
  String get loadMore => 'Mehr laden';

  @override
  String get localDishes => 'Lokale Gerichte';

  @override
  String get localIngredients => 'Lokale Zutaten';
}
