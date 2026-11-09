import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../onboarding/data/app_database.dart';
import 'backup_service.dart';
import 'platform_types.dart';

const _files = MethodChannel('hadgaly/backup_files');
const String? storageGuidance = null;
const hasRollback = false;
const restartInstructions = 'Аппыг хаагаад дахин нээнэ үү.';
const restartLabel = 'Аппыг хаах';

Future<PlatformStartup> initializePlatform() async => (
  db: null,
  outcome: await BackupService(await getApplicationDocumentsDirectory())
      .applyPending(),
);

Future<bool> exportBackup(AppDatabase db) =>
    _withFiles((service, image, transfer) async {
      await service.export(db, image, transfer);
      return await _files.invokeMethod<bool>('save', transfer.path) == true;
    });

Future<bool> importBackup(AppDatabase db, ConfirmBackup confirm) => _withFiles((
  service,
  image,
  transfer,
) async {
  if (await _files.invokeMethod<bool>('open', transfer.path) != true) {
    return false;
  }
  final preview = await service.inspect(transfer, image);
  if (!await confirm(preview)) return false;
  await service.stage(image);
  // Covered Finance screens can have paused Drift stream listeners.
  try {
    await db.executor.close();
  } catch (_) {
    // Restore is already queued. Engine teardown still precedes applying it.
  }
  return true;
});

Future<bool> _withFiles(
  Future<bool> Function(BackupService, File, File) run,
) async {
  final cache = await getTemporaryDirectory();
  final work = await cache.createTemp('hadgaly-backup-');
  try {
    return await run(
      BackupService(await getApplicationDocumentsDirectory()),
      File.fromUri(work.uri.resolve('image.sqlite')),
      File.fromUri(work.uri.resolve('transfer.hadgaly')),
    );
  } finally {
    try {
      await work.delete(recursive: true);
    } on FileSystemException {
      // Scratch files stay in the app-private cache if cleanup fails.
    }
  }
}

Future<void> restartForRestore() =>
    _files.invokeMethod<void>('closeForRestore');
Future<void> exportRollback() =>
    throw UnsupportedError('Browser rollback only');
