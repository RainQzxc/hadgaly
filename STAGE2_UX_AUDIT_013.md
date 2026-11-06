# Hadgaly — CEO #013 UX audit / REVIEW DRAFT

Дараагийн founder steering нь зөвхөн Home-first proportions/spacing pass-ийг зөвшөөрсөн.
STAGE2_HOME_PROPORTIONS_REVIEW.md-г үзнэ үү. Бусад дэлгэц/nav/shared design саналууд pending хэвээр;
энэ audit бүхэлдээ implementation approval болсон гэж үзэхгүй.

2026-11-03, Asia/Ulaanbaatar. **Зөвхөн audit; implementation эхлээгүй.**
Baseline: `6ea8e6c2405f211290bb29a74733ccc1a648387d`, `codex/stage-2-accounts`.
Stage 2 NOT approved. Доорх хэмжээс, шийдлүүд нь батлуулах санал; батлагдсан шинэ tokens биш.

## 1. Судалгааны хүрээ, нотолгоо

Flutter-ийн Home, product shell, account list/detail/default sheet, account/adjustment form,
shared navigation/field/button болон typography tokens-ийг уншсан.
Үндсэн emulator-5554 дээр одоогийн аппын дэлгэцүүдийг шинээр авч үзсэн:

| Reference | Одоогийн Android screenshot |
|---|---|
| A1 Finance | `build/design-audit-013/01-finance.png` |
| A2 Coming soon | `build/design-audit-013/02-coming-soon.png` |
| A3 My Accounts | `build/design-audit-013/03-accounts.png` |
| A4 Default account sheet | `build/design-audit-013/04-default-sheet.png` |
| A5 Account creation | `build/design-audit-013/05-create-account.png` |
| A6 Account detail/history | `build/design-audit-013/06-account-detail.png` |
| A7 Balance adjustment form | `build/design-audit-013/07-adjustment-form.png` |

Device: 1080×2400 px, density 420; ойролцоогоор **411×914 logical dp**. Screenshot дахь px-ийг
шууд Flutter dp гэж үзээгүй. Доорх хэмжээсүүдийг widget source-оос авсан.
Screenshot-ууд founder-ийн бодит өгөгдөлтэй тул local/Git-ignored; external skill/service рүү илгээгээгүй.

Зөвхөн navigation хийсэн, form submit/default selection/save хийгээгүй. Дараа нь Finance руу буцаасан.
Current production-ийн бүх profile/account/adjustment/audit мөр болон schema-ийн before/after
fingerprint таарсан. Financial/persistence source hashes хэвээр. Application code, database,
schema/migration, emulator settings болон installed packages өөрчлөгдөөгүй.

320dp/1.8× үед шинэ native visual capture энэ audit-д хийгээгүй. Өмнөх 84 тестийн нотолгоо болон
одоогийн large-text widget tests-ийг уншсан; тэдгээрийг энэ удаа дахин ажиллуулсан гэж тайлагнахгүй.
Onboarding болон edit-audit-ийн бүх төлөвийг шинэ native screenshot-аар үзсэн гэж үзэхгүй;
тэдгээрийн доорх саналыг shared component/source inspection дээр үндэслэв.

## 2. Design skills — эх сурвалж, лиценз, нийцэл

**Суулгах шаардлагагүй.** Нийтлэг skill directory, package manager, Flutter dependencies өөрчлөхгүй.
Pin хийсэн заавар/өгөгдлийг уншиж ашигласан; гуравдагч талын script огт ажиллуулаагүй.

### UI UX Pro Max — үндсэн mobile/Flutter guidance

- Repository: https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- Pin: **713eef51b04efc98d6fa565323b495f7c9c89fd4**; root LICENSE: **MIT**.
- Уншсан: `.claude/skills/ui-ux-pro-max/SKILL.md`, native pro-rules, Flutter CSV,
  UX rules; search/core/design-system/reasoning/validation entrypoints болон CLI package/build/launcher metadata.
- Flutter CSV нь 52 заавартай, `flutter 3.44.x`, 2026-08-13 verification гэж тэмдэглэсэн.
  Hadgaly **3.47.9** тул үүнийг dependency/API compatibility баталгаа гэж үзэхгүй.
- Шууд хамаарах нь LayoutBuilder, TextScaler, Semantics, PopScope, 48dp Android target,
  safe area, keyboard clearance, жигд spacing/visible form labels. Одоогийн primitive-үүдийг хадгална.
- CSV дахь GoRouter/Material-oriented зөвлөгөөг дагаж routing rewrite/UI kit нэмэхгүй.
- Reviewed Python search path нь standard-library/local modules; design-system persistence mode
  файл бичдэг. CLI v2.5.0 нь chalk/commander/ora/prompts, dev талд Bun/TypeScript/Playwright-тай.
  Энэ audit-д Python search/generator/CLI-г ажиллуулах, npm install хийх хэрэггүй.

### Taste Skill — зөвхөн visual critique

- Repository: https://github.com/Leonxlnx/taste-skill
- Pin: **12af471f627f866411b4bd785b19646d3672784c**; root LICENSE: **MIT**.
- Уншсан: `skills/taste-skill/SKILL.md`, app-screen/type/layout/color/critique-ийн хамаарах хэсгүүд;
  draw/inspect/lint/scenes/assets entrypoints болон local helper imports/effects.
- Node 22+ ба Chrome/Edge/Chromium-д чиглэсэн DOM/CSS/CDP inspector; native Flutter render tree-г
  хэмжих tool биш. Draw нь direction/history файл бичдэг; inspector нь browser/process/local server,
  screenshot output/cleanup ашигладаг; asset helper external network/download хийдэг. Ажиллуулаагүй.
- Ашигласан нь: screenshot-оор hierarchy шалгах, нэг visual focus, жингийн ялгаа, edge alignment,
  purpose-driven whitespace, truthful empty state. Эдгээр нь Hadgaly-д хийсэн инженер/design дүгнэлт.
- Desktop study-ийн chart/button хэмжээ, random direction, web typography ratios, required motion,
  photo/marketing patterns-ийг Flutter mobile руу хуулж хэрэглэхгүй. Navy/rounded/donut/дөрвөн tab
  нь founder-ийн шийдвэр тул skill-ийн house-style-оор сольж болохгүй.

Downloaded review copy, licenses, exact file SHA-256 manifests:
`build/design-audit-013/{ui-ux-pro-max-skill,taste-skill}/reviewed-files.json`.
Энэ нь ашиглах хэсгийн source/dependency review; бүх repo/transitive dependencies-ийн security certification биш.
Суулгах эсвэл scripts ажиллуулах шаардлага дараа гарвал тэр execution path-ийг тусад нь дахин хянана.

## 3. Эрэмбэлсэн бодит асуудал ба засах санал

### P1 — эхэлж засах

**1. Default сонголтын тайлбар санхүүгийн Home-той зөрж байна.**

A4 болон `accounts_screen.dart:26`: “Нүүрэнд харагдах дансаа сонгоорой.” гэж байна.
Home одоо default account биш бүх дансны нийт үлдэгдэл харуулдаг. Хэрэглэгч default солиход Home
дээрх дүн өөрчлөгдөнө гэж хүлээж болзошгүй. **“Үндсэн дансаа сонгоорой.”** гэж богиносгоно.
Default selection, query, balance calculation огт өөрчлөхгүй.

**2. Finance-ийн хоосон donut бодит мэдээллээс хэт их талбай авдаг.**

A1; `home_screen.dart:70`: diameter `min(width−40, 340)`, ring 14dp. Өгөгдөлгүй тойргийн
том хоосон төв нь balance болон action block-оос илүү давамгай. Энэ нь “calm” бус,
хэт сунгасан empty dashboard мэт харагдуулж байна. `spaceBetween` нь өндөр дэлгэц дээр зайг улам сунгана.

Санал: ердийн текст дээр **252–264dp** төв donut, **10–12dp** ring; chart block-ийн дээд/доод gap
16–24dp. Олон дурын flex gap бус, нягт төв бүлэг + доод action block хэрэглэнэ. Donut, доторх
income/expense, доорх total, expense-left/income-right гэсэн дараалал хэвээр.
1.8× үед diameter/content height өсгөж, хэрэгтэй бол scroll хийнэ; label-ийг shrink/clamp/clip хийхгүй.
Хоосон тойргийг өнгөт хэсгээр бөглөхгүй, proportions эсвэл sample activity үүсгэхгүй.

**3. Текстийн жин бараг бүх түвшинд ижил хүчтэй байна.**

A1/A5/A7; shared heading 28/700, section 17/700, Home total 20/700, action 17/700;
form дээр navigation title + дахин том body title байна. Энэ олон bold block нь жижиг нэр/label,
гол мөнгөн дүн хоёрын hierarchy-г бүдгэрүүлнэ. Кирилл нь Noto Sans, цифр/Latin нь Google Sans Flex
тул ижил 700 жинтэй үед mixed-script contrast илүү анзаарагдана. Glyph эвдэрсэн/tofu байгааг ажиглаагүй.

Санал: screen title **22/600**, body **16/400**, control **16/600**, section **16–17/600**,
metadata **13/400**. Home-ийн “Нийт үлдэгдэл” label 13–14/500, amount **28–30/600** тусдаа мөрөөр.
Greeting 16–17/500, brand/navigation title 17/600. Google Sans Flex + шаардлагатай Noto fallback хэвээр.
Хоёр font хоёулаа `tnum` дэмждэгийг font table-оос шалгасан; мөнгөн дүнгийн list-д tabular figures ашиглана.

### P2 — visual polish болон screen economy

**4. Home actions ба bottom selection хоёул хэт “хүнд”.**

A1; Home button minimum 80dp, бүтэн teal/rose fill; `_ModuleBar` selected icon-д midnight capsule,
label 700. Ингэснээр доод хэсэгт гурван өөр хүчтэй accent зэрэг үүснэ. Unavailable Stage 3 actions
маш идэвхтэй completed feature шиг харагдана; одоогийн tap feedback нь үнэн боловч дараа нь л гардаг.

Санал: Home actions **64–72dp**, radius 18–20dp, ижил хэмжээтэй; pale teal/pale rose surface,
navy label, +/− sign хэвээр. Brand teal/expense swatch-ийг semantic accent-д хадгална.
“Бүртгэл удахгүй нээгдэнэ.” гэсэн нэг quiet caption, одоогийн honest tap response-ийг хадгална.
Bottom selected background-ийг зөөлрүүлж, icon 22dp, selected label 600 болгоно; дөрвөн нэр хэвээр.
Tap target-ийг жижгэрүүлэхгүй. 1.8× үед tab label хоёр мөрийн талбай болон tap area-г жигд өсгөнө.

**5. Screen-үүдийн margin, radius, density нэг системд хараахан ороогүй.**

Home gutter 20dp; `PageContent` 24dp; card padding 22dp; list 18dp; radii 18/22/24dp.
A3 default summary өндөр, дараа нь ижил дансны нэр/дүн дахин жагсаалтад давтагдана.
Default summary нь scope-ийн шаардлага тул авч хаяхгүй; харин 16–20dp padding,
24–26/600 balance, 8dp дотоод gap, compact “Солих” action-тай болгоно.
20dp screen gutter, 16dp grouped inset, 8/12/16/24/32 rhythm хэрэглэнэ.
Account list дээр нэр 16/500–600, дүн 18–20/500, default note 13dp; эхний дансны мөрийг дээш татна.

**6. Form-уудын давхар гарчиг ба урт gap keyboard-тэй үед зай иднэ.**

A5: navigation “Данс нэмэх” + 28dp “Шинэ данс”; A7: “Тохируулах” + том “Үлдэгдэл тохируулах”.
Олон 24/28dp gap, ~60dp field зэрэгцэн form-ийг уртасгана. Mobile дээр гарчгийг нэг түвшинд
шийдэж, body title-г хэрэгтэй бол 22/600 болгоно; description→field 16–20dp, field хооронд 16dp,
input 52–56dp minimum ба scalable padding. Labels, required opening balance, zero/negative hint,
inline error, keyboard scrolling хэвээр. Placeholder `0` нь хадгалагдсан default утга биш гэдгийг
hint-ээр тодруулна; controller/value/validation-ийг өөрчлөхгүй.

**7. Audit history-д key amount, тайлбар, edit action нэгэн зэрэг анхаарал татаж байна.**

A6: target 24/700, хоёр урт difference sentence, том text action. Өнгө/том хэмжээ нэмэхийн оронд
target 22/600 + date 13, доор хоёр тусдаа label/value row (14–15dp), edit action 15/600 болгоно.
Нарийсах/том текст үед label дээр, value доор stack хийнэ; truncated money хэрэглэхгүй.
Анх ажигласан vs дахин тооцсон ялгаа, effective time, old→new/edit time бүгд харагдана.
Collapse/hidden history, deletion, шинэ audit semantics санал болгохгүй.

### P3 — дараагийн polish pass

**8. Coming-soon дэлгэцийн нэр, icon, 28dp bold message хоорондоо давхардсан.**

A2: маш их хоосон зай дунд том generic message. Fake content нэмэхгүй. Icon 28–32dp,
“Тун удахгүй” 20–22/600, нэг богино supporting sentence: “Энэ хэсгийг бэлдэж байна.”
Санхүү tab өөрөө харагдаж байгаа тул дахин урт finance prompt шаардлагагүй.
Нягт нэг empty-state бүлгийг usable area-ийн төвд байрлуулна; энэ зайг card/animation-аар дүүргэхгүй.

## 4. Товч visual specification — БАТЛУУЛАХ САНАЛ

| Role | Санал |
|---|---|
| Personality | Calm · Premium · Minimal · Friendly · Effortless |
| Palette | #F5F6F8 surfaces; #14243E ink/primary; #39B5AA small accent; #D66B72 semantic expense |
| 60/30/10 | Neutral давамгай; navy hierarchy/controls; accent цөөн зориудын цэгт. Pixel quota эсвэл dark theme биш |
| Typography | Google Sans Flex + Noto Sans missing-glyph fallback; 400/500/600; 700 ховор |
| Type scale | 13 metadata, 14 label, 16 body/control, 17 nav, 22 screen/section lead, 28–30 key money |
| Leading | Body 1.4–1.5; heading/amount 1.2–1.3; clippingгүй actual-font measurement |
| Grid | 4dp unit; 8/12/16/24/32 gaps; 20dp screen gutter; group inset 16dp |
| Shapes | Fields/buttons 16–20dp; grouped surfaces 20dp; subtle borders; resting shadowгүй |
| Touch | Android ≥48×48dp; ordinary controls 52–56dp, Home actions 64–72dp; large text үед өснө |
| Navigation | Дөрвөн tab, Finance initially selected; бар/keyboard/Back-ийн одоогийн behavior хадгална |
| Money | Signs/₮ үргэлж; ижил өргөнтэй tabular digits; ellipsis, rounding, шинэ math байхгүй |
| Empty states | Zero нь zero; саарал ring; богино copy; fake category, sample balance байхгүй |
| Motion | Зөвхөн одоогийн native press/page feedback; reduced motion; шинэ choreographed animationгүй |
| Accessibility | Small text ≥4.5:1, focus/labels/semantic order, 320dp/1.8×, keyboard ба safe area |

Санал болгосон numeric size бүрийг approval-ийн дараа actual font + Android render дээр батална.
Layout нь text scale-ийг даган тэлнэ; fixed-height clipping эсвэл font scale cap ашиглахгүй.

## 5. Өөрчлөх screens/components — approval-ийн дараа

1. `design_tokens.dart`, `app.dart`: typography roles; existing palette/fallback unchanged.
2. `home_screen.dart`: donut sizing/rhythm, greeting/total hierarchy, action proportions/feedback copy.
3. `product_shell.dart`: quieter selected treatment, equal-height scalable tab targets, compact placeholder.
4. `hadgaly_ui.dart`: unified gutter/radii/field spacing; 48dp back target, native transitions хэвээр.
5. `accounts_screen.dart`: compact default summary/list/audit, truthful default sheet copy.
6. `account_forms.dart`, onboarding presentation: shared typography/rhythm; onboarding flow/copy decisions хадгална.

Domain/application/repository/database/generated schema/migration scope-д орохгүй.
Нэмэлт UI kit, navigation destination, module model, transaction entry эсвэл Stage 5 report нэмэхгүй.

## 6. Founder/CEO review-д шийдэх хоёр зүйл

**A — Home-ийн compact hierarchy:** төв donut-ийг ердийн текст дээр 252–264dp болгох,
“Нийт үлдэгдэл” label ба amount-ийг хоёр мөр болгон мөнгөн дүнг гол болгохыг зөвлөж байна.
Энэ нь мэдээллийн баталсан дарааллыг хадгална. Бүтэн шинэ dashboard composition санал болгоогүй.

**B — Actions-ийн tone:** ижил хэмжээтэй pale teal/pale rose хоёр button + navy label,
quiet selected-tab treatment-ийг зөвлөж байна. Navy-filled income / pale expense гэх asymmetric
variant нь income-ийг илүү чухал мэт болгох тул энэ audit-ийн recommended direction биш.

Font солих, шинэ navigation, data semantics өөрчлөх нэмэлт шийдвэр шаардахгүй.
Дээрх A/B болон audit-ийг review хийсний дараах CEO/founder authorization хүртэл implementation зогсоно.
Энэ gate нь CEO #013-ийн шууд шаардлага; skill installation эсвэл tool approval-оос үүссэн blocker биш.

## 7. Approval-ийн дараах verification төлөвлөгөө

- Өөрчлөхөөс өмнөх screenshot-уудтай ижил data/device дээр before/after харьцуулах.
- 320dp болон ~390–411dp, 1.0×/1.8× actual fonts, long Mongolian names, max/negative balances,
  keyboard/safe areas, four tabs/Back, default picker болон adjustment/audit readability шалгах.
- Formatting, analyze, full financial/persistence/widget regressions; UI assertions шинэчилнэ,
  financial assertions сулруулахгүй. Disposable/synthetic sandbox APK ID installation-ээс өмнө шалгана.
- Main app-д зөвхөн verified identity + data-preserving update; өгөгдлийн before/after fingerprints.
- Шинэ commit SHA + live Android demo + founder-ийн explicit acceptance. Stage 3 эхлэхгүй.

**Энэ audit өөрөө UI implementation эсвэл Stage 2 acceptance биш.**
