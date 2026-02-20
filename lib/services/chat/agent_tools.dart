import '../../models/chat_types.dart';

/// Centralized OpenAI tool definitions for the PlatePal chat agent.
///
/// Using OpenAI function/tool calling instead of free-form JSON eliminates the
/// name-vs-id ambiguity: [createNewDishTool] has no `id` parameter so it is
/// structurally impossible for a "create" call to accidentally resolve to an
/// existing DB record.
class AgentTools {
  // ─────────────────────────────────────────────────────────────────────────
  // Tool: create_new_dish
  // ─────────────────────────────────────────────────────────────────────────
  /// Use this tool to create a brand-new dish.
  /// Deliberately has NO `id` parameter — the system assigns a UUID server-side.
  static const Map<String, dynamic> createNewDishTool = {
    'type': 'function',
    'function': {
      'name': 'create_new_dish',
      'description':
          'Creates a brand-new dish with ingredients and nutrition data. '
          'Use ONLY when the user wants to create a new dish or log a custom meal. '
          'Do NOT use this when referencing a dish that already exists in the database.',
      'parameters': {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description': 'The name of the dish (e.g. "Chicken Rice Bowl").',
          },
          'description': {
            'type': 'string',
            'description': 'A brief description of the dish.',
          },
          'meal_type': {
            'type': 'string',
            'enum': ['breakfast', 'lunch', 'dinner', 'snack'],
            'description': 'The meal type/category.',
          },
          'servings': {
            'type': 'number',
            'description': 'Typical number of servings (default 1).',
          },
          'reply_text': {
            'type': 'string',
            'description':
                'The conversational reply to the user explaining what was created.',
          },
          'recommendation': {
            'type': 'string',
            'description': 'Optional nutrition tip or suggestion for the user.',
          },
          'ingredients': {
            'type': 'array',
            'description':
                'List of ingredients. All nutrition values are PER 100g of the ingredient.',
            'items': {
              'type': 'object',
              'properties': {
                'name': {
                  'type': 'string',
                  'description': 'Ingredient name (e.g. "Chicken breast").',
                },
                'quantity': {
                  'type': 'number',
                  'description': 'Amount used in this dish.',
                },
                'unit': {
                  'type': 'string',
                  'description':
                      'Unit of measurement (prefer "g" or "ml" for accuracy).',
                },
                'calories_per_100': {
                  'type': 'number',
                  'description': 'Kilocalories per 100g of this ingredient.',
                },
                'protein_per_100': {
                  'type': 'number',
                  'description': 'Protein grams per 100g.',
                },
                'carbs_per_100': {
                  'type': 'number',
                  'description': 'Carbohydrate grams per 100g.',
                },
                'fat_per_100': {
                  'type': 'number',
                  'description': 'Fat grams per 100g.',
                },
                'fiber_per_100': {
                  'type': 'number',
                  'description': 'Fiber grams per 100g (0 if unknown).',
                },
              },
              'required': [
                'name',
                'quantity',
                'unit',
                'calories_per_100',
                'protein_per_100',
                'carbs_per_100',
                'fat_per_100',
              ],
            },
          },
        },
        'required': ['name', 'reply_text', 'ingredients'],
      },
    },
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Tool: reference_existing_dish
  // ─────────────────────────────────────────────────────────────────────────
  /// Use this tool ONLY when the user wants to log or view a dish that is
  /// already in the database. Requires an exact database ID from the context.
  static const Map<String, dynamic> referenceExistingDishTool = {
    'type': 'function',
    'function': {
      'name': 'reference_existing_dish',
      'description':
          'References a dish that already exists in the user\'s database. '
          'Use ONLY when you have an exact database ID from the provided context. '
          'Never guess or fabricate an ID — if you don\'t have the ID, use create_new_dish instead.',
      'parameters': {
        'type': 'object',
        'properties': {
          'dish_id': {
            'type': 'string',
            'description':
                'The exact database ID of the existing dish (from context).',
          },
          'dish_name': {
            'type': 'string',
            'description': 'Name of the dish for confirmation (cosmetic only).',
          },
          'servings': {
            'type': 'number',
            'description': 'How many servings the user wants (default 1).',
          },
          'reply_text': {
            'type': 'string',
            'description': 'The conversational reply to the user.',
          },
          'recommendation': {
            'type': 'string',
            'description': 'Optional nutrition tip.',
          },
        },
        'required': ['dish_id', 'reply_text'],
      },
    },
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Tool: provide_chat_response
  // ─────────────────────────────────────────────────────────────────────────
  /// Use this tool for conversational replies that don't involve dish creation
  /// or referencing existing dishes.
  static const Map<String, dynamic> provideChatResponseTool = {
    'type': 'function',
    'function': {
      'name': 'provide_chat_response',
      'description':
          'Sends a conversational reply to the user without any dish operations. '
          'Use for nutrition advice, general questions, logging history, or any '
          'response that does not create or reference a specific dish.',
      'parameters': {
        'type': 'object',
        'properties': {
          'reply_text': {
            'type': 'string',
            'description': 'The full conversational reply to show the user.',
          },
          'recommendation': {
            'type': 'string',
            'description': 'Optional nutrition tip or call-to-action.',
          },
        },
        'required': ['reply_text'],
      },
    },
  };

  // ─────────────────────────────────────────────────────────────────────────
  // Tool: ask_clarification
  // ─────────────────────────────────────────────────────────────────────────
  /// Use this tool when critical information is missing and cannot be inferred.
  static const Map<String, dynamic> askClarificationTool = {
    'type': 'function',
    'function': {
      'name': 'ask_clarification',
      'description':
          'Asks the user a clarifying question when critical information is '
          'missing. Use sparingly — only when no reasonable assumption is possible.',
      'parameters': {
        'type': 'object',
        'properties': {
          'question': {
            'type': 'string',
            'description': 'The clarifying question to ask the user.',
          },
          'context': {
            'type': 'string',
            'description':
                'Brief context explaining why the question is needed.',
          },
        },
        'required': ['question'],
      },
    },
  };

  // ─────────────────────────────────────────────────────────────────────────
  // All tools (used as default set)
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> allTools = [
    createNewDishTool,
    referenceExistingDishTool,
    provideChatResponseTool,
    askClarificationTool,
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Context-based tool selection
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns the minimal set of tools relevant for the current turn so we
  /// don't confuse the model with irrelevant options.
  static List<Map<String, dynamic>> toolsForContext(
    ThinkingStepResponse? thinkingResult,
  ) {
    if (thinkingResult == null) return allTools;

    final ctx = thinkingResult.contextRequirements;
    final tools = <Map<String, dynamic>>[];

    // Always include the base chat response and clarification tools
    tools.add(provideChatResponseTool);
    tools.add(askClarificationTool);

    // Dish creation requested
    if (ctx.needsInfoOnDishCreation) {
      tools.add(createNewDishTool);
    }

    // Existing dish reference requested
    if (ctx.needsExistingDishes) {
      tools.add(referenceExistingDishTool);
    }

    // If neither dish flag is set but there was some cooking-related intent,
    // still expose both dish tools as fallback
    if (!ctx.needsInfoOnDishCreation && !ctx.needsExistingDishes) {
      // Pure conversation — tools already contain provide_chat_response
    }

    return tools;
  }

  /// Returns the `tool_choice` value appropriate for the context.
  /// We use 'required' so the model always calls a tool (no free-text leakage).
  static dynamic toolChoiceForContext(ThinkingStepResponse? thinkingResult) {
    return 'required';
  }

  /// Checks whether the given finish reason indicates a tool call response.
  static bool isToolCallResponse(String finishReason) {
    return finishReason == 'tool_calls';
  }
}
