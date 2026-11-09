import '../../onboarding/data/app_database.dart';
import 'backup_types.dart';

typedef PlatformStartup = ({AppDatabase? db, RestoreOutcome outcome});

class StorageStartupError implements Exception {
  const StorageStartupError(this.message);
  final String message;
}
