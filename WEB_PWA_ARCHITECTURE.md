# Hadgaly Web/PWA архитектур

CEO #029-ийн веб салбар `codex/web-pwa`. Android Finance MVP-ийн батлагдсан Stage 6 суурь `4e7077f14caa4305b7c6a48352b8bd29f8b260b2`, түүнээс хойших Stage 6 салбарын `c721fe3` түүхийг хадгалсан. Веб хувилбар тусдаа founder review хүлээж байна.

## Апп ба хадгалалт

- Flutter 3.47.9, Dart 3.13.7, Riverpod, Drift 2.35.3, sqlite3.dart 3.5.2. Одоо байгаа Flutter дэлгэц, навигац, санхүүгийн repository, ledger, бүхэл MNT, SQLite schema v4 болон migration-ийг ашиглана.
- Conditional adapter нь Android дээр одоо байгаа SQLite болон файлын үйлдлийг ашиглана. Веб дээр dedicated Drift worker, SQLite WASM, IndexedDB ашиглана. Веб сан болон Android сан тусдаа.
- Ижил origin дээр санхүүгийн санг нээсэн цонх Web Lock-ийг барина. Давхар таб нээгдэхэд эхний табыг хааж дахин ачаалах Монгол заавар гарна. Шаардлагатай storage API ажиллахгүй эсвэл идэвхтэй сан олдохгүй бол апп алдаа харуулна. Түр сан руу шилжих, хоосон сангаар дарах зам байхгүй.
- Хадгалалтыг хамгаалах хүсэлт браузерт илгээнэ. Зөвшөөрөлгүй үед Settings тайлбар харуулна. Браузерын профайл, origin, төхөөрөмжийн хадгалалт тус бүрдээ бие даана. Сайтын өгөгдлийг арилгах эсвэл браузер зай чөлөөлөхөд мэдээлэл алдагдаж болно.
- Finance-ийн дэлгэцүүдийг дахин загварчлаагүй. Safe area, браузерын томруулсан текст, хөдөлгөөн багасгах тохиргоо, вебийн accessibility semantics-ийг платформын adapter зохицуулна.

## Offline ба хувилбар шинэчлэх

`tool/build-web.mjs` нь Flutter framework revision болон WASM/worker SHA-256-г тулгаад build гаргана. `tool/pwa-sw.js`-аас үүсэх service worker shell, дүрс, фонт, CanvasKit, SQLite WASM ба worker-ийн файлуудыг release тус бүрээр ачаалж, hash таарсны дараа cache бэлэн болно. Хуучин табууд хаагдсаны дараа шинэ worker идэвхжинэ. Service worker зөвхөн shell cache удирдана. IndexedDB рүү хандахгүй.

Эхний онлайн ачаалал бүрэн дууссан үед офлайн эхлэлт боломжтой. Browser cache устсан бол дараагийн онлайн ачаалалт shell-ийг нөхнө. Санхүүгийн мөрүүдийг Vercel рүү илгээхгүй. Веб runtime нь шаардлагатай файлуудыг тухайн origin-оос авна.

## Пин ба лиценз

- Flutter framework revision `c197ca5199e9ee5661e865596c9c07294dfab51c`.
- [Drift 2.35.3 worker](https://github.com/simolus3/drift/releases/tag/drift-2.35.3) SHA-256 `a54b81412d4c4ab56653bb9e4c02912b0820bb37e2bba00722ddef4d78083d4a`.
- [sqlite3.dart 3.5.2 WASM](https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.5.2) SHA-256 `13d3f11d05b39ba0618a7115fb41640a5d48b6300f5d3f325f554b42bd6688a4`.
- `web` 1.1.2 нь өмнөх lockfile-д байсан, одоо шууд dependency. `@playwright/test` 1.65.0 зөвхөн тестийн dependency. Onboarding-ийн Noto Color Emoji болон тайлан, аудитын сумын Noto Sans Symbols дэд фонт, WASM/worker лицензүүд веб эхэд багтсан.
- Build нь Flutter-ийн өөрийн service worker-ийг унтраахад пинтэй SDK-ийн `--pwa-strategy=none` тохиргоог ашиглана. SDK шинэчлэх үед энэ тохиргоо болон cache/update тестийг хамт шалгана.
