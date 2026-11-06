import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final directory = Directory(
      name.startsWith('stage5')
          ? 'build/stage5/screenshots'
          : name.startsWith('stage4')
          ? 'build/stage4/screenshots'
          : 'build/stage3/screenshots',
    );
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png').writeAsBytes(bytes, flush: true);
    return true;
  },
);
