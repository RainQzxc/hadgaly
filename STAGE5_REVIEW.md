> CEO #022 moves detail sections off Home into the dedicated Report screen. Current navigation/checks: STAGE5_REPORT_NAVIGATION_022.md. Older UI descriptions below are historical; financial rules unchanged; Stage 5 remains unapproved.

> CEO #021 presentation refinement supersedes the UI described below. See STAGE5_UX_REFINEMENT_021.md for current UI/checks. Financial calculations remain unchanged; Stage 5 is still pending founder acceptance.

# Stage 5 — Finance Dashboard & Insights

2026-11-04 · CEO #020 · `codex/stage-5-dashboard`.
Founder approved Stage 4 explicitly at **de5ea5d5054b146ae65ad055decc9c2792b0122d**.
Stage 5 нь founder acceptance хүлээнэ. Stage 6 эхлээгүй.
Exact tested/pushed commit SHA-г эцсийн CEO report-д өгнө.

## Хэрэгжүүлэлт ба review урсгал

- Finance Home-ийн батлагдсан дараалал: compact expense-category donut дотор сарын
  income/expense → all-account current balance → expense-left/income-right quick add.
  History болон Accounts navigation хэвээр. Default-account card буцааж нэмээгүй.
- Donut нь бодит зарлагын ангиллын хувь; доорх жагсаалтад нэр, exact MNT, хувь,
  архивласан тэмдэглэгээ. Зарлагагүй бол neutral ring/empty copy; sample мөнгө байхгүй.
- Сарын цэвэр урсгал, өмнөх календарь сартай income/expense харьцуулалт: previous,
  current, signed absolute difference, rounded percentage. Previous=0 бол хувь үзүүлэхгүй.
- Дансны товч тойм: бүх нэр/current balance/default badge; management нь өмнөх дэлгэцдээ.
  Санхүү эхэлж сонгогдоно; бусад 3 tab зөвхөн coming-soon. Шинэ route/dependency байхгүй.
- Normal 200–240dp ring/10dp stroke, 64dp actions; том текст дээр ring/мөрүүд өсөж scroll хийнэ.
  Дүнг багасгаж таслахгүй; мөнгөн утга бүтнээр уншигдана. Шинэ animation/card/gradient байхгүй.
- Google Sans Flex/Noto Sans, Cupertino, Midnight/Teal/neutral/expense tokens хэвээр.
  Category ID-д тогтвортой өнгө онооно; олон category үед palette давтагдаж болно.
  Нэр/дүн/хувь нь өнгөнөөс хамааралгүй мэдээлэл өгнө.

## Санхүү ба өгөгдөл

Implementation-ээс өмнөх **STAGE5_FINANCIAL_RULES.md** нь examples/defaults-ийг тодорхойлно.

- Pure Dart aggregation; existing `monthFlows` болон shared current snapshot resolver/replay-г
  дахин ашиглав. AccountsSnapshot-д нэг transaction дотор categories унших 4 мөр нэмсэн.
- Current balance нь opening/anchor/current cash бүхнээс replay хийгдсэн балансын BigInt нийлбэр.
  Monthly income/expense/net нь зөвхөн current non-deleted snapshots-ийн stored local date key.
- Base+revisions давхардахгүй. Edited type/date/category/account/amount болон logical deletion тусна.
  Archived category reference хадгалагдана. Category totals нь ижил month/all-account expense-тэй тэнцэнэ.
- Мөнгөн дүн/ялгавар BigInt. Comparison хувь integer half-up 0.1%; category хувь largest remainder
  0.1%, нийлээд 100.0%. Donut geometry дээр л bounded integer share → double хувиргана.
- **Schema v4 хэвээр**, migration/generated database/financial engine/write APIs өөрчлөгдөөгүй.
  Existing ledger, original observations, anchors, audits болон revision snapshots-ийн дүрэм хэвээр.
- Өмнөх incident-ийн data сэргээгүй. Founder fresh-start decision ба өнөөгийн бодит өгөгдөл тусдаа.
  Энэ stage нь user data зохиох, restore хийх, production дээр synthetic entry үүсгэхгүй.

## Баталгаажуулалт

- **136 unit/widget tests PASS** = өмнөх123 + шинэ13 (domain7, repository3, widget3).
  Empty/negative/multiple accounts, December→January, zero baseline/rounding, large exact totals,
  category reconciliation, archived rename/watch refresh, edit/date/type/account/delete around
  anchors, SQLite reopen, long metadata, 320dp/1.8×, quick add/cancel/navigation/accessibility.
- Format: 61 Dart files, zero changes. `flutter analyze`: no issues.
- **Full Android final: 10 functional cases / 6 APK targets PASS**:
  Stage1×1, Stage2×1, Stage3×2, Stage4×1, Stage5×1, migrations×4.
  `build/android-safety/20261104-171403/`; `build/stage5-android-tested.log`.
- Stage5 normal + preserved fixture migrations PASS: `build/android-safety/20261104-170035/`.
  v1 completed/partial, v2, v3 synthetic fixture cases тус тусдаа; original hashes өөрчлөгдөөгүй.
- Stage5 **native 320dp/1.8× full flow + reopen PASS**:
  `build/android-safety/20261104-172336/`.
  Final normal repeat: `build/android-safety/20261104-172432/`.
  Same verified Stage5 target APK SHA256:
  `d5682588b9095974fbe7d7806bf65d6c04825f9b51addadc3d90b20494c87ba2`.
- Native flow: synthetic opening1000/−500, prior flows100/100, current200/75,
  anchor900, archived food; combined375/net125. Quick income10 to default card →385/net135.
  Cancel/history/account/system Back/placeholders, close/reopen/default/category/anchor persisted.
- Initial attempts correctly failed on obsolete unique-text assumptions (same balance now appears
  in account summary) and native raster/clipped-semantics measurement. Updated tests target exact
  Home balance, preserving expected monetary assertions. Partial scroll-node rectangles are not
  treated as full tap targets: every real control is scrolled into view and checked ≥48dp/hit-testable;
  global tap guideline also runs at scroll origin. Real text styles are checked ≥4.5:1 and ≥13dp;
  widget raster contrast and native visual review remain. A failed pixel histogram is not called PASS.
- One later small native attempt lost the VM service after screenshot surface conversion
  happened BEFORE interaction/remount. The harness now converts only after all interactions
  and close/reopen, consistent with older Stage3/4 tests; native repeats are recorded separately.
  This changes no application code or monetary assertions. Failed attempts are not PASS.
- Native integration uses Flutter TestTextInput; do not describe it as actual IME input.
  Old Stage1/2 tests mixed OS input with programmatic enterText; a later repeat failed
  onboarding completion after real-IME smoke. Their binding now explicitly registers/
  unregisters TestTextInput consistently with Stages3–5. Expected values stay unchanged;
  subsequent Stage1/2 Android runs PASS. Real-IME verification stays separate.
  Separate actual Android IME PASS: synthetic income123/expense125 → report net−2,
  category125/100.0% → income edit200/confirmed expense delete → restart balance200.
  Originals remain123/125; exactly2 revision snapshots, no anchors/FK violations.
  `build/stage5-real-ime-tested.log`, `build/stage5/real-ime/result.txt`.
  Final normal sandbox APK SHA256:
  `2f5fc861c39d1e53e6151e84a1ffd7b622fe9f2e5be53846808d5f707b3fe5ad`.
  Production preservation is separate from fixtures/native TestTextInput.

## Production safety / live demo

All integration builds inspect actual APK applicationId/hash BEFORE installation:
`mn.hadgaly.hadgaly.sandbox` ≠ `mn.hadgaly.hadgaly`.
Only `Hadgaly_Stage2_Disposable` / emulator-5556 receives synthetic/destructive scenarios.
Runner checks unrelated packages and refuses the main AVD before build/install.

**Actual production v4→v4 preservation PASS**, separate from fixture migration.
All original rows, revisions, category/sequence/cash/anchor/audit data, profiles/default and
independently derived balances matched. Two cold launches rendered enabled real controls.
`build/stage5-production-demo.log`; private evidence outside Git:
`%LOCALAPPDATA%/HadgalyDev/stage5-update-20261104-172923`.
Actual production APK SHA256:
`9e3902c4a3983177a3e98e2de2eff1bb637809e0034b6a788e64d8a4bb0eda53`.
APK contains no synthetic fixture/user-download assets. Main is open on emulator-5554;
disposable emulator stopped with its data retained. Guard refusal on founder AVD was verified
before any build/install: `build/stage5-production-guard.log`.
No uninstall/clear-data/wipe/automatic restore fallback.
The existing runner first preserves private DB/sidecars outside Git, checks actual APK ID,
then only `adb install -r`, comparing original financial/category/sequence/cash/revision/audit
records and derived balances, SQLite integrity/FK, plus rendered UI readiness/cold launch.
This is separate from synthetic migration fixture evidence.

```powershell
Set-Location D:\sum\hadgaly
git fetch origin
git switch codex/stage-5-dashboard
git pull --ff-only
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git rev-parse HEAD
.\tool\run_production_demo.ps1
```

If needed, start the existing main emulator without wiping data:

```powershell
$env:QT_OPENGL = 'desktop'
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Medium_Phone_API_37.0 -port 5554 -no-snapshot-load -no-snapshot-save -gpu swiftshader -feature -Vulkan -cores 4
```

Review: Санхүү → totals/neutral-or-real ring → quick add → scroll monthly net/category shares/
comparison/account overview → History/edit/delete and Accounts/adjustment remain existing flows.
Native screenshots in `docs/review/stage5-*.png` contain **synthetic** data only;
large-text screenshots show scroll positions, not a promise that all content fits one viewport.
The native fixture screenshots are after quick-add10: income210, expense75, balance385/net135.
The separate real-IME ADB captures show synthetic income123/expense125 and negative balance−2.
Founder data/screenshots/private backups never enter Git.

Reproduce sandbox checks on the existing disposable AVD only:

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze
flutter test
.\tool\run_android_checks.ps1
# Actual Android keyboard smoke AFTER sandbox integration cleanup:
flutter build apk --debug --flavor sandbox
python tool/verify_sandbox_keyboard.py build/app/outputs/flutter-apk/app-sandbox-debug.apk
```

## Өөрчлөгдсөн файлууд / complexity audit

- Production: `home/domain/dashboard.dart`, `home/data/dashboard_report.dart`,
  `home/presentation/dashboard_details.dart`, existing `home_screen.dart`,
  `accounts/data/accounts_repository.dart` read metadata only.
- New tests: dashboard domain/repository/widget files, shared Stage5 synthetic data/flow,
  native Stage5 target. Existing Home/Stage1–3 tests only update obsolete presentation assumptions.
- Driver saves Stage5 screenshots; Android runner adds Stage5 target; existing keyboard helper
  checks net/category output; production runner only names its evidence directory for Stage5.
- Documentation: context/README, Stage4 approval banner, Stage5 rules/review, synthetic screenshots.
- Production Dart diff: **+443 / −75 = +368 net**, 5 files. Tests/driver: **+712 / −16 = +696 net**, 14 files.
  Scripts: **+11 / −4 = +7 net**, 3 existing files.
  Documentation: **+297 / −29**, 5 text files + 6 synthetic PNGs.
  Generated files: **0**. Database schema/migration files: **0**. Dependencies: **0**.
- Largest touched UI: existing Home429 lines; new details227, pure aggregation106, adapter22.
  Existing generated Drift7459 lines remains unchanged. No speculative reporting repository/schema.
- One authoritative resolver/replay and existing monthly summation, no duplicate revision pipeline.
  Aggregation is O(entries + categories log categories); existing all-entry replay remains unpaged.
  Safe later simplification: extract existing Home action/ring layout if it grows. No unrelated refactor now.

## Хязгаарлалт / founder review

- Current month-to-date versus full previous calendar month; no pace forecast/extrapolation.
- Calendar-month, all-account dashboard only; no custom ranges/dashboard filter/advanced reports.
- Fractions of a percentage are rounded as documented; extremely tiny shares can display0.0%
  but their exact amount/name remains listed. Palette repeats beyond six categories.
- Large text/small screens require scrolling; quick actions remain reachable. No performance benchmark
  or arbitrary large-history latency guarantee. Midnight/resume refresh reused, actual midnight hardware
  transition not separately timed. iOS/physical Android/TalkBack manual/release signing unverified.
- Existing Cupertino date picker English month names remain; no Stage6 product backup/restore UI.
- Founder review: information hierarchy/scroll density, category palette/archive label, monthly wording,
  and comparison clarity. No unresolved financial-rule decision identified.

**Tests/build are not acceptance. Stage 5 awaits explicit founder approval; do not begin Stage 6.**
