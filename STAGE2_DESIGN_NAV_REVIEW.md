# CEO #011 — Stage 2 design system and product navigation review

2026-11-03, Asia/Ulaanbaatar. Base: `6dad151fddb716001496a4ceca158c3fe6b2e38c`.
Stage 1 accepted. **Stage 2 NOT approved**, awaiting founder acceptance. No Stage 3 implementation.
This document supersedes earlier typography/color/navigation descriptions, preserving finance behavior.

## Product scope and presentation

Hadgaly's future modular vision has four pillars: Хийх зүйл / Авах зүйл / Санаа / Санхүү.
Simple Yet Effective remains the philosophy. The current approved six-stage MVP roadmap remains
finance-only; future module implementation or roadmap expansion requires a separate product decision.

After mandatory onboarding, a persistent four-tab shell initially selects **Санхүү**.
The other tabs display only a clean “Тун удахгүй” message. There are no new task, shopping, idea,
note or navigation-selection database models, persistence, permissions or background work.

Finance keeps the approved Home: centered neutral expense-category ring; income +0 ₮ / expense −0 ₮
inside; combined **current** balance below; expense left / income right; My Accounts access above
the bottom bar. No default-account card, invented category proportions or transactions. Period totals
remain zero; openings and adjustment anchors belong only to account balances. Entry remains unavailable.

Routine navigation defaults:

- Tab selection is session UI state; a new launch selects Finance.
- Nested finance navigator retains its account/detail/form route while visiting placeholders.
  Unsaved forms remain in memory; switching tabs never saves a form.
- Android Back on a placeholder returns to Finance; within Finance it pops the local route first.
  Finance root retains the platform's normal root Back behavior.
- The bar remains on account/detail/form screens. While the keyboard is open it hides to preserve
  editing space, then returns. Shell owns bottom safe-area padding; labels scale/wrap without truncation.
- Tab changes add no animation. Existing page/action-sheet reduced-motion behavior is preserved.

## Typography provenance and glyph coverage

Official, unmodified variable TTFs downloaded from **google/fonts**, revision
`2fe1e8c6b137fb13041a7cfca6fdcd8a910ea4dc`:

- [Google Sans Flex](https://github.com/google/fonts/tree/2fe1e8c6b137fb13041a7cfca6fdcd8a910ea4dc/ofl/googlesansflex)
- [Noto Sans](https://github.com/google/fonts/tree/2fe1e8c6b137fb13041a7cfca6fdcd8a910ea4dc/ofl/notosans)

`assets/fonts/SOURCES.json` records original paths and SHA-256 hashes. Both SIL OFL notices are
bundled and registered with Flutter LicenseRegistry; Google Sans Flex's trademark notice is retained.
Comfortaa assets/references were replaced. No runtime font downloads or proprietary files.

Actual cmap inspection found **Google Sans Flex lacks Cyrillic and ₮**. It remains the primary family
for supported glyphs, including numbers. Bundled **Noto Sans** is the fallback only for missing glyphs;
it covers the full modern Mongolian Cyrillic alphabet, Ө/Ү/өү, digits, −/+ and ₮. No glyph fabrication,
font renaming or subsetting. `python tool/verify_fonts.py` (QA-only fontTools dependency) checks hashes
and coverage. New widget tests load the real fonts through FontLoader to check Mongolian/numeric layout.

## Central design tokens

`lib/core/presentation/design_tokens.dart` centralizes palette, typography and text styles:

| Role | Token |
|---|---|
| Neutral surfaces | #F5F6F8 |
| Midnight brand / primary / main text | #14243E |
| Soft teal accent / income button | #39B5AA |
| Expense button / semantic swatch | #D66B72 |
| Secondary text | #4D5C72 |
| Income text on light surfaces | #13756E |
| Error/expense text on light surfaces | #A13948 |
| Subtle separator | #DCE1E8 |

60/30/10 guides hierarchy/composition, not a literal measured pixel quota. Neutral surfaces dominate;
midnight anchors text/primary actions; teal marks selection and income. The app remains light.
Dark semantic text variants and midnight text on colored buttons pass 4.5:1 contrast checks.
Cupertino interactions, rounded frames, minimal borders and no decorative gradients/shadows remain.
No third-party UI kit or new Flutter dependency was added; pubspec.lock is unchanged.

## Files changed

- `lib/core/presentation/design_tokens.dart`, `font_licenses.dart`: centralized identity/licensing.
- `lib/core/presentation/hadgaly_ui.dart`, `lib/app.dart`, `lib/main.dart`: theme/shared UI/fonts.
- `lib/features/shell/presentation/product_shell.dart`: tab shell, placeholders, nested finance navigation.
- Onboarding/account/Home presentation files: current typography/colors and shell handoff only.
- `assets/fonts/*`, `pubspec.yaml`, `tool/verify_fonts.py`: official assets/notices/provenance and QA.
- `.gitattributes`: preserve upstream license/trademark notice bytes across Windows checkouts.
- `test/product_shell_test.dart`: four typography/theme/navigation/accessibility tests.
- `integration_test/stage2_test.dart`: synthetic native tab/placeholder checks added; financial assertions retained.
- Project context, README and previous review notices updated alongside this review.

No financial domain/provider/repository/controller, Drift schema/generated file, migration or fixture changed.

## Executed verification

| Check | Result |
|---|---|
| Dart formatting | Passed |
| flutter analyze | No issues |
| Full flutter test | **84 passed**, existing Stage 1/financial/persistence regressions included |
| New tests | Real font assets/notices, palette/contrast, initial selection, honest placeholders, preserved routes/forms, Android Back |
| Small screen | 320×568 at 1.8× text; all tabs reachable; real font glyphs/layout; keyboard/safe areas/tap/label/contrast passed |
| Python font QA | Official hashes and modern Mongolian/numeric/MNT coverage passed |
| Production Android debug build | Passed; actual ID verified as mn.hadgaly.hadgaly |
| Sandbox Android builds and Stage 1/2 flows | Passed on disposable AVD, synthetic data only |
| Synthetic completed/partial v1→v2 migration | **2 cases passed**, records/balances/default/onboarding/close-reopen retained |
| Main-app native interaction | Three placeholders, Android Back, My Accounts and persistent bar viewed/verified |
| Production-data/source safety | Current records/schema fingerprint and protected financial-source hashes unchanged |

Guarded suite evidence: `build/android-safety/20261103-100645/`. Before each installation the actual
binary applicationId was checked as **mn.hadgaly.hadgaly.sandbox**, different from production.
Exact frozen APKs were driven only on Hadgaly_Stage2_Disposable / emulator-5556; unrelated packages
remained unchanged. Main app remained on emulator-5554. No production uninstall/clear/wipe/reset.

Main app was updated using `adb install -r` only after inspecting production APK identity, then cold
launched. Read-only fingerprints before/after cover every field/row in accounts/profiles/adjustments/audit
and schema version. No actual user record values were logged/committed. Local evidence and private
screenshots are under `build/directive011/`. Prior incident data was not recovered or reconstructed.

## Android demo / founder review

The updated main app remains at Finance on emulator-5554. Review the Home hierarchy, digits/Cyrillic,
four labels, neutral placeholders, account access, default picker, adjustment/audit forms, keyboard and Back.
Screenshots: `build/directive011/finance.png`, `module-0.png`, `module-1.png`, `module-2.png`, `accounts.png`.
Screenshots contain existing founder data and stay local/Git-ignored.

Use README's data-preserving build/checked-install instructions. Fetch only after preserving local work:

```powershell
Set-Location D:\sum\hadgaly
git status --short
git fetch origin
git switch codex/stage-2-accounts
git pull --ff-only origin codex/stage-2-accounts
git rev-parse HEAD
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell am start -W -n mn.hadgaly.hadgaly/.MainActivity
```

The exact review commit SHA is supplied in the final report. If restarting the main emulator, the
verified current renderer is process-local **QT_OPENGL=desktop**, guest **-gpu swiftshader -feature -Vulkan**.
No AVD data wipe or permanent configuration changes. Do not run direct integration tests on the founder AVD.

## Limitations / acceptance gate

- Cyrillic/₮ necessarily use Noto Sans because the requested primary font lacks them. Founder review
  should assess this mixed-script typography and the new brand/navigation hierarchy.
- Full native iOS/device build, full human TalkBack evaluation and release distribution were not run
  on Windows. Android emulator and automated accessibility are verified; existing iOS navigation widget
  regression passed. No claim that every possible display/font setting has been tested.
- Future modules have no functionality/data storage. No transactions, reports, transfers or new finance rules.
- Synthetic fixture migration evidence is separate from real-user migration/recovery; neither was performed.
- **Stage 2 remains pending explicit founder acceptance. Stop here; do not start Stage 3.**
