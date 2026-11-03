# Stage 3 — Fast Income & Expense Entry

**CEO #019: founder approved all eight criteria after interactive Android testing. COMPLETE.**
Approved commit: `89b8245674910028eaf3e1d7c05c00cd2c6aff74`. Pending statements below are historical.

2026-11-03 · CEO #016 · `codex/stage-3-entry`.
Stage 2 founder-approved baseline: `816af0e67bb92736ae1c887af9a2f5d2ab45dadc`.
**Stage 3 founder acceptance хүлээгдэж байна. Stage 4 эхлээгүй.**

## Хэрэгжүүлсэн

- Home −/+ → зөв төрлийн нэг дэлгэц: дүн → ангилал → данс → хадгалах.
  Default данс урьдчилан сонгогдоно; өөр данс сонгоно. Өнөөдрийн огноог өөрчилж,
  optional тэмдэглэл оруулна. Нэмэлт банк/онлайн бүртгэл шаардахгүй.
- Бүхэл MNT, зөвхөн эерэг transaction magnitude; 0, сөрөг, бутархай, overflow-г татгалзана.
  Данс/adjustment-ийн өмнөх zero/negative боломж хэвээр.
- Анхны орлого/зарлагын ангилал, custom нэр/дүрс, нэр/дүрс засах, архивлах.
  Архивласан ангилал шинэ сонголтоос хасагдана; өмнөх гүйлгээ/FK устахгүй.
- Атомик posting, бүх event-ийн replay/range validation, unique request key, busy guard.
  Давхар даралт нэг гүйлгээ; cancel хадгалалт хийхгүй.
- Home-ийн сарын бодит орлого/зарлага нь opening/anchor-ийг тооцохгүй. Нийт үлдэгдэл нь
  бүх дансны одоогийн replayed balance. Neutral ring нь ангиллын харьцаа зохиохгүй.
- Approved Home composition, дөрвөн tab, Cupertino controls, брэнд token/font хэвээр.
  Урт дүн/том текст цагирагийг босоогоор тэлж scroll хийнэ; дүнг тайрах/жижигрүүлэхгүй.
- Founder-ийн эх логог хадгалж, wordmark-ийг branded header, зөвхөн symbol-ийг Android
  legacy/adaptive icon-д ашиглав. `assets/logo/hf_*.png` хэрэглэгчийн зургуудыг өөрчлөөгүй,
  app bundle/commit-д оруулаагүй. Packaging: `tool/generate_brand_assets.ps1`.

## Санхүү ба migration

Implementation-ээс өмнө бичсэн contract: `STAGE3_FINANCIAL_RULES.md`.

- v3 additive migration: categories / cash_entries / ledger_sequences. v2 anchor ID нь
  global sequence registry-д өөрчлөгдөхгүй шилжинэ. Same timestamp tie нь global ID.
- Existing pure replay өөрчлөгдөөгүй. Target anchor authoritative; original observed difference
  хадгалагдаж, current difference нь earlier entry/anchor edit-ийн дараа дахин бодогдоно.
- Өнөөдөр = хадгалах мөч; clock rollback үед latest account event-тэй clamp хийнэ.
  Өмнөх өдөр = сонгосон local өдрийн төгсгөл. Сонгосон YYYY-MM-DD нь сарын тайлангийн үндэс.
  1970-01-01…өнөөдөр; future scheduling орохгүй. Note ≤500 Unicode code point.
- Opening baseline нь бүх event-ийн өмнө хэвээр; нээгээгүй түүхэн огноо зохиохгүй.
- Ижил төрлийн active category нэр trim/lowercase-ээр unique; type өөрчлөхгүй.
  Archive нь delete биш. Гүйлгээ өөрчлөх/устгах API/UI байхгүй (Stage 4).

Synthetic fixture ба бодит өгөгдлийн нотолгоог тусад нь авч үзнэ:

1. Preserved v1 completed/partial binary fixtures → current v3: original account/profile талбар,
   default, onboarding, balances, FK, close/reopen. v1→v2→v3 additive зам.
2. Preserved synthetic v2 fixture (`stage2_v2.fixture`, тусдаа SHA-256 manifest): хоёр данс,
   default=2, completed onboarding, хоёр anchor ба нэг audit. Бүх original талбар яг ижил;
   balances 800/−500; original/current differences; шинэ global sequence 3/4; reopen.
3. Founder-ийн бодит v2→v3 update: бүх original accounts/profiles/anchors/audits болон
   derived balance hashes ижил, integrity/FK check зөв, synthetic cash entry нэмэгдээгүй.
   DB/sidecar/canonical copy нь `%LOCALAPPDATA%\HadgalyDev\stage3-preserved-*` дотор,
   Git-ээс гадуур. Энэ нь өмнөх incident-ийн өгөгдлийг сэргээсэн гэсэн үг биш.
   Өмнөх fresh-start нь founder-ийн зөвшөөрөлтэй; өмнөх өгөгдөл сэргээгүй.

## Verification

- Dart format болон `flutter analyze` PASS; **102 unit/widget тест PASS**.
  Exact reviewed commit: эцсийн CEO тайлангийн SHA, эсвэл энэ checkout-ийн `git rev-parse HEAD`.
- Android guarded full run PASS: **7 functional cases / 4 APK targets** (Stage 1 ×1, Stage 2 ×1,
  Stage 3 ×2, synthetic migration ×3). `build/android-safety/20261103-172056/` дотор actual package,
  APK SHA-256, cleanup target, unrelated-package check ба driver/result logs байна.
- Native real-IME smoke PASS: synthetic onboarding → 123₮ income / 125₮ expense → −2₮ balance;
  хоёр posting-ийн SQLite record, FK, onboarding/default ба cold restart шалгасан.
  `build/stage3/real-ime/result.txt`, `home-after-restart.png`. Энэ нь main app-ийн мөнгө биш.
- Native 320dp / 1.8× Stage 3 хоёр case PASS. Эцсийн enlarged-text-only padding нь expense
  болон Finance label-ийн сүүлийн үсгийг тусдаа мөр рүү хуваахгүй; ердийн UI хэмжээс хэвээр.
  Evidence: `build/android-safety/20261103-172447/`.
- Real-IME-ийн эцсийн normal sandbox APK SHA-256:
  `31f767de814c889dbf5b68bec5c44f2c4b50eaf91b18fa22848f2208b6ccb5ee`.
  Full native болон enlarged-text Stage 3 target APK SHA-256:
  `1873bf2b55d5c47ad4783a48380c912c4f258eae0c81e5a5533de07928aff06c`.
- Production debug build / checked update / original-record comparison / rendered UI readiness PASS.
  APK SHA-256: `c7706bfb0b52e5f7a3504f8b081d2580c126ec9445dd3fbff04a24937ebe84d7`.
  Production APK дотор synthetic `.fixture` asset байхгүйг `aapt list`-ээр шалгасан.
  `am start -W` API 37 дээр exit 0 атлаа timeout мэдээлж байсан тул runner нь бодит UI content,
  enabled controls-ийг тусдаа bounded read-only шалгалтаар батална; exit code дангаар pass биш.
  Main app-ийн “Миний данс” дээр actual Android tap → account screen → Android system Back → Home
  урсгал мөн PASS; санхүүгийн бичилт хийгээгүй. Disposable emulator-ийг шалгалтын дараа зогсоосон.
- Unit/widget suite нь Stage 1/2 regressions, positive/zero/negative opening, validation/overflow,
  multiple/default accounts, backdating, anchor edit/audit, same-time ordering, duplicate keys,
  rollback, archive/FK, DB reopen, synthetic migration, current-month Home, 320dp/1.8×,
  keyboard/scroll, contrast/touch-target semantics-ийг шалгана.
- Native tests зөвхөн guarded runner / disposable `Hadgaly_Stage2_Disposable` / `emulator-5556`.
  Built APK-ийн бодит ID-г `aapt`-аар freeze/hash хийхээс өмнө шалгана:
  `mn.hadgaly.hadgaly.sandbox` ≠ `mn.hadgaly.hadgaly`.
- Stage 3 programmatic integration `enterText` нь Flutter test input ашиглана. Android IME-ийн
  хуучин editing buffer нь programmatic шинэ дүнг буцааж overwrite хийж байсныг тусгаарласан.
  Санхүүгийн assertion-ууд хэвээр. Real Android IME шалгалтыг тусдаа sandbox UI exercise-ээр
  тайлагнана; test input stub-ийг real-keyboard evidence гэж үзэхгүй.
- Эхний native давталтуудын timing/IME failure-уудыг pass гэж тооцоогүй. Native SQLite
  stream refresh болон route completion-ийг bounded wait-аар хүлээнэ.
- Founder production app-д test suite/cleanup, uninstall, clear-data, AVD wipe ажиллуулаагүй.
  Guarded runner-ийг emulator-5554 дээр зориуд дуудах read-only guard шалгалт нь build/install-ээс
  өмнө founder AVD-г татгалзсан. Actual production migration ба synthetic fixture үр дүн тусдаа.

## Өөрчлөгдсөн файлын бүлгүүд

- `lib/features/transactions/{domain,data,application,presentation}`: шинэ entry/category capability.
- `lib/features/onboarding/data/app_database.dart` ба generated `.g.dart`: additive schema v3.
  `lib/features/accounts/data/accounts_repository.dart`: shared event replay/sequence, live snapshots.
- Home, account-default microcopy, shell-ийн зөвхөн enlarged-text padding, shared field/header,
  `brand_wordmark.dart`, Android manifest/icon resources, `assets/brand`, эх logo PNG, `pubspec.yaml`.
- `test/entry_rules_test.dart`, `transactions_repository_test.dart`, `entry_widget_test.dart`,
  `stage3_migration_test.dart`, `test/support`, preserved v2 fixture/hash; хуучин action/version
  expectation-ууд шинэ scope/schema-д таарсан. Existing financial assertion-ууд хадгалагдсан.
- `integration_test/stage3_test.dart`, migration/Stage 1 expectation, screenshot driver;
  `tool/run_android_checks.ps1`, checked production update/private preservation, real-IME tool.
- README, project context, Stage 2 approval banner, Stage 3 financial/review documents.
  Бүх файлын жагсаалт: `git show --stat HEAD`.

## Windows live demo

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git status --short
git rev-parse HEAD
.\tool\run_production_demo.ps1
```

Runner actual main APK ID болон founder AVD-г шалгаж, private DB preservation хийсний дараа
`adb install -r` update хийнэ; old rows/balances/cash records-ийг харьцуулж cold launch хийнэ.
Ямар ч uninstall/restore fallback байхгүй. Өмнө суусан main app байх шаардлагатай.
Гүйлгээ шалгахдаа founder өөрийн бодит мэдээллээ өөрөө оруулна.

Founder review: Finance Home → −/+ → amount/category/default/change/date/note/save;
My Accounts default switching; category create/name/icon/archive; restart; adjustment audit.
Буруу оруулсан transaction-ийг Stage 3 UI-гаар засах/устгах боломжгүй тул synthetic
туршилтыг production app-д хийхгүй.

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze
flutter test
.\tool\run_android_checks.ps1
```

Real-IME smoke-ийг **main package байхгүй disposable AVD**, sandbox package хараахан суулгаагүй
үед тусад нь давтах (өмнөх guarded suite cleanup-ийн дараа):

```powershell
flutter build apk --debug --flavor sandbox
python tool/verify_sandbox_keyboard.py build/app/outputs/flutter-apk/app-sandbox-debug.apk
```

Tool actual APK ID болон AVD-г эхэлж шалгана. Existing sandbox өгөгдлийг clear/uninstall хийхгүй.
Зөвхөн өмнөх smoke setup оролт оруулахаас өмнө тасарсан бол `--resume-empty` нь identical installed
APK hash + empty profile/zero records-ийг шалгаад үргэлжлүүлнэ; бусад state-г татгалзана.

Disposable AVD startup болон SDK paths: README. Main app-д direct integration test бүү ажиллуул.
Native screenshots нь `build/stage3/screenshots/` дотор. `stage3-synthetic-home.png` нь зөвхөн
synthetic test fixture; production screenshot нь бодит founder UI, Git-д орохгүй.

Versioned native visual references (бүгд **synthetic**, founder-ийн мөнгө биш):
`docs/review/stage3-home.png`, `stage3-home-large-text.png` (scroll хийсэн доод хэсэг),
`stage3-entry-real-ime.png`, `stage3-home-real-ime.png` (real IME → cold restart).

## Хязгаарлалт / founder review

- Stage 3 acceptance хүлээгдэж байна. History/search/transaction edit/delete — Stage 4;
  category-distribution/reporting — Stage 5. Future modules, recurring, transfer нэмээгүй.
- Entry draft нь process restart-д хадгалагдахгүй; хадгалаагүй form-г cancel/restart хийхэд
  гүйлгээ үүсэхгүй. Хадгалсан posting/category/default/anchor/audit нь restart-д хадгалагдана.
- Cupertino date picker-ийн month нэр нь Flutter-ийн default locale-ийн English тексттэй;
  бусад label, огнооны numeric display, validation нь Монгол. Exact Mongolian picker localization
  энэ өөрчлөлтөд нэмэгдээгүй.
- Android debug/emulator чиглэл; iOS project/build, release signing, бодит Android hardware,
  TalkBack manual exploration энэ шатны run-д баталгаажаагүй.
- Current replay-ийг бүх event-ээр хийдэг; энэ MVP-д balance cache/report infrastructure нэмээгүй.
- Идэвхтэй scope-ийн шийдэгдээгүй financial calculation blocker илрээгүй. Founder review-д
  date-only backdating-ийн өдрийн төгсгөлийн байрлал, positive transaction range болон icon catalog орно.
