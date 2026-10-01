// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get screensCalendarHasMealsLogged => 'tiene comidas registradas';

  @override
  String get screensCalendarFailedToLoadDates =>
      'No se pudieron cargar las fechas del calendario';

  @override
  String get screensCalendarFailedToLoadSummary =>
      'No se pudo cargar el resumen nutricional';

  @override
  String get screensCalendarProfileNudge =>
      'Configura tu perfil para obtener objetivos diarios';

  @override
  String get screensCalendarSetUpProfile => 'Configurar perfil';

  @override
  String get screensCalendarLogMeal => 'Registrar comida';

  @override
  String screensCalendarCaloriesPerServing(int calories) {
    return '$calories kcal por ración';
  }

  @override
  String get componentsCalendarCalendarDayDetailErrorLoadingMeals =>
      'No se pudieron cargar las comidas de este día';

  @override
  String get componentsCalendarCalendarDayDetailNoMealsLoggedForDay =>
      'No hay comidas registradas para este día';

  @override
  String get componentsCalendarCalendarDayDetailUnknownDish =>
      'Plato Desconocido';

  @override
  String get componentsCalendarMacroSummaryCalories => 'Calorías';

  @override
  String get componentsCalendarMacroSummaryCarbs => 'Carbohidratos';

  @override
  String get componentsCalendarMacroSummaryEstimatedCalories =>
      'Calorías Estimadas';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesMessage =>
      'Estos datos están estimados basándose en la configuración de tu perfil y nivel de actividad ya que los datos de salud no estaban disponibles para esta fecha.';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesToday =>
      'Calorías Estimadas (Hoy)';

  @override
  String get componentsCalendarMacroSummaryEstimatedCaloriesTodayMessage =>
      'Este es tu gasto calórico estimado para hoy basado en tu nivel de actividad. Como el día aún no está completo, esto representa tu tasa metabólica basal más actividad estimada. Tus calorías realmente quemadas pueden ser mayores si realizas más actividades hoy.';

  @override
  String get componentsCalendarMacroSummaryFat => 'Grasa';

  @override
  String get componentsCalendarMacroSummaryFiber => 'Fibra';

  @override
  String get componentsCalendarMacroSummaryGetAiTip => 'Obtener Consejo IA';

  @override
  String componentsCalendarMacroSummaryPercentOfGoal(int percent) {
    return '$percent % del objetivo';
  }

  @override
  String componentsCalendarMacroSummaryOverBy(String amount, String unit) {
    return 'Por encima del objetivo en $amount $unit';
  }

  @override
  String get componentsCalendarMacroSummaryHealthDataMessage =>
      'Estos datos fueron recopilados de los datos de salud en tu teléfono, proporcionando información precisa sobre las calorías quemadas de tus actividades de fitness para este día completo.';

  @override
  String get componentsCalendarMacroSummaryHealthDataTitle => 'Datos de Salud';

  @override
  String get componentsCalendarMacroSummaryHealthDataTodayMessage =>
      'Estos datos fueron recopilados de los datos de salud en tu teléfono. Como el día de hoy aún no está completo, esto representa las calorías quemadas hasta ahora. Tu total puede aumentar mientras continúes con actividades durante el día.';

  @override
  String get componentsCalendarMacroSummaryHealthDataTodayPartial =>
      'Datos de Salud (Hoy - Parcial)';

  @override
  String get componentsCalendarMacroSummaryNutritionSummary =>
      'Resumen Nutricional';

  @override
  String get componentsCalendarMacroSummaryProtein => 'Proteína';

  @override
  String get componentsCalendarMacroSummaryCompactProtein => 'Proteína';

  @override
  String get componentsCalendarMacroSummaryCompactCarbs => 'Carb.';

  @override
  String get componentsCalendarMacroSummaryCompactFat => 'Grasa';

  @override
  String get componentsCommonOk => 'Aceptar';

  @override
  String get componentsChatAgentStepsModalAgentProcessingSteps =>
      'Pasos de procesamiento del agente';

  @override
  String get componentsChatAgentStepsModalCopiedToClipboard =>
      'Copiado al portapapeles';

  @override
  String get componentsChatAgentStepsModalCopyAll => 'Copiar todo';

  @override
  String get componentsChatAgentStepsModalViewFullData => 'Ver datos completos';

  @override
  String get componentsChatAgentStepsModalViewFullPrompt =>
      'Ver prompt completo';

  @override
  String get componentsChatAgentStepsModalThinkingProcessTitle =>
      '🧠 Proceso de Pensamiento';

  @override
  String get componentsChatAgentStepsModalThinkingProcessSubtitle =>
      'Pasos de pensamiento del agente en tiempo real';

  @override
  String get componentsChatAgentStepsModalProcessingStepsTitle =>
      '⚙️ Pasos de Procesamiento';

  @override
  String get componentsChatAgentStepsModalProcessingStepsSubtitle =>
      'Ejecución detallada paso a paso';

  @override
  String get componentsChatAgentStepsModalProcessingSummary =>
      'Resumen de Procesamiento';

  @override
  String get componentsChatAgentStepsModalCopySummaryTooltip =>
      'Copiar datos de resumen';

  @override
  String get componentsChatAgentStepsModalProcessingTime =>
      'Tiempo de Procesamiento';

  @override
  String get componentsChatAgentStepsModalBotType => 'Tipo de Bot';

  @override
  String get componentsChatAgentStepsModalTotalSteps => 'Pasos Totales';

  @override
  String get componentsChatAgentStepsModalSkippedSteps => 'Pasos Omitidos';

  @override
  String get componentsChatAgentStepsModalFailedSteps => 'Pasos Fallidos';

  @override
  String get componentsChatAgentStepsModalErrorRecovery =>
      'Recuperación de Errores';

  @override
  String get componentsChatAgentStepsModalCompletedSteps => 'Pasos Completados';

  @override
  String get componentsChatAgentStepsModalDeepSearch => 'Búsqueda Profunda';

  @override
  String get componentsChatAgentStepsModalEnabled => 'Habilitado';

  @override
  String get componentsChatAgentStepsModalDisabled => 'Deshabilitado';

  @override
  String get componentsChatAgentStepsModalModifications => 'Modificaciones';

  @override
  String get componentsChatAgentStepsModalNoModifications =>
      'Ninguna necesaria ✨';

  @override
  String get componentsChatAgentStepsModalPerfectProcessing =>
      '¡Procesamiento perfecto! No se necesitaron correcciones ni modificaciones.';

  @override
  String get componentsChatAgentStepsModalPipelineModificationsTitle =>
      '✨ Modificaciones del Pipeline';

  @override
  String get componentsChatAgentStepsModalPipelineModificationsSubtitle =>
      'No se necesitaron modificaciones - ¡tu solicitud se procesó sin problemas!';

  @override
  String get componentsChatAgentStepsModalStepModifications =>
      '🔧 Modificaciones de Paso';

  @override
  String get componentsChatAgentStepsModalCopyModifications =>
      'Copiar modificaciones';

  @override
  String componentsChatAgentStepsModalSummaryLabel(String summary) {
    return 'Resumen: $summary';
  }

  @override
  String get componentsChatAgentStepsModalEnhancedSystemPrompt =>
      '🤖 Prompt de Sistema Mejorado';

  @override
  String get componentsChatAgentStepsModalCopyEnhancedPrompt =>
      'Copiar prompt de sistema mejorado';

  @override
  String get componentsChatDishSuggestionCardHighProtein =>
      'Plato alto en proteína';

  @override
  String get componentsChatDishSuggestionCardHighCarb =>
      'Plato alto en carbohidratos';

  @override
  String get componentsChatDishSuggestionCardHighFat => 'Plato alto en grasa';

  @override
  String get componentsChatDishSuggestionCardBalanced => 'Plato equilibrado';

  @override
  String get componentsChatDishSuggestionCardUnbalanced =>
      'Plato desequilibrado';

  @override
  String get componentsChatDishSuggestionCardProtein => 'Proteína';

  @override
  String get componentsChatDishSuggestionCardCarbs => 'Carbohidratos';

  @override
  String get componentsChatDishSuggestionCardFat => 'Grasa';

  @override
  String get componentsChatDishSuggestionCardCalories => 'Calorías';

  @override
  String get componentsChatDishSuggestionCardInspect => 'Detalles';

  @override
  String get componentsChatMessageBubbleYou => 'Tú';

  @override
  String get componentsChatMessageBubbleAssistant => 'Asistente';

  @override
  String get componentsChatMessageBubbleBotTag => 'Bot';

  @override
  String get componentsChatMessageBubbleSending => 'Enviando...';

  @override
  String get componentsChatMessageBubbleSuggestedDishes => 'Platos sugeridos';

  @override
  String get componentsChatMessageBubbleRecommendation => 'Recomendación';

  @override
  String get componentsChatMessageBubbleNoRecommendationsAvailable =>
      'No hay recomendaciones disponibles.';

  @override
  String componentsChatAgentStepsModalLengthLabel(int count) {
    return 'Longitud: $count caracteres';
  }

  @override
  String get componentsChatAgentStepsModalTechnicalDetails =>
      'Detalles Técnicos';

  @override
  String get componentsChatAgentStepsModalDataChanges => 'Cambios de Datos';

  @override
  String get componentsChatAgentStepsModalBefore => 'Antes';

  @override
  String get componentsChatAgentStepsModalAfter => 'Después';

  @override
  String get componentsChatAgentStepsModalStatusSkipped => 'Omitido';

  @override
  String get componentsChatAgentStepsModalStatusErrorRecovered =>
      'Error recuperado';

  @override
  String get componentsChatAgentStepsModalStatusErrorHandlingFailed =>
      'Fallo en manejo de error';

  @override
  String get componentsChatAgentStepsModalStatusCompletedSuccessfully =>
      'Completado con éxito';

  @override
  String get componentsChatAgentStepsModalFailed => 'Fallido';

  @override
  String get componentsChatAgentStepsModalSeverityLow => 'Bajo';

  @override
  String get componentsChatAgentStepsModalSeverityMedium => 'Medio';

  @override
  String get componentsChatAgentStepsModalSeverityHigh => 'Alto';

  @override
  String get componentsChatAgentStepsModalSeverityCritical => 'Crítico';

  @override
  String get componentsChatAgentStepsModalBadgeEmergencyOverrides =>
      'Sobrescrituras de emergencia';

  @override
  String get componentsChatAgentStepsModalBadgeAiValidations =>
      'Validaciones IA';

  @override
  String get componentsChatAgentStepsModalBadgeAutomaticFixes =>
      'Correcciones automáticas';

  @override
  String componentsChatAgentStepsModalTotalModifications(int count) {
    return 'Total de modificaciones: $count';
  }

  @override
  String get componentsChatAgentStepsModalSkipDetails => '⏭️ Omitir Detalles';

  @override
  String get componentsChatAgentStepsModalMetadata => '📊 Metadatos';

  @override
  String get componentsChatAgentStepsModalDataOutput => '📤 Salida de Datos';

  @override
  String get componentsChatAgentStepsModalErrorDetails =>
      '❌ Detalles del Error';

  @override
  String get componentsChatAgentStepsModalRawStepData =>
      '🔍 Datos Brutos del Paso';

  @override
  String componentsChatAgentStepsModalIdLabel(String id) {
    return 'ID: $id';
  }

  @override
  String componentsChatAgentStepsModalTimeLabel(String time) {
    return 'Tiempo: $time';
  }

  @override
  String get componentsChatAgentStepsModalUnknownStep => 'Paso desconocido';

  @override
  String get componentsChatAgentStepsModalNoReasonProvided =>
      'No se indicó ningún motivo';

  @override
  String get componentsChatAgentStepsModalNoSummaryAvailable =>
      'No hay ningún resumen disponible';

  @override
  String componentsChatAgentStepsModalListItems(int count) {
    return 'Lista con $count elementos';
  }

  @override
  String componentsChatAgentStepsModalMapKeys(int count) {
    return 'Mapa con $count claves';
  }

  @override
  String componentsChatAgentStepsModalMoreItems(int count) {
    return '... y $count elementos más';
  }

  @override
  String get componentsCommonCopyToClipboard => 'Copiar al portapapeles';

  @override
  String get componentsChatBotProfileCustomizationDialogAngryGreg =>
      'Greg Enojado';

  @override
  String get componentsChatBotProfileCustomizationDialogBotName =>
      'Nombre del Bot';

  @override
  String get componentsChatBotProfileCustomizationDialogCancel => 'Cancelar';

  @override
  String get componentsChatBotProfileCustomizationDialogCasualGymBro =>
      'Gym Bro Casual';

  @override
  String get componentsChatBotProfileCustomizationDialogChangeAvatar =>
      'Cambiar Avatar';

  @override
  String get componentsChatBotProfileCustomizationDialogChooseFromGallery =>
      'Elegir de Galería';

  @override
  String get componentsChatBotProfileCustomizationDialogEditBotProfile =>
      'Editar Perfil del Bot';

  @override
  String get componentsChatBotProfileCustomizationDialogFitnessCoach =>
      'Entrenador de Fitness';

  @override
  String get componentsChatBotProfileCustomizationDialogNiceAndFriendly =>
      'Amable y Amigable';

  @override
  String get componentsChatBotProfileCustomizationDialogPersonality =>
      'Personalidad';

  @override
  String
  get componentsChatBotProfileCustomizationDialogProfessionalNutritionist =>
      'Nutricionista Profesional';

  @override
  String get componentsChatBotProfileCustomizationDialogProfileSaved =>
      'Perfil guardado exitosamente';

  @override
  String get componentsChatBotProfileCustomizationDialogProfileSaveFailed =>
      'Error al guardar perfil';

  @override
  String get componentsChatBotProfileCustomizationDialogRemoveAvatar =>
      'Eliminar Avatar';

  @override
  String get componentsChatBotProfileCustomizationDialogRequiredField =>
      'Este campo es requerido';

  @override
  String get componentsChatBotProfileCustomizationDialogSave => 'Guardar';

  @override
  String get componentsChatBotProfileCustomizationDialogTakePhoto =>
      'Tomar Foto';

  @override
  String get componentsChatBotProfileCustomizationDialogVeryAngryBro =>
      'Bro Muy Enojado';

  @override
  String get componentsChatBotPersonalityDescriptionNutritionist =>
      'Profesional y Basado en Evidencia';

  @override
  String get componentsChatBotPersonalityDescriptionCasualGymbro =>
      'Casual y Motivador';

  @override
  String get componentsChatBotPersonalityDescriptionAngryGreg =>
      'Intenso y Enfocado en Suplementos';

  @override
  String get componentsChatBotPersonalityDescriptionVeryAngryBro =>
      'Extremadamente Intenso';

  @override
  String get componentsChatBotPersonalityDescriptionFitnessCoach =>
      'Alentador y Solidario';

  @override
  String get componentsChatBotPersonalityDescriptionNice =>
      'Amable y Servicial';

  @override
  String get componentsChatEditBotProfileTooltip => 'Editar perfil del bot';

  @override
  String componentsChatChatInputErrorPickingImage(Object error) {
    return 'Error al seleccionar la imagen: $error';
  }

  @override
  String componentsChatMessageBubbleModificationEmergency(int count) {
    return '$count correcciones de emergencia aplicadas';
  }

  @override
  String componentsChatMessageBubbleModificationAi(int count) {
    return '$count mejoras de IA aplicadas';
  }

  @override
  String componentsChatMessageBubbleModificationAutomatic(int count) {
    return '$count mejoras automáticas aplicadas';
  }

  @override
  String get componentsChatChatInputImageAttached => 'Imagen adjuntada';

  @override
  String get componentsChatChatInputIngredientsAdded =>
      'Ingredientes agregados';

  @override
  String componentsChatChatInputRemoveIngredient(String name) {
    return 'Quitar $name';
  }

  @override
  String get componentsChatChatInputIngredientAdded =>
      'Ingrediente añadido al chat';

  @override
  String get componentsChatChatInputAttachments => 'Añadir archivos adjuntos';

  @override
  String get componentsChatChatInputScanBarcode => 'Escanear Código de Barras';

  @override
  String get componentsChatChatInputSearchProduct => 'Buscar Producto';

  @override
  String get componentsChatChatInputSendMessage => 'Enviar mensaje';

  @override
  String get componentsChatChatInputTypeMessage => 'Escribe un mensaje...';

  @override
  String get componentsChatChatWelcomeAnalyzeNutrition => 'Analizar nutrición';

  @override
  String get componentsChatChatWelcomeCalculateMacros => 'Calcular macros';

  @override
  String get componentsChatChatWelcomeChatWelcomeSubtitle =>
      'Tu asistente de nutrición IA está aquí para ayudar';

  @override
  String get componentsChatChatWelcomeChatWelcomeTitle =>
      'Bienvenido a PlatePal';

  @override
  String get componentsChatChatWelcomeFindAlternatives =>
      'Encontrar alternativas';

  @override
  String get componentsChatChatWelcomeGetStartedToday => 'Comienza hoy';

  @override
  String get componentsChatChatWelcomeIngredientInfo => 'Info de ingredientes';

  @override
  String get componentsChatChatWelcomeMealPlan => 'Ayuda con plan de comidas';

  @override
  String get componentsChatChatWelcomeSuggestMeal => 'Sugerir comida';

  @override
  String get componentsChatChatWelcomeSuggestMealSubtitle =>
      'Obtén recomendaciones personalizadas de comidas';

  @override
  String get componentsChatChatWelcomeSuggestMealMessage =>
      'Sugiéreme una comida saludable basada en mis objetivos de fitness';

  @override
  String get componentsChatChatWelcomeAnalyzeNutritionSubtitle =>
      'Analiza los valores nutricionales de tus comidas';

  @override
  String get componentsChatChatWelcomeAnalyzeNutritionMessage =>
      'Ayúdame a analizar los valores nutricionales de mi comida';

  @override
  String get componentsChatChatWelcomeFindAlternativesSubtitle =>
      'Descubre alternativas saludables de alimentos';

  @override
  String get componentsChatChatWelcomeFindAlternativesMessage =>
      'Encuentra alternativas saludables para mi comida actual';

  @override
  String get componentsChatChatWelcomeCalculateMacrosSubtitle =>
      'Calcula los macros para tus comidas';

  @override
  String get componentsChatChatWelcomeCalculateMacrosMessage =>
      'Ayúdame a calcular los macros para mis comidas';

  @override
  String get componentsChatChatWelcomeMealPlanSubtitle =>
      'Crea planes de comidas semanales';

  @override
  String get componentsChatChatWelcomeMealPlanMessage =>
      'Ayúdame a crear un plan de comidas semanal';

  @override
  String get componentsChatChatWelcomeIngredientInfoSubtitle =>
      'Aprende más sobre los ingredientes y sus beneficios';

  @override
  String get componentsChatChatWelcomeIngredientInfoMessage =>
      'Háblame sobre los beneficios nutricionales de los ingredientes';

  @override
  String get componentsChatChatWelcomeWhatCanIHelpWith =>
      '¿En qué puedo ayudarte?';

  @override
  String get componentsChatDishSuggestionCardDetails => 'Detalles';

  @override
  String componentsChatDishSuggestionCardErrorOpeningDishScreen(Object error) {
    return 'Error al abrir la pantalla del plato: $error';
  }

  @override
  String get componentsChatDishSuggestionCardLogDish => 'Registrar Plato';

  @override
  String get componentsChatMessageBubbleClose => 'Cerrar';

  @override
  String get componentsChatMessageBubbleIngredients => 'Ingredientes';

  @override
  String get componentsChatMessageBubbleMessageCopied =>
      'Mensaje copiado al portapapeles';

  @override
  String get componentsChatMessageBubbleRetryMessage => 'Reintentar';

  @override
  String get componentsChatMessageBubbleSelect => 'Seleccionar';

  @override
  String get componentsChatMessageBubbleTapToViewAgentSteps =>
      'Toca para ver los pasos del agente';

  @override
  String get componentsChatMessageBubbleYesterday => 'Ayer';

  @override
  String get componentsChatNutritionAnalysisCardDishName => 'Nombre del Plato';

  @override
  String get componentsChatNutritionAnalysisCardNutritionAnalysis =>
      'Análisis Nutricional';

  @override
  String get componentsChatQuickActionsQuickActions => 'Acciones Rápidas';

  @override
  String get componentsChatUserProfileCustomizationDialogEditUserProfile =>
      'Editar Perfil de Usuario';

  @override
  String get componentsChatUserProfileCustomizationDialogUsername =>
      'Nombre de usuario';

  @override
  String get componentsDishesDishCardDelete => 'Eliminar';

  @override
  String get componentsDishesDishCardEdit => 'Editar';

  @override
  String get componentsDishesDishFormIngredientFormModalAddIngredient =>
      'Agregar Ingrediente';

  @override
  String get componentsDishesDishFormIngredientFormModalEditIngredient =>
      'Editar Ingrediente';

  @override
  String get componentsDishesDishFormIngredientFormModalGrams => 'g';

  @override
  String get componentsDishesDishFormIngredientFormModalIngredientName =>
      'Nombre del Ingrediente';

  @override
  String
  get componentsDishesDishFormIngredientFormModalIngredientNamePlaceholder =>
      'Ingrese nombre del ingrediente';

  @override
  String get componentsDishesDishFormIngredientFormModalKcal => 'kcal';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionInformation =>
      'Información Nutricional';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPer100g =>
      'Nutrición por 100g';

  @override
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterIngredientName =>
      'Por favor ingresa un nombre para el ingrediente';

  @override
  String get componentsDishesDishFormIngredientFormModalPleaseEnterQuantity =>
      'Por favor ingrese una cantidad';

  @override
  String
  get componentsDishesDishFormIngredientFormModalPleaseEnterValidNumber =>
      'Por favor ingrese un número válido';

  @override
  String get componentsDishesDishFormIngredientFormModalQuantity => 'Cantidad';

  @override
  String get componentsDishesDishFormIngredientFormModalQuantityPlaceholder =>
      'Ingrese cantidad';

  @override
  String get componentsDishesDishFormSmartNutritionCardNutritionalInformation =>
      'Información Nutricional';

  @override
  String get componentsModalsDishLogModalAddNotes => 'Agregar notas (opcional)';

  @override
  String get componentsModalsDishLogModalBreakfast => 'Desayuno';

  @override
  String get componentsModalsDishLogModalCalculatedNutrition =>
      'Nutrición Calculada';

  @override
  String get componentsModalsDishLogModalDinner => 'Cena';

  @override
  String get componentsModalsDishLogModalDishLoggedSuccessfully =>
      '¡Plato registrado exitosamente!';

  @override
  String get componentsModalsDishLogModalErrorLoggingDish =>
      'Error al registrar el plato';

  @override
  String get componentsModalsDishLogModalLogDishTitle => 'Registrar Plato';

  @override
  String get componentsModalsDishLogModalLunch => 'Almuerzo';

  @override
  String get componentsModalsDishLogModalNotes => 'Notas';

  @override
  String get componentsModalsDishLogModalPortionSize => 'Tamaño de Porción';

  @override
  String get componentsModalsDishLogModalSelectDate => 'Seleccionar Fecha';

  @override
  String get componentsModalsDishLogModalSelectMealType =>
      'Seleccionar Tipo de Comida';

  @override
  String get componentsModalsDishLogModalSelectTime => 'Seleccionar hora';

  @override
  String get componentsModalsDishLogModalSnack => 'Merienda';

  @override
  String get componentsScannerBarcodeScannerBarcodeScanner =>
      'Escáner de código de barras';

  @override
  String componentsScannerBarcodeScannerErrorScanningBarcode(String error) {
    return 'Error al escanear el código de barras';
  }

  @override
  String get componentsScannerBarcodeScannerOpenSettings =>
      'Abrir Configuración';

  @override
  String get componentsScannerBarcodeScannerProductNotFound =>
      'Producto no encontrado';

  @override
  String get componentsScannerBarcodeScannerScanBarcodeToAddProduct =>
      'Escanea el código de barras para agregar producto';

  @override
  String get componentsScannerBarcodeScannerScanningBarcode =>
      'Escaneando código de barras...';

  @override
  String get componentsScannerBarcodeScannerClose => 'Cerrar';

  @override
  String get componentsScannerBarcodeScannerPermissionHint =>
      'Permite el acceso a la cámara para esta aplicación en los ajustes del sistema.';

  @override
  String componentsScannerBarcodeScannerScannerError(String errorCode) {
    return 'Error del escáner: $errorCode';
  }

  @override
  String get componentsScannerBarcodeScannerServiceUnavailable =>
      'El servicio de alimentos no está disponible. Inténtalo de nuevo.';

  @override
  String get componentsScannerBarcodeScannerTorchOn => 'Encender la linterna';

  @override
  String get componentsScannerBarcodeScannerTorchOff => 'Apagar la linterna';

  @override
  String get componentsScannerProductSearchLoadMore => 'Cargar más';

  @override
  String get componentsScannerProductSearchLocalDishes => 'Platos locales';

  @override
  String get componentsScannerProductSearchLocalIngredients =>
      'Ingredientes locales';

  @override
  String get componentsScannerProductSearchNoProductsFound =>
      'No se encontraron productos';

  @override
  String get componentsScannerProductSearchProductSearch =>
      'Búsqueda de producto';

  @override
  String get componentsScannerProductSearchSearchProducts => 'Buscar productos';

  @override
  String get componentsScannerProductSearchFiltersAndSort => 'Filtros y orden';

  @override
  String get componentsScannerProductSearchNutriScore => 'NUTRI-SCORE';

  @override
  String get componentsScannerProductSearchAny => 'Cualquiera';

  @override
  String get componentsScannerProductSearchSortBy => 'Ordenar por';

  @override
  String get componentsScannerProductSearchPopular => 'Populares';

  @override
  String componentsScannerProductSearchResultsFor(String query) {
    return 'Resultados para \"$query\"';
  }

  @override
  String get componentsScannerProductSearchMyDatabase => 'Mi base de datos';

  @override
  String get componentsScannerProductSearchGlobalFeed => 'Catálogo global';

  @override
  String get componentsScannerProductSearchEndOfResults =>
      'Fin de los resultados';

  @override
  String get componentsScannerProductSearchSelectCategoryOrSearch =>
      'Elige una categoría o escribe para buscar';

  @override
  String componentsScannerProductSearchNoResultsFor(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get componentsScannerProductSearchUnknown => 'Desconocido';

  @override
  String get componentsScannerProductSearchKcal => 'kcal';

  @override
  String get componentsScannerProductSearchProteinAbbreviation => 'P:';

  @override
  String get componentsScannerProductSearchCarbsAbbreviation => 'C:';

  @override
  String get componentsScannerProductSearchFatAbbreviation => 'G:';

  @override
  String get componentsScannerProductSearchGramsAbbreviation => 'g';

  @override
  String get componentsScannerProductSearchIngredient => 'Ingrediente';

  @override
  String componentsScannerProductSearchDishIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredientes — plato',
      one: '1 ingrediente — plato',
    );
    return '$_temp0';
  }

  @override
  String get componentsScannerProductSearchBrowseUnavailable =>
      'No se pueden cargar los productos. Inténtalo de nuevo.';

  @override
  String get componentsScannerProductSearchUnknownProduct =>
      'Producto desconocido';

  @override
  String get componentsScannerProductSearchCategoryAll => 'Todos';

  @override
  String get componentsScannerProductSearchCategoryFruits => 'Frutas';

  @override
  String get componentsScannerProductSearchCategoryVegetables => 'Verduras';

  @override
  String get componentsScannerProductSearchCategoryDairy => 'Lácteos';

  @override
  String get componentsScannerProductSearchCategoryMeat => 'Carnes';

  @override
  String get componentsScannerProductSearchCategorySeafood =>
      'Pescados y mariscos';

  @override
  String get componentsScannerProductSearchCategoryBeverages => 'Bebidas';

  @override
  String get componentsScannerProductSearchCategoryCereals => 'Cereales';

  @override
  String get componentsScannerProductSearchCategoryBreads => 'Panes';

  @override
  String get componentsScannerProductSearchCategorySnacks => 'Aperitivos';

  @override
  String get componentsScannerProductSearchCategorySweets => 'Dulces';

  @override
  String get componentsScannerProductSearchCategoryLegumes => 'Legumbres';

  @override
  String get componentsScannerProductSearchCategoryNuts => 'Frutos secos';

  @override
  String get componentsScannerProductSearchCategoryCondiments => 'Condimentos';

  @override
  String get componentsScannerProductSearchCategoryOilsAndFats =>
      'Aceites y grasas';

  @override
  String get componentsScannerProductSearchCategoryFrozen => 'Congelados';

  @override
  String get componentsScannerProductSearchCategoryReadyMeals =>
      'Platos preparados';

  @override
  String get componentsScannerProductSearchCategoryBabyFoods =>
      'Alimentos infantiles';

  @override
  String get componentsScannerProductSearchSortPopularity => 'Más populares';

  @override
  String get componentsScannerProductSearchSortName => 'Nombre A–Z';

  @override
  String get componentsScannerProductSearchSortNewest => 'Más recientes';

  @override
  String get componentsScannerProductSearchSortCompleteness => 'Más completos';

  @override
  String get componentsSharedErrorDisplayRetry => 'Reintentar';

  @override
  String get componentsUiCustomTabBarCalendar => 'Calendario';

  @override
  String get componentsUiCustomTabBarChat => 'Chat';

  @override
  String get componentsUiCustomTabBarMeals => 'Comidas';

  @override
  String get componentsUiCustomTabBarMenu => 'Menú';

  @override
  String get providersChatProviderAiThinking => 'La IA está pensando...';

  @override
  String get providersChatProviderIngredientsPrompt =>
      '¿Qué puedo preparar con estos ingredientes?';

  @override
  String get providersChatProviderTestChatResponse =>
      '¡Gracias por probar PlatePal! Esta es una respuesta de prueba para mostrarte cómo funciona nuestro asistente IA. Para obtener consejos nutricionales reales y sugerencias de comidas, por favor configura tu clave API de OpenAI en ajustes.';

  @override
  String get providersChatProviderTestChatWelcome =>
      '¡Este es el modo de prueba! Puedo ayudarte a explorar las características de PlatePal. Intenta preguntarme sobre nutrición, planificación de comidas o recomendaciones de alimentos.';

  @override
  String get providersChatProviderWelcomeToChat =>
      '¡Bienvenido a tu asistente nutricional IA! Pregúntame cualquier cosa sobre comidas, nutrición o tus objetivos de fitness.';

  @override
  String get screensCalendarAiNutritionTip => 'Consejo de Nutrición IA';

  @override
  String get screensCalendarConfigureApiKeyForAiTips =>
      'Configura tu clave de OpenAI en ajustes para usar consejos de IA';

  @override
  String get screensCalendarDeleteLog => 'Eliminar Registro';

  @override
  String get screensCalendarDeleteLogConfirmation =>
      '¿Está seguro de que desea eliminar esta comida registrada?';

  @override
  String get screensCalendarFailedToDeleteMealLog =>
      'Error al eliminar el registro de comida';

  @override
  String get screensCalendarFailedToGetAiTip =>
      'Error al obtener el consejo de IA. Inténtalo de nuevo.';

  @override
  String get screensCalendarMealLogDeletedSuccessfully =>
      'Registro de comida eliminado exitosamente';

  @override
  String get screensCalendarOk => 'OK';

  @override
  String get screensChatChatAssistant => 'Asistente de Chat IA';

  @override
  String get screensChatSystemAnalyzing => 'SISTEMA ANALIZANDO ::';

  @override
  String get screensChatChatCleared => 'Historial del chat eliminado';

  @override
  String get screensChatClearChat => 'Limpiar Chat';

  @override
  String get screensChatClearChatConfirmation =>
      '¿Estás seguro de que quieres limpiar el historial del chat? Esta acción no se puede deshacer.';

  @override
  String get screensChatConfigureApiKeyButton => 'Configurar Clave API';

  @override
  String get screensChatConfigureApiKeyToUseChat =>
      'Por favor configura tu clave API de OpenAI en ajustes para usar el asistente de chat IA.';

  @override
  String get screensChatLoading => 'Cargando...';

  @override
  String get screensChatNoApiKeyConfigured => 'No hay clave API configurada';

  @override
  String get screensDishCreateBasicInfo => 'Información Básica';

  @override
  String get screensDishCreateCamera => 'Cámara';

  @override
  String get screensDishCreateCategory => 'Categoría';

  @override
  String get screensDishCreateConfirmDeleteIngredient =>
      '¿Está seguro de que desea eliminar este ingrediente?';

  @override
  String get screensDishCreateCreateDish => 'Crear Plato';

  @override
  String get screensDishCreateDeleteIngredient => 'Eliminar Ingrediente';

  @override
  String get screensDishCreateDescription => 'Descripción';

  @override
  String get screensDishCreateDescriptionPlaceholder =>
      'Ingrese la descripción (opcional)';

  @override
  String get screensDishCreateDishCreatedSuccessfully =>
      'Plato creado exitosamente';

  @override
  String get screensDishCreateDishNamePlaceholder =>
      'Ingrese el nombre del plato';

  @override
  String get screensDishCreateDishUpdatedSuccessfully =>
      'Plato actualizado exitosamente';

  @override
  String get screensDishCreateEditDish => 'Editar Plato';

  @override
  String get screensDishCreateErrorSavingDish => 'Error al guardar el plato';

  @override
  String get screensDishCreateFavorite => 'Favoritos';

  @override
  String get screensDishCreateGallery => 'Galería';

  @override
  String get screensDishCreateIngredientDeleted => 'Ingrediente eliminado';

  @override
  String get screensDishCreateMarkAsFavorite => 'Marcar como plato favorito';

  @override
  String get screensDishCreateNoIngredientsAdded =>
      'No se han agregado ingredientes aún';

  @override
  String get screensDishCreateNutritionRecalculated =>
      'Nutrición recalculada desde ingredientes';

  @override
  String get screensDishCreateOptions => 'Opciones';

  @override
  String get screensDishCreatePleaseEnterDishName =>
      'Por favor ingresa un nombre para el plato';

  @override
  String get screensDishCreateProductAddedSuccessfully =>
      'Producto agregado exitosamente';

  @override
  String get screensDishCreateRemoveImage => 'Quitar imagen';

  @override
  String get screensDishCreateSaveDish => 'Guardar Plato';

  @override
  String get screensHomeAppTitle => 'PlatePal Tracker';

  @override
  String get providersStorageError => 'No se pudieron cargar tus datos.';

  @override
  String get providersStorageRetry => 'Reintentar';

  @override
  String get screensMealsAddedToFavorites => 'Agregado a favoritos';

  @override
  String get screensMealsAddMeal => 'Agregar Comida';

  @override
  String get screensMealsAddToFavorites => 'Agregar a Favoritos';

  @override
  String get screensMealsAllCategories => 'Todas las Categorías';

  @override
  String get screensMealsCreateFirstDish =>
      'Crea tu primer plato para comenzar';

  @override
  String get screensMealsDeleteDish => 'Eliminar Plato';

  @override
  String screensMealsDeleteDishConfirmation(String dishName) {
    return '¿Estás seguro de que quieres eliminar \"$dishName\"?';
  }

  @override
  String get screensMealsDishDeletedSuccessfully =>
      'Plato eliminado exitosamente';

  @override
  String get screensMealsErrorLoadingDishes => 'Error al cargar los platos';

  @override
  String get screensMealsLoadFailedHint =>
      'No se pudieron cargar tus platos. Inténtalo de nuevo.';

  @override
  String get screensMealsErrorUpdatingDish => 'Error al actualizar el plato';

  @override
  String get screensMealsFailedToDeleteDish => 'Error al eliminar el plato';

  @override
  String get screensMealsNoDishesCreated => 'No se han creado platos aún';

  @override
  String get screensMealsNoDishesFound => 'No se encontraron platos';

  @override
  String get screensMealsOtherCategory => 'Otros';

  @override
  String get screensMealsRemovedFromFavorites => 'Removido de favoritos';

  @override
  String get screensMealsRemoveFromFavorites => 'Remover de Favoritos';

  @override
  String get screensMealsSearchDishes => 'Buscar platos...';

  @override
  String get screensMealsTryAdjustingSearch =>
      'Intenta ajustar tus términos de búsqueda';

  @override
  String get screensMenuAbout => 'Acerca de';

  @override
  String get screensMenuAiFeatures => 'IA y Características';

  @override
  String get screensMenuApiKeySettings => 'Configuración de Clave API';

  @override
  String get screensMenuAppearance => 'Apariencia';

  @override
  String get screensMenuChatAgentOptions => 'Opciones de Agente de Chat';

  @override
  String get screensMenuConfigureApiKey => 'Configura tu clave API de OpenAI';

  @override
  String get screensMenuContributors => 'Contribuidores';

  @override
  String get screensMenuCurrentStats => 'Estadísticas Actuales';

  @override
  String get screensMenuDark => 'Oscuro';

  @override
  String get screensMenuDataManagement => 'Gestión de Datos';

  @override
  String get screensMenuEditPersonalInfo => 'Edita tu información personal';

  @override
  String get screensMenuEnableAgentModeDeepSearch =>
      'Habilitar modo agente, búsqueda profunda y más';

  @override
  String get screensMenuExportData => 'Exportar Datos';

  @override
  String get screensMenuExportMealData => 'Exporta tus datos de comidas';

  @override
  String get screensMenuImportData => 'Importar Datos';

  @override
  String get screensMenuImportMealDataBackup =>
      'Importa datos de comidas desde respaldo';

  @override
  String get screensMenuInformation => 'Información';

  @override
  String get screensMenuLanguage => 'Idioma';

  @override
  String get screensMenuSystemDefault => 'Predeterminado del sistema';

  @override
  String get screensMenuLearnMorePlatePal => 'Aprende más sobre PlatePal';

  @override
  String get screensMenuLight => 'Claro';

  @override
  String get screensMenuMadeBy => 'Hecho por MrLappes';

  @override
  String get screensMenuNutritionGoals => 'Objetivos Nutricionales';

  @override
  String get screensMenuOceanic => 'Oceánico';

  @override
  String get screensMenuForest => 'Bosque';

  @override
  String get screensMenuPlatePal => 'PlatePal';

  @override
  String get screensMenuProfile => 'Perfil';

  @override
  String get screensMenuSetNutritionTargets =>
      'Establece tus objetivos nutricionales diarios';

  @override
  String get screensMenuSystem => 'Sistema';

  @override
  String get screensMenuTheme => 'Tema';

  @override
  String get screensMenuUserProfile => 'Perfil de Usuario';

  @override
  String get screensMenuViewContributors => 'Ver contribuidores del proyecto';

  @override
  String get screensMenuViewStatistics => 'Ver Estadísticas';

  @override
  String get screensPrivacyTitle => 'Política de privacidad';

  @override
  String get screensPrivacyEffectiveDate =>
      'Fecha de entrada en vigor: 2026-10-01';

  @override
  String get screensPrivacyOverviewTitle => 'En resumen';

  @override
  String get screensPrivacyOverviewBody =>
      'PlatePal Tracker es una aplicación de seguimiento nutricional que funciona principalmente sin conexión. No operamos servidores para tus datos ni exigimos una cuenta, y la aplicación no incluye herramientas de análisis, publicidad ni rastreo. Las funciones de red opcionales que se describen a continuación contactan con sus proveedores cuando las usas.';

  @override
  String get screensPrivacyStorageTitle => 'Datos en tu dispositivo';

  @override
  String get screensPrivacyStorageBody =>
      'Los platos, registros de comidas, datos de perfil (incluidas las medidas corporales), objetivos, historial del chat y ajustes se guardan en tu dispositivo mediante SQLite o SharedPreferences. Las fotos de alimentos guardadas también pueden conservarse en el almacenamiento de la aplicación. La clave API que introduces se guarda en el almacenamiento seguro del sistema; las claves antiguas de SharedPreferences se migran cuando es posible.';

  @override
  String get screensPrivacyAiTitle => 'Chat con IA';

  @override
  String get screensPrivacyAiBody =>
      'El chat con IA es opcional y requiere tu propia clave API. Al usarlo, tus mensajes, imágenes adjuntas y, cuando corresponde, el historial de la conversación, tu perfil, registros de comidas o resúmenes nutricionales y platos guardados se envían a OpenAI o al servicio compatible con OpenAI que hayas configurado. La clave se envía a ese proveedor para autenticarte. Ese proveedor trata la información según su propia política de privacidad; elige uno en quien confíes. Nosotros no recibimos esas solicitudes.';

  @override
  String get screensPrivacyFoodFactsTitle => 'Open Food Facts';

  @override
  String get screensPrivacyFoodFactsBody =>
      'Al buscar alimentos o escanear un código de barras, la aplicación envía el texto de búsqueda o el número del código y los filtros elegidos a world.openfoodfacts.org. También puede descargar información e imágenes de productos de Open Food Facts.';

  @override
  String get screensPrivacyHealthTitle => 'Health Connect y Apple Health';

  @override
  String get screensPrivacyHealthBody =>
      'Con tu permiso, la aplicación lee las calorías quemadas (totales y activas en Android; activas y basales en iOS) de Health Connect o Apple Health y escribe allí los datos nutricionales de las comidas que registras. Las lecturas se guardan temporalmente en este dispositivo y se usan para cálculos de energía y objetivos dentro de la aplicación; no se incluyen en las solicitudes a la IA ni se envían a un servidor del desarrollador. Health Connect y Apple Health gestionan sus propios registros.';

  @override
  String get screensPrivacyExternalTitle => 'Enlaces e imágenes externos';

  @override
  String get screensPrivacyExternalBody =>
      'La pantalla de colaboradores carga avatares de avatars.githubusercontent.com, de GitHub. Al abrir GitHub, la política en línea, otros sitios externos o imágenes de productos remotas, contactas con esos servicios, que pueden conocer tu dirección IP y tratar las solicitudes según sus propias políticas.';

  @override
  String get screensPrivacyExportTitle => 'Exportación e importación';

  @override
  String get screensPrivacyExportBody =>
      'Los archivos de exportación (JSON, CSV o una copia completa en ZIP que también incluye las fotos de tus platos) se crean localmente cuando decides exportar y puedes compartirlos desde tu dispositivo. La importación lee el archivo que eliges y antes crea una copia de seguridad local, salvo que decidas continuar expresamente si falla esa copia. No subimos estos datos a ningún servidor propio.';

  @override
  String get screensPrivacyBackupTitle => 'Copia de seguridad de Android';

  @override
  String get screensPrivacyBackupBody =>
      'La copia de seguridad del sistema Android puede copiar la base de datos y las preferencias de la aplicación, incluidos los registros de chat y las calorías de salud guardadas temporalmente, a tu cuenta de Google o transferirlas a otro dispositivo. Las reglas excluyen los archivos de preferencias del almacenamiento seguro, pero una clave API antigua puede permanecer en otras preferencias hasta su migración. Revisa los ajustes de copia de seguridad de Android para controlarlo.';

  @override
  String get screensPrivacyDeletionTitle => 'Eliminar tus datos';

  @override
  String get screensPrivacyDeletionBody =>
      'En Perfil, Restablecer la aplicación elimina la base de datos SQLite, SharedPreferences y la clave API guardada en este dispositivo. Desinstalarla elimina los datos privados de la aplicación. Restablecerla no elimina las imágenes guardadas, archivos exportados o copias previas a una importación, copias compartidas en otros lugares, registros ya escritos en Health Connect o Apple Health ni copias del sistema; bórralos por separado cuando corresponda.';

  @override
  String get screensPrivacyChildrenTitle => 'Menores';

  @override
  String get screensPrivacyChildrenBody =>
      'PlatePal Tracker no está destinada a menores. La aplicación no verifica la edad; madres, padres o tutores deben supervisar su uso, especialmente antes de activar servicios externos o compartir información sensible.';

  @override
  String get screensPrivacyChangesTitle => 'Cambios en esta política';

  @override
  String get screensPrivacyChangesBody =>
      'Podemos actualizar esta política cuando cambie la aplicación. La fecha de entrada en vigor indicada arriba corresponde a esta versión; consulta la política vigente en la aplicación o en el repositorio de GitHub.';

  @override
  String get screensPrivacyContactTitle => 'Contacto';

  @override
  String get screensPrivacyContactBody =>
      'Si tienes preguntas sobre privacidad, escribe a mike.busam@plate-pal.de o abre una incidencia en github.com/MrLappes/platepal-tracker-flutter/issues. No podemos acceder a los datos almacenados únicamente en tu dispositivo; usa los controles de la aplicación y del sistema descritos arriba para eliminarlos.';

  @override
  String get screensPrivacyMenuSubtitle =>
      'Qué datos salen del dispositivo y cómo controlarlos';

  @override
  String get screensPrivacyViewOnline => 'Ver en línea';

  @override
  String get screensPrivacyLinkError =>
      'No se pudo abrir la política de privacidad.';

  @override
  String get screensSettingsAboutAboutAppTitle => 'Acerca de la Aplicación';

  @override
  String get screensSettingsAboutAboutDescription =>
      'PlatePal Tracker fue creado para proporcionar una alternativa de código abierto y centrada en la privacidad a las costosas aplicaciones de seguimiento nutricional. Creemos en poner el control en tus manos sin suscripciones, sin anuncios y sin recopilación de datos.';

  @override
  String get screensSettingsAboutAppMotto =>
      'Hecho por deportistas para deportistas que odian las aplicaciones de pago';

  @override
  String get screensSettingsAboutCodersMessage =>
      'Los programadores no deberían tener que pagar';

  @override
  String get screensSettingsAboutDataStaysOnDevice =>
      'Tus datos permanecen en tu dispositivo';

  @override
  String get screensSettingsAboutFreeOpenSource =>
      '100% gratuito y de código abierto';

  @override
  String get screensSettingsAboutGithubRepository =>
      'github.com/MrLappes/platepal-tracker';

  @override
  String get screensSettingsAboutUseOwnAiKey =>
      'Usa tu propia clave de IA para control total';

  @override
  String get screensSettingsAboutWebsite => 'plate-pal.de';

  @override
  String get screensSettingsAboutWhyPlatePal => '¿Por qué PlatePal?';

  @override
  String get screensSettingsApiKeySettingsAboutOpenAiApiKey =>
      'Acerca de la clave API de OpenAI';

  @override
  String get screensSettingsApiKeySettingsAiFeaturesEnabled =>
      'Las funciones de IA están habilitadas';

  @override
  String get screensSettingsApiKeySettingsApiKeyBulletPoints =>
      '• Obtén tu clave API desde platform.openai.com\n• Tu clave se almacena localmente en tu dispositivo\n• Los cargos por uso se aplican directamente a tu cuenta de OpenAI';

  @override
  String get screensSettingsApiKeySettingsApiKeyConfigured =>
      'Clave API configurada';

  @override
  String get screensSettingsApiKeySettingsApiKeyDescription =>
      'Para usar funciones de IA como análisis de comidas y sugerencias, necesitas proporcionar tu propia clave API de OpenAI. Esto asegura que tus datos permanezcan privados y tengas control total.';

  @override
  String get screensSettingsApiKeySettingsApiKeyHelperText =>
      'Ingresa tu clave API de OpenAI o déjalo vacío para desactivar las funciones de IA';

  @override
  String get screensSettingsApiKeySettingsApiKeyMustStartWith =>
      'La clave API debe comenzar con \"sk-\"';

  @override
  String get screensSettingsApiKeySettingsApiKeyPlaceholder => 'sk-...';

  @override
  String get screensSettingsApiKeySettingsApiKeyRemovedSuccessfully =>
      'Clave API eliminada exitosamente';

  @override
  String get screensSettingsApiKeySettingsApiKeySavedSuccessfully =>
      'Clave API guardada exitosamente';

  @override
  String get screensSettingsApiKeySettingsApiKeyTestWarning =>
      'Su clave API será probada con una pequeña solicitud para verificar que funcione. La clave solo se almacena en su dispositivo y nunca se envía a nuestros servidores';

  @override
  String get screensSettingsApiKeySettingsApiKeyTooShort =>
      'La clave API parece ser demasiado corta';

  @override
  String get screensSettingsApiKeySettingsClipboardEmpty =>
      'El portapapeles está vacío';

  @override
  String get screensSettingsApiKeySettingsCouldNotLoadModels =>
      'No se pudieron cargar los modelos disponibles. Usando lista de modelos predeterminada';

  @override
  String get screensSettingsApiKeySettingsFailedToAccessClipboard =>
      'Error al acceder al portapapeles';

  @override
  String get screensSettingsApiKeySettingsFailedToLoadApiKey =>
      'Error al cargar la clave API';

  @override
  String get screensSettingsApiKeySettingsFailedToRemoveApiKey =>
      'Error al eliminar la clave API';

  @override
  String get screensSettingsApiKeySettingsInvalidBaseUrl =>
      'La URL base debe empezar con https:// (http:// solo se permite para localhost)';

  @override
  String get screensSettingsApiKeySettingsGetApiKeyFromOpenAi =>
      'Obtener clave API de OpenAI';

  @override
  String get screensSettingsApiKeySettingsGpt35ModelsInfo =>
      'Los modelos GPT-3.5 son más rentables para análisis básicos';

  @override
  String get screensSettingsApiKeySettingsGpt4ModelsInfo =>
      'Los modelos GPT-4 proporcionan el mejor análisis pero cuestan más';

  @override
  String get screensSettingsApiKeySettingsLinkError =>
      'Ocurrió un error al abrir el enlace';

  @override
  String get screensSettingsApiKeySettingsOpenAiApiKey => 'Clave API de OpenAI';

  @override
  String get screensSettingsApiKeySettingsPastedFromClipboard =>
      'Pegado desde portapapeles';

  @override
  String get screensSettingsApiKeySettingsPasteFromClipboard =>
      'Pegar desde portapapeles';

  @override
  String get screensSettingsApiKeySettingsRemove => 'Eliminar';

  @override
  String get screensSettingsApiKeySettingsRemoveApiKey => 'Eliminar clave API';

  @override
  String get screensSettingsApiKeySettingsShowKey => 'Mostrar clave API';

  @override
  String get screensSettingsApiKeySettingsHideKey => 'Ocultar clave API';

  @override
  String get screensSettingsApiKeySettingsDeleteKey => 'Eliminar clave API';

  @override
  String get screensSettingsApiKeySettingsRemoveApiKeyConfirmation =>
      '¿Estás seguro de que quieres eliminar tu clave API? Esto desactivará las funciones de IA.';

  @override
  String get screensSettingsApiKeySettingsSelectModel => 'Seleccionar Modelo';

  @override
  String get screensSettingsApiKeySettingsTestAndSaveApiKey =>
      'Probar y Guardar Clave API';

  @override
  String get screensSettingsApiKeySettingsTestingApiKey =>
      'Probando clave API...';

  @override
  String get screensSettingsApiKeySettingsUpdateApiKey =>
      'Actualizar clave API';

  @override
  String get screensSettingsApiKeySettingsApiMode => 'Modo de API';

  @override
  String get screensSettingsApiKeySettingsCompatibleApi =>
      'API compatible con OpenAI';

  @override
  String get screensSettingsApiKeySettingsUsingCustomEndpoint =>
      'Usando un servidor API personalizado compatible con OpenAI';

  @override
  String get screensSettingsApiKeySettingsUsingOfficialApi =>
      'Usando la API oficial de OpenAI';

  @override
  String get screensSettingsApiKeySettingsBaseUrl => 'URL base';

  @override
  String get screensSettingsApiKeySettingsBaseUrlHelper =>
      'Introduce la URL base de tu API compatible con OpenAI';

  @override
  String get screensSettingsApiKeySettingsBaseUrlRequired =>
      'La URL base es obligatoria en modo compatible';

  @override
  String get screensSettingsApiKeySettingsApiKeyGeneric => 'Clave de API';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyHelper =>
      'Introduce tu clave de API o déjala vacía para desactivar las funciones de IA';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyRequired =>
      'La clave de API es obligatoria en modo compatible';

  @override
  String get screensSettingsApiKeySettingsCompatibilityKeyTooShort =>
      'La clave de API parece demasiado corta';

  @override
  String get screensSettingsApiKeySettingsModelName => 'Nombre del modelo';

  @override
  String get screensSettingsApiKeySettingsModelNameHelper =>
      'Introduce el nombre exacto del modelo admitido por tu API';

  @override
  String get screensSettingsApiKeySettingsModelNameRequired =>
      'El nombre del modelo es obligatorio en modo compatible';

  @override
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchSubtitle =>
      'Permite que el agente use búsqueda profunda para respuestas más precisas';

  @override
  String get screensSettingsChatAgentSettingsChatAgentDeepSearchTitle =>
      'Activar Búsqueda Profunda';

  @override
  String get screensSettingsChatAgentSettingsChatAgentEnableSubtitle =>
      'Usa la canalización de agente de varios pasos para el chat';

  @override
  String get screensSettingsChatAgentSettingsChatAgentEnableTitle =>
      'Activar Modo Agente';

  @override
  String get screensSettingsChatAgentSettingsChatAgentInfoDescription =>
      'El modo agente activa la avanzada canalización de razonamiento de varios pasos de PlatePal para el chat. Esto permite que el asistente analice tu consulta, recopile contexto y proporcione respuestas más precisas y explicables. La Búsqueda Profunda permite al agente usar más datos para obtener mejores resultados.';

  @override
  String get screensSettingsChatAgentSettingsChatAgentInfoTitle =>
      '¿Qué es el Modo Agente?';

  @override
  String get screensSettingsChatAgentSettingsChatAgentSettingsTitle =>
      'Configuración del Agente de Chat';

  @override
  String get screensSettingsChatAgentSettingsChatSettingsSaved =>
      'Configuración de chat guardada correctamente';

  @override
  String get screensSettingsChatAgentSettingsSaveFailed =>
      'No se pudo guardar la configuración del chat';

  @override
  String get screensSettingsContributorsBuyMeCreatine => 'Cómprame creatina';

  @override
  String get screensSettingsContributorsCheckGitHub =>
      'Echa un vistazo a nuestro repositorio de GitHub';

  @override
  String screensSettingsContributorsOpenGitHubProfile(String name) {
    return 'Abrir el perfil de $name en GitHub';
  }

  @override
  String get screensSettingsContributorsContributorPlural => 'Contribuidores';

  @override
  String get screensSettingsContributorsContributorSingular => 'Contribuidor';

  @override
  String get screensSettingsContributorsContributorsThankYou =>
      '¡Gracias a todos los que han contribuido a hacer posible PlatePal Tracker!';

  @override
  String get screensSettingsContributorsOpenSourceMessage =>
      'PlatePal Tracker es de código abierto: ¡únete a nosotros en GitHub!';

  @override
  String get screensSettingsContributorsSupportDevelopment =>
      'Apoyar el desarrollo';

  @override
  String get screensSettingsContributorsSupportMessage =>
      '¿Quieres comprarme mi creatina? Tu apoyo es muy apreciado pero no es para nada obligatorio.';

  @override
  String get screensSettingsContributorsWantToContribute =>
      '¿Quieres contribuir?';

  @override
  String get screensSettingsExportDataAllData => 'Todos los Datos';

  @override
  String get screensSettingsExportDataDishes => 'Platos';

  @override
  String get screensSettingsExportDataExportAsCsv => 'Exportar como CSV';

  @override
  String get screensSettingsExportDataExportAsJson => 'Exportar como JSON';

  @override
  String screensSettingsExportDataExportedItemsCount(int count) {
    return 'Se exportaron $count elementos';
  }

  @override
  String get screensSettingsExportDataExportProgress => 'Exportando datos...';

  @override
  String get screensSettingsExportDataMealLogs => 'Registros de Comidas';

  @override
  String get screensSettingsExportDataNutritionGoalsData =>
      'Objetivos Nutricionales';

  @override
  String get screensSettingsExportDataSelectDataToExport =>
      'Seleccionar datos para exportar';

  @override
  String get screensSettingsExportDataSupplements => 'Suplementos';

  @override
  String get screensSettingsExportDataUserProfiles => 'Perfiles de Usuario';

  @override
  String get screensSettingsImportDataHowToHandleDuplicates =>
      '¿Cómo manejar duplicados?';

  @override
  String screensSettingsImportDataImportedItemsCount(int count) {
    return 'Se importaron $count elementos';
  }

  @override
  String get screensSettingsImportDataImportFailed => 'Error en la importación';

  @override
  String get screensSettingsImportDataImportFromFile =>
      'Importar desde Archivo';

  @override
  String get screensSettingsImportDataImportProgress => 'Importando datos...';

  @override
  String get screensSettingsImportDataMergeDuplicates => 'Fusionar Duplicados';

  @override
  String get screensSettingsImportDataOverwriteDuplicates =>
      'Sobrescribir Duplicados';

  @override
  String get screensSettingsImportDataSelectDataToImport =>
      'Seleccionar datos para importar';

  @override
  String get screensSettingsImportDataSelectFile => 'Seleccionar Archivo';

  @override
  String get screensSettingsImportDataSkipDuplicates => 'Omitir Duplicados';

  @override
  String get screensSettingsExportDataPreparing => 'Preparando tus datos...';

  @override
  String get screensSettingsExportDataPreview =>
      'Vista previa de la exportación';

  @override
  String screensSettingsExportDataFormatLabel(String format) {
    return 'Formato: $format';
  }

  @override
  String screensSettingsExportDataTypesSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tipos',
      one: '1 tipo',
    );
    return 'Tipos de datos seleccionados: $_temp0';
  }

  @override
  String get screensSettingsExportDataReady => 'Listo para exportar';

  @override
  String get screensSettingsExportDataDishesDescription =>
      'Tus recetas y platos guardados';

  @override
  String get screensSettingsExportDataMealLogsDescription =>
      'Tu historial de comidas y registros nutricionales';

  @override
  String get screensSettingsExportDataUserProfilesDescription =>
      'Perfil de usuario y preferencias';

  @override
  String get screensSettingsExportDataIngredientsDescription =>
      'Base de datos de ingredientes';

  @override
  String get screensSettingsExportDataSupplementsDescription =>
      'Datos de seguimiento de suplementos';

  @override
  String get screensSettingsExportDataFitnessGoalsDescription =>
      'Objetivos de ejercicio y nutrición';

  @override
  String get screensSettingsExportDataAllDataDescription =>
      'Exportar todos tus datos';

  @override
  String get screensSettingsExportDataFormatTitle => 'Formato de exportación';

  @override
  String get screensSettingsExportDataJsonDescription =>
      'Formato estructurado, ideal para copias de seguridad';

  @override
  String get screensSettingsExportDataCsvDescription =>
      'Formato de hoja de cálculo, útil para análisis';

  @override
  String get screensSettingsExportDataError => 'Error de exportación';

  @override
  String get screensSettingsExportDataResults => 'Resultados de la exportación';

  @override
  String screensSettingsExportDataFileLabel(String fileName) {
    return 'Archivo: $fileName';
  }

  @override
  String screensSettingsExportDataLocationLabel(String path) {
    return 'Ubicación: $path';
  }

  @override
  String get screensSettingsExportDataItemsExported => 'Elementos exportados:';

  @override
  String get screensSettingsExportDataShare => 'Compartir';

  @override
  String get screensSettingsExportDataShowFileLocation =>
      'Mostrar ubicación del archivo';

  @override
  String get screensSettingsExportDataLocationTitle =>
      'Ubicación de la exportación';

  @override
  String get screensSettingsExportDataLocationDescription =>
      'El archivo exportado se encuentra en:';

  @override
  String get screensSettingsExportDataNoFileToShare =>
      'No hay archivo para compartir. Exporta tus datos primero.';

  @override
  String get screensSettingsExportDataFileNotFound =>
      'No se encuentra el archivo exportado. Exporta los datos de nuevo.';

  @override
  String screensSettingsExportDataShareFailed(String error) {
    return 'No se pudo compartir el archivo: $error';
  }

  @override
  String screensSettingsExportDataShareText(String fileName) {
    return 'Exportación de datos de PlatePal - $fileName';
  }

  @override
  String get screensSettingsExportDataShareSubject =>
      'Exportación de datos de PlatePal';

  @override
  String screensSettingsExportDataFailedDetail(String error) {
    return 'Error de exportación: $error';
  }

  @override
  String get screensSettingsExportDataSectionFailed =>
      'No se pudieron exportar los datos seleccionados. No se creó ningún archivo. Inténtalo de nuevo.';

  @override
  String get screensSettingsExportDataWriteFailed =>
      'No se pudo guardar el archivo de exportación. Inténtalo de nuevo.';

  @override
  String get screensSettingsExportDataShareProblem =>
      'No se pudo compartir el archivo. Inténtalo de nuevo.';

  @override
  String get screensSettingsImportDataRestoring =>
      'Restaurando desde la copia de seguridad...';

  @override
  String screensSettingsImportDataProcessingItems(int current, int total) {
    return 'Procesando $current de $total elementos';
  }

  @override
  String screensSettingsImportDataCurrentType(String type) {
    return 'Actual: $type';
  }

  @override
  String get screensSettingsImportDataUndoing =>
      'Deshaciendo la última importación...';

  @override
  String get screensSettingsImportDataFileSelection => 'Selección de archivo';

  @override
  String get screensSettingsImportDataRemoveFile =>
      'Quitar el archivo seleccionado';

  @override
  String get screensSettingsImportDataChangeFile => 'Cambiar archivo';

  @override
  String get screensSettingsImportDataSupportedFormats =>
      'Formatos admitidos: JSON, CSV, ZIP (copia completa)';

  @override
  String get screensSettingsImportDataAllDataDescription =>
      'Importar todos los datos del archivo';

  @override
  String get screensSettingsImportDataSkipDescription =>
      'Conservar los datos existentes; omitir los duplicados importados';

  @override
  String get screensSettingsImportDataOverwriteDescription =>
      'Reemplazar los datos existentes con los importados';

  @override
  String get screensSettingsImportDataAdvancedOptions => 'Opciones avanzadas';

  @override
  String get screensSettingsImportDataValidateBeforeImport =>
      'Validar los datos antes de importar';

  @override
  String get screensSettingsImportDataValidateDescription =>
      'Comprobar la integridad de los datos y mostrar advertencias';

  @override
  String get screensSettingsImportDataBackupBeforeImport =>
      'Crear una copia de seguridad antes de importar';

  @override
  String get screensSettingsImportDataBackupDescription =>
      'Guardar automáticamente los datos existentes';

  @override
  String get screensSettingsImportDataIssues => 'Problemas de importación';

  @override
  String get screensSettingsImportDataDetailedErrors => 'Errores detallados:';

  @override
  String get screensSettingsImportDataTechnicalDetails =>
      'Detalles del archivo y las filas (pueden aparecer en inglés):';

  @override
  String get screensSettingsImportDataResults => 'Resultados de la importación';

  @override
  String get screensSettingsImportDataPartialResults =>
      'Importación completada con elementos omitidos';

  @override
  String screensSettingsImportDataImportedSkipped(int imported, int skipped) {
    return 'Importados: $imported; omitidos: $skipped';
  }

  @override
  String get screensSettingsImportDataShowReasons => 'Mostrar motivos';

  @override
  String screensSettingsImportDataMoreReasons(int count) {
    return '…y $count más';
  }

  @override
  String screensSettingsImportDataFailedSection(String section) {
    return 'Sección fallida: $section';
  }

  @override
  String get screensSettingsImportDataConfirmTitle => 'Confirmar importación';

  @override
  String get screensSettingsImportDataSelectedSections =>
      'Secciones seleccionadas:';

  @override
  String screensSettingsImportDataDuplicatesLabel(String strategy) {
    return 'Duplicados: $strategy';
  }

  @override
  String get screensSettingsImportDataConfirmAction => 'Importar';

  @override
  String get screensSettingsImportDataBackupFailedTitle =>
      'Falló la copia de seguridad';

  @override
  String get screensSettingsImportDataBackupFailedDescription =>
      'No se pudo crear la copia de seguridad automática. ¿Continuar con la importación sin copia de seguridad?';

  @override
  String get screensSettingsImportDataContinueWithoutBackup =>
      'Continuar sin copia de seguridad';

  @override
  String screensSettingsImportDataFileSelectionFailed(String error) {
    return 'Error al seleccionar el archivo: $error';
  }

  @override
  String screensSettingsImportDataCompletedWithErrors(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importación completada con $count errores',
      one: 'Importación completada con 1 error',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataFailedDetail(String error) {
    return 'Error de importación: $error';
  }

  @override
  String get screensSettingsImportDataBackupAvailable =>
      'Copia de seguridad disponible';

  @override
  String get screensSettingsImportDataBackupAvailableDescription =>
      'Hay una copia de seguridad de tu última importación.';

  @override
  String screensSettingsImportDataBackupCreated(String date) {
    return 'Creada: $date';
  }

  @override
  String screensSettingsImportDataBackupSize(String size) {
    return 'Tamaño: $size KB';
  }

  @override
  String get screensSettingsImportDataUndoLastImport =>
      'Deshacer última importación';

  @override
  String screensSettingsImportDataMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count minutos',
      one: 'hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String screensSettingsImportDataDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get screensSettingsImportDataRestoreTitle =>
      'Restaurar desde la copia de seguridad';

  @override
  String get screensSettingsImportDataRestoreWarning =>
      'Esto restaurará los datos al estado anterior a la última importación. Se perderán todos los cambios realizados desde entonces. ¿Quieres continuar?';

  @override
  String get screensSettingsImportDataRestoreAction => 'Restaurar';

  @override
  String get screensSettingsImportDataRestoreSuccess =>
      '¡Restauración completada desde la copia de seguridad!';

  @override
  String screensSettingsImportDataRestoreFailedDetail(String error) {
    return 'Error de restauración: $error';
  }

  @override
  String get screensSettingsImportDataFileMissing =>
      'No se encontró el archivo. Selecciónalo de nuevo.';

  @override
  String screensSettingsImportDataFileTooLarge(int maxSize) {
    return 'El archivo es demasiado grande. Selecciona uno de hasta $maxSize MB.';
  }

  @override
  String get screensSettingsImportDataInvalidJson =>
      'El archivo no contiene JSON válido. Revísalo e inténtalo de nuevo.';

  @override
  String get screensSettingsImportDataUnsupportedFormat =>
      'Formato de archivo no admitido. Selecciona un archivo JSON, CSV o ZIP.';

  @override
  String get screensSettingsImportDataInvalidData =>
      'El archivo contiene datos no válidos. Revisa los detalles e inténtalo de nuevo.';

  @override
  String get screensSettingsImportDataFileSelectionProblem =>
      'No se pudo seleccionar un archivo. Inténtalo de nuevo.';

  @override
  String get screensSettingsImportDataBackupMissing =>
      'No se encontró ninguna copia de seguridad para restaurar.';

  @override
  String get screensSettingsImportDataBackupUnreadable =>
      'No se pudo leer la copia de seguridad. No se modificaron los datos.';

  @override
  String get screensSettingsImportDataSnapshotFailed =>
      'No se pudieron proteger tus datos actuales. No se modificaron los datos.';

  @override
  String get screensSettingsImportDataRestoreProblem =>
      'No se pudo restaurar la copia de seguridad. Comprueba tus datos antes de reintentar.';

  @override
  String get screensSettingsImportDataRestoreRolledBack =>
      'La restauración falló, pero tus datos anteriores no se modificaron.';

  @override
  String screensSettingsImportDataRestoreCopySaved(String path) {
    return 'La restauración falló y tus datos anteriores pueden estar incompletos. Hay una copia de recuperación en $path.';
  }

  @override
  String get screensSettingsImportProfileCompletionActivityLevel =>
      'Nivel de Actividad';

  @override
  String get screensSettingsImportProfileCompletionAge => 'Edad';

  @override
  String get screensSettingsImportProfileCompletionAgeRange =>
      'La edad debe estar entre 13 y 120';

  @override
  String get screensSettingsImportProfileCompletionBuildMuscle =>
      'Construir Músculo';

  @override
  String get screensSettingsImportProfileCompletionExtraActive =>
      'Extremadamente Activo';

  @override
  String get screensSettingsImportProfileCompletionFemale => 'Femenino';

  @override
  String get screensSettingsImportProfileCompletionFitnessGoal =>
      'Objetivo de Fitness';

  @override
  String get screensSettingsImportProfileCompletionGainWeight => 'Ganar Peso';

  @override
  String get screensSettingsImportProfileCompletionGender => 'Género';

  @override
  String get screensSettingsImportProfileCompletionHeight => 'Altura';

  @override
  String get screensSettingsImportProfileCompletionHeightRange =>
      'La altura debe estar entre 100-250 cm';

  @override
  String get screensSettingsImportProfileCompletionImperial =>
      'Imperial (lb, ft)';

  @override
  String get screensSettingsImportProfileCompletionLightlyActive =>
      'Ligeramente Activo';

  @override
  String get screensSettingsImportProfileCompletionLoseWeight => 'Perder Peso';

  @override
  String get screensSettingsImportProfileCompletionMaintainWeight =>
      'Mantener Peso';

  @override
  String get screensSettingsImportProfileCompletionMale => 'Masculino';

  @override
  String get screensSettingsImportProfileCompletionMetric => 'Métrico (kg, cm)';

  @override
  String get screensSettingsImportProfileCompletionModeratelyActive =>
      'Moderadamente Activo';

  @override
  String get screensSettingsImportProfileCompletionName => 'Nombre';

  @override
  String get screensSettingsImportProfileCompletionOther => 'Otro';

  @override
  String get screensSettingsImportProfileCompletionPersonalInformation =>
      'Información Personal';

  @override
  String get screensSettingsImportProfileCompletionPreferences =>
      'Preferencias';

  @override
  String get screensSettingsImportProfileCompletionSedentary => 'Sedentario';

  @override
  String get screensSettingsImportProfileCompletionUnitSystem =>
      'Sistema de Unidades';

  @override
  String get screensSettingsImportProfileCompletionVeryActive => 'Muy Activo';

  @override
  String get screensSettingsImportProfileCompletionWeight => 'Peso';

  @override
  String get screensSettingsImportProfileCompletionWeightRange =>
      'El peso debe estar entre 30-300 kg';

  @override
  String get screensSettingsMacroCustomizationDiscardChanges =>
      'Descartar Cambios';

  @override
  String get screensSettingsMacroCustomizationMacroCustomization =>
      'Personalización de Macros';

  @override
  String get screensSettingsMacroCustomizationMacroCustomizationInfo =>
      'Personaliza tus objetivos de macros. Todos los porcentajes deben sumar 100%.';

  @override
  String get screensSettingsMacroCustomizationMacroTargetsUpdated =>
      'Objetivos de macros actualizados exitosamente';

  @override
  String get screensSettingsMacroCustomizationResetToDefaults =>
      'Restablecer por Defecto';

  @override
  String get screensSettingsMacroCustomizationSaveChanges => 'Guardar Cambios';

  @override
  String get screensSettingsMacroCustomizationUnsavedChanges =>
      'Cambios No Guardados';

  @override
  String get screensSettingsMacroCustomizationUnsavedChangesMessage =>
      'Tienes cambios no guardados. ¿Quieres guardarlos antes de salir?';

  @override
  String get screensSettingsProfileSettingsAnalyzeTargets =>
      'Analizar Objetivos';

  @override
  String get screensSettingsProfileSettingsBmi => 'IMC';

  @override
  String get screensSettingsProfileSettingsConnectToHealth =>
      'Conectar con Salud';

  @override
  String get screensSettingsProfileSettingsDangerZone => 'Zona de Peligro';

  @override
  String get screensSettingsProfileSettingsDebugHealthData =>
      'Depurar Datos de Salud';

  @override
  String get screensSettingsProfileSettingsDisconnectHealth =>
      'Desconectar Salud';

  @override
  String get screensSettingsProfileSettingsFitnessGoals =>
      'Objetivos de Fitness';

  @override
  String get screensSettingsProfileSettingsHealthConnected =>
      'Datos de salud conectados';

  @override
  String get screensSettingsProfileSettingsHealthDataSync =>
      'Sincronización de Datos de Salud';

  @override
  String get screensSettingsProfileSettingsHealthDisconnected =>
      'Datos de salud no conectados';

  @override
  String get screensSettingsProfileSettingsHealthNotAvailable =>
      'Datos de Salud No Disponibles';

  @override
  String get screensSettingsProfileSettingsHealthNotAvailableMessage =>
      'Los datos de salud no están disponibles en este dispositivo. Asegúrate de tener Health Connect (Android) o la app Salud (iOS) instalada y configurada.';

  @override
  String get screensSettingsProfileSettingsHealthPermissionDenied =>
      'Permiso de Salud Denegado';

  @override
  String get screensSettingsProfileSettingsHealthPermissionDeniedMessage =>
      'Para sincronizar tus datos de salud, PlatePal necesita acceso a tu información de salud. Puedes otorgar permisos en la configuración de tu teléfono.';

  @override
  String get screensSettingsProfileSettingsHealthSyncFailed =>
      'Error al sincronizar datos de salud';

  @override
  String get screensSettingsProfileSettingsHealthSyncSuccess =>
      'Datos de salud sincronizados exitosamente';

  @override
  String get screensSettingsProfileSettingsProfileSettings =>
      'Configuración de Perfil';

  @override
  String get screensSettingsProfileSettingsProfileUpdated =>
      'Perfil actualizado exitosamente';

  @override
  String get screensSettingsProfileSettingsResetApp => 'Restablecer App';

  @override
  String get screensSettingsProfileSettingsResetAppCancel => 'Cancelar';

  @override
  String get screensSettingsProfileSettingsResetAppConfirm =>
      'Sí, Eliminar Todo';

  @override
  String get screensSettingsProfileSettingsResetAppDescription =>
      'Esto eliminará permanentemente TODOS tus datos incluyendo:\n\n• Tu información de perfil\n• Todos los registros de comidas y datos nutricionales\n• Todas las preferencias y configuraciones\n• Toda la información almacenada\n\nEsta acción no se puede deshacer. ¿Estás seguro de que quieres continuar?';

  @override
  String get screensSettingsProfileSettingsResetAppError =>
      'Error al restablecer los datos de la aplicación';

  @override
  String get screensSettingsProfileSettingsResetAppSuccess =>
      'Los datos de la aplicación se han restablecido exitosamente';

  @override
  String get screensSettingsProfileSettingsResetAppTitle =>
      'Restablecer Datos de la Aplicación';

  @override
  String get screensSettingsProfileSettingsSyncHealthData =>
      'Sincronizar Datos de Salud';

  @override
  String get screensSettingsProfileSettingsTargetWeight => 'Peso Objetivo';

  @override
  String get screensSettingsStatisticsAllTime => 'Todo el Tiempo';

  @override
  String get screensSettingsStatisticsBmiHistory => 'Historial de IMC';

  @override
  String get screensSettingsStatisticsBmiNormal => 'Normal';

  @override
  String get screensSettingsStatisticsBmiObese => 'Obeso';

  @override
  String get screensSettingsStatisticsBmiOverweight => 'Sobrepeso';

  @override
  String get screensSettingsStatisticsBmiStatsTip =>
      'El Índice de Masa Corporal (IMC) se calcula a partir de tus medidas de peso y altura.';

  @override
  String get screensSettingsStatisticsBmiUnderweight => 'Bajo peso';

  @override
  String get screensSettingsStatisticsBodyFat => 'Grasa Corporal';

  @override
  String get screensSettingsStatisticsBodyFatHistory =>
      'Historial de Grasa Corporal';

  @override
  String get screensSettingsStatisticsBodyFatStatsTip =>
      'El porcentaje de grasa corporal ayuda a rastrear tu composición corporal más allá del peso.';

  @override
  String get screensSettingsStatisticsBulking => 'Volumen';

  @override
  String get screensSettingsStatisticsCalorieBalanceTip =>
      'Rastrea tu balance calórico real usando datos de salud. Verde = mantenimiento, Azul = déficit, Naranja = superávit.';

  @override
  String get screensSettingsStatisticsCalorieBalanceTitle =>
      'Balance Calórico (Ingesta vs Gasto)';

  @override
  String get screensSettingsStatisticsCalorieIntakeHistory =>
      'Ingesta de Calorías vs Mantenimiento';

  @override
  String get screensSettingsStatisticsCalorieStatsTip =>
      'Compara tu ingesta diaria de calorías con tus calorías de mantenimiento. Verde indica mantenimiento, azul es fase de corte, naranja es fase de volumen.';

  @override
  String get screensSettingsStatisticsCannotCalculateBmiFromData =>
      'No se puede calcular el IMC con los datos disponibles';

  @override
  String get screensSettingsStatisticsCutting => 'Corte';

  @override
  String get screensSettingsStatisticsErrorLoadingData =>
      'Error al cargar datos';

  @override
  String get screensSettingsStatisticsLoadFailedHint =>
      'No se pudieron cargar las estadísticas. Inténtalo de nuevo.';

  @override
  String get screensSettingsStatisticsEstimatedBalance => 'Balance Estimado';

  @override
  String get screensSettingsStatisticsExtremeDeficitWarning =>
      'Advertencia: Los déficits calóricos extremos frecuentes pueden ralentizar el metabolismo y causar pérdida muscular.';

  @override
  String get screensSettingsStatisticsGenerateTestData =>
      'Generar Datos de Prueba';

  @override
  String get screensSettingsStatisticsHealthDataActive =>
      'Usando los datos de tu aplicación de salud para proporcionar un análisis más preciso de déficit/superávit.';

  @override
  String screensSettingsStatisticsHealthDataAlert(String days) {
    return 'Alerta de Datos de Salud: $days día(s) con déficits calóricos muy grandes (>1000 cal) basados en el gasto real.';
  }

  @override
  String get screensSettingsStatisticsHealthDataInactive =>
      'Activa la sincronización de datos de salud en Configuración de Perfil para un análisis más preciso.';

  @override
  String get screensSettingsStatisticsHealthDataIntegration =>
      'Integración de Datos de Salud';

  @override
  String screensSettingsStatisticsInconsistentDeficitWarning(String variance) {
    return 'Advertencia: Tu déficit calórico varía significativamente día a día (varianza: $variance cal). Considera una ingesta más consistente.';
  }

  @override
  String get screensSettingsStatisticsLastMonth => 'Último Mes';

  @override
  String get screensSettingsStatisticsLastSixMonths => 'Últimos 6 Meses';

  @override
  String get screensSettingsStatisticsLastThreeMonths => 'Últimos 3 Meses';

  @override
  String get screensSettingsStatisticsLastWeek => 'Última Semana';

  @override
  String get screensSettingsStatisticsLastYear => 'Último Año';

  @override
  String get screensSettingsStatisticsMaintenance => 'Mantenimiento';

  @override
  String get screensSettingsStatisticsNoBmiDataAvailable =>
      'No hay datos de IMC disponibles';

  @override
  String get screensSettingsStatisticsNoBodyFatDataAvailable =>
      'No hay datos de grasa corporal disponibles';

  @override
  String get screensSettingsStatisticsNoCalorieDataAvailable =>
      'No hay datos de calorías disponibles';

  @override
  String get screensSettingsStatisticsNotEnoughDataTitle =>
      'No Hay Suficientes Datos';

  @override
  String get screensSettingsStatisticsNoWeightDataAvailable =>
      'No hay datos de peso disponibles';

  @override
  String get screensSettingsStatisticsPhaseAnalysis => 'Análisis de Fase';

  @override
  String get screensSettingsStatisticsRealData => 'Datos Reales';

  @override
  String get screensSettingsStatisticsRefresh => 'Actualizar';

  @override
  String get screensSettingsStatisticsStatistics => 'Estadísticas';

  @override
  String get screensSettingsStatisticsStatisticsEmptyDescription =>
      'Necesitamos al menos una semana de datos para mostrar estadísticas significativas. Sigue rastreando tus métricas para ver tendencias con el tiempo.';

  @override
  String get screensSettingsStatisticsTestDataDescription =>
      'Para fines de demostración, puedes generar datos de muestra para ver cómo se ven las estadísticas.';

  @override
  String get screensSettingsStatisticsTimeRange => 'Rango de Tiempo';

  @override
  String get screensSettingsStatisticsTryAgain => 'Intentar de Nuevo';

  @override
  String get screensSettingsStatisticsUpdateMetricsNow =>
      'Actualizar Métricas Ahora';

  @override
  String screensSettingsStatisticsVeryHighCalorieNotice(String days) {
    return 'Aviso: $days día(s) con ingesta calórica muy alta (>1000 cal por encima del mantenimiento).';
  }

  @override
  String screensSettingsStatisticsVeryLowCalorieWarning(String days) {
    return 'Advertencia: $days día(s) con ingesta calórica extremadamente baja (<1000 cal). Esto puede ser poco saludable.';
  }

  @override
  String get screensSettingsStatisticsVsExpenditure => 'vs gasto';

  @override
  String get screensSettingsStatisticsWeeklyAverage => 'Promedio Semanal';

  @override
  String get screensSettingsStatisticsWeightHistory => 'Historial de Peso';

  @override
  String get screensSettingsStatisticsWeightStatsTip =>
      'El gráfico muestra el peso promedio semanal para tener en cuenta las fluctuaciones diarias debido al peso del agua.';

  @override
  String get utilsLinkHandlerAvailable => 'Disponible';

  @override
  String utilsLinkHandlerCouldNotOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get utilsLinkHandlerNotAvailable => 'No disponible';

  @override
  String get utilsLinkHandlerOpeningLink =>
      'Abriendo página de Buy Me Creatine...';

  @override
  String get screensSettingsIndustrialSystemInfo =>
      'INFORMACIÓN DEL SISTEMA //';

  @override
  String get screensSettingsIndustrialProjectSchematics =>
      'ESQUEMÁTICOS DEL PROYECTO';

  @override
  String get screensSettingsIndustrialCoreDirectives => 'DIRECTIVAS_NUCLEARES';

  @override
  String get screensSettingsIndustrialNetworkLinks => 'ENLACES_DE_RED';

  @override
  String get screensSettingsIndustrialNetworkOperatives => 'OPERATIVOS_DE_RED';

  @override
  String get screensSettingsIndustrialSourceRepository => 'REPOSITORIO_FUENTE';

  @override
  String get screensSettingsIndustrialOfficialDomain => 'DOMINIO_OFICIAL';

  @override
  String get screensSettingsIndustrialWantToContribute =>
      '¿QUIERES CONTRIBUIR?';

  @override
  String get screensSettingsIndustrialSourceCode => 'CÓDIGO_FUENTE';

  @override
  String screensSettingsIndustrialStableBuild(Object version) {
    return 'VERSIÓN_ESTABLE_$version';
  }

  @override
  String get screensSettingsContributorsHansRole =>
      'Copiloto de IA y Hacker Residente';

  @override
  String get screensSettingsContributorsHansDesc =>
      'Automatizando el esfuerzo y manteniendo la telemetría nítida. Arquitecto de ciber-minimalismo.';

  @override
  String get screensSettingsContributorsMrLappesRole =>
      'Creador y Desarrollador';

  @override
  String get screensSettingsContributorsMrLappesDesc =>
      'Creó PlatePal Tracker con la visión de hacer una aplicación de nutrición gratuita y centrada en la privacidad para todos.';

  @override
  String get screensSettingsHealthSettingsTitle => 'HEALTH CONNECT //';

  @override
  String get screensSettingsHealthSettingsConnected => 'Conectado';

  @override
  String get screensSettingsHealthSettingsNotConnected => 'No conectado';

  @override
  String screensSettingsHealthSettingsLastSynced(String time) {
    return 'Última sincronización: $time';
  }

  @override
  String get screensSettingsHealthSettingsNotAvailableOnDevice =>
      'Health Connect no está disponible en este dispositivo.';

  @override
  String get screensSettingsHealthSettingsDisconnectTitle =>
      'Desconectar Health';

  @override
  String get screensSettingsHealthSettingsDisconnectMessage =>
      'Esto dejará de sincronizar las calorías quemadas de Health Connect y dejará de escribir datos de comidas. Sus datos existentes se conservarán.';

  @override
  String get screensSettingsHealthSettingsDisconnect => 'Desconectar';

  @override
  String get screensSettingsHealthSettingsDataOverview => 'RESUMEN DE DATOS';

  @override
  String get screensSettingsHealthSettingsTodaysBurned => 'Quemadas hoy';

  @override
  String get screensSettingsHealthSettingsNoDataYet => 'Sin datos aún';

  @override
  String screensSettingsHealthSettingsDaysCached(int count) {
    return '$count días de datos en caché';
  }

  @override
  String get screensSettingsHealthSettingsSyncControls =>
      'CONTROLES DE SINCRONIZACIÓN';

  @override
  String get screensSettingsHealthSettingsSyncDescription =>
      'Obtiene los últimos datos de calorías quemadas de Health Connect de los últimos 7 días.';

  @override
  String get screensSettingsHealthSettingsOpenHealthConnect =>
      'Abrir Health Connect';

  @override
  String get screensSettingsHealthSettingsWriteBehavior =>
      'COMPORTAMIENTO DE ESCRITURA';

  @override
  String get screensSettingsHealthSettingsWriteMeals =>
      'Escribir comidas en Health Connect';

  @override
  String get screensSettingsHealthSettingsWriteMealsDescription =>
      'Registrar nutrición automáticamente al guardar una comida';

  @override
  String get screensSettingsHealthSettingsTargetAnalysis =>
      'ANÁLISIS DE OBJETIVOS';

  @override
  String get screensSettingsHealthSettingsTargetAnalysisDescription =>
      'Compare su gasto calórico de Health Connect con sus objetivos calóricos actuales para ver si se necesitan ajustes.';

  @override
  String get screensSettingsHealthSettingsCurrentTarget => 'Objetivo actual';

  @override
  String get screensSettingsHealthSettingsAvgExpenditure => 'Gasto promedio';

  @override
  String get screensSettingsHealthSettingsSuggestedTarget =>
      'Objetivo sugerido';

  @override
  String get screensSettingsHealthSettingsDaysAnalyzed => 'Días analizados';

  @override
  String get screensSettingsHealthSettingsApply => 'Aplicar';

  @override
  String screensSettingsHealthSettingsCalorieTargetUpdated(String target) {
    return 'Objetivo calórico actualizado a $target kcal';
  }

  @override
  String get screensSettingsHealthSettingsCalorieTargetUpdateFailed =>
      'Error al actualizar el objetivo calórico';

  @override
  String screensSettingsHealthSettingsAnalysisFailed(String error) {
    return 'Análisis fallido: $error';
  }

  @override
  String get screensSettingsHealthSettingsAboutHealthConnect =>
      'ACERCA DE HEALTH CONNECT';

  @override
  String get screensSettingsHealthSettingsAboutDescription =>
      'Conecta PlatePal a Health Connect (Google Fit) para:';

  @override
  String get screensSettingsHealthSettingsFeatureReadCalories =>
      'Leer las calorías reales quemadas del seguimiento de actividad';

  @override
  String get screensSettingsHealthSettingsFeatureWriteMeals =>
      'Escribir automáticamente datos de nutrición en Health Connect';

  @override
  String get screensSettingsHealthSettingsFeatureNetBalance =>
      'Ver el balance calórico neto preciso (consumidas vs quemadas)';

  @override
  String get screensSettingsHealthSettingsFeatureRecommendations =>
      'Obtener recomendaciones de objetivos calóricos basadas en gasto real';

  @override
  String get screensSettingsHealthSettingsAboutNote =>
      'Cuando está conectado, Health Connect se convierte en la única fuente de verdad para las calorías quemadas — sin valores estimados.';

  @override
  String get screensSettingsHealthSettingsJustNow => 'Ahora mismo';

  @override
  String screensSettingsHealthSettingsMinutesAgo(int minutes) {
    return 'hace $minutes min';
  }

  @override
  String screensSettingsHealthSettingsHoursAgo(int hours) {
    return 'hace $hours h';
  }

  @override
  String screensSettingsHealthSettingsDaysAgo(int days) {
    return 'hace $days d';
  }

  @override
  String get screensMenuHealthAndFitness => 'Salud y Fitness';

  @override
  String get screensMenuHealthConnect => 'HEALTH CONNECT';

  @override
  String get screensMenuHealthConnectedSubtitle =>
      'Conectado — sincronizando con Google Fit';

  @override
  String get screensMenuHealthDisconnectedSubtitle =>
      'Sincronizar con Google Fit y Health Connect';

  @override
  String componentsCalendarMacroSummaryBurned(String calories) {
    return '$calories quemadas';
  }

  @override
  String componentsCalendarMacroSummaryNetCalories(String value) {
    return 'Neto: $value';
  }

  @override
  String get componentsCalendarMacroSummaryNoBurnData =>
      'Sin datos de gasto para este día';

  @override
  String get screensCalendarHealthDeleteWarning =>
      'La entrada de nutrición en Health Connect no se eliminará. Puede eliminarla manualmente en la aplicación Health Connect.';

  @override
  String get screensSettingsProfileSettingsManageHealthConnect =>
      'Gestionar Health Connect';

  @override
  String screensSettingsProfileSettingsLastSynced(String time) {
    return 'Última sincronización: $time';
  }

  @override
  String get servicesChatAgentFallbackParsing =>
      'Me disculpo, pero tengo problemas para procesar tu solicitud. ¿Podrías reformularla?';

  @override
  String get servicesChatAgentFallbackCritical =>
      'Estoy experimentando dificultades técnicas. Por favor, inténtalo de nuevo en unos momentos.';

  @override
  String get servicesChatAgentFallbackNetwork =>
      'Tengo problemas para conectarme. Por favor, comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get servicesChatAgentFallbackContext =>
      'Tu solicitud contiene mucha información. ¿Podrías dividirla en preguntas más pequeñas?';

  @override
  String get servicesChatAgentFallbackGeneric =>
      'Me disculpo, pero encontré un problema inesperado. Por favor, inténtalo de nuevo.';

  @override
  String get servicesChatAgentFallbackGenerateResponse =>
      'Me disculpo, pero encontré un problema al generar una respuesta. Por favor, inténtalo de nuevo.';

  @override
  String get servicesChatAgentFallbackTemporaryIssue =>
      'Encontré un problema temporal al procesar tu solicitud. Por favor, inténtalo de nuevo.';

  @override
  String get servicesChatAgentFallbackRephrase =>
      'Me disculpo, pero tengo dificultades con esa solicitud. ¿Podrías reformularla?';

  @override
  String get servicesChatAgentFallbackDishInfo =>
      'Aquí está la información del plato:';

  @override
  String get servicesChatAgentFallbackNoResponse =>
      'No se encontró texto de respuesta.';

  @override
  String get servicesChatAgentFallbackFormatting =>
      'No pude procesar mi respuesta. Inténtalo de nuevo.';

  @override
  String get screensDishCreateImage => 'Imagen';

  @override
  String get screensDishCreateNoImageSelected =>
      'No se ha seleccionado ninguna imagen';

  @override
  String get screensDishCreateChangeImage => 'Cambiar imagen';

  @override
  String get screensDishCreateAddImage => 'Añadir imagen';

  @override
  String get screensDishCreateConfirmDiscardChanges =>
      '¿Descartar los cambios sin guardar?';

  @override
  String get screensDishCreateProteinAbbreviation => 'P';

  @override
  String get screensDishCreateCarbsAbbreviation => 'C';

  @override
  String get screensDishCreateFatAbbreviation => 'G';

  @override
  String get componentsDishesDishFormIngredientFormModalUnit => 'Unidad';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPerPiece =>
      'Valores nutricionales por pieza';

  @override
  String get componentsDishesDishFormIngredientFormModalNutritionPerSlice =>
      'Valores nutricionales por rebanada';

  @override
  String
  get componentsDishesDishFormIngredientFormModalProductInformationLoaded =>
      'Datos del producto cargados. Ajusta la cantidad y guarda.';

  @override
  String
  get componentsDishesDishFormSmartNutritionCardRecalculateFromIngredients =>
      'Recalcular a partir de los ingredientes';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighProtein =>
      'Alto en proteínas';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighCarb =>
      'Alto en carbohidratos';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighFat =>
      'Alto en grasas';

  @override
  String get componentsDishesDishFormSmartNutritionCardWellBalanced =>
      'Bien equilibrado';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighProteinFeedback =>
      '¡Excelente! Su alto contenido de proteínas favorece el desarrollo muscular y la saciedad.';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighCarbFeedback =>
      '¡Una buena fuente de energía! Ideal antes de entrenar o en días de mucha actividad.';

  @override
  String get componentsDishesDishFormSmartNutritionCardHighFatFeedback =>
      'Alto contenido de grasas. Disfrútalo con moderación y acompáñalo con comidas equilibradas.';

  @override
  String get componentsDishesDishFormSmartNutritionCardBalancedFeedback =>
      '¡Muy equilibrado! Este plato aporta una combinación variada de nutrientes.';

  @override
  String get componentsDishesDishFormSmartNutritionCardUnbalancedFeedback =>
      'Introduce los valores nutricionales para ver el análisis y las recomendaciones.';

  @override
  String get screensSettingsProfileSettingsPhysicalStats => 'Datos físicos';

  @override
  String get screensSettingsProfileSettingsBodyFatOptional =>
      'Grasa corporal % (opcional)';

  @override
  String get screensSettingsProfileSettingsOptional => 'Opcional';

  @override
  String get screensSettingsProfileSettingsNameHint => 'Introduce tu nombre';

  @override
  String get screensSettingsProfileSettingsCustomizeMacroRatios =>
      'Personalizar proporciones de macronutrientes';

  @override
  String get screensSettingsProfileSettingsImperialHeightRange =>
      'La altura debe estar entre 39 y 98 pulgadas';

  @override
  String get screensSettingsProfileSettingsImperialWeightRange =>
      'El peso debe estar entre 66 y 660 lb';

  @override
  String get screensSettingsProfileSettingsValidNumber =>
      'Introduce un número válido';

  @override
  String get screensSettingsProfileSettingsBodyFatRange =>
      'La grasa corporal debe estar entre el 3 % y el 50 %';

  @override
  String get screensSettingsProfileSettingsBaseMetabolicRate =>
      'Tasa metabólica basal';

  @override
  String get screensSettingsProfileSettingsTotalDailyEnergy =>
      'Gasto energético diario total';

  @override
  String get screensSettingsProfileSettingsResettingAppData =>
      'Restableciendo los datos de la aplicación...';

  @override
  String screensSettingsProfileSettingsLoadFailed(String error) {
    return 'No se pudieron cargar los datos del perfil: $error';
  }

  @override
  String screensSettingsProfileSettingsUpdateFailed(String error) {
    return 'No se pudo actualizar el perfil: $error';
  }

  @override
  String screensSettingsMacroCustomizationDailyCalories(String calories) {
    return 'Calorías diarias: $calories kcal';
  }

  @override
  String get screensSettingsMacroCustomizationMacroRatios =>
      'Proporciones de macronutrientes';

  @override
  String get screensSettingsMacroCustomizationFiberTarget =>
      'Objetivo de fibra';

  @override
  String get screensSettingsMacroCustomizationTargetPreview =>
      'Vista previa del objetivo';

  @override
  String get screensSettingsMacroCustomizationQuickPresets => 'Ajustes rápidos';

  @override
  String screensSettingsMacroCustomizationTotalRatio(String value) {
    return 'Total: $value %';
  }

  @override
  String screensSettingsMacroCustomizationPinMacro(String macro) {
    return 'Fijar $macro';
  }

  @override
  String screensSettingsMacroCustomizationUnpinMacro(String macro) {
    return 'Desfijar $macro';
  }

  @override
  String get screensSettingsMacroCustomizationPinnedValue =>
      'Fijado: valor bloqueado';

  @override
  String get screensSettingsMacroCustomizationTooManyPins =>
      'No se puede ajustar: hay demasiados valores fijados';

  @override
  String screensSettingsMacroCustomizationFiberTotal(String grams) {
    return '$grams g en total';
  }

  @override
  String screensSettingsMacroCustomizationFiberPer1000Calories(String grams) {
    return '$grams g por cada 1000 calorías';
  }

  @override
  String get screensSettingsMacroCustomizationFiberGuidance =>
      'Recomendación: 14 g por cada 1000 calorías (guía de la FDA). Intervalo: 5-35 g por cada 1000 calorías';

  @override
  String get screensSettingsMacroCustomizationDailyMacroTargets =>
      'Objetivos diarios de macronutrientes';

  @override
  String get screensSettingsMacroCustomizationPresetDescription =>
      'Elige una distribución habitual de macronutrientes';

  @override
  String get screensSettingsMacroCustomizationBalancedPreset =>
      'Equilibrado (30P / 40C / 30G)';

  @override
  String get screensSettingsMacroCustomizationHighProteinPreset =>
      'Alto en proteínas (40P / 30C / 30G)';

  @override
  String get screensSettingsMacroCustomizationProfileNotFound =>
      'No se encontró el perfil. Configura tu perfil.';

  @override
  String screensSettingsMacroCustomizationLoadFailed(String error) {
    return 'No se pudo cargar el perfil: $error';
  }

  @override
  String screensSettingsMacroCustomizationSaveFailed(String error) {
    return 'No se pudieron guardar los objetivos de macronutrientes: $error';
  }

  @override
  String get screensSettingsStatisticsProfileNotFound =>
      'No se encontró el perfil de usuario';

  @override
  String screensSettingsStatisticsTestDataFailed(String error) {
    return 'No se pudieron generar los datos de prueba: $error';
  }

  @override
  String screensSettingsStatisticsPhaseDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '($_temp0)';
  }

  @override
  String screensSettingsStatisticsCalPerDay(String value) {
    return '$value calorías/día';
  }

  @override
  String screensSettingsStatisticsCalValue(String value) {
    return '$value calorías';
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
      other: 'días',
      one: 'día',
    );
    return 'Cobertura de datos del gasto calórico: $percent% ($healthDays/$totalDays $_temp0)';
  }

  @override
  String get screensSettingsStatisticsActualBalance => 'Balance real';

  @override
  String screensSettingsStatisticsChartSummary(
    String chart,
    int count,
    String minimum,
    String maximum,
  ) {
    return 'Gráfico de $chart: $count puntos, escala de $minimum a $maximum';
  }

  @override
  String get screensSettingsHealthSettingsAnalysisProfileNotFound =>
      'No se encontró el perfil de usuario';

  @override
  String get screensSettingsHealthSettingsAnalysisNoData =>
      'No hay datos de gasto calórico disponibles para el análisis';

  @override
  String get screensSettingsHealthSettingsAnalysisIncreaseIntake =>
      'Tu gasto calórico es mucho mayor de lo que indica tu objetivo actual. Considera aumentar la ingesta de calorías.';

  @override
  String get screensSettingsHealthSettingsAnalysisDecreaseIntake =>
      'Tu gasto calórico es menor de lo que indica tu objetivo actual. Considera ajustar la ingesta de calorías o aumentar la actividad.';

  @override
  String get screensSettingsHealthSettingsAnalysisOnTarget =>
      'Tus objetivos calóricos actuales parecen adecuados para tu nivel de actividad.';

  @override
  String screensSettingsHealthSettingsAnalysisError(String error) {
    return 'Se produjo un error durante el análisis: $error';
  }

  @override
  String get servicesChatAgentThinking =>
      'Analizando tu solicitud y planificando cómo proceder...';

  @override
  String get servicesChatAgentThinkingDetail =>
      'Desglosando tu solicitud para decidir el mejor enfoque';

  @override
  String get servicesChatAgentContext =>
      'Reuniendo contexto y datos relevantes...';

  @override
  String get servicesChatAgentContextDetail =>
      'Recopilando tu perfil, preferencias e historial de comidas';

  @override
  String get servicesChatAgentResponse =>
      'Preparando una respuesta personalizada...';

  @override
  String get servicesChatAgentResponseDetail =>
      'Combinando la información para darte una respuesta útil y personalizada';

  @override
  String get servicesChatAgentDish => 'Procesando y analizando platos...';

  @override
  String get servicesChatAgentDishDetail =>
      'Calculando los valores nutricionales, ingredientes y detalles de las comidas';

  @override
  String get servicesChatAgentDishValidation =>
      'Validando y ajustando los platos...';

  @override
  String get servicesChatAgentDishValidationDetail =>
      'Comprobando los valores nutricionales y los ingredientes de los platos';

  @override
  String get servicesChatAgentError => 'Gestionando un error inesperado...';

  @override
  String get servicesChatAgentErrorDetail =>
      'Intentando recuperarse del error y ofrecer una respuesta útil';

  @override
  String get servicesChatAgentVerify =>
      'Verificando que el contexto permita una respuesta óptima...';

  @override
  String get servicesChatAgentVerifyDetail =>
      'Analizando el contexto reunido para ofrecer la mejor respuesta posible';

  @override
  String get servicesChatAgentImage => 'Analizando la imagen que has subido...';

  @override
  String get servicesChatAgentImageDetail =>
      'Identificando alimentos, ingredientes y porciones de tu imagen';

  @override
  String servicesChatAgentUnknownStep(String step) {
    return 'Procesando el paso: $step...';
  }

  @override
  String servicesChatAgentUnknownDetail(String step) {
    return 'Procesando información para el paso: $step';
  }

  @override
  String servicesChatAgentRestart(int attempt) {
    return 'Reiniciando con una estrategia mejorada (intento $attempt/3)...';
  }

  @override
  String servicesChatAgentFailedStep(String step) {
    return 'Se produjo un problema en el paso \"$step\"; intentando recuperarse...';
  }

  @override
  String get componentsChatMessageBubbleErrorAuth =>
      'Tu clave de API fue rechazada. Revísala en los ajustes de la clave de API.';

  @override
  String get componentsChatMessageBubbleErrorRateLimit =>
      'Se alcanzó el límite de solicitudes o la cuota de tu proveedor de IA. Espera un momento o revisa tu plan y tu saldo, y vuelve a intentarlo.';

  @override
  String get componentsChatMessageBubbleErrorNetwork =>
      'No se pudo conectar con el proveedor de IA o la solicitud tardó demasiado. Comprueba tu conexión a internet y vuelve a intentarlo.';

  @override
  String get componentsChatMessageBubbleErrorServer =>
      'El proveedor de IA no está disponible en este momento. Vuelve a intentarlo en un momento.';

  @override
  String get componentsChatMessageBubbleErrorKeyUnreadable =>
      'No se pudo leer tu clave de API en este dispositivo. Vuelve a introducirla en los ajustes de la clave de API.';

  @override
  String get componentsChatMessageBubbleErrorUnknown =>
      'No se pudo enviar el mensaje. Vuelve a intentarlo.';

  @override
  String get componentsChatMessageBubbleOpenApiKeySettings =>
      'Ajustes de la clave de API';

  @override
  String get componentsChatMessageBubbleNoteContextIncomplete =>
      'No se pudieron cargar algunos de tus datos; la respuesta puede ser menos personalizada.';

  @override
  String get componentsChatMessageBubbleNoteImageNotAnalyzed =>
      'No se pudo analizar la imagen.';

  @override
  String get screensChatHistoryLoadFailed =>
      'No se pudo cargar parte de tu historial de chat.';

  @override
  String get screensChatHistorySaveFailed =>
      'No se pudo guardar tu historial de chat en este dispositivo.';

  @override
  String get screensChatSettingsFailed =>
      'No se pudieron cargar o guardar los ajustes del chat. Por ahora se usan los valores predeterminados.';

  @override
  String get screensChatProfilesLoadFailed =>
      'No se pudieron cargar los perfiles del chat. Se muestran los predeterminados; tus perfiles guardados no se modificaron.';

  @override
  String get screensChatProfileSaveFailed =>
      'No se pudieron guardar los cambios del perfil.';

  @override
  String get screensChatApiKeyReadFailedTitle =>
      'No se pudo leer tu clave de API';

  @override
  String get screensChatApiKeyReadFailedMessage =>
      'No se pudo acceder a la clave guardada en este dispositivo. Recarga para volver a intentarlo o introdúcela de nuevo en los ajustes de la clave de API.';

  @override
  String get screensSettingsStatisticsPartialLoadFailed =>
      'No se pudieron cargar algunos datos de salud o de calorías, por lo que los gráficos pueden estar incompletos.';

  @override
  String get screensSettingsHealthSettingsLoadDataFailed =>
      'No se pudieron cargar los datos de salud de hoy.';

  @override
  String get screensSettingsHealthSettingsOpenSettingsFailed =>
      'No se pudieron abrir los ajustes de Health Connect.';

  @override
  String get screensCalendarProfileLoadFailed =>
      'No se pudo cargar tu perfil, por eso no se muestran los objetivos diarios.';

  @override
  String get componentsLowCalorieWarningTitle => 'Objetivo calórico muy bajo';

  @override
  String componentsLowCalorieWarningMessage(String calories, String threshold) {
    return 'Un objetivo calórico diario de $calories kcal está por debajo de $threshold kcal. Puede que algo no esté bien: revisa los datos de tu perfil, como peso, altura, edad y nivel de actividad. Una ingesta calórica muy baja solo debe seguirse bajo supervisión médica.';
  }

  @override
  String get screensSettingsProfileSettingsInvalidCalorieTarget =>
      'Con estos datos no se puede calcular un objetivo calórico. Revisa tu peso, altura y edad.';

  @override
  String get screensMenuSupport => 'Ayuda y comentarios';

  @override
  String get screensMenuSendFeedback => 'Enviar comentarios';

  @override
  String get screensMenuSendFeedbackSubtitle =>
      'Escribe un correo al desarrollador';

  @override
  String get screensMenuReportProblem => 'Informar de un problema';

  @override
  String get screensMenuReportProblemSubtitle =>
      'Comparte el registro de diagnóstico con la app que elijas';

  @override
  String get screensMenuClearDiagnosticLog => 'Borrar registro de diagnóstico';

  @override
  String get screensMenuClearDiagnosticLogSubtitle =>
      'Elimina los registros de errores guardados en este dispositivo';

  @override
  String get screensMenuDiagnosticsNote =>
      'No se envía nada automáticamente: los errores se guardan en un breve registro local sin datos personales y solo salen de tu dispositivo si los compartes.';

  @override
  String screensMenuFeedbackSubject(String version) {
    return 'Comentarios sobre PlatePal Tracker (v$version)';
  }

  @override
  String screensMenuNoEmailApp(String email) {
    return 'No se encontró ninguna app de correo. Puedes escribir a $email.';
  }

  @override
  String screensMenuReportProblemSubject(String version) {
    return 'Informe de problema de PlatePal Tracker (v$version)';
  }

  @override
  String screensMenuReportProblemShareText(String email) {
    return 'Registro de diagnóstico de PlatePal Tracker. Contacto del desarrollador: $email';
  }

  @override
  String get screensMenuDiagnosticLogEmpty =>
      'Aún no se ha registrado ningún problema. El registro de diagnóstico está vacío.';

  @override
  String get screensMenuDiagnosticLogShareFailed =>
      'No se pudo compartir el registro de diagnóstico. Inténtalo de nuevo.';

  @override
  String get screensMenuDiagnosticLogCleared =>
      'Registro de diagnóstico borrado.';

  @override
  String get screensMenuDiagnosticLogClearFailed =>
      'No se pudo borrar el registro de diagnóstico. Inténtalo de nuevo.';

  @override
  String get screensPrivacyDiagnosticsTitle =>
      'Registro de diagnóstico y comentarios';

  @override
  String get screensPrivacyDiagnosticsBody =>
      'Si la app sufre un error inesperado, guarda en tu dispositivo un breve registro técnico: la hora, la versión de la app, el tipo de error, un mensaje de error abreviado y la ubicación en el código. Se elimina el texto que pueda contener datos personales, como valores entre comillas, direcciones de correo, claves y medidas, y solo se conservan las últimas 20 entradas. El registro nunca se envía automáticamente. Solo sale de tu dispositivo si eliges «Informar de un problema» y lo compartes con la app que prefieras; «Borrar registro de diagnóstico» en el menú lo elimina. «Enviar comentarios» abre tu app de correo y no se envía nada hasta que tú mismo envíes el correo.';

  @override
  String get screensSettingsImportDataInvalidArchive =>
      'Este archivo ZIP no es una copia de seguridad de PlatePal Tracker.';

  @override
  String get screensSettingsExportDataExportAsZip => 'Copia completa (.zip)';

  @override
  String get screensSettingsExportDataZipDescription =>
      'Datos y fotos de los platos en un solo archivo, para pasar a otro dispositivo';

  @override
  String screensSettingsStatisticsNotEnoughMetrics(int count) {
    return 'Registra tus medidas corporales al menos $count veces para ver este gráfico.';
  }

  @override
  String componentsScannerBarcodeScannerNotFoundMessage(String barcode) {
    return 'El código $barcode aún no está en Open Food Facts. Busca por nombre o introduce el alimento tú mismo.';
  }

  @override
  String get componentsScannerBarcodeScannerSearchByName => 'Buscar por nombre';

  @override
  String get componentsScannerBarcodeScannerEnterManually =>
      'Introducir manualmente';

  @override
  String get componentsScannerBarcodeScannerScanAgain => 'Escanear de nuevo';

  @override
  String componentsDishesDishFormIngredientFormModalBarcode(String barcode) {
    return 'Código de barras: $barcode';
  }

  @override
  String get screensMealsScanBarcode => 'Escanear código de barras';

  @override
  String get screensMealsSearchFood => 'Buscar alimento';

  @override
  String get componentsScannerProductSearchErrorOffline =>
      'Estás sin conexión. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get componentsScannerProductSearchErrorTimeout =>
      'Open Food Facts tardó demasiado en responder. Inténtalo de nuevo.';

  @override
  String get componentsScannerProductSearchErrorServer =>
      'Open Food Facts está saturado o no disponible. Espera un momento e inténtalo de nuevo.';

  @override
  String get componentsModalsLogFoodTitle => 'Registrar comida';

  @override
  String componentsModalsLogFoodForMealType(String mealType) {
    return 'Para $mealType';
  }

  @override
  String get componentsModalsLogFoodFavorites => 'Favoritos';

  @override
  String get componentsModalsLogFoodRecent => 'Recientes';

  @override
  String get componentsModalsLogFoodAllDishes => 'Todos los platos';

  @override
  String get componentsModalsLogFoodQuickAdd => 'Añadido rápido';

  @override
  String get componentsModalsLogFoodSearchOpenFoodFacts =>
      'Buscar en Open Food Facts';

  @override
  String get componentsModalsQuickAddCalories => 'Calorías (kcal)';

  @override
  String get componentsModalsQuickAddCaloriesRequired =>
      'Introduce las calorías';

  @override
  String get componentsModalsQuickAddInvalidNumber =>
      'Introduce un número mayor o igual que 0';

  @override
  String get componentsModalsQuickAddName => 'Nombre (opcional)';

  @override
  String get componentsModalsQuickAddProtein => 'Proteína (g)';

  @override
  String get componentsModalsQuickAddCarbs => 'Carbohidratos (g)';

  @override
  String get componentsModalsQuickAddFat => 'Grasa (g)';

  @override
  String get componentsModalsQuickAddFiber => 'Fibra (g)';

  @override
  String get componentsModalsQuickAddSaved => 'Añadido rápido registrado';

  @override
  String get componentsModalsQuickAddFailed =>
      'No se pudo guardar el añadido rápido. Inténtalo de nuevo.';

  @override
  String get componentsModalsDishLogModalServings => 'Raciones';

  @override
  String get componentsModalsDishLogModalWeight => 'Peso';

  @override
  String componentsModalsDishLogModalAmountInUnit(String unit) {
    return 'Cantidad ($unit)';
  }

  @override
  String componentsModalsDishLogModalServingWeight(String amount, String unit) {
    return '1 ración = $amount $unit';
  }

  @override
  String get componentsModalsDishLogModalFewerServings => 'Menos raciones';

  @override
  String get componentsModalsDishLogModalMoreServings => 'Más raciones';

  @override
  String componentsModalsDishLogModalAmountRange(String min, String max) {
    return 'Introduce un valor de $min a $max';
  }

  @override
  String get componentsModalsDishLogModalEditTitle => 'Editar entrada';

  @override
  String get componentsModalsDishLogModalEntryUpdated => 'Entrada actualizada';

  @override
  String get componentsModalsDishLogModalUpdateFailed =>
      'No se pudo actualizar la entrada. Inténtalo de nuevo.';

  @override
  String get componentsModalsDishLogModalHealthEditWarning =>
      'Health Connect conserva la entrada original. Cámbiala o elimínala allí si es necesario.';

  @override
  String get screensCalendarEntryActions => 'Más acciones';

  @override
  String get screensCalendarCopyToToday => 'Copiar a hoy';

  @override
  String get screensCalendarCopyToDate => 'Copiar a fecha…';

  @override
  String screensCalendarCopyFromPreviousDay(String mealType) {
    return 'Copiar $mealType del día anterior';
  }

  @override
  String screensCalendarAddToMeal(String mealType) {
    return 'Añadir a $mealType';
  }

  @override
  String screensCalendarEntriesCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas copiadas',
      one: '1 entrada copiada',
    );
    return '$_temp0';
  }

  @override
  String screensCalendarNothingToCopy(String mealType) {
    return 'El día anterior no tiene entradas de $mealType';
  }

  @override
  String get screensCalendarCopyFailed =>
      'No se pudo copiar. Inténtalo de nuevo.';

  @override
  String get screensDishCreateRecipeMakes => 'Esta receta rinde';

  @override
  String get screensDishCreateServingsSuffix => 'raciones';

  @override
  String get screensDishCreateServingsHelper =>
      'Los valores nutricionales de abajo son para toda la receta';

  @override
  String screensDishCreatePerServingSummary(
    String servings,
    String calories,
    String protein,
    String carbs,
    String fat,
  ) {
    return 'Por ración (1 de $servings): $calories kcal · $protein g proteína · $carbs g carbohidratos · $fat g grasa';
  }

  @override
  String componentsChatMealLogProposalSummaryOne(
    String name,
    String mealType,
    String day,
    String calories,
  ) {
    return 'Registrar 1 ración de $name como $mealType $day – $calories kcal';
  }

  @override
  String componentsChatMealLogProposalSummaryOther(
    String servings,
    String name,
    String mealType,
    String day,
    String calories,
  ) {
    return 'Registrar $servings raciones de $name como $mealType $day – $calories kcal';
  }

  @override
  String get componentsChatMealLogProposalToday => 'hoy';

  @override
  String get componentsChatMealLogProposalYesterday => 'ayer';

  @override
  String componentsChatMealLogProposalOnDate(String date) {
    return 'el $date';
  }

  @override
  String get componentsChatMealLogProposalConfirm => 'Confirmar';

  @override
  String get componentsChatMealLogProposalEdit => 'Editar';

  @override
  String get componentsChatMealLogProposalDismiss => 'Descartar';

  @override
  String get componentsChatMealLogProposalLogged => 'Registrado';

  @override
  String get componentsChatMealLogProposalDismissed => 'Descartado';

  @override
  String get componentsChatMealLogProposalDishMissing =>
      'Este plato ya no existe.';

  @override
  String get componentsChatMealLogProposalInvalid =>
      'No se pudo leer la entrada del asistente. Vuelve a preguntar.';
}
