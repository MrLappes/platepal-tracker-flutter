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
