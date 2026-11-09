enum RestoreOutcome { none, restored, rejected }

typedef BackupPreview = ({
  int accounts,
  int entries,
  int revisions,
  int adjustments,
  int audits,
  BigInt balance,
});

typedef ConfirmBackup = Future<bool> Function(BackupPreview preview);
