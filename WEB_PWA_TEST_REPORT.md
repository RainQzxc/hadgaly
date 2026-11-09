# Hadgaly Web/PWA шалгалтын тайлан

2026-11-09, Windows, Flutter 3.47.9 / Dart 3.13.7, Node.js 25.2.1. Бүх туршилт синтетик өгөгдөл, тусгаарласан browser context эсвэл Android sandbox ашигласан.

| Шалгалт | Үр дүн |
| --- | --- |
| Dart format / Flutter analyze | 78 файл, формат өөрчлөлтгүй. Analyzer алдаагүй. |
| Flutter unit / widget | 148 тэнцсэн. Ledger, тайлан, миграци, Android backup contract ба дэлгэцийн регрессүүд. |
| Android sandbox | Stage 1–5 ба migration, 6 target-д 10 тохиолдол тэнцсэн. Тусдаа хоёр чиглэлийн backup bridge мөн тэнцсэн. |
| Chrome, Edge | Desktop browser automation. Chrome-д 6, Edge-д 3 тохиолдол. |
| Pixel 7 Chromium, iPhone 13 WebKit | Тус бүр 3 тохиолдол. Утасны viewport эмуляци. |
| HTTPS loopback | Chrome, 2 тохиолдол, туршилтын self-signed сертификат. Нийтэд итгэмжлэгдсэн сертификат эсвэл Vercel deploy шалгаагүй. |
| Бодит iPhone Safari, суулгасан iPhone PWA, macOS Safari | Шалгаагүй. iPhone-оос нээгдэх HTTPS preview болон бодит төхөөрөмжийн шалгалт шаардлагатай. |

Playwright-ийн 24 тохиолдлоос Chrome-д нэг удаа гүйцэтгэх миграци, update/restart, ledger UI тестийг бусад гурван төсөлд алгассан (9). Веб release 508f7092a78627f3a86663e5 нь 39 офлайн файл, 25 MB орчим шахаагүй cache payload-тай.

## Баталгаажуулсан урсгалууд

- Browser onboarding 1,000 ₮-өөр эхэлсэн. Орлого 230 ₮, зарлага 55 ₮-ийн дараа Home 1,175 ₮, donut 55 ₮ зарлага, тайлан 175 ₮ цэвэр урсгал, хоол 55 ₮ / 100.0% гэж үзүүлсэн.
- Ижил origin-ийн хоёр дахь таб бичих эрхгүй. Offline cache-д shell, Flutter JS, SQLite WASM, Drift worker байсан. Сүлжээг салгаж deep link-ээс дахин нээгээд 25 ₮ орлого нэмсэн. Онлайн болоод дахин нээхэд 1,200 ₮ ба гурван гүйлгээ хэвээр.
- Нөөц экспортолсны дараа 80 ₮ зарлага нэмж 1,120 ₮ болсон. Эвдэрсэн файл, цуцалсан сэргээх, IndexedDB pointer commit тасалдсан сэргээх нь 1,120 ₮-ийг хадгалсан. Баталгаажуулж сэргээсний дараа 1,200 ₮ болсон. Өмнөх нөөцийг татаж буцаан сэргээхэд 1,120 ₮ хэвээр гарсан. Сэргээх үед navigation түгжээтэй.
- Chrome дээр хоёр дахь данс үүсгэж үндсэн болгосон. 500 → 450 ₮ anchor засвар аудитад үлдсэн. Зарлага 55 → 60 ₮ болж, устгасны дараа 1,450 ₮ эргэж гарсан. SQLite экспортод анхдагч данс, засвар болон устгалын revision-ийг тулгасан.
- Chrome дээр IndexedDB-д хадгалсан v3 fixture бодит веб executor-оор v4 болсон. Өмнөх данс, гүйлгээ, тохируулга, аудитын мөрүүд таарсан. Chrome DevTools installability алдаагүй. Хүлээж буй shell update, браузерыг бүрэн хааж дахин нээх, офлайн ачаалсны дараа 1,007 ₮ хэвээр.
- 320px / 180% текст ба хөдөлгөөн багасгах тохиргоотой onboarding, Home, Settings шалгасан. 320px Android эмуляцид координатаар submit дарах автомат шалгалт тогтворгүй байсан. Томруулсан layout-ийг Enter-ээр илгээх замаар дөрвөн тохиргоонд нийт 12 удаа давтан шалгасан. Бодит iPhone keyboard, VoiceOver, суулгах UI ба Files тусдаа шалгалт хүлээнэ.
- Android → Web → Android backup. Browser хоёр дахь данс default, 950 ₮ болон −525 ₮, нийт 425 ₮, архивласан ангилал, 50 ₮-ийн устгасан гүйлгээний revision, 900 → 950 ₮ audit бүхий нөөцийг сэргээсэн. Browser экспортын хүснэгтүүд ба SQLite sequence мөр бүрийг эх Android нөөцтэй тулгасан. Android sandbox буцаж сэргээхдээ ижил дүн, аудит, revision, өмнөх rollback санг баталгаажуулсан.

Android guard нь `emulator-5556`, `Hadgaly_Stage2_Disposable`, APK `mn.hadgaly.hadgaly.sandbox`-ийг суулгахаас өмнө шалгасан. Production package sandbox төхөөрөмжид байхгүй байсан, бусад package жагсаалт өөрчлөгдөөгүй. Founder-ийн төхөөрөмж эсвэл өгөгдөл ашиглаагүй. Локал evidence `build/android-safety/20261109-151526`, `build/android-safety/20261109-151941`, `build/browser-review`, `build/browser-review-https`.

## Дахин ажиллуулах

```powershell
$env:Path = "C:\dev\flutter\bin;$env:Path"
$env:FLUTTER_ROOT = 'C:\dev\flutter'
npm ci
npx playwright install chromium webkit
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
npm run build:web

# Зөвхөн ажиллаж буй Hadgaly_Stage2_Disposable AVD, emulator-5556.
./tool/run_android_checks.ps1
./tool/run_android_checks.ps1 -Tests web_backup_bridge_test
$env:HADGALY_ANDROID_FIXTURE = (Get-ChildItem build/android-safety -Recurse -Filter android-synthetic.hadgaly |
  Sort-Object LastWriteTime | Select-Object -Last 1).FullName
npm run test:web -- --workers=2 --reporter=line --output=build/browser-review
$browserFixture = (Get-ChildItem build/browser-review -Recurse -Filter browser-rich.hadgaly |
  Where-Object DirectoryName -match 'chrome$' | Select-Object -First 1).FullName
./tool/run_android_checks.ps1 -Tests web_backup_bridge_test -BrowserBackup $browserFixture
```

Playwright Chrome болон Edge-ийг Windows-ийн суулгасан хувилбараар нээнэ. HTTPS loopback-д SAN `IP:127.0.0.1`-тай туршилтын сертификат, түлхүүрийн замыг `HADGALY_TEST_TLS_CERT` / `HADGALY_TEST_TLS_KEY`-д өгч `HADGALY_WEB_PORT=4443`-өөр `node tool/serve-web.mjs` ажиллуулна. Тусдаа PowerShell-д `HADGALY_TEST_ORIGIN=https://127.0.0.1:4443`, `HADGALY_TEST_SELF_SIGNED=1` тохируулаад доорх командыг ажиллуулна. Түлхүүрийг Git-д нэмэхгүй.

```powershell
npm run test:web -- --project=chrome --grep 'offline shell|web edits' --reporter=line --output=build/browser-review-https
```

## Харах материал

Синтетик өгөгдөлтэй [Home](docs/review/web-pwa-home.png), [цэс](docs/review/web-pwa-drawer.png), [тайлан](docs/review/web-pwa-report.png), [Тохиргоо](docs/review/web-pwa-settings.png), [сэргээх preview](docs/review/web-pwa-restore.png), [320px / 180%](docs/review/web-pwa-settings-320-180.png).

Git diff-ийн мөрийн тоо. Аппын Dart +819/−174 (хуваалцсан нөөцийн шалгалтыг зөөсөн мөрүүд орно), тест +550, tooling +230/−3. Vendored Drift worker, лиценз, зураг, binary, build output тоонд ороогүй.
