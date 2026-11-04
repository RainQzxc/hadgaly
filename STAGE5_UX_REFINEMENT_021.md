# Stage 5 — CEO #021 UI refinement

2026-11-04 · `codex/stage-5-dashboard` · baseline9e2af7146f85643e9fe8ce06d530f7c95df6291c.
Stage 5 is NOT approved. Founder visual review required; no Stage 6.

## Өөрчлөлт

- Цагирагийн сегмент, төвийн дүн, тайлбар бүгд ижил metric: сарын зарлагын
  ангиллын хуваарилалт/нийт зарлага. Орлогыг цагирагаас гадна тусдаа мөрөөр харуулна.
  Цагирагийн caption нь орлогын мөрөөс өмнө, chart-тайгаа хамт байрлана.
- Normal ring176–200dp, stroke10dp; том текстэд агуулга өсөж scroll хийнэ.
  Нийт үлдэгдэл30dp нь үндсэн numerical emphasis; сарын зарлага26dp, орлого20dp.
  Expense-left/income-right64dp quick actions, History/Accounts navigation хэвээр.
- Харьцуулалтын одоогийн дүнг20dp/600, өмнөх дүн ба signed difference/percentage-г
  secondary13dp болгож нягтруулав. Давхар “Одоо” болон zero-baseline тайлбарын
  paragraphs арилсан. Baseline0 үед хувь үзүүлэхгүй гэсэн existing rule хэвээр.
- Monthly net-ийн давхардсан тайлбар хасагдсан. Category amounts16dp/600, хувь13dp;
  нэр болон утгыг нэг мөрт зэрэгцүүлнэ. Cards/gradient/shadow/animation нэмээгүй.
- Дансны нэр, үлдэгдэл зэрэгцэнэ; default account нь “Үндсэн данс” гэсэн тодорхой,
  contrast-той тексттэй. Row padding8dp, subtle separators. Нэр/edit/default actions
  нь existing Accounts дэлгэцдээ үлдэнэ; management functionality давхардаагүй.
- Width<340dp эсвэл text scale өндөр үед name/value мөр босоо болно. Мөнгөн дүнг
  таслах/багасгахгүй. Existing four tabs, brand/font tokens, бусад Finance flow untouched.

## Өөрчлөгдөөгүй protected source

`git diff --exit-code 9e2af7146f85643e9fe8ce06d530f7c95df6291c --` ашиглан
home/domain, home/data, transactions, accounts/data/domain, onboarding, shell, core,
pubspec/lock болон STAGE5_FINANCIAL_RULES.md өөрчлөгдөөгүйг шалгасан.
Ledger/revision resolution, category aggregation, integer MNT, anchor/audit rules,
data models, SQLite schema v4/migrations бүгд ижил. New dependency0.

Production code зөвхөн `home_screen.dart`, `dashboard_details.dart`.
Tests: `home_widget_test.dart`, `dashboard_widget_test.dart`, shared `stage5_flow.dart`;
native Stage5 target-д accounts screenshot нэмсэн. Documentation/context + synthetic PNGs.

## Шалгалт

- **137 unit/widget PASS**: бүх existing financial/persistence/history/migration regression.
  New income-only case: ring expense0/empty, income200 outside, zero-baseline no percentage.
  Shared UI tests: expense center75 reconciles category50+25; income200 outside chart;
  default badge зөвхөн account2; balance−525; compact comparison amounts unchanged.
- 320dp/1.8×: existing full flow, large exact amounts, long Mongolian metadata, insets,
  scrolling, touch targets/labels, text contrast. Layout spacing measures income-row bounds
  (24dp section gap), not a vertically centered Text's glyph bounds.
- Android **6 functional cases /3 targets PASS**: Stage5×1, Stage4×1, migration fixtures×4.
  Evidence: `build/android-safety/20261104-180709/`.
- Final UI normal PASS: `build/android-safety/20261104-181254/`.
  Final UI320dp/1.8× PASS: `build/android-safety/20261104-181325/`.
  Same verified APK SHA256:
  `b92964c16ac0d4f6553a87fec7bf8673ede8a545611f8dba5220aa46c058d5e6`.
- Actual APK ID `mn.hadgaly.hadgaly.sandbox` inspected BEFORE installation;
  only Hadgaly_Stage2_Disposable/emulator5556. Production never used for integration tests.
- Format61 Dart files, zero changes; flutter analyze no issues. Logs:
  `build/stage5-refine-tests.log`, `stage5-refine-analyze.log`, native logs `stage5-refine-*.log`.
- Production v4→v4 preservation PASS: all rows/revisions/category/sequence/anchor/audit,
  profile/default and independently derived balances matched. Two cold launches/UI readiness PASS.
  Actual production APK SHA256:
  `ef7f4ede98a0d86c7bfb18d48fe111753224d07e4549aae0dc3c89f931b88e4d`.
  Private evidence outside Git: `%LOCALAPPDATA%/HadgalyDev/stage5-update-20261104-181625`.
  Initial update attempt refused the absent main AVD before build/install; existing main was
  then cold-booted without loading snapshots or wiping data. Only install-r was used.
  Main emulator5554 is open; disposable5556 stopped with its AVD data retained.
  Actual IME smoke/full native Stage1–3 suite not repeated for this presentation-only change;
  existing entry UI/financial source is unchanged. Current native quick-add/cancel/Back/reopen passed.

## Android review

Synthetic native screenshots (not founder balances):

- `docs/review/stage5-refine-home.png`
- `docs/review/stage5-refine-details.png`, `stage5-refine-accounts.png`
- `docs/review/stage5-refine-home-large-text.png`
- `docs/review/stage5-refine-details-large-text.png`, `stage5-refine-accounts-large-text.png`

Scenario after quick-add: income210, expense75 (food50 archived + groceries25),
net135, all-account current balance385; anchor900 and second account−515 preserved.
Screenshot conversion remains AFTER all interactions/reopen; no converted-surface remount.

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git fetch origin
git switch codex/stage-5-dashboard
git pull --ff-only
.\tool\run_production_demo.ps1
```

Runner privately preserves existing DB/sidecars, verifies actual production APK ID, only
install-r updates and compares original records/revisions/audit/default/balance hashes.
No uninstall/clear-data/wipe/automatic restore. Previous incident data was not recovered;
this iteration preserves currently existing founder data.

Known limits: large text/small screens scroll; custom periods/reports/other modules not added.
iOS/physical Android/manual TalkBack/release signing not verified. Financial behavior untouched.
Founder reviews metric clarity, compact comparison/account rows, typography and vertical rhythm.

**Stop for founder acceptance. Stage5 is not approved; Stage6 not started.**
