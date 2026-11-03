# Stage 2 — Миний данс ба найдвартай үлдэгдэл

**CEO #016, 2026-11-03: founder Stage 2-ийг илэрхий зөвшөөрсөн. COMPLETE.**
Approved commit: `816af0e67bb92736ae1c887af9a2f5d2ab45dadc`.
Доорх pending/эхлээгүй төлөвүүд нь тухайн үеийн түүхэн тайлан; одоо Stage 3 зөвшөөрөгдсөн.

CEO #011 font/color/product navigation supersedes earlier design descriptions below.
Latest evidence: STAGE2_DESIGN_NAV_REVIEW.md. Stage 2 is still pending founder acceptance.

Latest Home revision supersedes the Home/default-card descriptions below: see STAGE2_HOME_REVIEW.md.

Latest UI refinement and updated verification: see STAGE2_UI_REFINEMENT.md. Current founder data
was preserved during that UI update. The fresh-install statements below describe the earlier baseline.

2026-11-02, Asia/Ulaanbaatar. Stage 1-ийг founder илэрхий зөвшөөрсөн.
Stage 2-ийн хэрэгжүүлэлт review-д бэлэн; **Stage 2 acceptance хүлээгдсэн**.
Stage 3 эхлээгүй. Branch: `codex/stage-2-accounts`; review SHA-г эцсийн тайланд өгнө.

## Fresh start ба өмнөх incident

Founder үндсэн аппыг **шинэ локал өгөгдлөөр эхлүүлэхийг илэрхий зөвшөөрсөн**.
Өмнөх өгөгдөл **сэргээгүй**; screenshot/таамгаар нэр, данс, үлдэгдэл үүсгээгүй.
Fresh installation-ийг migration эсвэл recovered history гэж тайлагнахгүй.

Incident-ийн APK болон commit хийгдээгүй Stage 2 эх кодыг өөрчлөхөөс өмнө
`C:\Users\NewTech\AppData\Local\HadgalyDev\incident-preserved-20261102-143350`
дотор хуулж, SHA-256 manifest хадгалсан. Энэ нь **эх код/APK-ийн нотолгоо**, өмнөх
санхүүгийн database backup биш. Existing default_boot RAM artifact-ийг зөвхөн жагсааж үзсэн;
snapshot restore, AVD wipe, бусад аппын reset хийгээгүй. Historical record: STAGE2_BLOCKER.md.

## 1. Хэрэгжүүлсэн

- Home → “Миний данс” холбоос; одоогийн үндсэн дансны үлдэгдэл realtime шинэчлэгдэнэ.
- “Миний данс”-ны дээд хэсэгт default данс/үлдэгдэл, доор бүх дансны тусдаа үлдэгдэл.
- Данс нэмэх нь зөвхөн “Миний данс” дотор. Нэр ба integer эхний үлдэгдэл шаардлагатай;
  0 болон сөрөг үлдэгдэл зөвшөөрнө. Нэр засах, default сонгох, local persistence.
- Дансны дэлгэрэнгүй: үлдэгдэл тохируулах, тусдаа түүх, effective time, анхны ажигласан
  болон дахин тооцсон зөрүү, хуучин/шинэ дүн ба засварын огноотой audit.
- Тохируулга зөвхөн одоо хүчинтэй; дүнг засаж болно; огноо/order өөрчлөхгүй; устгахгүй.
- Comfortaa, off-white/green, rounded UI, монгол microcopy, жижиг дэлгэц/том текст/контраст.
- Stage 3-ийн орлого/зарлага бүртгэл, transfer, bank integration, speculative cards нэмээгүй.

## 2. Гол файлууд

- `lib/features/accounts/domain/ledger.dart`: Flutter/DB-ээс үл хамаарах pure Dart replay.
- `lib/features/accounts/data/accounts_repository.dart`: atomic mutation, snapshots, audit/retry/revision.
- `lib/features/accounts/application/accounts_providers.dart`: Riverpod stream/provider/request key.
- `lib/features/accounts/presentation`: жагсаалт, дэлгэрэнгүй, account/adjustment forms.
- `lib/features/onboarding/data/app_database.dart`, `.g.dart`: schema v2, additive migration, indexes/triggers.
- `lib/features/home/presentation/home_screen.dart`: navigation ба calculated default balance.
- `test/ledger_test.dart`, `accounts_repository_test.dart`, `accounts_widget_test.dart`: Stage 2 tests.
- `test/fixtures`: synthetic v1 SQL, completed/partial SQLite fixtures ба hash manifest.
- `integration_test/stage2_test.dart`, `migration_test.dart`, `test_driver/integration_test.dart`.
- `android/app/build.gradle.kts`, manifest, `pubspec.yaml`: explicit production/sandbox flavors,
  sandbox-only fixture assets. Main applicationId өөрчлөгдөөгүй.
- `tool/create_disposable_avd.ps1`, `tool/run_android_checks.ps1`: guarded device-test workflow.
- Context, README болон incident/financial-rule/review баримтууд шинэчлэгдсэн.

## 3. Санхүүгийн дүрэм ба defaults

Бүрэн дүрэм/тоон жишээг implementation-ээс өмнө STAGE2_FINANCIAL_RULES.md-д бичсэн.

- Input/current balance: ±999,999,999,999₮ inclusive. BigInt-аар шалгаж integer хадгална.
  Зөрүү нь хоёр захын утгын ялгаа тул ±1,999,999,999,998₮ хүртэл байж болно.
- Opening balance эхний baseline. Event-үүд `(UTC microsecond, stable sequence)` дараалалтай.
  Stage 2 adjustment-ийн autoincrement id sequence болно. Same-time дараалал edit-ээр өөрчлөгдөхгүй.
- Орлого нэмнэ, зарлага хасна; adjustment дээр өмнөх дүн дээр delta нэмэхийн оронд target-ийг тогтооно.
  Дараагийн anchor өөрийн target-ийг дахин тогтоодог тул өмнөх засвар түүнийг хөдөлгөхгүй.
- Анхны target/observed balance immutable; original difference тэдгээрээс сэргээгдэнэ.
  Current difference replay-ээр дахин тооцогдоно. Adjustment нь income/expense/net totals-д орохгүй.
- Device clock ухарвал шинэ adjustment-ийн effective time-г хамгийн сүүлийн anchor дээр clamp хийж,
  sequence-ээр дараа байрлуулна; actual creation time-г тусдаа хадгална.
- Random form request key + unique constraint + busy guard: retry/double tap idempotent.
  Revision checking: хуучирсан edit шинэ утгыг дарж бичихгүй. Ижил дүн хадгалах нь auditгүй no-op.
- Audit insert ба target/revision update нэг transaction; append-only болон matching-audit triggers.
  Audit/adjustment deletion, original observation/effective ordering өөрчлөхийг хориглоно.
- v1→v2: nullable creation key, adjustment/audit tables/indexes/triggers нэмж, хуучин мөрийг reset хийхгүй.
- Transaction add/edit/delete хувилбарууд зөвхөн domain fixtures; бодит transaction schema/UI байхгүй.

## 4. Бодитоор гүйцэтгэсэн шалгалтууд

| Шалгалт | Үр дүн |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | **72 passed**, Stage 1 regressions багтсан |
| `flutter build apk --debug --flavor production` | Амжилттай |
| Production APK `aapt dump badging` | `mn.hadgaly.hadgaly` |
| Production APK assets inspection | Synthetic fixture assets ороогүй |
| Guarded Stage 1 device test, sandbox/disposable | 1 scenario passed |
| Guarded Stage 2 device test, sandbox/disposable | 1 scenario passed |
| Preserved synthetic completed/partial v1 migration, sandbox/disposable | **2 cases passed** |
| Guard against `emulator-5554` | Build/install-ээс өмнө татгалзсан, expected failure |
| Main fresh start | COLD launch; welcome, хоосон nickname; schema v2; 0 accounts/defaultгүй |

72 tests нь opening/zero/negative, олон данс/default, single/multiple anchors, same-time order,
edit/audit, backdated income/expense add/edit/delete, later-anchor invariance, report exclusion,
overflow, rollback, duplicate protection, close/reopen, v1 migration, navigation болон accessibility-г хамарна.
320×568, 1.8× text, урт нэр, том сөрөг дүн, keyboard inset болон tap/label/contrast guidelines шалгасан.

### Device-test package safety

Disposable: **Hadgaly_Stage2_Disposable / emulator-5556**, зөвхөн synthetic data.
Тест бүрийн actual APK applicationId-г **суулгахаас өмнө** `aapt`-аар шалгасан:
**mn.hadgaly.hadgaly.sandbox**, үндсэн app-аас ялгаатай. SHA-256-гаар баталгаажуулсан
яг тэр APK-г `flutter drive --use-application-binary` суулгана; test target-ийг дахин build хийж солихгүй.
Drive cleanup uninstall хийдэг нь pinned Flutter source-оор батлагдсан; cleanup target нь
inspected sandbox package. Test device дээр үндсэн app байхгүй, unrelated packages өөрчлөгдөөгүй.
Үндсэн app emulator-5554 дээр суусан хэвээрийг шалгасан.

Suite evidence: `build/android-safety/20261102-143820/`; logging-enabled migration rerun:
`build/android-safety/20261102-144107/`. APK/badging/result JSON, rerun driver log хадгалагдсан.
Verified APK SHA-256:

- Stage 1: `746468EDF6F49C3D0BDC2A42D587D099D8A0B6017A75A617212A0D2969204EA9`
- Stage 2: `9B54734601B24CF9AD6A7264C22BFDB1AF432446CF316964B7AE11A0ABDA984B`
- Migration: `C01656FD97D70530A64F64D11921B267B2012FDF63ABD1CE36ADA9BA3FE04736`

### Migration ба fresh start — тусдаа нотолгоо

Synthetic completed v1 fixture: 2 данс, −123/0₮, default id 7, nickname “Туршилт”,
completed=true, step=4. Partial fixture: дансгүй, defaultгүй, step=2, дутуу дансны нэр/`-` оролт.
Fixture-ийн эх binary/hash өөрчлөгдөөгүй. Disposable device дээр copy үүсгээд v1-г эхлээд шалгасан;
v2 migration-ийн дараа бүх original account/profile field-ийг харьцуулж, balances/default/onboarding,
foreign keys болон close/reopen-ийг баталсан. Тестийн copy cleanup-д устаж болох disposable өгөгдөл.

**Бодит хуучин хэрэглэгчийн database дээр migration хийгдээгүй, сэргэлт батлагдаагүй.**
Үндсэн app-ийн fresh schema v2/empty onboarding нь өөр, тусдаа шалгалт.

## 5. Founder-ийн interactive demo

Main emulator-5554 дээр үндсэн апп welcome дэлгэцтэй нээгдсэн. Нэр/данс/үлдэгдлийг founder оруулна.
Дахин ажиллуулах бол:

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git status --short
git fetch origin
git switch codex/stage-2-accounts
git pull --ff-only origin codex/stage-2-accounts
git rev-parse HEAD
flutter pub get
flutter run --flavor production -d emulator-5554
```

Хэрэв өөр checkout дээр local өөрчлөлт байвал эхлээд хадгална; хүчээр reset/clean хийхгүй.
Review урсгал:

1. Өөрийн nickname, эхний данс/үлдэгдлээр onboarding дуусгах.
2. Home → “Миний данс”; хоёр дахь данс нэмэх, 0/сөрөг дүн турших.
3. Default сольж, дээд summary болон Home хоёул шинэчлэгдсэнийг харах.
4. Дансны нэр засах; үлдэгдэл өөрчлөгдөхгүйг шалгах.
5. Үлдэгдэл тохируулга үүсгэж, түүх/анхны ба дахин тооцсон зөрүүг үзэх.
6. Дүн засаж old/new/edit-time audit харах; дараагийн anchor нэмээд өмнөхийг засахад
   сүүлийн target хэвээр үлдэхийг шалгах.
7. Аппаа хааж дахин нээх; данс/default/adjustment/audit хадгалагдсаныг шалгах.

## 6–7. Хязгаар, үлдсэн ажил ба review

- Stage 2-д founder-ийн interactive UX/санхүүгийн review ба **илэрхий acceptance үлдсэн**.
- Main app-д fake/synthetic account үүсгээгүй. Шинээр оруулсан дүн нь recovered history биш.
- Clock rollback clamp, supported range, audit labels болон numeric examples-ийг founder review-д харуулна.
  Зөвшөөрөгдсөн хүрээг өөрчлөх нэмэлт шийдвэр одоогоор шаардлагагүй.
- Native Android sandbox flow-ийг бодитоор ажиллуулсан; real-device, release distribution болон
  хүнээр хийсэн бүрэн TalkBack үнэлгээ хийгдээгүй. Stage 1-ийн хүртээмжийн дизайн хадгалагдсан.
- Native renderer workaround README-д бий. Working tools-ийг дахин суулгаагүй.
- Stage 3 UI, бодит backdated transaction persistence, transfers, account/adjustment deletion,
  product backup/restore хэрэгжээгүй. Future transaction ordering нь энэ contract-ийг хадгалах ёстой.
- Stage 2-г accepted гэж автоматаар тэмдэглэхгүй. Stage 3 эхлүүлэхгүй.
