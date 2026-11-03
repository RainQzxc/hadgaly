/// Exact integer MNT. UI and persistence share this validation boundary.
const maxMnt = 999999999999;

int parseMnt(String raw) {
  final value = raw.trim();
  if (!RegExp(r'^-?[0-9]+$').hasMatch(value) || value.length > 64) {
    throw const FormatException('Бутархайгүй, бүхэл төгрөгөөр оруулаарай.');
  }
  final amount = BigInt.parse(value);
  if (amount.abs() > BigInt.from(maxMnt)) {
    throw const FormatException(
      'Дүн −999,999,999,999₮–999,999,999,999₮ хооронд байна.',
    );
  }
  return amount.toInt();
}

String validateName(String raw, {String label = 'Нэр'}) {
  final value = raw.trim();
  if (value.isEmpty) throw FormatException('$label хоосон байж болохгүй.');
  if (value.runes.length > 60) {
    throw FormatException('$label 60 хүртэл тэмдэгттэй байна.');
  }
  if (RegExp(r'[\x00-\x1f\x7f]').hasMatch(value)) {
    throw FormatException('$label нэг мөрөнд байна.');
  }
  return value;
}

String formatMnt(int amount) {
  final digits = amount.abs().toString();
  final grouped = digits.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  );
  return '${amount < 0 ? '−' : ''}$grouped ₮';
}
