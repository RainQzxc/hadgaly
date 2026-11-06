# CEO #024 — Stage 5 right-side drawer

Baseline: `7011450e7150bfce96f7836ad0de74ee5b8f05f7` on
`codex/stage-5-dashboard`, verified locally and against origin.
The founder approved the design. Stage 5 implementation still awaits acceptance.

The toolbar menu slides in from the right, dims the current page and lists four
modules: Хийх зүйл, Авах зүйл, Санаа and Санхүү. The current module has a Soft Teal
fill, a checkmark and selected semantics. There is no Settings destination.
The three inactive modules only show their existing coming-soon message.

Use X, tap the scrim, press Android Back, or swipe right inside the drawer to close.
There is no edge-swipe shortcut to open it; Android keeps its system Back gesture.
Finance opens initially. Switching modules leaves its current route and form draft
mounted; opening the menu dismisses the keyboard. Menu animation respects reduced
motion. The menu is absent during onboarding.

Finance Home, the expense donut, quick entry, History, Accounts and Reports retain
their existing behavior. Ledger, adjustments, audits, SQLite schema v4, migrations,
dependencies, brand assets and fonts are unchanged.

## Automated verification

- Dart formatting: 63 files checked, no changes. Flutter analyze: no issues.
- Flutter test: 139 unit/widget cases passed, including drawer accessibility and
  state restoration, finance/persistence regressions and migration fixtures.
- Android: 10 functional cases across six guarded APK targets passed (Stages 1–5
  and four synthetic migration fixtures). The runner verified each APK's ID
  `mn.hadgaly.hadgaly.sandbox`, absence of production on the disposable AVD and
  no change to unrelated packages. Local logs: `build/android-safety/20261106-171216`.
  Stages 2 and 5 were rerun after separating the header and close-button Android
  accessibility nodes: both passed (`build/android-safety/20261106-171849`).

## Android screenshots

Native captures use the normal sandbox build and synthetic income 123 ₮,
expense 125 ₮, and combined balance −2 ₮. No founder data appears in these files.
Native interaction passed at both sizes: scrim/X/swipe/system Back, all four modules,
return to the same report, and return to the same unsaved amount entered through
the actual Android IME. At 320dp the report's Back returns to Home's previous
scroll position. Synthetic evidence is in `build/stage5/drawer-ime/20261106-172013`;
the enlarged run was repeated on the identical installed APK and fixture.
After the synthetic edit and deletion, the copied SQLite database retained both
original entries and both revisions. Cold restart displayed the expected 200 ₮.

| Android display | Drawer closed | Drawer open |
| --- | --- | --- |
| Default | [Home](docs/review/stage5-drawer-closed.png) | [Menu](docs/review/stage5-drawer-open.png) |
| 320dp, 1.8× | [Home](docs/review/stage5-drawer-closed-large-text.png) | [Menu](docs/review/stage5-drawer-open-large-text.png) |

At 320dp and enlarged text, Finance Home scrolls to quick actions and details.
The menu and its close button remain available in the toolbar. Native iOS and
hands-on TalkBack navigation were not run.

## Run the demo on Windows

With the existing founder AVD (`Medium_Phone_API_37.0`, port 5554) online:

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
git pull --ff-only origin codex/stage-5-dashboard
.\tool\run_production_demo.ps1
```

The production runner validates the APK ID, backs up the private database/sidecars,
updates with `adb install -r` and compares data before and after. It never falls
back to uninstall or clear-data. Open the hamburger from Finance Home, try each
module, and switch away from Reports or an unsaved entry and back to Finance.

The checked update and two cold launches passed on the founder AVD. Schema v4,
database integrity, record fingerprints and calculated balance fingerprints
matched before and after. The founder AVD was neither wiped nor used for
integration tests. Private evidence remains outside Git.

## Repeat the tests

Run the Android checks only on `Hadgaly_Stage2_Disposable` (port 5556). The smoke
command expects no previously installed sandbox app. It enters synthetic data
with the actual keyboard and restores the disposable display/font settings.

```powershell
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze
flutter test
.\tool\run_android_checks.ps1
flutter build apk --debug --flavor sandbox
python tool/verify_sandbox_keyboard.py build/app/outputs/flutter-apk/app-sandbox-debug.apk --drawer-screenshots
```
