# Stage 4 — Transaction History, Editing & Financial Integrity

2026-11-03 · CEO #019 · branch `codex/stage-4-history`.
Founder approved Stage 3's eight criteria at **89b8245674910028eaf3e1d7c05c00cd2c6aff74**.
**Stage 4 founder acceptance хүлээгдэж байна. Stage 5 эхлээгүй.**

## Хэрэгжүүлэлт

- Finance Home → “Гүйлгээний түүх”. Өдрөөр бүлэглэж, шинэ өдрийг эхэнд харуулна.
  Account, period, income/expense filter болон тэмдэглэлээс хайх нөхцөлүүд AND-аар нийлнэ.
- Cash row → existing one-screen editor: type, integer amount, category, account, date, note.
  Normal edits нэмэлт confirmation шаардахгүй. Устгал нэг Cupertino confirmation-той;
  dialog нь хадгалагдсан гүйлгээний төрөл/дүн/огноог тодорхой харуулна.
- Balance Adjustment нь тусдаа нэр, icon, target дүн, “Орлого, зарлагад орохгүй” тайлбартай.
  Row нь өмнөх account adjustment/audit дэлгэцийг нээнэ; transaction editor руу орохгүй.
- Archived category-г тухайн гүйлгээнд retained selection болгон харуулж болно; шинэ сонголтод
  архивласан өөр category зөвшөөрөхгүй. Хуучин бүх category reference үлдэнэ.
- Home-ийн сарын бодит flow болон бүх дансны current balance нь edit/delete-ийн дараа шинэчлэгдэнэ.
  Brand, font, дөрвөн tab, onboarding/default/account/anchor ажиллагаа хэвээр. Stage 5 chart/report нэмээгүй. Time-relative history filters нь local midnight болон app resume үед шинэчлэгдэнэ.

## Санхүүгийн integrity ба defaults

Implementation-ээс өмнө бичсэн **STAGE4_FINANCIAL_RULES.md** нь ordering, numerical cases,
snapshot/deletion, retry болон filter defaults-ийг тодорхойлно.

- Schema **v4** зөвхөн append-only `entry_revisions` table/index/guards нэмнэ. Original cash,
  accounts/profiles/categories/global sequence/adjustment/audit table-ийн хуучин талбар өөрчлөгдөхгүй.
- Revision 0 = original cash. Latest snapshot л current entry; tombstone нь history/ledger/flow-оос
  хасагдана. Original cash ба хуучин snapshots нь integrity evidence болж үлдэнэ; restore UI нэмээгүй.
- Stable event ID хэзээ ч өөрчлөгдөхгүй. Registry kind нь original allocation type;
  active income/expense нь resolved snapshot-оос ирнэ. Base + revisions-ийг давхар нэмэхгүй.
- Date өөрчлөгдөөгүй бол exact effective timestamp/order хадгална, account/type өөрчлөгдсөн ч адил.
  Date өөрчилбөл Stage 3 local day-end/current-time дүрэм; today дээр шинэчлэгдсэн older ID нь
  later same-time event-ийн ард орох шаардлагатай үед +1 microsecond. Future scheduling байхгүй.
- Both old/new accounts бүх event-ээр SQLite transaction дотор replay хийнэ. Overflow, invalid data,
  stale revision, injected write failure үед snapshot бүхэлдээ rollback болно. Delete ч мөн replay validation-тай.
- Optimistic revision + unique per-form operation key + busy guards. Same committed retry нь дараагийн
  edit/delete-ийг буцаахгүй; mismatched key reuse/stale writes татгалзана. Cancel write хийхгүй.
- Anchor target, original observation, edit audit өөрчлөгдөхгүй. Earlier edit/delete нь зөвхөн replayed
  balance/difference-ийг өөрчилнө. Opening/anchor нь income/expense/net cash flow биш.

## Баталгаажуулалт

- **123 unit/widget тест PASS**, үүнд бүх Stage 1–3 regression болон 21 шинэ domain/repository/
  migration/widget case. Format (52 Dart files) / analyze PASS.
- Android guarded full suite: **9 functional cases / 5 APK targets PASS**:
  Stage1 ×1, Stage2 ×1, Stage3 ×2, Stage4 ×1, preserved migration ×4.
  Evidence: `build/android-safety/20261103-182342/`.
- Stage 4-ийн нэмэлт native **320dp / 1.8× full flow + reopen PASS**:
  `build/android-safety/20261103-183333/`. Virtual list-ийн offscreen rows-ийг бодитоор scroll
  хийж шалгана. Search, filter sheet, editor, confirmation-ийн contrast/touch-target guideline PASS.
- Programmatic Stage 3/4 integration нь Flutter test input ашигладаг; native rendering/SQLite бодит.
  Үүнийг actual Android IME evidence гэж тооцохгүй. Separate real-IME smoke-ийн үр дүнг эцсийн тайланд
  тодорхой тэмдэглэнэ; OS System UI ANR гарсан эхний smoke attempt-ийг pass гэж тооцоогүй.
- Separate actual Android IME clean run PASS: originals income123/expense125 → income edit200 →
  expense confirmed delete → restart balance200. Original cash rows untouched, exactly two revisions,
  stable IDs/default/onboarding/FK батлагдсан. `build/stage4/real-ime-clean.log` / `real-ime/result.txt`.
  Verified normal sandbox APK SHA-256:
  `a3913286f0ed64324bcacc05ef6f6ad360a6ed713dfc436380cbbd8876d26bb9`.
- Latest normal болон 320dp/1.8× Stage4 target нь ижил APK:
  `c33a3adfc360da7e63a3dfb29724d381a416d07e6343b9109cdb0d7ed7c30bc8`.
  Final normal/small evidence: `build/android-safety/20261103-185420/`, `20261103-185519/`.
- Actual APK applicationId бүрийг installation-ээс өмнө `aapt`-аар шалгасан:
  `mn.hadgaly.hadgaly.sandbox` ≠ production `mn.hadgaly.hadgaly`.
  Only `Hadgaly_Stage2_Disposable` / emulator-5556; cleanup target нь verified sandbox package.
  Founder emulator-5554-ийг runner зориуд татгалзаж байгааг build/install-ээс өмнө шалгасан.
- Founder-ийн production app-д test suite/cleanup, uninstall, clear-data, wipe ажиллуулаагүй.

## Migration: synthetic ба бодит өгөгдөл тусдаа

1. Preserved v1 completed/partial, v2 fixture болон шинэ preserved **v3** fixture-ийн SHA-256-г
   runner шалгана; үргэлж copy дээр upgrade хийнэ. Existing v1/v2 fixture hashes өөрчлөгдөөгүй.
2. v3 fixture нь зөвхөн synthetic: accounts/default/onboarding, cash entries, archived categories,
   anchor/audit. v3→v4 дээр original **долоон table-ийн бүх мөр/талбар** ижил, balances 750/−505,
   category references/ordering хэвээр; overlay edit/delete ба close/reopen мөн шалгасан.
3. Production update нь private DB + sidecars/canonical copy preservation, existing row hashes,
   cash/revisions/category/sequence hashes, derived balance hashes, SQLite integrity/FK check-тэй.
   Үүний бодит үр дүнг эцсийн тайланд synthetic fixture-ээс тусад нь өгнө. Fresh install нь migration proof биш.
   **Actual v3→v4 PASS**: all original rows/cash/category/sequence/anchor/audit and derived balances
   unchanged; no synthetic revisions added. Private evidence:
   `%LOCALAPPDATA%\HadgalyDev\stage4-update-20261103-184848`. Main APK SHA-256:
   `174bdcf16f0487f53e9e13b6c40250378685ea008ba88b46420dde2a960486e7`.
   Production APK has no synthetic fixture assets. Cold launches and rendered UI readiness PASS.
   Final calendar-refresh build update also preserved all existing v4 records/revisions and balances:
   `%LOCALAPPDATA%\HadgalyDev\stage4-update-20261103-185730`; final main APK SHA-256
   `f1ea310979bb994259afa18ba4ac51c3c1de267ec325125b814df0317b0a7d4f`.
   Main History navigation/filters and Android Back were exercised read-only, without financial writes.
4. Өмнөх incident-ийн өгөгдөл сэргээгүй. Founder-ийн зөвшөөрсөн fresh start ба түүнээс хойш
   оруулсан бодит өгөгдлийг хадгална; таамгаар user data/history бүтээхгүй.

## Windows demo / review

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git status --short
git rev-parse HEAD
.\tool\run_production_demo.ps1
```

Exact tested SHA-г final CEO report-д өгнө. Runner зөв production APK/AVD-г шалгаж, private backup
хийсний дараа зөвхөн `adb install -r` update хийнэ; original fields/balances-ийг харьцуулж,
rendered UI + enabled controls-ийг батална. Ямар ч automatic uninstall/clear/restore fallback байхгүй.
`am start -W` exit code 0 атлаа timeout гаргаж болдог тул shell exit code дангаар pass гэж үзэхгүй.

Versioned native screenshots (**synthetic**, founder-ийн мөнгө биш):
`docs/review/stage4-history.png`, `stage4-history-large-text.png` (scrolled), `stage4-editor.png`,
`stage4-delete-confirmation.png`, `stage4-real-ime-history.png`.
Production screenshots/private DB нь Git-д орохгүй. Disposable AVD-г шалгалтын дараа зогсоосон.

Founder review: Home → History → date grouping; account/period/type + note search;
edit amount/type/category/account/date/note; delete cancel/confirm; account balance/anchor difference;
restart. Бодит бус туршилтын мөнгийг production-д оруулахгүй. Synthetic destructive checks нь disposable дээр.

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze
flutter test
.\tool\run_android_checks.ps1
```

Real Android IME smoke нь fresh sandbox installation дээр л ажиллана (guarded test cleanup-ийн дараа):

```powershell
flutter build apk --debug --flavor sandbox
python tool/verify_sandbox_keyboard.py build/app/outputs/flutter-apk/app-sandbox-debug.apk
```

APK ID + AVD + absence of main package-г tool эхэлж шалгана. Existing sandbox data-г clear/uninstall
хийхгүй. `--resume-empty` нь identical installed APK hash, empty profile/zero records-ийг баталсан
setup-д л үргэлжлүүлэх боломжтой; бусад state-г татгалзана.

## Файлын бүлгүүд ба хязгаарлалт

- `features/transactions`: current snapshot resolver, repository edit/delete, pure history/date rules,
  History screen болон existing Entry editor mode. `features/accounts/data`: shared replay integration.
- `features/onboarding/data`: additive v4 schema/generated code. Home дээр нэг History navigation row.
- Tests/support, preserved v3 fixture/hash, native Stage4/migration target; guarded runners/private
  preservation/real-IME tool; README/context/Stage3 approval banner/Stage4 contract/review.
- Period presets: all/current month/previous month/last 7 days. Custom ranges, detailed reports,
  transaction-revision browser/restore, export/backup product UI, recurring/transfers нэмээгүй.
- Filters нь transient; restart-д default all болно. Persisted entry/category/default/anchor/audits хадгалагдана.
- Cupertino date picker сарын нэр English хэвээр; бусад microcopy Монгол. iOS, physical Android hardware,
  TalkBack manual exploration/release signing энэ Windows run-д баталгаажаагүй.
- Replay/history filtering нь MVP-ийн бүх current entries/revisions дээр ажиллана; performance benchmark
  амлалт өгөөгүй. Stage 5-ийн report infrastructure нэмээгүй.
- Active scope-ийн unresolved financial blocker илрээгүй. Founder review: day-edit placement,
  archived-category retention, preset periods, confirmed logical deletion and UI.

**Tests/build дангаараа Stage 4 acceptance биш. Explicit founder approval хүлээнэ.**
