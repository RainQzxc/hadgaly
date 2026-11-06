import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/presentation/hadgaly_ui.dart';
import '../../onboarding/application/onboarding_controller.dart';
import '../data/backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _files = MethodChannel('hadgaly/backup_files');
  bool _busy = false;
  bool _queued = false;
  String? _message;

  Future<void> _transfer({required bool saving}) async {
    if (_busy || _queued) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    Directory? work;
    try {
      final cache = await getTemporaryDirectory();
      work = await cache.createTemp('hadgaly-backup-');
      final transfer = File.fromUri(work.uri.resolve('transfer.hadgaly'));
      final image = File.fromUri(work.uri.resolve('image.sqlite'));
      final service = BackupService(await getApplicationDocumentsDirectory());
      if (saving) {
        await service.export(ref.read(databaseProvider), image, transfer);
        if (await _files.invokeMethod<bool>('save', transfer.path) == true &&
            mounted) {
          setState(() => _message = 'Нөөц файл хадгалагдлаа.');
        }
      } else {
        if (await _files.invokeMethod<bool>('open', transfer.path) != true) {
          return;
        }
        final preview = await service.inspect(transfer, image);
        if (!mounted || !await _confirm(preview) || !mounted) return;
        await service.stage(image);
        if (!mounted) return;
        setState(() => _queued = true);
        // Settings covers Finance, so its stream listeners can be paused.
        // Close the SQLite executor now. Engine teardown disposes the streams.
        await ref.read(databaseProvider).executor.close();
      }
    } catch (_) {
      if (mounted && !_queued) {
        setState(
          () => _message = saving
              ? 'Нөөц файлыг хадгалж чадсангүй. Дахин оролдоно уу.'
              : 'Нөөц файлыг шалгах эсвэл бэлтгэх боломжгүй байна. Одоогийн өгөгдөл хэвээр байна.',
        );
      }
    } finally {
      try {
        await work?.delete(recursive: true);
      } on FileSystemException {
        // Scratch files stay in the app-private cache if cleanup fails.
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(BackupPreview preview) async =>
      await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Нөөцөөс сэргээх үү?'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Аппыг дахин нээхэд одоогийн өгөгдлийг энэ нөөцөөр солино.\n\n'
              'Нийт үлдэгдэл: ${preview.balance} ₮\n'
              'Данс: ${preview.accounts}\n'
              'Гүйлгээ: ${preview.entries}\n'
              'Гүйлгээний засвар, устгал: ${preview.revisions}\n'
              'Үлдэгдэл тохируулга: ${preview.adjustments}\n'
              'Тохируулгын засвар: ${preview.audits}\n\n'
              'Одоогийн өгөгдлийн буцаах хувийг апп дотроо хадгална.',
            ),
          ),
          actions: [
            AccessibleDialogAction(
              label: 'Болих',
              onPressed: () => Navigator.pop(context, false),
            ),
            AccessibleDialogAction(
              key: const Key('confirmRestore'),
              label: 'Сэргээх',
              destructive: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy && !_queued,
    child: HadgalyPage(
      title: 'Тохиргоо',
      backEnabled: !_busy && !_queued,
      child: PageContent(
        children: [
          if (_queued) ...[
            const Text('Нөөц сэргээхэд бэлэн', style: sectionStyle),
            const SizedBox(height: 8),
            const Text('Аппыг хаагаад дахин нээнэ үү.'),
            const SizedBox(height: 16),
            HadgalyButton(
              label: 'Аппыг хаах',
              onPressed: _busy
                  ? null
                  : () => _files.invokeMethod<void>('closeForRestore'),
            ),
          ] else ...[
            const Text('Нөөц ба сэргээх', style: sectionStyle),
            const SizedBox(height: 8),
            const Text(
              'Нөөц файлд таны санхүүгийн мэдээлэл орно. Файл шифрлэгдээгүй тул итгэлтэй газарт хадгалаарай.',
            ),
            const SizedBox(height: 16),
            HadgalyButton(
              key: const Key('exportBackup'),
              label: 'Өгөгдөл нөөцлөх',
              icon: CupertinoIcons.arrow_down_doc,
              onPressed: _busy ? null : () => _transfer(saving: true),
            ),
            const SizedBox(height: 8),
            HadgalyButton(
              key: const Key('importBackup'),
              label: 'Нөөцөөс сэргээх',
              filled: false,
              icon: CupertinoIcons.arrow_up_doc,
              onPressed: _busy ? null : () => _transfer(saving: false),
            ),
            if (_busy) const CupertinoActivityIndicator(),
            if (_message case final message?) ...[
              const SizedBox(height: 8),
              Semantics(liveRegion: true, child: Text(message)),
            ],
            const SizedBox(height: 24),
            const Text('Аппын тухай', style: sectionStyle),
            const SizedBox(height: 8),
            const Text('Хадгалъя · Хувийн санхүүгээ төхөөрөмж дээрээ хөтөлнө.'),
          ],
        ],
      ),
    ),
  );
}
