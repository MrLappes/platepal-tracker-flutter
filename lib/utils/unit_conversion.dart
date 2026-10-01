double nutritionMultiplier(double amount, String unit) {
  // Approximate 1 ml as 1 g for volume-based units (density 1 g/ml).
  final grams = switch (unit.toLowerCase().trim()) {
    'piece' || 'pieces' || 'slice' || 'slices' => null,
    'kg' || 'l' => amount * 1000,
    'oz' => amount * 28.3495,
    'cup' => amount * 240,
    'tbsp' => amount * 15,
    'tsp' => amount * 5,
    _ => amount,
  };
  return grams == null ? amount : grams / 100;
}

/// Total amount of a dish in g, or in ml when every ingredient is a liquid
/// measure. Null when any ingredient is counted (piece) or measured by
/// spoon/cup, or when there are no ingredients.
({double amount, String unit})? totalDishWeight(
  Iterable<({double amount, String unit})> ingredients,
) {
  var total = 0.0;
  var allVolume = true;
  var any = false;
  for (final ingredient in ingredients) {
    final unit = ingredient.unit.toLowerCase().trim();
    final (factor, isVolume) = switch (unit) {
      'g' => (1.0, false),
      'kg' => (1000.0, false),
      'oz' => (28.3495, false),
      'ml' => (1.0, true),
      'l' => (1000.0, true),
      _ => (null, false),
    };
    if (factor == null || !ingredient.amount.isFinite) return null;
    total += ingredient.amount * factor;
    allVolume &= isVolume;
    any = true;
  }
  if (!any || total <= 0) return null;
  return (amount: total, unit: allVolume ? 'ml' : 'g');
}
