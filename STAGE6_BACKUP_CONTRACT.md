# Stage 6 backup contract

Backup v1 is a binary file with the eight ASCII bytes HADGALY1, a 32-byte
SHA-256 of the payload, and one self-contained SQLite schema-v4 image. The
maximum SQLite payload is 64 MiB. A snapshot uses SQLite VACUUM INTO on the
active Drift connection, which includes committed WAL data and omits free pages.
The file contains the profile, every account, category, sequence, original entry,
revision, adjustment and audit row. The checksum detects corruption. The file
is plaintext and its checksum does not establish authenticity.

Android uses ACTION_CREATE_DOCUMENT and ACTION_OPEN_DOCUMENT with scoped URI
access. App-private scratch files are used for validation and transfer. The
app itself has no cloud API. The system picker can expose user-chosen providers.

An import checks the envelope, checksum, schema version, trusted schema,
SQLite integrity and foreign keys, profile/default, ledger sequences, category
references, audit/revision history and existing account replay. The preview shows
record counts and the derived total. Confirmation publishes the validated SQLite
image under a private name containing its SHA-256. The settings screen then asks
the user to close and reopen Hadgaly.

Before Drift opens at startup, the app rechecks the staged image and saves a
flushed, verified snapshot of the current database as restore-rollback.sqlite.
SQLite checkpoints the live database and leaves DELETE journal mode before its
only startup connection is closed. A single same-directory rename installs the
staged image and consumes the pending request. Process interruption before that
rename leaves the old live database and the pending request. Interruption after
the rename leaves the verified new database and the rollback copy. A rejected
request is removed from the queue and the next screen reports failure. This
protocol targets Android process interruption. Device power-loss durability has
not been verified. The rollback file is app-private and retained until the next
confirmed restore reaches the replacement step.

The portable format starts with v4. Older raw databases are handled by the
existing v1/v2/v3 migrations on app update. They are not portable backup files.
