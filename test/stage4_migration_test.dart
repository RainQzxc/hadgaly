import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/stage4_migration.dart';

void main() {
  test('Preserved v3 fixture upgrades to v4; all original fields, cash, archives and audit survive', () async {
    await verifyStage3Migration(
      await File('test/fixtures/stage3_v3.fixture').readAsBytes(),
    );
  });
}
