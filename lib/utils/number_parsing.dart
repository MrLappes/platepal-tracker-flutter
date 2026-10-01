import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

double? parseLocalizedDouble(String input) {
  final value = double.tryParse(input.trim().replaceAll(',', '.'));
  return value?.isFinite == true ? value : null;
}

/// Formats [value] for display with the decimal separator of [locale].
String formatDecimal(num value, String locale, {int fractionDigits = 1}) =>
    (NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: fractionDigits,
    )..turnOffGrouping()).format(value);

final TextInputFormatter decimalInputFormatter =
    TextInputFormatter.withFunction(
      (oldValue, newValue) =>
          RegExp(r'^\d*(?:[.,]\d*)?$').hasMatch(newValue.text)
              ? newValue
              : oldValue,
    );
