import 'package:flutter_test/flutter_test.dart';
import 'package:platepal_tracker/utils/number_parsing.dart';

void main() {
  test('accepts a decimal comma with surrounding spaces', () {
    expect(parseLocalizedDouble(' 2,5 '), 2.5);
  });

  test('continues to accept a decimal point', () {
    expect(parseLocalizedDouble(' 2.5 '), 2.5);
  });

  test('does not treat non-finite input as nutrition', () {
    expect(parseLocalizedDouble('NaN'), isNull);
    expect(parseLocalizedDouble('Infinity'), isNull);
  });

  test('accepts one decimal separator and rejects a second one', () {
    const previous = TextEditingValue(text: '1,2');
    expect(
      decimalInputFormatter.formatEditUpdate(
        const TextEditingValue(text: '1'),
        previous,
      ),
      previous,
    );
    expect(
      decimalInputFormatter.formatEditUpdate(
        previous,
        const TextEditingValue(text: '1,2.3'),
      ),
      previous,
    );
    expect(
      decimalInputFormatter
          .formatEditUpdate(previous, const TextEditingValue(text: '1,23'))
          .text,
      '1,23',
    );
  });
}
