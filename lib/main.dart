import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/presentation/font_licenses.dart';
import 'core/presentation/hadgaly_ui.dart';
import 'core/presentation/viewport.dart';
import 'features/backup/data/platform_backup.dart';
import 'features/onboarding/application/onboarding_controller.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  enablePlatformSemantics();
  try {
    final (:db, :outcome) = await initializePlatform();
    runApp(
      ProviderScope(
        overrides: [if (db != null) databaseProvider.overrideWithValue(db)],
        child: HadgalyApp(home: _RestoreNotice(outcome)),
      ),
    );
  } catch (error) {
    runApp(
      HadgalyApp(
        home: HadgalyPage(
          title: 'хадгалъя',
          child: PageContent(
            children: [
              Text(
                error is StorageStartupError ? error.message : 'Өгөгдлийг нээх боломжгүй байна. Аппыг хаагаад дахин оролдоно уу.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestoreNotice extends StatefulWidget {
  const _RestoreNotice(this.outcome);
  final RestoreOutcome outcome;

  @override
  State<_RestoreNotice> createState() => _RestoreNoticeState();
}

class _RestoreNoticeState extends State<_RestoreNotice> {
  @override
  void initState() {
    super.initState();
    if (widget.outcome == RestoreOutcome.none) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(
            widget.outcome == RestoreOutcome.restored
                ? 'Нөөц сэргээгдлээ'
                : 'Нөөцийг сэргээж чадсангүй',
          ),
          content: Text(
            widget.outcome == RestoreOutcome.restored
                ? 'Өмнөх өгөгдлийн буцаах хувийг апп дотроо хадгаллаа.'
                : 'Одоогийн өгөгдөл хэвээр байна. Нөөц файлаа шалгаад дахин оролдоно уу.',
          ),
          actions: [
            AccessibleDialogAction(
              label: 'Ойлголоо',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const OnboardingScreen();
}
