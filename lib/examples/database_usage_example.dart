import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../models/user_profile.dart';
import '../utils/service_extensions.dart';

/// This is an example widget showing how to use the database services
/// It's not meant to be used directly in the app, but as a reference
class DatabaseUsageExample extends StatefulWidget {
  const DatabaseUsageExample({Key? key}) : super(key: key);

  @override
  State<DatabaseUsageExample> createState() => _DatabaseUsageExampleState();
}

class _DatabaseUsageExampleState extends State<DatabaseUsageExample> {
  List<Dish> _dishes = [];
  UserProfile? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use our service extensions to access database services
      // Load dishes
      final dishes = await context.dishService.getAllDishes();

      // Load user profile
      final userProfile = await context.userProfileService.getUserProfile(
        "current_user_id",
      );

      // Update state with loaded data
      if (mounted) {
        setState(() {
          _dishes = dishes;
          _userProfile = userProfile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDish(Dish dish) async {
    try {
      // Save a dish to the database
      await context.dishService.saveDish(dish);

      // Reload data to refresh the UI
      await _loadData();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _updateUserMetrics() async {
    try {
      if (_userProfile == null) return;

      // Update user metrics and add history entry
      await context.userProfileService.updateUserMetrics(
        userId: _userProfile!.id,
        weight: 75.5, // new weight in kg
        bodyFat: 18.2, // body fat percentage
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User metrics updated and history recorded')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _logMeal(Dish dish) async {
    try {
      if (_userProfile == null) return;

      // Log a meal for the current user
      await context.mealLogService.logMeal(
        userId: _userProfile!.id,
        dishId: dish.id,
        servingSize: 1.0,
        mealType: 'lunch',
      );

      // Show success message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Meal logged successfully')));
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _viewNutritionSummary() async {
    try {
      if (_userProfile == null) return;

      final today = DateTime.now();
      final startDate = DateTime(today.year, today.month, today.day);
      final endDate = startDate.add(const Duration(days: 1));

      // Get nutrition summary for today
      final summary = await context.mealLogService.getNutritionSummary(
        userId: _userProfile!.id,
        startDate: startDate,
        endDate: endDate,
      );

      // Display nutrition summary
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Today\'s Nutrition Summary'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calories: ${summary.totalCalories.toStringAsFixed(1)} kcal',
                    ),
                    Text(
                      'Protein: ${summary.totalProtein.toStringAsFixed(1)} g',
                    ),
                    Text('Carbs: ${summary.totalCarbs.toStringAsFixed(1)} g'),
                    Text('Fat: ${summary.totalFat.toStringAsFixed(1)} g'),
                    Text('Number of meals: ${summary.mealLogs.length}'),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Profile',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (_userProfile != null) ...[
            Text('Name: ${_userProfile!.name}'),
            Text('Weight: ${_userProfile!.weight} kg'),
            Text('Height: ${_userProfile!.height} cm'),
            Text('Goal: ${_userProfile!.goals.goal}'),
            ElevatedButton(
              onPressed: _updateUserMetrics,
              child: Text('Update Metrics'),
            ),
          ] else ...[
            Text('No user profile found'),
          ],
          const SizedBox(height: 24),
          Text('Dishes', style: Theme.of(context).textTheme.headlineSmall),
          if (_dishes.isNotEmpty) ...[
            Expanded(
              child: ListView.builder(
                itemCount: _dishes.length,
                itemBuilder: (context, index) {
                  final dish = _dishes[index];
                  return ListTile(
                    title: Text(dish.name),
                    subtitle: Text(
                      '${dish.nutrition.calories.toStringAsFixed(0)} kcal, ' +
                          'P: ${dish.nutrition.protein.toStringAsFixed(0)}g, ' +
                          'C: ${dish.nutrition.carbs.toStringAsFixed(0)}g, ' +
                          'F: ${dish.nutrition.fat.toStringAsFixed(0)}g',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _logMeal(dish),
                      tooltip: 'Log meal',
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _viewNutritionSummary,
              child: Text('View Nutrition Summary'),
            ),
          ] else ...[
            Text('No dishes found'),
          ],
        ],
      ),
    );
  }
}
