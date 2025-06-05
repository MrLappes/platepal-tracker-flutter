import 'package:platepal_tracker/services/chat/agent_steps/context_gathering_step.dart';

import '../../../models/chat_types.dart';
import '../../../repositories/dish_repository.dart';
import '../../../repositories/meal_repository.dart';
import '../../../repositories/user_profile_repository.dart';
import '../../chat/openai_service.dart';
import '../../storage/dish_service.dart';
import 'thinking_step.dart';
import 'response_generation_step.dart';
import 'dish_processing_step.dart';
import 'error_handling_step.dart';
import 'deep_search_verification_step.dart';

/// Factory for creating agent steps
class AgentStepFactory {
  final OpenAIService _openaiService;
  final DishRepository _dishRepository;
  final MealRepository _mealRepository;
  final UserProfileRepository _userProfileRepository;
  final DishService _dishService;

  // Cache of created steps
  final Map<String, AgentStep> _stepCache = {};

  AgentStepFactory({
    required OpenAIService openaiService,
    required DishRepository dishRepository,
    required MealRepository mealRepository,
    required UserProfileRepository userProfileRepository,
    required DishService dishService,
  }) : _openaiService = openaiService,
       _dishRepository = dishRepository,
       _mealRepository = mealRepository,
       _userProfileRepository = userProfileRepository,
       _dishService = dishService;

  /// Creates or returns cached agent step instance
  AgentStep getStep(String stepName) {
    if (_stepCache.containsKey(stepName)) {
      return _stepCache[stepName]!;
    }

    final step = _createStep(stepName);
    _stepCache[stepName] = step;
    return step;
  }

  /// Creates a new instance of the specified step
  AgentStep _createStep(String stepName) {
    switch (stepName) {
      case 'thinking':
        return ThinkingStep(openaiService: _openaiService);

      case 'context_gathering':
        return ContextGatheringStep(
          dishRepository: _dishRepository,
          mealRepository: _mealRepository,
          userProfileRepository: _userProfileRepository,
        );
      case 'response_generation':
        return ResponseGenerationStep(openaiService: _openaiService);
      case 'dish_processing':
        return DishProcessingStep(
          dishRepository: _dishRepository,
          dishService: _dishService,
        );

      case 'error_handling':
        return ErrorHandlingStep();

      case 'deep_search_verification':
        return DeepSearchVerificationStep(openaiService: _openaiService);

      default:
        throw ArgumentError('Unknown step name: $stepName');
    }
  }

  /// Gets all available step names
  List<String> get availableSteps => [
    'thinking',
    'context_gathering',
    'response_generation',
    'dish_processing',
    'image_processing',
    'error_handling',
    'deep_search_verification',
  ];

  /// Clears the step cache (useful for testing or configuration changes)
  void clearCache() {
    _stepCache.clear();
  }

  /// Checks if a step is available
  bool hasStep(String stepName) {
    return availableSteps.contains(stepName);
  }

  /// Determines the pipeline steps based on the thinking step result
  List<String> buildPipelineStepsFromThinking(ThinkingStepResponse thinking) {
    final steps = <String>['thinking'];

    // Context gathering is only needed if any context is required
    final ctx = thinking.contextRequirements;
    final hasHistoricalMealPeriod =
        ctx.historicalMealPeriod != null &&
        ctx.historicalMealPeriod!.isNotEmpty;
    final needsContext =
        ctx.needsUserProfile == true ||
        ctx.needsTodaysNutrition == true ||
        ctx.needsWeeklyNutritionSummary == true ||
        ctx.needsListOfCreatedDishes == true ||
        ctx.needsExistingDishes == true ||
        ctx.needsInfoOnDishCreation == true ||
        ctx.needsNutritionAdvice == true ||
        hasHistoricalMealPeriod;

    if (needsContext) {
      steps.add('context_gathering');
    }

    // Add image processing if the user message or history contains an image
    // (You may need to pass this info in or check in your runner)
    // steps.add('image_processing'); // Only if needed

    // Add dish processing if responseRequirements include dish/recipe
    if (thinking.responseRequirements.any(
      (r) => r.contains('dish') || r.contains('recipe'),
    )) {
      steps.add('dish_processing');
    }

    // Always add response generation at the end
    steps.add('response_generation');

    // Optionally add deep search verification if enabled
    // steps.add('deep_search_verification'); // Only if enabled

    return steps;
  }
}

/// Registry for managing agent step configurations and capabilities
class AgentStepRegistry {
  static final Map<String, AgentStepMetadata> _registry = {};

  /// Registers a step with metadata
  static void registerStep(String stepName, AgentStepMetadata metadata) {
    _registry[stepName] = metadata;
  }

  /// Gets metadata for a step
  static AgentStepMetadata? getStepMetadata(String stepName) {
    return _registry[stepName];
  }

  /// Gets all registered steps
  static Map<String, AgentStepMetadata> get allSteps => Map.from(_registry);

  /// Checks if a step supports verification
  static bool stepSupportsVerification(String stepName) {
    final metadata = _registry[stepName];
    return metadata?.supportsVerification ?? false;
  }

  /// Gets steps that support deep search
  static List<String> getDeepSearchCapableSteps() {
    return _registry.entries
        .where((entry) => entry.value.supportsDeepSearch)
        .map((entry) => entry.key)
        .toList();
  }

  /// Initialize registry with default steps
  static void initializeDefaultSteps() {
    registerStep(
      'thinking',
      AgentStepMetadata(
        name: 'thinking',
        description: 'Analyzes user intent and determines context requirements',
        category: 'analysis',
        supportsVerification: true,
        supportsDeepSearch: true,
        estimatedExecutionTime: Duration(seconds: 3),
        dependencies: [],
      ),
    );

    registerStep(
      'context_gathering',
      AgentStepMetadata(
        name: 'context_gathering',
        description: 'Gathers required context from data repositories',
        category: 'data',
        supportsVerification: true,
        supportsDeepSearch: false,
        estimatedExecutionTime: Duration(seconds: 2),
        dependencies: ['thinking'],
      ),
    );

    registerStep(
      'response_generation',
      AgentStepMetadata(
        name: 'response_generation',
        description: 'Generates AI response based on context and user input',
        category: 'generation',
        supportsVerification: true,
        supportsDeepSearch: true,
        estimatedExecutionTime: Duration(seconds: 5),
        dependencies: ['thinking', 'context_gathering'],
      ),
    );

    registerStep(
      'dish_processing',
      AgentStepMetadata(
        name: 'dish_processing',
        description: 'Processes and validates dishes from AI responses',
        category: 'processing',
        supportsVerification: true,
        supportsDeepSearch: false,
        estimatedExecutionTime: Duration(seconds: 2),
        dependencies: [],
      ),
    );

    registerStep(
      'image_processing',
      AgentStepMetadata(
        name: 'image_processing',
        description: 'Analyzes and processes uploaded images',
        category: 'processing',
        supportsVerification: true,
        supportsDeepSearch: true,
        estimatedExecutionTime: Duration(seconds: 4),
        dependencies: [],
      ),
    );

    registerStep(
      'error_handling',
      AgentStepMetadata(
        name: 'error_handling',
        description: 'Handles errors and implements recovery strategies',
        category: 'utility',
        supportsVerification: true,
        supportsDeepSearch: false,
        estimatedExecutionTime: Duration(seconds: 1),
        dependencies: [],
      ),
    );
    registerStep(
      'deep_search_verification',
      AgentStepMetadata(
        name: 'deep_search_verification',
        description:
            'Validates context sufficiency and provides pipeline control decisions',
        category: 'validation',
        supportsVerification: false, // Meta-verification not supported
        supportsDeepSearch: false,
        estimatedExecutionTime: Duration(seconds: 3),
        dependencies: ['thinking', 'context_gathering'],
      ),
    );
  }
}

/// Metadata for agent steps
class AgentStepMetadata {
  final String name;
  final String description;
  final String category;
  final bool supportsVerification;
  final bool supportsDeepSearch;
  final Duration estimatedExecutionTime;
  final List<String> dependencies;
  final Map<String, dynamic>? configuration;

  const AgentStepMetadata({
    required this.name,
    required this.description,
    required this.category,
    this.supportsVerification = false,
    this.supportsDeepSearch = false,
    required this.estimatedExecutionTime,
    this.dependencies = const [],
    this.configuration,
  });

  /// Checks if this step can run after the given completed steps
  bool canExecuteAfter(List<String> completedSteps) {
    return dependencies.every((dep) => completedSteps.contains(dep));
  }

  /// Gets missing dependencies
  List<String> getMissingDependencies(List<String> completedSteps) {
    return dependencies.where((dep) => !completedSteps.contains(dep)).toList();
  }
}

/// Pipeline configuration for agent execution
class AgentPipelineConfig {
  final List<String> requiredSteps;
  final List<String> optionalSteps;
  final bool deepSearchEnabled;
  final int maxRetries;
  final Duration timeout;
  final Map<String, dynamic>? stepConfigurations;

  const AgentPipelineConfig({
    required this.requiredSteps,
    this.optionalSteps = const [],
    this.deepSearchEnabled = false,
    this.maxRetries = 3,
    this.timeout = const Duration(minutes: 5),
    this.stepConfigurations,
  });

  /// Creates default pipeline configuration
  factory AgentPipelineConfig.defaultConfig() {
    return const AgentPipelineConfig(
      requiredSteps: ['thinking', 'context_gathering', 'response_generation'],
      optionalSteps: ['image_processing', 'dish_processing'],
      deepSearchEnabled: false,
      maxRetries: 3,
      timeout: Duration(minutes: 5),
    );
  }

  /// Creates configuration with deep search enabled
  factory AgentPipelineConfig.withDeepSearch() {
    return const AgentPipelineConfig(
      requiredSteps: ['thinking', 'context_gathering', 'response_generation'],
      optionalSteps: [
        'image_processing',
        'dish_processing',
        'deep_search_verification',
      ],
      deepSearchEnabled: true,
      maxRetries: 2,
      timeout: Duration(minutes: 10),
    );
  }

  /// Gets configuration for a specific step
  Map<String, dynamic>? getStepConfiguration(String stepName) {
    return stepConfigurations?[stepName] as Map<String, dynamic>?;
  }

  /// Gets all steps in execution order
  List<String> get allSteps => [...requiredSteps, ...optionalSteps];

  /// Validates the pipeline configuration
  List<String> validate() {
    final issues = <String>[];

    // Check if all steps are registered
    for (final stepName in allSteps) {
      if (!AgentStepRegistry.allSteps.containsKey(stepName)) {
        issues.add('Unknown step: $stepName');
      }
    }

    // Check dependencies
    final completedSteps = <String>[];
    for (final stepName in allSteps) {
      final metadata = AgentStepRegistry.getStepMetadata(stepName);
      if (metadata != null) {
        final missingDeps = metadata.getMissingDependencies(completedSteps);
        if (missingDeps.isNotEmpty) {
          issues.add(
            'Step $stepName missing dependencies: ${missingDeps.join(', ')}',
          );
        }
      }
      completedSteps.add(stepName);
    }

    return issues;
  }
}
