# Stage 5 — CEO #022: compact Home / dedicated Report

2026-11-05 · branch `codex/stage-5-dashboard` · baseline
`b1128085a0d1764d830a44619710a783d5a6306a`.
**Stage 5 founder approval хүлээгдэж байна. Stage 6 эхлээгүй.**

## Хэрэгжүүлэлт

- Home: existing brand/greeting, compact expense-category ring/monthly income,
  combined current balance, expense-left/income-right actions, History, My Accounts.
  Нэмсэн “Санхүүгийн тайлан” row нь subtle chart icon + chevron, ≥48dp target-тай.
- Monthly net, category breakdown list, month comparisons, account overview Home-оос
  бүрэн гарсан. Эдгээр existing widgets нь шинэ `ReportScreen` дотор л байна.
- Existing Cupertino route/back болон Finance-ийн nested navigator ашиглана;
  дөрвөн tab хэвээр, Android Back нь тайлангаас Home руу буцна.
- Shared `dashboardProvider` нь existing `dashboardReport`-ийг нэг л газар дуудаж,
  Home/Report-д ижил coherent snapshot/report өгнө. Route нээхэд calculator дахин
  хуулбарлагдахгүй; object identity-г тестээр шалгасан. Existing midnight/resume
  UI timer нь provider руу шилжсэн тул тайлан нээлттэй үед ч period шинэчлэгдэнэ.
- Refined `DashboardDetails` / `AccountSummary`-г өөрчлөөгүй, шууд дахин ашигласан.
  Шинэ financial model/formula/schema/dependency/report repository нэмээгүй.
  App restart нь Home/Finance-ийг нээнэ; тайлан дахин нээхэд хадгалсан дүнг харуулна.

## Файлууд ба хамгаалсан source

- Production presentation: `home_screen.dart`, шинэ `dashboard_provider.dart`,
  шинэ `report_screen.dart` (`lib/features/home/presentation/`).
- Tests: existing Home/Accounts/dashboard widget tests, shared Stage5 flow,
  Stage5 Android integration target; guarded real-IME helper-ийн report navigation/captures.
- Context/README/review banners болон энэ report; synthetic screenshot artifacts.
- Baseline-тай `git diff --exit-code` ашиглан home/domain/data, accounts, transactions,
  onboarding/schema/generated code, shell, core/tokens/fonts, pubspec/lock,
  STAGE5_FINANCIAL_RULES.md өөрчлөгдөөгүйг баталсан. Ledger/revisions/anchors/audits,
  integer MNT, stored date keys, category totals, default/account behavior хэвээр.

## Гүйцэтгэсэн шалгалт

- **138 unit/widget PASS**, бүх existing financial/persistence/migration regressions.
  Home detail sections absent, correct report route, shared report identity, all original
  numeric expectations, edited income/default/anchor reactivity, system/toolbar Back.
  Empty/income-only, negative/large amounts, long Mongolian metadata, 320dp/1.8×,
  safe areas, touch targets, contrast болон existing History/Accounts/quick-add flows.
- Format/analyze цэвэр; 63 Dart files. Logs `build/stage5-report-tests.log`,
  `build/stage5-report-analyze.log` (exact commit-ийн final run мөн хадгалагдана).
- Guarded Android: **6 functional cases /3 targets PASS** (Stage5, Stage4, four fixtures):
  `build/android-safety/20261105-161843/`.
- Final normal Stage5 PASS: `build/android-safety/20261105-163241/`.
  Final 320dp/1.8× Stage5 PASS: `build/android-safety/20261105-163345/`.
  Target APK SHA256 `b06ca827228664080a664674a01f6d616dd5c95b42ba90262c07f07224915853`.
  Additional synthetic precheck PASS: `build/android-safety/20261105-163942/`.
- Initial small screenshot conversion stalled after entering capture phase. This attempt
  is NOT a PASS. Stage5 functional integration no longer converts Android surfaces;
  real ADB screenshots are captured separately, avoiding surface/remount/frame artifacts.
  Only the verified sandbox process on disposable5556 was stopped; no production reset.
- Separate actual Android IME/ADB PASS: `build/stage5-report-ime.log`;
  `build/stage5/report-ime/20261105-164035/`. APK SHA256:
  `059bc8e09b2c1947a1760feb861e6020572b3d7c9fbf8bdee72c1941172c5323`.
  The earlier capture helper assumed Home balance was visible at 1.8×; it correctly failed
  when balance was below the fold. Readiness now uses the visible overview, then scrolls
  to actual report controls. Final full run passed; no financial assertions were removed.
- IME scenario: mandatory onboarding/Wallet0, income123/expense125 → Home−2/report net−2,
  food125/100.0%, previous baseline0/no percentage. Both sizes captured same records.
  Then income edit200, expense confirmed-delete, restart balance200. Original rows123/125,
  exactly two revision snapshots, stable sequences/default/onboarding/FK preserved.
  Each helper run uses a fresh evidence directory, keeping old copies/sidecars separate.
- Actual APK package IDs verified before install: sandbox `mn.hadgaly.hadgaly.sandbox`
  differs from main `mn.hadgaly.hadgaly`; only disposable AVD receives synthetic tests.

## Бодит өгөгдөл / live demo

- Main v4→v4 update/preservation PASS: all original rows/revisions/category/sequence/
  adjustment/audit/profile/default and independently derived balances matched.
  Private backup: `%LOCALAPPDATA%/HadgalyDev/stage5-update-20261105-164444`.
  Production APK SHA256:
  `03db2aa1a10db6d70ceee74b7bf5007d6f253e7b26e1dee28f4d3142439768ef`.
- `build/stage5-report-production.log`: actual APK identity, only install-r, two cold
  launches and rendered UI readiness. No uninstall/clear-data/wipe/automatic restore.
- Actual main read-only report row → Report → OS Android Back → Home passed;
  four tabs present on both routes. No financial actions during this inspection.
  Evidence `build/stage5-report-main-navigation.log`. Main5554 remains open;
  disposable5556 stopped, AVD data retained. Previous incident data was not recovered.

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git fetch origin
git switch codex/stage-5-dashboard
git pull --ff-only
.\tool\run_production_demo.ps1
```

Home → “Санхүүгийн тайлан” → monthly net/categories/comparisons/accounts → Back.
Quick-add, History, My Accounts нь Home дээрээ хэвээр.

## Visual review

Real Android OS captures, **synthetic** data only:

- `docs/review/stage5-report-home.png`, `stage5-report-screen.png`
- `docs/review/stage5-report-home-large-text.png`, `stage5-report-screen-large-text.png`
- `docs/review/stage5-report-accounts.png`, `stage5-report-accounts-large-text.png`

Normal Report uses the later settled capture at the same top scroll position, retaining
the visible four-tab bar. No image cropping/compositing or invented financial activity.
Large text requires scrolling; toolbar title may ellipsize using the existing navigation
pattern, while its full accessibility label and Back remain available. MNT amounts wrap.
iOS/physical Android/manual TalkBack/release signing/performance benchmarks not rerun.
No Stage6 backup/restore product UI, custom periods, new reports or other modules.

**Return for founder visual review. Stage5 is NOT approved.**
