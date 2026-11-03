import 'package:flutter_test/flutter_test.dart';
import 'package:hadgaly/core/domain/money.dart';

void main() {
  for (final value in [
    '0',
    '120000',
    '-120000',
    '$maxMnt',
    '-$maxMnt',
    '0002',
  ]) {
    test(
      'Exact integer $value',
      () => expect(parseMnt(value), int.parse(value)),
    );
  }
  for (final value in [
    '',
    ' ',
    '-',
    '1.5',
    '1,000',
    '1e3',
    '+2',
    'NaN',
    '∞',
    '1000000000000',
    '-1000000000000',
    '9999999999999999999999999999999999999999999',
  ]) {
    test(
      'Reject invalid MNT "$value"',
      () => expect(() => parseMnt(value), throwsFormatException),
    );
  }
  test('Whitespace names and controls rejected', () {
    for (final value in ['', '  ', '\n\t', 'Bo\nld']) {
      expect(() => validateName(value), throwsFormatException);
    }
    expect(validateName(' Болд '), 'Болд');
    expect(() => validateName('а' * 61), throwsFormatException);
  });
  test('Money display does not round or use float', () {
    expect(formatMnt(-1234567), '−1,234,567 ₮');
    expect(formatMnt(0), '0 ₮');
  });
}
