import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../onboarding/data/app_database.dart';
import 'backup_schema.dart';

Future<void> validateBackupDatabase(Database db) async {
  final trusted = sqlite3.openInMemory();
  final schema = AppDatabase(NativeDatabase.opened(trusted));
  try {
    await schema.customSelect('SELECT 1').get();
    validateBackupSchema(db, trusted);
  } finally {
    await schema.close();
  }
}
