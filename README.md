# Хадгалъя · Hadgaly

Modular personal organization vision; **only offline-first, manual-entry finance is active now**.
Tasks, shopping and ideas are coming-soon UI only; the finance six-stage roadmap is unchanged.
Flutter **3.47.9**, bundled Dart **3.13.7**,
Riverpod, SQLite/Drift; feature-first organization. Preserve `pubspec.lock`.

Stages 1–4 are explicitly accepted. Founder approved Stage 4 on 2026-11-04 at
`de5ea5d5054b146ae65ad055decc9c2792b0122d` under CEO #020.
Stage 5 Finance Dashboard & Insights is authorized, pending founder acceptance.
See STAGE5_FINANCIAL_RULES.md, STAGE5_REPORT_NAVIGATION_022.md and STAGE5_DRAWER_024.md
for current scope, screenshots and verification.
No Stage 6, transfers, bank integration or other-module functionality.
The UI uses Cupertino components, Google Sans Flex + Noto Sans missing-glyph fallback,
and Midnight Blue/neutral/teal tokens. CEO #024 replaces the bottom tabs with a right-side
drawer accessed from the upper-right hamburger. Finance is initially selected.
See `STAGE2_DESIGN_NAV_REVIEW.md` for current UI/accessibility/data-preservation results.
Latest Home layout supersedes the earlier default-account card: see `STAGE2_HOME_REVIEW.md`.
Home keeps the expense-category donut/current-month income, combined current balance and quick actions.
“Санхүүгийн тайлан” opens monthly net, category breakdown, comparisons and account overview on a
separate Finance route; one shared presentation provider reuses existing aggregation. Empty spending keeps a neutral ring.
Existing quick entry, history and account management remain accessible. No schema change: v4.
See STAGE3_REVIEW.md and STAGE3_FINANCIAL_RULES.md for verification, dates and acceptance limits.

## Fresh-start decision

The founder explicitly authorized a fresh main database after the device-test cleanup incident.
**Previous data was not recovered.** No user profile/account/balance was guessed or reconstructed.
The founder enters their own nickname and first account. Historical incident details remain in
`STAGE2_BLOCKER.md`; current results and limitations are in `STAGE2_REVIEW.md`.

## Main Android app

Main APK applicationId: `mn.hadgaly.hadgaly`. Native flavor: `production` (default).
Founder device: `emulator-5554` / `Medium_Phone_API_37.0`.

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
flutter --version
flutter pub get
flutter analyze
flutter test
.\tool\run_production_demo.ps1
# Verifies the actual APK ID, preserves private DB/sidecars, updates with install -r,
# compares original records/balances, then launches. No uninstall/clear fallback.
```

This checked install uses Android replace/update mode and preserves the current app database. Do not uninstall or clear data
to repeat onboarding. Do not run direct integration tests on the founder device.
Never wipe the AVD or install a test APK over the main app.

If the main emulator needs starting, in a separate terminal:

```powershell
$env:QT_OPENGL = 'desktop'
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Medium_Phone_API_37.0 -no-snapshot-load -no-snapshot-save -gpu swiftshader -feature -Vulkan -cores 4
```

The normal renderer previously crashed in NVIDIA `nvoglv64.dll`; basic `-gpu software` later hung.
On 2026-11-03 Qt `angle` failed loading software OpenGL; process-local `QT_OPENGL=desktop` with
guest `-gpu swiftshader` passed. No permanent main-AVD configuration change is required.
NDK 28.2.13676358 and CMake 3.22.1 are already installed; do not reinstall working tools.
Hot Reload: `r`; Hot Restart: `R`. Neither replaces cold-start persistence verification.

## Safe Android integration checks

Only synthetic data, only `Hadgaly_Stage2_Disposable`, default port/device `emulator-5556`.
The sandbox applicationId is **`mn.hadgaly.hadgaly.sandbox`**, different from the main app.
Flavor is explicit; it is never inferred from a generated Dart test path.

Create the disposable AVD once (refuses to overwrite an existing AVD):

```powershell
.\tool\create_disposable_avd.ps1
```

Start it in a separate terminal:

```powershell
$env:QT_OPENGL = 'desktop'
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Hadgaly_Stage2_Disposable -port 5556 -no-window -no-snapshot-load -no-snapshot-save -gpu swiftshader -feature -Vulkan -cores 2 -memory 2048
```

Then use the guarded runner:

```powershell
.\tool\run_android_checks.ps1
# Or only preserved-fixture migration:
.\tool\run_android_checks.ps1 -Tests migration_test
```

The runner verifies the AVD name and absence of the main package on the test device, checks preserved
fixture hashes, builds the sandbox APK, inspects its actual applicationId using `aapt`, freezes and
hashes that binary, and only then installs that exact verified APK with `flutter drive`.
Drive cleanup uninstalls the **sandbox** package; unrelated packages are checked before/after.
An attempted run against emulator-5554 was verified to fail before build/install.
Evidence: `build/android-safety/<timestamp>/` (APK, badging, SHA-256/result JSON and driver logs).
Do not copy any real user data to the disposable AVD. Do not bypass these guards.

## Financial rules and persistence

See `STAGE2_FINANCIAL_RULES.md`, written before financial implementation.

- Input/current-balance range: **−999,999,999,999 through 999,999,999,999 MNT** inclusive.
  No fractions, floating-point arithmetic, silent rounding or truncation. BigInt validates arithmetic.
- Opening is a baseline. Adjustment targets are authoritative anchors, ordered by effective UTC
  microsecond and stable sequence. New adjustments are current-time only; no date picker/deletion.
- Target edits preserve effective position and append old/new/edit-time audit in the same transaction.
  Original observed difference and recalculated difference are separately preserved/displayed.
- Later anchors stay authoritative. Adjustments/openings are excluded from income/expense/net cash flow.
  Manual additions remain immutable originals. Stage 4 appends edit/delete snapshots; only the latest active revision enters balances/history/flows. Stale/duplicate writes are guarded and both affected accounts replay atomically.
- Random form request keys, unique constraints, revision checks and busy guards prevent duplicate saves.
- Database schema **v4** upgrades v1/v2/v3 additively, atomically. A global event sequence preserves old anchor IDs/order. No destructive migration fallback.
  SQLite foreign keys and triggers protect default accounts, immutable observation, audit and deletion rules.
- Names: trimmed, nonblank, single-line, at most 60 Unicode code points.
- Google Sans Flex and Noto Sans are bundled offline under SIL OFL. Google Sans Flex lacks Cyrillic/₮;
  Noto Sans supplies only missing glyphs, including Ө/Ү/өү and ₮. Source revision, hashes and licenses:
  `assets/fonts/SOURCES.json`, `assets/fonts/*-OFL.txt`, `GoogleSansFlex-TRADEMARKS.md`.
  Optional font QA: `python tool/verify_fonts.py` with fontTools (already available locally).
- No sensitive financial logs, automatic data upload or automatic Android backup.
  Product backup/restore remains Stage 6 scope.

## Preserved synthetic migration fixtures

`test/fixtures/stage1_completed_v1.fixture` and `stage1_partial_v1.fixture` are real SQLite **v1**
files containing synthetic data only. Their SHA-256 manifest is committed. Tests copy them to unique
device paths, inspect version/records before upgrade, compare all original account/profile fields
after migration to the current v4 schema, verify balances/default/onboarding/foreign keys, then close/reopen.
These assets are packaged **only in sandbox APKs**, not in the production app.
`stage2_v2.fixture` is a preserved synthetic v2 database with two accounts, default account, two anchors
and an edited anchor audit. Its separate SHA-256 manifest is checked before device tests. All original
fields, balances, default/onboarding and stable event IDs are compared after v2→v3 and reopen.
Fresh-install success is separate evidence and does not validate migration or recover previous data.

Preserved `stage3_v3.fixture` separately verifies v3→v4 with actual synthetic cash entries, archived
categories, two accounts/default and adjustment audit. All seven original tables remain identical after
migration and after overlay edit/delete. New entry revisions are append-only; originals are never erased.

## Source and review

- `lib/core/domain/money.dart`: exact validation/formatting.
- `lib/features/accounts/domain/ledger.dart`: pure Dart chronological financial replay.
- `lib/features/accounts/{data,application,presentation}`: repository, streams, forms, My Accounts/history.
- `lib/features/onboarding/data`: current Drift schema and additive v1/v2/v3→v4 migrations; generated Dart is committed.
- `test`, `integration_test`, `test_driver`, `tool`: unit/widget/device checks and safety workflow.

After changing the Drift schema, review/add a migration and regenerate:

```powershell
dart run build_runner build
```

Never commit real databases/notes/exports/credentials. Only the explicitly identified synthetic
`.fixture` files are versioned. Founder acceptance gates remain tests + Android demo + explicit approval.
