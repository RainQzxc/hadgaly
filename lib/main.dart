import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/presentation/font_licenses.dart';
import 'core/presentation/hadgaly_ui.dart';
import 'features/backup/data/backup_service.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  try {
    final directory = await getApplicationDocumentsDirectory();
    final outcome = await BackupService(directory).applyPending();
    runApp(ProviderScope(child: HadgalyApp(home: _RestoreNotice(outcome))));
  } catch (_) {
    runApp(
      const HadgalyApp(
        home: HadgalyPage(
          title: 'хадгалъя',
          child: PageContent(
            children: [
              Text(
                'Өгөгдлийг нээх боломжгүй байна. Аппыг хаагаад дахин оролдоно уу.',
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
