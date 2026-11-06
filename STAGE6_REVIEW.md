# Stage 6 review

CEO #027 approved Stage 5 at b271438d2f7b5efe7009e9385a3ddcbff19448d0.
Stage 6 is on codex/stage-6-safety and awaits explicit founder acceptance.

## Review on Android

Use the isolated Hadgaly_Stage2_Disposable AVD on emulator-5556. Verify
mn.hadgaly.hadgaly.sandbox with aapt before installing the sandbox artifact.
Use only synthetic data for the following demonstration.

The local demo can be reopened from PowerShell.

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5556 emu avd name
# Expected AVD is Hadgaly_Stage2_Disposable.
& $adb -s emulator-5556 shell am start -n mn.hadgaly.hadgaly.sandbox/mn.hadgaly.hadgaly.MainActivity
```

1. Enter the four-module drawer and choose Тохиргоо below the module list.
2. Choose Өгөгдөл нөөцлөх and save to a local folder in Android Files.
3. Make a synthetic change such as renaming the first account or posting income.
4. Choose Нөөцөөс сэргээх and select the file. Review counts and total, then
   select Сэргээх. Close and reopen the app when instructed.
5. Verify the prior accounts and balance returned. A fresh install can reach
   Settings from the gear on the welcome screen.

The app retains the previous database in an app-private rollback snapshot.
The exported file contains sensitive information in plaintext. Keep it private.
Rollback is app-private and has no user-facing recovery action.
See [the backup contract](STAGE6_BACKUP_CONTRACT.md) for format and failure handling.

## Android release and privacy checklist

- Use the production flavor and application ID mn.hadgaly.hadgaly for Play.
  Reserve mn.hadgaly.hadgaly.sandbox for test installs.
- The current Gradle release build uses Android debug signing for local testing.
  Before publishing, create an upload key with keytool, store the keystore
  outside Git, and configure release signing through local properties or CI secrets.
  Record key custody and recovery procedures, verify signatures with apksigner
  or jarsigner, and use Play App Signing for distribution. Increase versionCode for
  subsequent releases. [Flutter Android release guide](https://docs.flutter.dev/deployment/android)
- Android in-place updates require the same signing identity. Plan and verify
  export and restore before moving a debug-signed installation to a
  store-signed build. Keep the founder installation and its data intact.
- Keep the backup file picker scoped to the document selected by the user.
  Android cloud-backed file providers may appear according to device settings.
  [Android Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files)
- Before publishing, complete the store privacy policy and Data safety
  declaration with the final build's behavior. Describe the local database,
  disabled Android automatic backup and user-initiated file export.
  [Google Play Data safety guide](https://support.google.com/googleplay/android-developer/answer/10787469)

## iOS prerequisites

The repository currently targets Android. An iOS release needs the iOS runner
and native file picker bridge, macOS and Xcode, an Apple Developer account,
registered bundle ID, signing/provisioning, device backup/restore testing,
an App Store Connect record, a signed IPA and TestFlight review before
App Store submission. [Flutter iOS release guide](https://docs.flutter.dev/deployment/ios)

## Verification evidence

- Format checked 67 Dart files. Flutter analyze found no issues.
- 148 unit/widget tests passed, including eight backup cases. They cover a live
  WAL snapshot, close/reopen and v4 restore, rollback publication failure,
  corrupt checksums, incompatible schema, v1/v2/v3 fixture export after migration,
  negative balances, archived references, deletion revisions and adjustment audit.
- The guarded native suite passed 10 cases across six Android sandbox APKs.
  It checks the actual package and excludes production. Logs are under
  build/android-safety/20261106-174532. The native suite preceded the final\n  restart-control fix, which was then verified on the final release APK.
- Android release APK and AAB package mn.hadgaly.hadgaly, version 0.1.0 (1),
  minimum SDK 24 and target SDK 36. Bundletool validated the AAB. Both artifacts
  were inspected for packaged fixtures, private database and key files.
  Only the internal signature permission for non-exported receivers was present.
  Android backup is disabled. The production release artifacts use the debug
  certificate and are for local inspection.
- APK SHA-256 8d09d4ed488190f11900b1aa4cd07cf040c5b12b93de991941812d6ba0a0f2d6.
  AAB SHA-256 a488ee8e6c82b483c742e3927cb428b7395d525708b78ba99e97970bb9ae450a.

## Release sandbox results

- Updated the verified Stage 5 sandbox in place using Android install -r. The
  existing synthetic profile and 120 ₮ balance survived the v4-to-v4 update.
  The founder production package and AVD were outside these tests.
- Android Files exported a valid SHA-256 backup. Posting 80 ₮ raised the test
  balance to 200 ₮. Picker cancellation, preview cancellation and a corrupt
  import preserved 200 ₮. After confirmation, the app restored 120 ₮.
- A force-stop after queuing the restore recovered the approved image on launch.
  The final release also closed through its own button and restored after launch.
  A paused Finance stream had blocked connection shutdown during the first live
  attempt. The final route closes SQLite before the Android task exits.
- Final sandbox APK SHA-256 94555c2fdc6c8422bdcf175363faebdc4bae1b65d5d49a28af6f2cab7683ae88.
- The final release passed 320dp and 1.8× text with native accessible actions,
  Android Back cancellation, restore confirmation and the restart flow. The
  replacement warning and balance are visible before the scrollable details.
  Physical-device performance and manual TalkBack verification remain open.
- Three cold launches on emulator-5556 took 1265, 1360 and 1099 ms according to
  Android am start -W. The Home balance was visible after each launch.
- Native images use synthetic data. [Settings](docs/review/stage6-settings.png)
  [Android Files export](docs/review/stage6-backup.png)
  [Restore preview](docs/review/stage6-restore.png)
  [Restore at 320dp and 1.8×](docs/review/stage6-restore-large.png)

## Complexity audit

Physical lines include comments and whitespace. Production includes 6,127
handwritten Dart lines in lib and 102 Kotlin lines in Android. Test and driver
Dart total 4,888 lines. Drift-generated Dart accounts for 7,459 lines separately.
This excludes tools, documents, fixtures, assets, Gradle and XML.

Backup Dart is divided among file handling and startup recovery (246 lines),
schema and invariant validation (132 lines) and Settings UI (163 lines).
The Android bridge handles one scoped document transfer at a time.
Only dependency declarations for three previously locked transitive packages
changed. The validator reuses existing account replay and performs read-only
verification before staging and again before startup replacement.
