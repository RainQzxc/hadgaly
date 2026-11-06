import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'support/stage3_migration.dart';

void main() {
  test('Preserved synthetic v2 fixture migrates all original fields and stable ordering to v3', () async {
    await verifyStage2Migration(
      await File('test/fixtures/stage2_v2.fixture').readAsBytes(),
    );
  });
}
