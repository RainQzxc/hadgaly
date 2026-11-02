# Stage 1 — Founder review

Огноо: 2026-11-02, Asia/Ulaanbaatar.
Төлөв: **хэрэгжүүлэлт ба инженерийн шалгалт дууссан; founder acceptance хүлээгдэж байна.**
Branch: `codex/stage-1-onboarding`. Review хийх commit SHA-г эцсийн тайланд өгнө;
checkout дээр `git rev-parse HEAD` командаар шалгана. Stage 2 эхлээгүй.

## Хэрэгжүүлсэн

- Flutter 3.47.9 / Dart 3.13.7, Riverpod, Drift/SQLite, feature-first бүтэц.
- Comfortaa-г OFL лицензтэйгээр offline bundle хийсэн. Монгол кирилл, Ө/Ү, тоонууд,
  ₮ тэмдгийн glyph бүр байгааг fontTools-оор шалгасан. Зөөлөн ногоон, off-white,
  дугуйрсан товч/талбар, том touch target, монгол microcopy.
- “Сайн уу? 👋” → нэр → хувийн мэндчилгээ → заавал эхний данс →
  “Бэлэн боллоо…” → Home. Нэр/дансны хоосон оролт, бутархай, буруу дүн, overflow-г хориглоно.
- Эхний данс үндсэн данс болно. 0 болон сөрөг үлдэгдэл зөвшөөрнө.
  Хүрээ: −999,999,999,999–999,999,999,999₮. Бүх тооцоо/хадгалалт integer;
  хөрвүүлэхээс өмнө BigInt-аар хязгаар шалгана. Тоймлох/таслахгүй.
- Алхам, нэр, дутуу дансны нэр/дүн local SQLite-д дарааллаар хадгалагдана.
  Restart үед хамгийн сүүлд commit болсон checkpoint сэргээнэ.
- Данс үүсгэх/үндсэн данс тогтоох/дараагийн алхамд шилжих нь нэг transaction.
  Completion нь хүчинтэй дансгүйгээр хадгалагдахгүй. Давхар tap/retry нэг данс үүсгэнэ.
  DB нээхэд алдаа гарвал хуучин мэдээллийг reset хийхгүй.
- Home: том +/−, үндсэн данс, бодит эхний үлдэгдэл. +/− дээр боломж хараахан
  нээгдээгүйг тайлбарлана; гүйлгээ үүсгэхгүй.

## Гол файлууд

- `lib/app.dart`, `lib/main.dart`: theme, app bootstrap.
- `lib/core/domain/money.dart`: UI/DB-ээс үл хамаарах validation ба MNT formatting.
- `lib/features/onboarding/{application,data,presentation}`: controller, schema,
  generated Drift code, transaction, draft checkpoint, onboarding UI.
- `lib/features/home/presentation/home_screen.dart`: хөнгөн Home.
- `assets/fonts`: Comfortaa ба эх лиценз.
- `android`: native scaffold, app label/icon, offline privacy тохиргоо.
- `test`: domain, persistence, rollback, retry, widget, responsive/accessibility tests.
- `integration_test/stage1_test.dart`: тусгаарласан synthetic DB-тэй Android flow.
- `pubspec.yaml`, `pubspec.lock`, `.flutter-version`: тогтоосон SDK/хамаарлууд.
- `README.md`, `HADGALY_PROJECT_CONTEXT.md`: ажиллуулах заавар ба шинэ directive төлөв.

## Бодитоор ажиллуулсан шалгалтууд

| Команд / шалгалт | Үр дүн |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | **36 passed** |
| `flutter test integration_test/stage1_test.dart -d emulator-5554` | **1 passed** |
| `flutter build apk --debug` | APK амжилттай бүтээгдсэн |
| `flutter run -d emulator-5554 --debug` | Install/run, OpenGLES Impeller, debug service ажилласан |
| `dart format --output=none --set-exit-if-changed lib test integration_test` | Өөрчлөлтгүй |
| `git diff --cached --check` | Whitespace алдаагүй |

Unit/widget coverage: fresh onboarding, whitespace/empty names, required account name,
zero/positive/negative дүн, invalid input/overflow, back/system-back, дутуу input,
SQLite file close/reopen, default account, duplicate submission, injected DB failure rollback,
accountгүй completion хориглох, foreign key, invalid saved-state handling, жижиг дэлгэц,
1.8× text, keyboard inset, touch-target/label/contrast guidelines.

Android integration: “Өнөр”, “Миний хэтэвч”, `-25000` synthetic өгөгдлөөр full flow;
дутуу `-` оролт болон completed Home-ийг SQLite хааж/нээхэд сэргээсэн.
Нэг л данс үүсэж, unavailable-action feedback зөв гарсан.

Native шалгалт: `adb shell wm size 720x1280`, `wm density 360` буюу **320dp** өргөн;
жинхэнэ keyboard дээр нэр, дансны нэр, signed numeric input харагдаж/scroll хийгдсэн.
`dumpsys input_method`: input shown. `am force-stop` → `am start -W` **COLD** launch;
нэр болон дансны дутуу оролт, сөрөг balance draft UI hierarchy-д хэвээр байсан.
Дараа нь дэлгэцийн size/density-г reset хийсэн. Туршилтын main-app оролтыг UI-ээр
цэвэрлэж, хоосон welcome дээр үлдээсэн; main app-д данс үүсгээгүй. AVD data wipe хийгээгүй.

## Android demo ба founder шалгах урсгал

Emulator: `Medium_Phone_API_37.0`, `emulator-5554`, Android 17 / API 37.
Бүрэн PowerShell заавар README-д бий. Repository root-оос:

```powershell
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
flutter pub get
flutter run -d emulator-5554
```

1. Монгол нэр оруулах; хоосон/space-only оролтын алдааг харах.
2. Хувийн мэндчилгээ, буцах үйлдлээр оруулсан нэр хадгалагдахыг шалгах.
3. Дансны нэр болон бүхэл төгрөгийн үлдэгдэл; 0/сөрөг утга, бутархай/хязгаараас давсан утгыг турших.
4. Данс үүсгэхээс өмнө аппыг хааж дахин нээх; дутуу оролт сэргэсэн эсэхийг шалгах.
5. Дансаа үүсгээд completion → Home; үндсэн данс/үлдэгдэл зөв эсэх.
6. Home-оос аппыг хааж дахин нээх; дараа нь + болон −-ийн тайлбарыг шалгах.
7. Copy, Comfortaa уншигдах байдал, spacing, keyboard, том текст, урсгалын таатай байдлыг үнэлэх.

## Хязгаар ба үлдсэн зүйл

- **Founder-ийн интерактив UX/copy/design зөвшөөрөл үлдсэн.** Баталгаажих хүртэл Stage 1 accepted биш.
- Тогтмол hardware renderer NVIDIA `nvoglv64.dll` дээр унасан; анхны `-gpu software` горим
  удаан ажиллахад гацсан. README-ийн SwiftShader/Vulkan-disabled/4-core командтай
  build/run, integration, native keyboard/restart шалгалтууд амжилттай. AVD-ийн байнгын
  тохиргоог өөрчлөөгүй; цааш асаахдаа туршсан командыг хэрэглэнэ.
- Шинэ SDK CLI-ийн sdkmanager wrapper NDK package нэрийг буруу задалсан.
  Албан ёсны `android sdk install ndk/28.2.13676358` командаар шийдсэн.
- Энэ нь Android debug validation; release signing/distribution болон бусад OS-ийн
  бүтээгдэхүүний дэмжлэгийг баталсан гэсэн үг биш.
- Stage 2+ дансны удирдлага, adjustment, гүйлгээ, тайлан, backup/restore хэрэгжээгүй.
  Android automatic backup-г Stage 6 дизайн хүртэл хаасан.
- Comfortaa-ийн бүх шаардлагатай glyph байна; TalkBack-ийн хүнээр хийсэн бүрэн
  үнэлгээ болон founder-ийн харааны хүртээмжийн review хараахан хийгдээгүй.
- Мэдэгдсэн шийдээгүй мөнгөн дүнгийн эсвэл өгөгдөл алдах critical defect илрээгүй.
  Энэ нь алдаагүй гэсэн абсолют баталгаа биш.

Дараагийн ажил: founder review-ийн засваруудыг Stage 1 хүрээнд хийх, эсвэл илэрхий
Stage 1 acceptance хүлээн авах. Тусдаа зөвшөөрөлгүйгээр Stage 2 эхлүүлэхгүй.

## Stage 1 UI өнгөлгөө — founder feedback

- Home мэндчилгээ 30 → 24, weight 600; урт нэрийг таслахгүйгээр мөр шилжүүлнэ.
- “Үндсэн данс” label #53655B → #40584D, 12 → 13; цагаан карт дээрх
  sRGB relative-luminance контраст **6.21:1 → 7.72:1**.
- Тайлбарын өнгийг #243E35 гэж ил тод тогтоосон; #FAF9F4 дэвсгэр дээр **10.97:1**.
- “Одоогийн үлдэгдэл” давхардсан мөрийг хасаж, padding 24 → 20, дотоод зайг багасгасан.
- Доод хэсэгт шинэ feature/card нэмээгүй. “Миний данс” навигац Stage 2-ийн
  дансны удирдлагын хүрээнд шийдэгдэнэ; одоо ажиллагаагүй холбоос оруулаагүй.
- Одоо байгаа responsive/accessibility тестийг урт монгол нэр, урт дансны нэр,
  хамгийн их сөрөг үлдэгдэлтэй болгож өргөтгөсөн (320×568, 1.8× text).
- Шинээр ажиллуулсан: analyze clean; **36 tests pass**; Android debug build/run амжилттай.
  Emulator дээр хадгалсан бодит profile/account-ийг өөрчлөхгүйгээр шинэ Home-ийг нээж,
  харагдацыг шалгасан. Энэ өнгөлгөөнд Android integration suite-г дахин ажиллуулаагүй.
- Stage 1-ийн нийт acceptance болон дараагийн шатны зөвшөөрөл хүлээгдсэн хэвээр.
