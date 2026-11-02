# Stage 2 — Home layout review

2026-11-02, Asia/Ulaanbaatar. Base commit: `11e8513a5d341c73dc81c783208378c67f3b872e`.
Stage 2 remains pending explicit founder acceptance. No Stage 3 or full Stage 5 work.

## Implemented

- Centered neutral expense-category donut, fixed “Энэ сар”, income **+0 ₮** and expense **−0 ₮**
  inside. No transaction/category persistence or period selector exists in Stage 2; no proportions,
  transactions or amounts were fabricated. Empty text: “Гүйлгээ бүртгэгдээгүй байна.”
- Combined **current** balance of all accounts above bottom actions. Uses the existing verified
  repository snapshot/replayed balances, including opening balances and adjustment anchors.
  BigInt sums exactly across accounts; the aggregate is not restricted to one account's input range.
  No floating-point money calculation and no use of period income-minus-expense.
- Expense button on the left, income on the right, above existing My Accounts navigation and safe area.
  Both keep honest unavailable feedback. No new navigation destination or entry UI.
- Removed Home default-account card; selection and behavior in My Accounts are unchanged.
- Comfortaa/Cupertino/green/coral retained. No gradient, shadow, card stack, category colors or animation.
- Scrollable minimum-height layout keeps actions near the bottom when content fits; long names,
  large text and keyboard insets can scroll rather than clipping. Monetary labels and ring have semantics.
- Approved Home direction is recorded for Stage 5 without implementing its reporting infrastructure.

## Files changed

- `lib/features/home/presentation/home_screen.dart`: Home presentation only.
- `test/home_widget_test.dart`: four new widget tests for combined balance/anchor edits/default
  independence, large/zero aggregate, hierarchy/semantics/honest feedback, small-screen accessibility.
- `test/accounts_widget_test.dart`, `test/onboarding_widget_test.dart`: new Home expectations/controls.
- `integration_test/stage1_test.dart`, `stage2_test.dart`: combined-balance expectations, zero period totals.
  Existing persistence, adjustment/audit and financial assertions remain.
- Context, README and review notices updated. No dependency changes.

## Verification

- `dart format --output=none --set-exit-if-changed lib test integration_test test_driver`: passed.
- `flutter analyze`: no issues.
- `flutter test`: **80 passed**, including existing financial/persistence/migration regressions.
- Four new Home tests cover positive/negative/zero totals, sums beyond the individual input limit,
  opening and multiple adjustment anchors, target editing/later-anchor invariance, default-independent
  totals, zero period totals, left/right action placement, navigation, semantics, 320×568 / 1.8× text,
  long names, safe-area/keyboard insets, tap target/label/contrast guidelines.
- `flutter build apk --debug --flavor production`: passed.
- Production APK actual applicationId checked as `mn.hadgaly.hadgaly`, then **adb install -r only**;
  cold launch succeeded on emulator-5554. Native My Accounts navigation and Android Back verified.
- Guarded `tool/run_android_checks.ps1 -Tests stage1_test,stage2_test`: both Android scenarios passed
  on `Hadgaly_Stage2_Disposable` / emulator-5556, synthetic data only. Actual sandbox APK IDs checked
  **before installation** as `mn.hadgaly.hadgaly.sandbox`; exact verified binaries used by drive.
  Evidence: `build/android-safety/20261102-183159/`. Unrelated packages unchanged.

## Data safety

Working tree was clean at start. No financial-domain, application/provider, repository, Drift schema,
generated database or migration sources changed (protected SHA-256 checks passed).
Read-only production fingerprints cover all fields/rows in profiles/accounts/adjustments/audit and
schema version. Before/after fingerprints match exactly. Evidence is Git-ignored under
`build/home-layout/`; no user record values were printed or committed.
No uninstall, clear-data, database reset, emulator wipe or recovery operation was performed.
Previously lost incident data was not recovered; the founder's current records were preserved.

## Interactive demo

Main app remains open on emulator-5554. Inspect empty donut/period totals, total balance, left expense /
right income feedback, then My Accounts and Android Back. Default account management is unchanged.
The exact review SHA is in the final report. To fetch without discarding local work:

```powershell
Set-Location D:\sum\hadgaly
git status --short
git fetch origin
git switch codex/stage-2-accounts
git pull --ff-only origin codex/stage-2-accounts
git rev-parse HEAD
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell am start -W -n mn.hadgaly.hadgaly/.MainActivity
```

For another checkout/build, use README's production APK identity check and `adb install -r` commands.
Never uninstall as a fallback; never run integration tests on the founder emulator.

## Limitations and remaining work

- No real transaction/category distribution or period selection exists yet. Zero totals represent
  Stage 2's lack of recorded transactions, not inferred bank activity. This is intentionally an empty state.
- This UI task did not rerun device v1→v2 migration; schema/migration and fixtures are unchanged.
  Existing automated migration regression tests passed; prior synthetic device evidence remains in
  STAGE2_UI_REFINEMENT.md. Fresh launch is not real-user migration/recovery evidence.
- No native iOS build/device or full human TalkBack/release validation on Windows. Widget accessibility
  and existing reduced-motion/navigation tests passed; no chart animation was added.
- Founder visual/interactive acceptance remains. Stage 2 is not automatically accepted by passing tests.
