# Stage 2 UI refinement — founder review

Home layout was subsequently revised by founder directive; STAGE2_HOME_REVIEW.md supersedes this
document's Home/default-account card description. Other Cupertino refinement evidence remains historical.

2026-11-02, Asia/Ulaanbaatar. Base commit: `8787bcc9526da9b20dd84573b4e1f0534608fb9e`.
This is UI refinement within Stage 2. Stage 2 remains pending explicit founder acceptance.
The approved six-stage roadmap and all financial behavior remain unchanged. Stage 3 has not begun.

## UI changes

- Root shell uses Flutter `CupertinoApp`, `CupertinoTheme`, `CupertinoPageScaffold` and
  Cupertino page transitions. Comfortaa, soft green/coral, off-white and rounded frames remain.
- iOS uses `CupertinoNavigationBar`. Android uses a matching 60dp toolbar so back targets remain
  at least 48dp and navigation titles retain 1.8× scaling; UIKit's default 44pt/no-scaling behavior
  is not imposed on Android. The iOS navigation branch is also widget-tested with scaled titles.
- Shared Cupertino buttons and fields have consistent spacing, clear labels, inline validation,
  focus borders, keyboard actions and comfortable targets. No Material ripples/buttons/snackbars
  are mixed into the Cupertino presentation.
- Onboarding keeps the approved wording, mandatory first account, validation/back/progress behavior.
  Smaller icon treatment and tighter hierarchy reduce decoration.
- Home retains prominent + income / − expense controls. Their unavailable feedback is inline and
  non-blocking; no transaction is posted. Default-account navigation is a clear grouped row.
- My Accounts uses one inset grouped list with subtle separators instead of a separate card for
  every account. A compact “Солих” control in the default summary opens a Cupertino action sheet.
  Cancel and Android system back dismiss without changing the default.
- Account/name/adjustment forms use the same fields and primary button. The adjustment date is
  still fixed by the approved rules; no date picker, deletion or new destination was introduced.
- Audit presentation is one grouped history section with subdued dates, distinct original/current
  differences and readable old→new edits, without extra nested cards or shadows.
- Page and action-sheet transitions become zero-duration for reduced-motion/accessibility navigation.
  Navigation hero transitions are disabled. No decorative/continuous animation was added.
- Screen-reader labels preserve tap actions and enabled state, including +/−, Back and default selector.

No third-party UI kit was added. `cupertino_icons` **1.0.9** is the official icon font used by Flutter's
built-in `CupertinoIcons`; no business/persistence dependency was upgraded.

## Files changed

- `lib/app.dart`, `lib/main.dart`: Cupertino app/theme/bootstrap.
- `lib/core/presentation/hadgaly_ui.dart`: reusable page/navigation, fields, buttons, group, motion helpers.
- `lib/features/onboarding/presentation/onboarding_screen.dart`: onboarding presentation only.
- `lib/features/home/presentation/home_screen.dart`: Home shell and inline unavailable feedback.
- `lib/features/accounts/presentation/account_forms.dart`, `accounts_screen.dart`: forms/list/selection/audit UI.
- `test/accounts_widget_test.dart`, `test/onboarding_widget_test.dart`: Cupertino behavior, accessibility,
  proper keyboard MediaQuery, cancel/system-back/reduced-motion/iOS navigation cases.
- `integration_test/stage1_test.dart`, `stage2_test.dart`: Cupertino field access and action-sheet interaction.
  Financial assertions were retained.
- `pubspec.yaml`, `pubspec.lock`: official Cupertino icon font only.
- Context, README and review documentation updated.

## Financial and data safety evidence

At the start, working tree was clean. Source hashes were recorded for the financial domain, money
validation, repositories, application/controllers/providers, Drift schema and generated code.
**Every protected source hash is unchanged** at the end of refinement. No financial rules,
database schema, migration or stored amount representation changed. Schema remains v2.

Production data was inspected read-only, using an in-memory SQLite snapshot. A canonical fingerprint
covered **all fields/rows** of `accounts`, `profiles`, `balance_adjustments`, `adjustment_edits`,
plus schema version. Before/after fingerprints match exactly. No user record values were printed
or committed. Evidence is local under `build/ui-refinement/`.

The production app was updated only with **`adb install -r`**, after checking actual APK applicationId
`mn.hadgaly.hadgaly`. No uninstall, clear-data, fresh database, emulator wipe, invented account,
balance or history was used. Read-only native review opened/dismissed the default selector and an
empty creation form without submitting anything, then returned to Home.

Previous incident data was not recovered; the founder's earlier fresh-start authorization is history.
This UI task preserved the records present when refinement began.

## Executed checks

| Check | Result |
|---|---|
| Formatting check | Passed |
| `flutter analyze` | No issues found |
| `flutter test` | **76 passed** |
| Existing financial/persistence/migration regression assertions | Retained and passed |
| Android production debug build | Passed |
| Production update/start | Passed, records/schema fingerprint unchanged |
| Sandbox Stage 1 Android scenario | Passed; rerun after final presentation changes |
| Sandbox Stage 2 Android scenario | Passed; rerun after final presentation changes |
| Synthetic completed/partial v1→v2 device migration | **2 cases passed** in this refinement run |
| Native Android Back / safe areas / real keyboard | Viewed and verified on the main app, without form submission |
| Small screen, 1.8× text, long names, keyboard, tap/label/contrast | Widget checks passed |
| Screen-reader tap semantics and reduced-motion transitions | Widget checks passed |

Initial full device suite: `build/android-safety/20261102-163531/`.
Final UI scenario rerun: `build/android-safety/20261102-164448/`.
Before installation each test APK was verified as **`mn.hadgaly.hadgaly.sandbox`**, hashed and
installed as that exact binary on **Hadgaly_Stage2_Disposable / emulator-5556** only.
Guarded cleanup targeted sandbox; unrelated packages remained unchanged. The founder's main app
on emulator-5554 remains installed. The disposable AVD is stopped after verification.

Final sandbox APK hashes:

- Stage 1: `7D9363C2A703DC51E8B65976F51D57A8D5D04154D05BC07F720794C2575D95FB`
- Stage 2: `F02E46D9572585CCAF15F06BD940A336E284ECA62FF762F3C419568C72968F81`

The migration source/fixture bytes did not change. Synthetic fixture migration remains separate
from real-user-data migration; the latter was not performed or claimed.

## Interactive Android demo

The refined main app is open on emulator-5554 with its existing data. Review Home → My Accounts,
default-selection cancel/back, account/name forms, adjustment forms and existing audit presentation.
Use only your intended real edits; this review did not add sample data to production.

Fetch the review branch without discarding local work, then follow README's checked, data-preserving
build/install commands. Never uninstall as an installation fallback.

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git status --short
git fetch origin
git switch codex/stage-2-accounts
git pull --ff-only origin codex/stage-2-accounts
git rev-parse HEAD
flutter pub get
flutter build apk --debug --flavor production
```

Then inspect the production APK id and use `adb install -r`, as shown in README. The exact review
commit SHA is supplied in the final report.

## Remaining limitations / approval

- Actual iOS build/device/simulator verification was not run on this Windows environment. The iOS
  navigation branch was widget-tested; Android is the verified interactive target.
- Full human TalkBack evaluation and release distribution checks were not run. Automated semantics,
  contrast, target-size, long-name and scaling checks passed.
- Founder review of visual hierarchy, copy, default action sheet and audit readability remains.
- Stage 2 is **not accepted automatically**. Stop at this review gate; no Stage 3 implementation.
