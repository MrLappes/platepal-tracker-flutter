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
        description: 'Checkpoint-based autonomous verification system',
        category: 'validation',
        supportsVerification: false, // Meta-verification not supported
        supportsDeepSearch: false,
        estimatedExecutionTime: Duration(seconds: 4),
        dependencies: [], // Flexible dependencies based on checkpoint
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

  AgentPipelineConfig({
    required this.requiredSteps,
    this.optionalSteps = const [],
    this.deepSearchEnabled = false,
    this.maxRetries = 3,
    this.timeout = const Duration(minutes: 5),
    this.stepConfigurations,
  });

  /// Creates default pipeline configuration
  factory AgentPipelineConfig.defaultConfig() {
    return AgentPipelineConfig(
      requiredSteps: ['thinking', 'context_gathering', 'response_generation'],
      optionalSteps: ['image_processing', 'dish_processing'],
      deepSearchEnabled: false,
      maxRetries: 3,
      timeout: Duration(minutes: 5),
    );
  }

  /// Creates configuration with autonomous verification at strategic checkpoints
  factory AgentPipelineConfig.withAutonomousVerification() {
    return AgentPipelineConfig(
      requiredSteps: [
        'thinking',
        'context_gathering',
        'deep_search_verification', // Post-execution checkpoint
        'response_generation',
        'dish_processing',
        'deep_search_verification', // Post-response checkpoint
      ],
      optionalSteps: ['image_processing'],
      deepSearchEnabled: true,
      maxRetries: 3,
      timeout: Duration(minutes: 15),
      stepConfigurations: {
        'deep_search_verification': {'checkpointBased': true, 'maxRetries': 3},
      },
    );
  }

  /// Creates configuration with deep search verification after each step
  factory AgentPipelineConfig.withComprehensiveVerification() {
    return AgentPipelineConfig(
      requiredSteps: [
        'thinking',
        'deep_search_verification',
        'context_gathering',
        'deep_search_verification',
        'response_generation',
        'deep_search_verification',
      ],
      optionalSteps: [
        'image_processing',
        'dish_processing',
        'deep_search_verification',
      ],
      deepSearchEnabled: true,
      maxRetries: 3,
      timeout: Duration(minutes: 15),
      stepConfigurations: {
        'deep_search_verification': {'verifyAfterEachStep': true},
      },
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
