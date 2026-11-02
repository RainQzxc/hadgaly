# Historical Stage 2 emulator app-data incident

**Latest founder decision — 2026-11-02:** fresh local data explicitly authorized. Recovery is no
longer a prerequisite. Previous user data was not recovered. The main app was freshly installed;
test-package isolation was replaced by explicit native flavors and a verified-APK/disposable-device
workflow. See STAGE2_REVIEW.md for current evidence. The incident and prior stop below remain
historical facts, not instructions to undo the approved fresh start.

## Historical record

2026-11-02. Stage 1 is explicitly accepted by the founder. Stage 2 implementation was authorized.
Stage 2 is **not accepted** and work is stopped at a financial-data-integrity blocker.

## Verified incident

- Ran `flutter test integration_test -d emulator-5554` after adding a conditional integration
  application-id suffix in Gradle. The condition did **not** activate for the actual generated test
  target. The merged manifest still used `mn.hadgaly.hadgaly`.
- Both Android tests passed, but Flutter's integration-test cleanup uninstalled that package.
- `adb shell pm list packages -u hadgaly` returned no package; `dumpsys package
  mn.hadgaly.hadgaly` returned `Unable to find package`; `run-as` returned unknown package.
- Pinned Flutter source confirms `IntegrationTestDevice.kill()` invokes `uninstallApp` when enabled,
  and AndroidDevice invokes `adb uninstall <app.id>` without `-k` (keep data).
- Consequently, preservation of the founder's prior emulator app data cannot be claimed; uninstall
  normally removes app-private data. There was no verified pre-test backup of that data.
  The last screenshot is not a complete or authoritative financial backup.
- This was a developer verification error: package identity should have been checked before install.
  A uniquely named SQLite test file did not protect the app's other data from package uninstall.

## Stopped actions and recovery gate

No subsequent normal-app installation, account recreation, guessed balance restoration, AVD wipe,
or GitHub push was performed after discovery. Existing repository changes remain on
`codex/stage-2-accounts`, based on `42c6df80a5634ec81c4cde285825e1cf422d8959`, uncommitted.

Next required input: whether the founder has a prior app/AVD backup or snapshot. If none exists,
any reconstruction needs explicit confirmation of the complete original account/profile data;
never silently infer financial records from screenshots.

Before running device tests again: enforce an explicit separate test application id and verify
the produced APK id **before install**, with cleanup restricted to that test package. The current
Gradle target-string conditional is unverified/unsafe and must not be relied on. Review and test
the harness safely before further use of the founder's emulator.

## Implementation/checks completed before stop

- Pure Dart anchor replay; multiple accounts/default/name changes; current-time adjustments;
  immutable original observation; amount edits with revision checking and append-only audit;
  atomic repository operations; schema v1→v2; Home/My Accounts/detail/forms/history UI.
- Financial rules and numeric cases were documented before behavior implementation in
  `STAGE2_FINANCIAL_RULES.md`.
- `flutter analyze`: no issues. `flutter test`: **72 passed**, including Stage 1 regressions,
  financial fixtures, rollback/idempotency, migration, stream and responsive/accessibility checks.
- `flutter build apk --debug`: passed before the integration harness change. The device-test
  APK builds also passed. Android integration: **2 passed** (Stage 1 + Stage 2).
- No normal Stage 2 interactive founder demo or real-data migration was subsequently verified.
  The acceptance gate is not satisfied. Do not begin Stage 3.

Remaining: recover/confirm prior emulator data, fix and verify safe test-package isolation,
run normal Android migration/demo without losing user data, review Stage 2 implementation,
record/publish a review commit, then obtain explicit founder acceptance.
