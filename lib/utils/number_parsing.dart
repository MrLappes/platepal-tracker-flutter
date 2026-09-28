import 'package:flutter/services.dart';

double? parseLocalizedDouble(String input) {
  final value = double.tryParse(input.trim().replaceAll(',', '.'));
  return value?.isFinite == true ? value : null;
}

final TextInputFormatter decimalInputFormatter =
    TextInputFormatter.withFunction(
      (oldValue, newValue) =>
          RegExp(r'^\d*(?:[.,]\d*)?$').hasMatch(newValue.text)
              ? newValue
              : oldValue,
    );
