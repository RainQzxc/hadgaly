# Stage 2 — Home-first proportions review

2026-11-03, Asia/Ulaanbaatar. Base: `6ea8e6c2405f211290bb29a74733ccc1a648387d`.
Founder steering: first refine Home proportions/spacing, approve its language, then consider other screens.
Stage 2 remains pending explicit acceptance; no Stage 3 work.

## Scope implemented

- Only `lib/features/home/presentation/home_screen.dart` changed among application sources.
  Existing palette/fonts/shared components/navbar/accounts/onboarding were preserved.
- Normal-text ring reduced from 340dp to **240dp** on the founder's standard device (~29% diameter
  reduction). Shorter screens use 200–240dp. Stroke reduced 14→10dp. Larger text can expand the ring;
  it is not locked to 240dp at 1.8× or shrunk by a font-scale cap.
- Greeting and chart form one compact group with 16dp separation. Visible gaps use 8/16/24dp rhythm.
  Extra vertical room separates the overview group from the lower balance/action group instead of
  stretching the greeting-to-donut gap or leaving action controls detached above the tab bar.
- “Нийт үлдэгдэл” is a quiet 14dp label; its amount is separate at 30dp/600. Greeting and My Accounts
  use lighter 500 weights. Financial semantics still announce the complete all-account current balance.
- Home actions are **64dp** at normal scale, 18dp radius, centered icon + label, 16dp inter-button gap.
  At large text they grow and place the icon above the label; no clipping or overlapping nav.
  Expense remains left, income right. Existing palette and honest unavailable feedback remain.
- Neutral centered donut, period income/expense inside, all-account balance below, then actions and
  My Accounts retain the approved order. No default card or fabricated transactions/proportions.
- The founder's text sketch was treated as layout direction, not a Flutter screenshot or permission
  to remove the donut/period figures or add another brand heading.

## Files / preservation

- Home presentation only; relevant Home/account/onboarding/shell widget and Stage 1/2 device tests
  adapted to the split balance label/value. Expected financial **amounts** and assertions retained.
- Home geometry checks now assert compact ring, 64dp default actions, tight greeting/chart spacing,
  clear hierarchy and lower-group clearance above the persistent nav.
- Handoff updated and previous audit preserved as a document. All non-Home audit fixes remain pending.
- No financial-domain/application/provider/repository, database/generated schema, migration or fixture change.
  Protected source hashes and full production records/schema before/after fingerprints match.
  No uninstall/clear-data/wipe. Main APK identity inspected before `adb install -r` update only.

## Verification / evidence

- Formatting and flutter analyze passed.
- Full flutter test: **84 passed**, including financial/persistence/migration regressions, default
  selection, anchor edits/audit, combined/zero/negative balance, long names, 320dp/1.8×, keyboard,
  semantics/contrast/tap targets and four-tab/Back behavior.
- Production Android debug build and existing-data interactive Home preview passed.
- Guarded synthetic sandbox Stage 1/2 Android flows passed on Hadgaly_Stage2_Disposable; actual
  sandbox package checked before installation. The main package stayed on emulator-5554.
- New synthetic device migration was not required/rerun for this Home-only change; unchanged migration
  unit regressions passed. Prior two-case device migration evidence remains in the #011 review.
- Native screenshot: `build/home-proportions/home.png`; original baseline:
  `build/design-audit-013/01-finance.png`. Current founder-data screenshots remain local/Git-ignored.
- Exact reviewed commit SHA and final device log directory are supplied in the final report.

## Founder review / remaining work

Main app remains at Home inside Finance. Review donut proportion, greeting/chart distance, total-amount
hierarchy, button shape/label placement and lower action-group spacing. Live launch:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell am start -W -n mn.hadgaly.hadgaly/.MainActivity
```

Use README's checked identity + adb install -r workflow for another build; never uninstall as a fallback.

Navbar pill/height, other account/form/onboarding design and the audit's default-picker wording remain
unchanged in this deliberately narrow pass. Those should follow Home approval, not be bundled into it.
Native iOS and full human TalkBack review were not run. Small-screen/large-text checks are widget
verification; the native screenshot is the founder's standard emulator size. Stage 2 is not accepted
by test/build success. Stop for Home review; do not start Stage 3.
