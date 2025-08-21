// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PlatePal Tracker';

  @override
  String get welcome => 'Bienvenido a PlatePal';

  @override
  String get meals => 'Comidas';

  @override
  String get nutrition => 'Nutrición';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuración';

  @override
  String get addMeal => 'Agregar Comida';

  @override
  String get breakfast => 'Desayuno';

  @override
  String get lunch => 'Almuerzo';

  @override
  String get dinner => 'Cena';

  @override
  String get snack => 'Merienda';

  @override
  String get noMealsLogged => 'Aún no hay comidas registradas';

  @override
  String get startTrackingMeals => 'Comienza a registrar tus comidas para verlas aquí';

  @override
  String get todaysMeals => 'Comidas de Hoy';

  @override
  String get allMeals => 'Todas las Comidas';

  @override
  String get mealHistory => 'Historial de Comidas';

  @override
  String get filterByMealType => 'Filtrar por tipo de comida';

  @override
  String get logMeal => 'Registrar Comida';

  @override
  String mealLoggedAt(String time) {
    return 'Registrado a las $time';
  }

  @override
  String get calories => 'Calorías';

  @override
  String get protein => 'Proteína';

  @override
  String get carbs => 'Carbohidratos';

  @override
  String get fat => 'Grasa';

  @override
  String get calendar => 'Calendario';

  @override
  String get unknownDish => 'Plato Desconocido';

  @override
  String get noMealsLoggedForDay => 'No hay comidas registradas para este día';

  @override
  String get nutritionSummary => 'Resumen Nutricional';

  @override
  String get getAiTip => 'Obtener Consejo IA';

  @override
  String get deleteLog => 'Eliminar Registro';

  @override
  String get deleteLogConfirmation => '¿Está seguro de que desea eliminar esta comida registrada?';

  @override
  String get delete => 'Eliminar';

  @override
  String get mealLogDeletedSuccessfully => 'Registro de comida eliminado exitosamente';

  @override
  String get failedToDeleteMealLog => 'Error al eliminar el registro de comida';

  @override
  String get chat => 'Chat';

  @override
  String get menu => 'Menú';

  @override
  String get userProfile => 'Perfil de Usuario';

  @override
  String get nutritionGoals => 'Objetivos Nutricionales';

  @override
  String get appearance => 'Apariencia';

  @override
  String get aiFeatures => 'IA y Características';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get information => 'Información';

  @override
  String get apiKeySettings => 'Configuración de Clave API';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get importData => 'Importar Datos';

  @override
  String get selectFile => 'Seleccionar Archivo';

  @override
  String get selectFilesToImport => 'Seleccionar archivos para importar';

  @override
  String get importFromFile => 'Importar desde Archivo';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get importCsv => 'Importar CSV';

  @override
  String get exportAsJson => 'Exportar como JSON';

  @override
  String get exportAsCsv => 'Exportar como CSV';

  @override
  String get selectDataToExport => 'Seleccionar datos para exportar';

  @override
  String get selectDataToImport => 'Seleccionar datos para importar';

  @override
  String get userProfiles => 'Perfiles de Usuario';

  @override
  String get mealLogs => 'Registros de Comidas';

  @override
  String get dishes => 'Platos';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get supplements => 'Suplementos';

  @override
  String get nutritionGoalsData => 'Objetivos Nutricionales';

  @override
  String get allData => 'Todos los Datos';

  @override
  String get importProgress => 'Importando datos...';

  @override
  String get exportProgress => 'Exportando datos...';

  @override
  String get importSuccessful => 'Datos importados exitosamente';

  @override
  String get exportSuccessful => 'Datos exportados exitosamente';

  @override
  String get importFailed => 'Error en la importación';

  @override
  String get exportFailed => 'Error en la exportación';

  @override
  String get noFileSelected => 'Ningún archivo seleccionado';

  @override
  String get invalidFileFormat => 'Formato de archivo inválido';

  @override
  String get fileNotFound => 'Archivo no encontrado';

  @override
  String get dataValidationFailed => 'Error en la validación de datos';

  @override
  String importedItemsCount(int count) {
    return 'Se importaron $count elementos';
  }

  @override
  String exportedItemsCount(int count) {
    return 'Se exportaron $count elementos';
  }

  @override
  String get backupAndRestore => 'Respaldo y Restauración';

  @override
  String get createBackup => 'Crear Respaldo';

  @override
  String get restoreFromBackup => 'Restaurar desde Respaldo';

  @override
  String get backupCreatedSuccessfully => 'Respaldo creado exitosamente';

  @override
  String get restoreSuccessful => 'Restauración completada exitosamente';

  @override
  String get warningDataWillBeReplaced => 'Advertencia: Los datos existentes serán reemplazados';

  @override
  String get confirmRestore => '¿Está seguro de que desea restaurar? Esto reemplazará todos los datos existentes.';

  @override
  String fileSize(String size) {
    return 'Tamaño del archivo: $size';
  }

  @override
  String duplicateItemsFound(int count) {
    return 'Elementos duplicados encontrados: $count';
  }

  @override
  String get howToHandleDuplicates => '¿Cómo manejar duplicados?';

  @override
  String get skipDuplicates => 'Omitir Duplicados';

  @override
  String get overwriteDuplicates => 'Sobrescribir Duplicados';

  @override
  String get mergeDuplicates => 'Fusionar Duplicados';

  @override
  String formatNotSupported(String format) {
    return 'Formato no soportado: $format';
  }

  @override
  String get about => 'Acerca de';

  @override
  String get aboutAppTitle => 'Acerca de la Aplicación';

  @override
  String get madeBy => 'Hecho por MrLappes';

  @override
  String get website => 'plate-pal.de';

  @override
  String get githubRepository => 'github.com/MrLappes/platepal-tracker';

  @override
  String get appMotto => 'Hecho por deportistas para deportistas que odian las aplicaciones de pago';

  @override
  String get codersMessage => 'Los programadores no deberían tener que pagar';

  @override
  String get whyPlatePal => '¿Por qué PlatePal?';

  @override
  String get aboutDescription => 'PlatePal Tracker fue creado para proporcionar una alternativa de código abierto y centrada en la privacidad a las costosas aplicaciones de seguimiento nutricional. Creemos en poner el control en tus manos sin suscripciones, sin anuncios y sin recopilación de datos.';

  @override
  String get dataStaysOnDevice => 'Tus datos permanecen en tu dispositivo';

  @override
  String get useOwnAiKey => 'Usa tu propia clave de IA para control total';

  @override
  String get freeOpenSource => '100% gratuito y de código abierto';

  @override
  String couldNotOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get linkError => 'Ocurrió un error al abrir el enlace';

  @override
  String get contributors => 'Contribuidores';

  @override
  String get editPersonalInfo => 'Edita tu información personal';

  @override
  String get setNutritionTargets => 'Establece tus objetivos nutricionales diarios';

  @override
  String get configureApiKey => 'Configura tu clave API de OpenAI';

  @override
  String get exportMealData => 'Exporta tus datos de comidas';

  @override
  String get importMealDataBackup => 'Importa datos de comidas desde respaldo';

  @override
  String get learnMorePlatePal => 'Aprende más sobre PlatePal';

  @override
  String get viewContributors => 'Ver contribuidores del proyecto';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get german => 'Alemán';

  @override
  String get contributorSingular => 'Contribuidor';

  @override
  String get contributorPlural => 'Contribuidores';

  @override
  String get contributorsThankYou => '¡Gracias a todos los que han contribuido a hacer posible PlatePal Tracker!';

  @override
  String get wantToContribute => '¿Quieres contribuir?';

  @override
  String get openSourceMessage => 'PlatePal Tracker es de código abierto: ¡únete a nosotros en GitHub!';

  @override
  String get checkGitHub => 'Echa un vistazo a nuestro repositorio de GitHub';

  @override
  String get supportDevelopment => 'Apoyar el desarrollo';

  @override
  String get supportMessage => '¿Quieres comprarme mi creatina? Tu apoyo es muy apreciado pero no es para nada obligatorio.';

  @override
  String get buyMeCreatine => 'Cómprame creatina';

  @override
  String get openingLink => 'Abriendo página de Buy Me Creatine...';

  @override
  String get aboutOpenAiApiKey => 'Acerca de la clave API de OpenAI';

  @override
  String get apiKeyDescription => 'Para usar funciones de IA como análisis de comidas y sugerencias, necesitas proporcionar tu propia clave API de OpenAI. Esto asegura que tus datos permanezcan privados y tengas control total.';

  @override
  String get apiKeyBulletPoints => '• Obtén tu clave API desde platform.openai.com\n• Tu clave se almacena localmente en tu dispositivo\n• Los cargos por uso se aplican directamente a tu cuenta de OpenAI';

  @override
  String get apiKeyConfigured => 'Clave API configurada';

  @override
  String get aiFeaturesEnabled => 'Las funciones de IA están habilitadas';

  @override
  String get openAiApiKey => 'Clave API de OpenAI';

  @override
  String get apiKeyPlaceholder => 'sk-...';

  @override
  String get apiKeyHelperText => 'Ingresa tu clave API de OpenAI o déjalo vacío para desactivar las funciones de IA';

  @override
  String get updateApiKey => 'Actualizar clave API';

  @override
  String get saveApiKey => 'Guardar clave API';

  @override
  String get getApiKeyFromOpenAi => 'Obtener clave API de OpenAI';

  @override
  String get removeApiKey => 'Eliminar clave API';

  @override
  String get removeApiKeyConfirmation => '¿Estás seguro de que quieres eliminar tu clave API? Esto desactivará las funciones de IA.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Eliminar';

  @override
  String get apiKeyMustStartWith => 'La clave API debe comenzar con \"sk-\"';

  @override
  String get apiKeyTooShort => 'La clave API parece ser demasiado corta';

  @override
  String get apiKeyRemovedSuccessfully => 'Clave API eliminada exitosamente';

  @override
  String get apiKeySavedSuccessfully => 'Clave API guardada exitosamente';

  @override
  String get failedToLoadApiKey => 'Error al cargar la clave API';

  @override
  String get failedToSaveApiKey => 'Error al guardar la clave API';

  @override
  String get failedToRemoveApiKey => 'Error al eliminar la clave API';

  @override
  String get visitOpenAiPlatform => 'Visita platform.openai.com para obtener tu clave API';

  @override
  String get pasteFromClipboard => 'Pegar desde portapapeles';

  @override
  String get clipboardEmpty => 'El portapapeles está vacío';

  @override
  String get pastedFromClipboard => 'Pegado desde portapapeles';

  @override
  String get failedToAccessClipboard => 'Error al acceder al portapapeles';

  @override
  String get selectModel => 'Seleccionar Modelo';

  @override
  String get testAndSaveApiKey => 'Probar y Guardar Clave API';

  @override
  String get testingApiKey => 'Probando clave API...';

  @override
  String get gpt4ModelsInfo => 'Los modelos GPT-4 proporcionan el mejor análisis pero cuestan más';

  @override
  String get gpt35ModelsInfo => 'Los modelos GPT-3.5 son más rentables para análisis básicos';

  @override
  String get loadingModels => 'Cargando modelos disponibles...';

  @override
  String get couldNotLoadModels => 'No se pudieron cargar los modelos disponibles. Usando lista de modelos predeterminada';

  @override
  String get apiKeyTestWarning => 'Su clave API será probada con una pequeña solicitud para verificar que funcione. La clave solo se almacena en su dispositivo y nunca se envía a nuestros servidores';

  @override
  String get ok => 'OK';

  @override
  String get welcomeToPlatePalTracker => 'Bienvenido a PlatePal Tracker';

  @override
  String get profileSettings => 'Configuración de Perfil';

  @override
  String get personalInformation => 'Información Personal';

  @override
  String get name => 'Nombre';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get age => 'Edad';

  @override
  String get gender => 'Género';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get other => 'Otro';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get targetWeight => 'Peso Objetivo';

  @override
  String get activityLevel => 'Nivel de Actividad';

  @override
  String get sedentary => 'Sedentario';

  @override
  String get lightlyActive => 'Ligeramente Activo';

  @override
  String get moderatelyActive => 'Moderadamente Activo';

  @override
  String get veryActive => 'Muy Activo';

  @override
  String get extraActive => 'Extremadamente Activo';

  @override
  String get fitnessGoals => 'Objetivos de Fitness';

  @override
  String get fitnessGoal => 'Objetivo de Fitness';

  @override
  String get loseWeight => 'Perder Peso';

  @override
  String get maintainWeight => 'Mantener Peso';

  @override
  String get gainWeight => 'Ganar Peso';

  @override
  String get buildMuscle => 'Construir Músculo';

  @override
  String get preferences => 'Preferencias';

  @override
  String get unitSystem => 'Sistema de Unidades';

  @override
  String get metric => 'Métrico (kg, cm)';

  @override
  String get imperial => 'Imperial (lb, ft)';

  @override
  String get save => 'Guardar';

  @override
  String get saveChanges => 'Guardar Cambios';

  @override
  String get discardChanges => 'Descartar Cambios';

  @override
  String get profileUpdated => 'Perfil actualizado exitosamente';

  @override
  String get profileUpdateFailed => 'Error al actualizar el perfil';

  @override
  String get unsavedChanges => 'Cambios No Guardados';

  @override
  String get unsavedChangesMessage => 'Tienes cambios no guardados. ¿Quieres guardarlos antes de salir?';

  @override
  String get deleteProfile => 'Eliminar Perfil';

  @override
  String get deleteProfileConfirmation => '¿Estás seguro de que quieres eliminar tu perfil? Esta acción no se puede deshacer.';

  @override
  String get loading => 'Cargando...';

  @override
  String get requiredField => 'Este campo es requerido';

  @override
  String get invalidEmail => 'Por favor ingresa una dirección de correo válida';

  @override
  String get ageRange => 'La edad debe estar entre 13 y 120';

  @override
  String get heightRange => 'La altura debe estar entre 100-250 cm';

  @override
  String get weightRange => 'El peso debe estar entre 30-300 kg';

  @override
  String get currentStats => 'Estadísticas Actuales';

  @override
  String get bmi => 'IMC';

  @override
  String get bmr => 'TMB';

  @override
  String get tdee => 'TDEE';

  @override
  String get years => 'años';

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
  String get chatAssistant => 'Asistente de Chat IA';

  @override
  String get chatSubtitle => 'Obtén sugerencias personalizadas de comidas y consejos nutricionales';

  @override
  String get typeMessage => 'Escribe un mensaje...';

  @override
  String get sendMessage => 'Enviar mensaje';

  @override
  String get analyzeDish => 'Analizar Plato';

  @override
  String get scanBarcode => 'Escanear Código de Barras';

  @override
  String get searchProduct => 'Buscar Producto';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get suggestMeal => 'Sugerir comida';

  @override
  String get analyzeNutrition => 'Analizar nutrición';

  @override
  String get findAlternatives => 'Encontrar alternativas';

  @override
  String get calculateMacros => 'Calcular macros';

  @override
  String get mealPlan => 'Ayuda con plan de comidas';

  @override
  String get ingredientInfo => 'Info de ingredientes';

  @override
  String get clearChat => 'Limpiar Chat';

  @override
  String get clearChatConfirmation => '¿Estás seguro de que quieres limpiar el historial del chat? Esta acción no se puede deshacer.';

  @override
  String get chatCleared => 'Historial del chat eliminado';

  @override
  String get messageFailedToSend => 'Error al enviar mensaje';

  @override
  String get retryMessage => 'Reintentar';

  @override
  String get copyMessage => 'Copiar mensaje';

  @override
  String get messageCopied => 'Mensaje copiado al portapapeles';

  @override
  String get aiThinking => 'La IA está pensando...';

  @override
  String get noApiKeyConfigured => 'No hay clave API configurada';

  @override
  String get configureApiKeyToUseChat => 'Por favor configura tu clave API de OpenAI en ajustes para usar el asistente de chat IA.';

  @override
  String get configureApiKeyButton => 'Configurar Clave API';

  @override
  String get reloadApiKeyButton => 'Recargar Clave API';

  @override
  String get welcomeToChat => '¡Bienvenido a tu asistente nutricional IA! Pregúntame cualquier cosa sobre comidas, nutrición o tus objetivos de fitness.';

  @override
  String get attachImage => 'Adjuntar imagen';

  @override
  String get imageAttached => 'Imagen adjuntada';

  @override
  String get removeImage => 'Quitar imagen';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de Galería';

  @override
  String get imageSourceSelection => 'Seleccionar Fuente de Imagen';

  @override
  String get nutritionAnalysis => 'Análisis Nutricional';

  @override
  String get addToMeals => 'Agregar a Comidas';

  @override
  String get details => 'Detalles';

  @override
  String get tapToViewAgentSteps => 'Toca para ver los pasos del agente';

  @override
  String addedToMealsSuccess(String dishName) {
    return 'Se agregó $dishName a las comidas';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get servingSize => 'Tamaño de Porción';

  @override
  String get perServing => 'por porción';

  @override
  String get dishName => 'Nombre del Plato';

  @override
  String get cookingInstructions => 'Instrucciones de Cocina';

  @override
  String get mealType => 'Tipo de Comida';

  @override
  String get addedToMeals => 'Agregado a comidas exitosamente';

  @override
  String get failedToAddMeal => 'Error al agregar comida';

  @override
  String get testChatWelcome => '¡Este es el modo de prueba! Puedo ayudarte a explorar las características de PlatePal. Intenta preguntarme sobre nutrición, planificación de comidas o recomendaciones de alimentos.';

  @override
  String get testChatResponse => '¡Gracias por probar PlatePal! Esta es una respuesta de prueba para mostrarte cómo funciona nuestro asistente IA. Para obtener consejos nutricionales reales y sugerencias de comidas, por favor configura tu clave API de OpenAI en ajustes.';

  @override
  String get chatWelcomeTitle => 'Bienvenido a PlatePal';

  @override
  String get chatWelcomeSubtitle => 'Tu asistente de nutrición IA está aquí para ayudar';

  @override
  String get getStartedToday => 'Comienza hoy';

  @override
  String get whatCanIHelpWith => '¿En qué puedo ayudarte?';

  @override
  String get featureComingSoon => '¡Esta función estará disponible pronto!';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get viewStatistics => 'Ver Estadísticas';

  @override
  String get weightHistory => 'Historial de Peso';

  @override
  String get bmiHistory => 'Historial de IMC';

  @override
  String get bodyFatHistory => 'Historial de Grasa Corporal';

  @override
  String get calorieIntakeHistory => 'Ingesta de Calorías vs Mantenimiento';

  @override
  String get weightStatsTip => 'El gráfico muestra el peso promedio semanal para tener en cuenta las fluctuaciones diarias debido al peso del agua.';

  @override
  String get bmiStatsTip => 'El Índice de Masa Corporal (IMC) se calcula a partir de tus medidas de peso y altura.';

  @override
  String get bodyFatStatsTip => 'El porcentaje de grasa corporal ayuda a rastrear tu composición corporal más allá del peso.';

  @override
  String get calorieStatsTip => 'Compara tu ingesta diaria de calorías con tus calorías de mantenimiento. Verde indica mantenimiento, azul es fase de corte, naranja es fase de volumen.';

  @override
  String get notEnoughDataTitle => 'No Hay Suficientes Datos';

  @override
  String get statisticsEmptyDescription => 'Necesitamos al menos una semana de datos para mostrar estadísticas significativas. Sigue rastreando tus métricas para ver tendencias con el tiempo.';

  @override
  String get updateMetricsNow => 'Actualizar Métricas Ahora';

  @override
  String get timeRange => 'Rango de Tiempo';

  @override
  String get week => 'Semana';

  @override
  String get month => 'Mes';

  @override
  String get threeMonths => '3 Meses';

  @override
  String get sixMonths => '6 Meses';

  @override
  String get year => 'Año';

  @override
  String get allTime => 'Todo el Tiempo';

  @override
  String get bulking => 'Volumen';

  @override
  String get cutting => 'Corte';

  @override
  String get maintenance => 'Mantenimiento';

  @override
  String get extremeLowCalorieWarning => 'Advertencia de Calorías Extremadamente Bajas';

  @override
  String get extremeHighCalorieWarning => 'Advertencia de Calorías Extremadamente Altas';

  @override
  String get caloriesTooLowMessage => 'Tu ingesta de calorías está significativamente por debajo de las recomendaciones. Esto puede afectar tu salud y metabolismo.';

  @override
  String get caloriesTooHighMessage => 'Tu ingesta de calorías está significativamente por encima de las recomendaciones. Considera ajustar tus porciones.';

  @override
  String get weeklyDeficit => 'Déficit Semanal';

  @override
  String get weeklySurplus => 'Superávit Semanal';

  @override
  String get phaseAnalysis => 'Análisis de Fase';

  @override
  String get weeklyAverage => 'Promedio Semanal';

  @override
  String get lastWeek => 'Última Semana';

  @override
  String get lastMonth => 'Último Mes';

  @override
  String get lastThreeMonths => 'Últimos 3 Meses';

  @override
  String get lastSixMonths => 'Últimos 6 Meses';

  @override
  String get lastYear => 'Último Año';

  @override
  String get generateTestData => 'Generar Datos de Prueba';

  @override
  String get testDataDescription => 'Para fines de demostración, puedes generar datos de muestra para ver cómo se ven las estadísticas.';

  @override
  String get errorLoadingData => 'Error al cargar datos';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get refresh => 'Actualizar';

  @override
  String get realData => 'Datos Reales';

  @override
  String get noWeightDataAvailable => 'No hay datos de peso disponibles';

  @override
  String get noBmiDataAvailable => 'No hay datos de IMC disponibles';

  @override
  String get cannotCalculateBmiFromData => 'No se puede calcular el IMC con los datos disponibles';

  @override
  String get noBodyFatDataAvailable => 'No hay datos de grasa corporal disponibles';

  @override
  String get noCalorieDataAvailable => 'No hay datos de calorías disponibles';

  @override
  String get bmiUnderweight => 'Bajo peso';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Sobrepeso';

  @override
  String get bmiObese => 'Obeso';

  @override
  String get healthDataIntegration => 'Integración de Datos de Salud';

  @override
  String healthDataCoverage(String coverage, String healthDataDays, String totalDays) {
    return 'Cobertura de datos de gasto calórico: $coverage% ($healthDataDays/$totalDays días)';
  }

  @override
  String get healthDataActive => 'Usando los datos de tu aplicación de salud para proporcionar un análisis más preciso de déficit/superávit.';

  @override
  String get healthDataInactive => 'Activa la sincronización de datos de salud en Configuración de Perfil para un análisis más preciso.';

  @override
  String get calorieBalanceTitle => 'Balance Calórico (Ingesta vs Gasto)';

  @override
  String get calorieBalanceTip => 'Rastrea tu balance calórico real usando datos de salud. Verde = mantenimiento, Azul = déficit, Naranja = superávit.';

  @override
  String get estimatedBalance => 'Balance Estimado';

  @override
  String get actualBalance => 'Balance Real';

  @override
  String get vsExpenditure => 'vs gasto';

  @override
  String healthDataAlert(String days) {
    return 'Alerta de Datos de Salud: $days día(s) con déficits calóricos muy grandes (>1000 cal) basados en el gasto real.';
  }

  @override
  String inconsistentDeficitWarning(String variance) {
    return 'Advertencia: Tu déficit calórico varía significativamente día a día (varianza: $variance cal). Considera una ingesta más consistente.';
  }

  @override
  String veryLowCalorieWarning(String days) {
    return 'Advertencia: $days día(s) con ingesta calórica extremadamente baja (<1000 cal). Esto puede ser poco saludable.';
  }

  @override
  String veryHighCalorieNotice(String days) {
    return 'Aviso: $days día(s) con ingesta calórica muy alta (>1000 cal por encima del mantenimiento).';
  }

  @override
  String get extremeDeficitWarning => 'Advertencia: Los déficits calóricos extremos frecuentes pueden ralentizar el metabolismo y causar pérdida muscular.';

  @override
  String get maintenanceLabel => 'Mantenimiento';

  @override
  String get bodyFat => 'Grasa Corporal';

  @override
  String get resetApp => 'Restablecer App';

  @override
  String get resetAppTitle => 'Restablecer Datos de la Aplicación';

  @override
  String get resetAppDescription => 'Esto eliminará permanentemente TODOS tus datos incluyendo:\n\n• Tu información de perfil\n• Todos los registros de comidas y datos nutricionales\n• Todas las preferencias y configuraciones\n• Toda la información almacenada\n\nEsta acción no se puede deshacer. ¿Estás seguro de que quieres continuar?';

  @override
  String get resetAppConfirm => 'Sí, Eliminar Todo';

  @override
  String get resetAppCancel => 'Cancelar';

  @override
  String get resetAppSuccess => 'Los datos de la aplicación se han restablecido exitosamente';

  @override
  String get resetAppError => 'Error al restablecer los datos de la aplicación';

  @override
  String get dangerZone => 'Zona de Peligro';

  @override
  String get chatAgentSettingsTitle => 'Configuración del Agente de Chat';

  @override
  String get chatAgentEnableTitle => 'Activar Modo Agente';

  @override
  String get chatAgentEnableSubtitle => 'Usa la canalización de agente de varios pasos para el chat';

  @override
  String get chatAgentDeepSearchTitle => 'Activar Búsqueda Profunda';

  @override
  String get chatAgentDeepSearchSubtitle => 'Permite que el agente use búsqueda profunda para respuestas más precisas';

  @override
  String get chatAgentInfoTitle => '¿Qué es el Modo Agente?';

  @override
  String get chatAgentInfoDescription => 'El modo agente activa la avanzada canalización de razonamiento de varios pasos de PlatePal para el chat. Esto permite que el asistente analice tu consulta, recopile contexto y proporcione respuestas más precisas y explicables. La Búsqueda Profunda permite al agente usar más datos para obtener mejores resultados.';

  @override
  String get chatSettingsSaved => 'Configuración de chat guardada correctamente';

  @override
  String get yesterday => 'Ayer';

  @override
  String get basicInformation => 'Información Básica';

  @override
  String get pleaseEnterDishName => 'Por favor ingresa un nombre para el plato';

  @override
  String get imageUrl => 'URL de Imagen';

  @override
  String get optional => 'Opcional';

  @override
  String get nutritionInfo => 'Información Nutricional';

  @override
  String get required => 'Requerido';

  @override
  String get invalidNumber => 'Número inválido';

  @override
  String get addIngredient => 'Agregar Ingrediente';

  @override
  String get noIngredientsAdded => 'No se han agregado ingredientes aún';

  @override
  String get ingredientsAdded => 'Ingredientes agregados';

  @override
  String get options => 'Opciones';

  @override
  String get markAsFavorite => 'Marcar como plato favorito';

  @override
  String get editDish => 'Editar Plato';

  @override
  String get dishUpdatedSuccessfully => 'Plato actualizado exitosamente';

  @override
  String get dishCreatedSuccessfully => 'Plato creado exitosamente';

  @override
  String get errorSavingDish => 'Error al guardar el plato';

  @override
  String get ingredientName => 'Nombre del Ingrediente';

  @override
  String get pleaseEnterIngredientName => 'Por favor ingresa un nombre para el ingrediente';

  @override
  String get amount => 'Cantidad';

  @override
  String get unit => 'Unidad';

  @override
  String get add => 'Agregar';

  @override
  String get edit => 'Editar';

  @override
  String get retry => 'Reintentar';

  @override
  String get errorLoggingDish => 'Error al registrar el plato';

  @override
  String get allCategories => 'Todas las Categorías';

  @override
  String get searchDishes => 'Buscar platos...';

  @override
  String get createDish => 'Crear Plato';

  @override
  String get noDishesCreated => 'No se han creado platos aún';

  @override
  String get createFirstDish => 'Crea tu primer plato para comenzar';

  @override
  String get errorLoadingDishes => 'Error al cargar los platos';

  @override
  String get noDishesFound => 'No se encontraron platos';

  @override
  String get tryAdjustingSearch => 'Intenta ajustar tus términos de búsqueda';

  @override
  String get deleteDish => 'Eliminar Plato';

  @override
  String deleteDishConfirmation(String dishName) {
    return '¿Estás seguro de que quieres eliminar \"$dishName\"?';
  }

  @override
  String get dishDeletedSuccessfully => 'Plato eliminado exitosamente';

  @override
  String get failedToDeleteDish => 'Error al eliminar el plato';

  @override
  String get addedToFavorites => 'Agregado a favoritos';

  @override
  String get removedFromFavorites => 'Removido de favoritos';

  @override
  String get errorUpdatingDish => 'Error al actualizar el plato';

  @override
  String get addToFavorites => 'Agregar a Favoritos';

  @override
  String get removeFromFavorites => 'Remover de Favoritos';

  @override
  String get fiber => 'Fibra';

  @override
  String get favorite => 'Favoritos';

  @override
  String get createNewDish => 'Crear Nuevo Plato';

  @override
  String get errorCreatingDish => 'Error al crear el plato';

  @override
  String get pleaseEnterDescription => 'Por favor ingresa una descripción';

  @override
  String get pleaseEnterValidUrl => 'Por favor ingresa una URL válida';

  @override
  String get pleaseEnterIngredient => 'Por favor ingresa un ingrediente';

  @override
  String get errorDeletingDish => 'Error al eliminar el plato';

  @override
  String get confirmDeleteDish => '¿Estás seguro de que quieres eliminar este plato?';

  @override
  String get description => 'Descripción';

  @override
  String get category => 'Categoría';

  @override
  String get caloriesPer100g => 'Calorías por 100g';

  @override
  String get proteinPer100g => 'Proteína por 100g';

  @override
  String get carbsPer100g => 'Carbohidratos por 100g';

  @override
  String get fatPer100g => 'Grasa por 100g';

  @override
  String get fiberPer100g => 'Fibra por 100g';

  @override
  String get invalidImageUrl => 'URL de imagen inválida';

  @override
  String get enterIngredientName => 'Ingresa el nombre del ingrediente';

  @override
  String get toggleFavorite => 'Alternar favorito';

  @override
  String get basicInfo => 'Información Básica';

  @override
  String get dishNamePlaceholder => 'Ingrese el nombre del plato';

  @override
  String get descriptionPlaceholder => 'Ingrese la descripción (opcional)';

  @override
  String get pickFromGallery => 'Elegir de la Galería';

  @override
  String get selectImageSource => 'Seleccionar Fuente de Imagen';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get nutritionalInformation => 'Información Nutricional';

  @override
  String get per100g => 'por 100g';

  @override
  String get recalculate => 'Recalcular';

  @override
  String get recalculateNutrition => 'Recalcular Nutrición';

  @override
  String get nutritionRecalculated => 'Nutrición recalculada desde ingredientes';

  @override
  String get addManually => 'Agregar Manualmente';

  @override
  String get saveDish => 'Guardar Plato';

  @override
  String get saving => 'Guardando...';

  @override
  String get mg => 'mg';

  @override
  String get mcg => 'mcg';

  @override
  String get iu => 'UI';

  @override
  String get g => 'g';

  @override
  String get ml => 'ml';

  @override
  String get cup => 'taza';

  @override
  String get tbsp => 'cda';

  @override
  String get tsp => 'cdta';

  @override
  String get oz => 'oz';

  @override
  String get piece => 'pieza';

  @override
  String get slice => 'rebanada';

  @override
  String get tablespoon => 'cucharada';

  @override
  String get teaspoon => 'cucharadita';

  @override
  String get ounce => 'onza';

  @override
  String get pound => 'libra';

  @override
  String get gram => 'gramo';

  @override
  String get kilogram => 'kilogramo';

  @override
  String get milliliter => 'mililitro';

  @override
  String get liter => 'litro';

  @override
  String get editIngredient => 'Editar Ingrediente';

  @override
  String get deleteIngredient => 'Eliminar Ingrediente';

  @override
  String get confirmDeleteIngredient => '¿Está seguro de que desea eliminar este ingrediente?';

  @override
  String get ingredientDeleted => 'Ingrediente eliminado';

  @override
  String get ingredientAdded => 'Ingrediente agregado';

  @override
  String get ingredientUpdated => 'Ingrediente actualizado';

  @override
  String get errorAddingIngredient => 'Error al agregar ingrediente';

  @override
  String get errorUpdatingIngredient => 'Error al actualizar ingrediente';

  @override
  String get errorDeletingIngredient => 'Error al eliminar ingrediente';

  @override
  String get noNutritionData => 'No hay datos nutricionales disponibles';

  @override
  String get ingredientNamePlaceholder => 'Ingrese nombre del ingrediente';

  @override
  String get quantity => 'Cantidad';

  @override
  String get quantityPlaceholder => 'Ingrese cantidad';

  @override
  String get pleaseEnterQuantity => 'Por favor ingrese una cantidad';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingrese un número válido';

  @override
  String get unitPlaceholder => 'ej. g, taza, pieza';

  @override
  String get pleaseEnterUnit => 'Por favor ingrese una unidad';

  @override
  String get nutritionInformation => 'Información Nutricional';

  @override
  String get nutritionPer100g => 'Nutrición por 100g';

  @override
  String get caloriesPlaceholder => 'Ingrese calorías';

  @override
  String get kcal => 'kcal';

  @override
  String get grams => 'g';

  @override
  String get logDish => 'Registrar Plato';

  @override
  String get logDishTitle => 'Registrar Plato';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get selectMealType => 'Seleccionar Tipo de Comida';

  @override
  String get portionSize => 'Tamaño de Porción';

  @override
  String get notes => 'Notas';

  @override
  String get addNotes => 'Agregar notas (opcional)';

  @override
  String get calculatedNutrition => 'Nutrición Calculada';

  @override
  String get dishLoggedSuccessfully => '¡Plato registrado exitosamente!';

  @override
  String get select => 'Seleccionar';

  @override
  String errorOpeningDishScreen(Object error) {
    return 'Error al abrir la pantalla del plato: $error';
  }

  @override
  String errorPickingImage(Object error) {
    return 'Error al seleccionar la imagen: $error';
  }

  @override
  String get agentProcessingSteps => 'Pasos de procesamiento del agente';

  @override
  String get copyAll => 'Copiar todo';

  @override
  String get viewFullData => 'Ver datos completos';

  @override
  String get viewFullPrompt => 'Ver prompt completo';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get barcodeScanningComingSoon => '¡Escaneo de código de barras próximamente!';

  @override
  String get productSearchComingSoon => '¡Búsqueda de producto próximamente!';

  @override
  String get configureApiKeyForAiTips => 'Configura tu clave de OpenAI en ajustes para usar consejos de IA';

  @override
  String get failedToGetAiTip => 'Error al obtener el consejo de IA. Inténtalo de nuevo.';

  @override
  String get aiNutritionTip => 'Consejo de Nutrición IA';

  @override
  String get available => 'Disponible';

  @override
  String get notAvailable => 'No disponible';

  @override
  String get chatAndAiSettings => 'Configuración de Chat e IA';

  @override
  String get chatAgentOptions => 'Opciones de Agente de Chat';

  @override
  String get enableAgentModeDeepSearch => 'Habilitar modo agente, búsqueda profunda y más';

  @override
  String get chatProfiles => 'Perfiles de Chat';

  @override
  String get userChatProfile => 'Tu Perfil';

  @override
  String get botChatProfile => 'Perfil del Bot';

  @override
  String get customizeUserProfile => 'Personaliza tu perfil de chat';

  @override
  String get customizeBotProfile => 'Personaliza la personalidad y apariencia del bot';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get botName => 'Nombre del Bot';

  @override
  String get avatar => 'Avatar';

  @override
  String get changeAvatar => 'Cambiar Avatar';

  @override
  String get removeAvatar => 'Eliminar Avatar';

  @override
  String get personality => 'Personalidad';

  @override
  String get selectPersonality => 'Seleccionar Personalidad';

  @override
  String get professionalNutritionist => 'Nutricionista Profesional';

  @override
  String get casualGymBro => 'Gym Bro Casual';

  @override
  String get angryGreg => 'Greg Enojado';

  @override
  String get veryAngryBro => 'Bro Muy Enojado';

  @override
  String get fitnessCoach => 'Entrenador de Fitness';

  @override
  String get niceAndFriendly => 'Amable y Amigable';

  @override
  String get selectImage => 'Seleccionar Imagen';

  @override
  String get profileSaved => 'Perfil guardado exitosamente';

  @override
  String get profileSaveFailed => 'Error al guardar perfil';

  @override
  String get editUserProfile => 'Editar Perfil de Usuario';

  @override
  String get editBotProfile => 'Editar Perfil del Bot';

  @override
  String get connectToHealth => 'Conectar con Salud';

  @override
  String get healthDataSync => 'Sincronización de Datos de Salud';

  @override
  String get healthConnected => 'Datos de salud conectados';

  @override
  String get healthDisconnected => 'Datos de salud no conectados';

  @override
  String get syncHealthData => 'Sincronizar Datos de Salud';

  @override
  String get healthPermissionRequired => 'Se requieren permisos de salud para sincronizar tus datos';

  @override
  String get healthSyncSuccess => 'Datos de salud sincronizados exitosamente';

  @override
  String get healthSyncFailed => 'Error al sincronizar datos de salud';

  @override
  String lastSynced(String date) {
    return 'Última sincronización: $date';
  }

  @override
  String get healthPermissionDenied => 'Permiso de Salud Denegado';

  @override
  String get healthPermissionDeniedMessage => 'Para sincronizar tus datos de salud, PlatePal necesita acceso a tu información de salud. Puedes otorgar permisos en la configuración de tu teléfono.';

  @override
  String get openSettings => 'Abrir Configuración';

  @override
  String get healthNotAvailable => 'Datos de Salud No Disponibles';

  @override
  String get healthNotAvailableMessage => 'Los datos de salud no están disponibles en este dispositivo. Asegúrate de tener Health Connect (Android) o la app Salud (iOS) instalada y configurada.';

  @override
  String get scanBarcodeToAddProduct => 'Escanea el código de barras para agregar producto';

  @override
  String get searchForProducts => 'Buscar productos';

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String get productAddedSuccessfully => 'Producto agregado exitosamente';

  @override
  String errorScanningBarcode(String error) {
    return 'Error al escanear el código de barras';
  }

  @override
  String errorSearchingProduct(String error) {
    return 'Error al buscar el producto';
  }

  @override
  String get barcodeScanner => 'Escáner de código de barras';

  @override
  String get productSearch => 'Búsqueda de producto';

  @override
  String get tapToScan => 'Toca para escanear';

  @override
  String get scanningBarcode => 'Escaneando código de barras...';

  @override
  String get searchProducts => 'Buscar productos';

  @override
  String get noProductsFound => 'No se encontraron productos';

  @override
  String get addToIngredients => 'Agregar a ingredientes';

  @override
  String get productDetails => 'Detalles del producto';

  @override
  String get brand => 'Marca';

  @override
  String get cameraPermissionRequired => 'Se requiere permiso de cámara';

  @override
  String get grantCameraPermission => 'Otorgar permiso de cámara';

  @override
  String get barcodeNotFound => 'Código de barras no encontrado';

  @override
  String get enterProductName => 'Ingresa el nombre del producto';

  @override
  String get tryDifferentKeywords => 'Intenta con diferentes palabras clave';

  @override
  String get selectServingSize => 'Selecciona el tamaño de la porción';

  @override
  String get enableCameraPermission => 'Habilitar permiso de cámara';

  @override
  String get macroCustomization => 'Personalización de Macros';

  @override
  String get macroCustomizationInfo => 'Personaliza tus objetivos de macros. Todos los porcentajes deben sumar 100%.';

  @override
  String get macroTargetsUpdated => 'Objetivos de macros actualizados exitosamente';

  @override
  String get resetToDefaults => 'Restablecer por Defecto';

  @override
  String get healthDataTitle => 'Datos de Salud';

  @override
  String get healthDataTodayPartial => 'Datos de Salud (Hoy - Parcial)';

  @override
  String get estimatedCaloriesToday => 'Calorías Estimadas (Hoy)';

  @override
  String get estimatedCalories => 'Calorías Estimadas';

  @override
  String get healthDataMessage => 'Estos datos fueron recopilados de los datos de salud en tu teléfono, proporcionando información precisa sobre las calorías quemadas de tus actividades de fitness para este día completo.';

  @override
  String get healthDataTodayMessage => 'Estos datos fueron recopilados de los datos de salud en tu teléfono. Como el día de hoy aún no está completo, esto representa las calorías quemadas hasta ahora. Tu total puede aumentar mientras continúes con actividades durante el día.';

  @override
  String get estimatedCaloriesTodayMessage => 'Este es tu gasto calórico estimado para hoy basado en tu nivel de actividad. Como el día aún no está completo, esto representa tu tasa metabólica basal más actividad estimada. Tus calorías realmente quemadas pueden ser mayores si realizas más actividades hoy.';

  @override
  String get estimatedCaloriesMessage => 'Estos datos están estimados basándose en la configuración de tu perfil y nivel de actividad ya que los datos de salud no estaban disponibles para esta fecha.';

  @override
  String get analyzeTargets => 'Analizar Objetivos';

  @override
  String get debugHealthData => 'Depurar Datos de Salud';

  @override
  String get disconnectHealth => 'Desconectar Salud';

  @override
  String get calorieTargetAnalysis => 'Análisis de Objetivo Calórico';

  @override
  String get daysAnalyzed => 'Días Analizados';

  @override
  String get currentTarget => 'Objetivo Actual';

  @override
  String get averageExpenditure => 'Gasto Promedio';

  @override
  String get suggestedTarget => 'Objetivo Sugerido';

  @override
  String get applySuggestion => 'Aplicar Sugerencia';

  @override
  String get calorieTargetsUpdated => '¡Objetivos calóricos actualizados exitosamente!';

  @override
  String get failedToUpdateTargets => 'Error al actualizar objetivos calóricos';

  @override
  String get loadMore => 'Cargar más';

  @override
  String get localDishes => 'Platos locales';

  @override
  String get localIngredients => 'Ingredientes locales';
}
