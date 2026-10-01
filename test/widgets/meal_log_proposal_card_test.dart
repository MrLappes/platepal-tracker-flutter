import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/components/chat/meal_log_proposal_card.dart';
import 'package:platepal_tracker/l10n/app_localizations.dart';
import 'package:platepal_tracker/models/dish.dart';
import 'package:platepal_tracker/services/chat/meal_log_proposal.dart';
import 'package:platepal_tracker/services/storage/dish_service.dart';

class _FakeDishService extends DishService {
  _FakeDishService(this.dish);

  final Dish? dish;
  final logged = <({String dishId, double servings, String mealType})>[];
  final quickAdds = <({String name, double calories})>[];

  @override
  Future<Dish?> getDishById(String id) async => id == dish?.id ? dish : null;

  @override
  Future<String> logDish({
    required String dishId,
    required DateTime loggedAt,
    required String mealType,
    required double servingSize,
    String? notes,
  }) async {
    logged.add((dishId: dishId, servings: servingSize, mealType: mealType));
    return 'log-1';
  }

  @override
  Future<String> logQuickAdd({
    required String name,
    required DateTime loggedAt,
    required String mealType,
    required double calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    double fiber = 0,
    String? notes,
  }) async {
    quickAdds.add((name: name, calories: calories));
    return 'log-2';
  }
}

final _pasta = Dish(
  id: 'pasta',
  name: 'Pasta',
  ingredients: const [],
  nutrition: const NutritionInfo(
    calories: 1280,
    protein: 48,
    carbs: 200,
    fat: 32,
  ),
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  servings: 3,
);

Map<String, dynamic> _proposal(Map<String, dynamic> args) =>
    MealLogProposal.fromToolArguments(args, now: DateTime.now()).toJson();

Future<void> _pump(
  WidgetTester tester,
  Map<String, dynamic> proposal, {
  required DishService service,
  String? status,
  ValueChanged<String>? onStatusChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MealLogProposalCard(
          key: ValueKey('$proposal'),
          proposal: proposal,
          status: status,
          onStatusChanged: onStatusChanged,
          dishService: service,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Confirm logs the proposed dish and resolves the card', (
    tester,
  ) async {
    final service = _FakeDishService(_pasta);
    final statuses = <String>[];
    await _pump(
      tester,
      _proposal({'dish_id': 'pasta', 'servings': 1.5, 'meal_type': 'lunch'}),
      service: service,
      onStatusChanged: statuses.add,
    );

    expect(
      find.text('Log 1.5 servings of Pasta as Lunch today – 640 kcal'),
      findsOneWidget,
    );
    expect(service.logged, isEmpty, reason: 'nothing is written up front');

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(service.logged, [(dishId: 'pasta', servings: 1.5, mealType: 'lunch')]);
    expect(statuses, [mealLogProposalLogged]);
    expect(find.text('Logged'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
  });

  testWidgets('a quick-add proposal of one serving is confirmed as such', (
    tester,
  ) async {
    final service = _FakeDishService(null);
    await _pump(
      tester,
      _proposal({'name': 'Apple', 'calories': 95, 'meal_type': 'snack'}),
      service: service,
    );

    expect(
      find.text('Log 1 serving of Apple as Snack today – 95 kcal'),
      findsOneWidget,
    );
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(service.quickAdds, [(name: 'Apple', calories: 95.0)]);
  });

  testWidgets('Dismiss writes nothing', (tester) async {
    final service = _FakeDishService(_pasta);
    final statuses = <String>[];
    await _pump(
      tester,
      _proposal({'dish_id': 'pasta'}),
      service: service,
      onStatusChanged: statuses.add,
    );

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(statuses, [mealLogProposalDismissed]);
    expect(find.text('Dismissed'), findsOneWidget);
    expect(service.logged, isEmpty);
  });

  testWidgets('a resolved proposal stays resolved', (tester) async {
    await _pump(
      tester,
      _proposal({'dish_id': 'pasta'}),
      service: _FakeDishService(_pasta),
      status: mealLogProposalLogged,
    );
    expect(find.text('Logged'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
  });

  testWidgets('a missing dish or invalid proposal cannot be confirmed', (
    tester,
  ) async {
    await _pump(
      tester,
      _proposal({'dish_id': 'gone'}),
      service: _FakeDishService(_pasta),
    );
    expect(find.text('This dish no longer exists.'), findsOneWidget);
    expect(find.text('Confirm'), findsNothing);
    expect(find.text('Dismiss'), findsOneWidget);

    await _pump(
      tester,
      {'error': 'missingFood'},
      service: _FakeDishService(_pasta),
    );
    expect(
      find.text("The assistant's entry couldn't be read. Try asking again."),
      findsOneWidget,
    );
    expect(find.text('Confirm'), findsNothing);
  });
}
