# Hadgaly Web/PWA ажиллуулах, суулгах

## Windows дээр шалгах

Flutter 3.47.9, Git, Node.js 22.16+ болон npm хэрэгтэй. Репозиторийн үндсэн хавтсаас PowerShell 7 дээр ажиллуулна.

```powershell
git fetch origin
git switch codex/web-pwa
$env:FLUTTER_ROOT = 'C:\dev\flutter'
npm ci
npm run build:web
node tool/serve-web.mjs
```

Chrome эсвэл Edge дээр [локал демо](http://127.0.0.1:4173)-г нээнэ. `127.0.0.1` зөвхөн тухайн компьютероос нээгдэнэ. iPhone дээр туршихад утаснаас нээгдэх хүчинтэй HTTPS хаяг шаардлагатай.

## Clerk Development нэвтрэлт

Clerk Dashboard-ийн сонгосон аппын **Development → API Keys** хэсгээс `pk_test_` Publishable Key-г авна. PowerShell-ийн тухайн сессэд `$env:HADGALY_CLERK_PUBLISHABLE_KEY` болгож тохируулаад `npm run build:web` ажиллуулна. **Тохиргоо → Clerk бүртгэл** нь Clerk-ийн hosted нэвтрэх, бүртгүүлэх хуудсыг нээнэ. Түлхүүргүй build-д энэ үйлдэл харагдахгүй.

Нэвтрэлт онлайн шаарддаг. Санхүүгийн хэсэг браузерт офлайнаар ажиллана. Clerk session нь локал SQLite өгөгдөлд эрхийн түгжээ болохгүй. MongoDB болон үүлэн синк тусдаа ажил.

Vercel дээр **Settings → Environment Variables** хэсэгт `HADGALY_CLERK_PUBLISHABLE_KEY`-г **Preview** орчинд нэмээд дахин build хийнэ. Энэ туршилтын интеграц `pk_test_` түлхүүртэй. `CLERK_SECRET_KEY` эсвэл MongoDB нууц утгыг веб build-д өгөх хэрэггүй. [Vercel environment variables](https://vercel.com/docs/environment-variables)

## Vercel preview

Root directory нь репозиторийн үндэс, framework preset **Other**, Node.js **22.x** эсвэл **24.x**. `vercel.json` нь SDK-г пинтэй суулгах build, `build/web` гаралт, extensionless SPA fallback, WASM MIME, CSP болон service-worker header-ийг тодорхойлно. Зөвхөн `build/web` нийтлэгдэнэ. Үйлчилгээний нууц эсвэл санхүүгийн өгөгдлийн сан тохируулах хэрэггүй.

GitHub-тай холбосон deploy нь Git-д push хийсэн эх кодоос Vercel дээр шинээр build хийнэ. CLI-ээр локал эх код upload хийхэд `.vercelignore` нь өмнөх build, тестийн гаралт болон локал environment файлуудыг хасна. [Vercel-ийн үл хэрэгсэх файлын заавар](https://vercel.com/docs/deployments/vercel-ignore)

Hadgaly-д зориулсан одоо байгаа Vercel төсөл байхгүй. Шинэ төслийн эхний deployment production болдог тул энэ ажлын хүрээнд deployment хийгээгүй. Founder тусдаа зөвшөөрсөн production суурьтай зориулалтын төсөл бэлэн бол дараах командууд preview үүсгэнэ. CLI буцаасан HTTPS хаягийг ашиглана. [Vercel CLI](https://vercel.com/docs/cli/deploy#prod)

```powershell
vercel link --yes --project <хадгалъя-төслийн-нэр> --scope <зөв-баг>
vercel pull --yes --environment=preview
vercel build
vercel deploy --prebuilt
```

Төслийн Node.js тохиргоотой ижил runtime ашиглана. Preview дээр `/sw.js`, `/sqlite3.wasm`, deep link, офлайн дахин нээлт, нөөцийн экспорт/сэргээхийг синтетик өгөгдлөөр шалгана. Preview ба production-ийн hostname өөр бол browser storage тусдаа байна. Vercel Hobby нь хувийн, арилжааны бус хэрэглээнд зориулагдсан. [Vercel Hobby нөхцөл](https://vercel.com/docs/plans/hobby#hobby-billing-cycle)

## Суулгах

- **iPhone:** Safari-д HTTPS хаягаа нээгээд **Share → Add to Home Screen → Add**. Харагдвал **Open as Web App**-ийг идэвхжүүлнэ. Home Screen-ийн дүрсээр нээж onboarding эсвэл нөөц сэргээхээ үргэлжлүүлнэ. [Apple-ийн заавар](https://support.apple.com/guide/iphone/iphea86e5236/ios)
- **Android:** Chrome-д HTTPS хаягаа нээгээд **⋮ → Install and create shortcut → Install**. Аппыг шинэ дүрсээр нээнэ. [Chrome-ийн заавар](https://support.google.com/chrome/answer/9658361?co=GENIE.Platform%3DAndroid&hl=en)
- **Chrome, Edge:** Хаягийн мөрийн суулгах дүрс эсвэл браузерын цэсний **Install** үйлдэл ашиглана. Суулгах цэсний нэр браузераас хамаарч өөр байж болно.

Аппыг анх онлайнаар бүрэн нээнэ. Сүлжээг салгаж дахин нээгээд орлого, зарлага бүртгэхийг шалгана. Онлайн эргэж ороод дүн хэвээр байгааг тулгана. **Тохиргоо → Өгөгдөл нөөцлөх**-өөр Files-д нөөцлөөд туршилтын профайлд сэргээнэ. Утас эсвэл браузер хооронд өгөгдөл автоматаар шилжихгүй.
