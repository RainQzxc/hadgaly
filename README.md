# Хадгалъя · Hadgaly

Offline-first personal finance. Stage 1: friendly Mongolian onboarding and a minimal home.
Founder acceptance is pending. Stage 2 and financial transactions are not implemented.

## Local Android development

Pinned Flutter **3.47.9** (c197ca5199), bundled Dart **3.13.7**. Preserve `pubspec.lock`.
In PowerShell:

```powershell
Set-Location D:\sum\hadgaly
$env:Path = 'C:\dev\flutter\bin;' + $env:Path
flutter --version
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter devices
flutter run -d emulator-5554
```

If the emulator is not online, start in a separate terminal:

```powershell
$env:QT_OPENGL = 'angle'
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd Medium_Phone_API_37.0 -no-snapshot-load -no-snapshot-save -gpu swiftshader -feature -Vulkan -cores 4
```

The normal renderer crashed in NVIDIA `nvoglv64.dll`. `-gpu software` booted but later hung.
The command above (SwiftShader, Vulkan disabled, 4 cores) passed the Android build/run,
integration test and native keyboard/cold-start checks. No permanent AVD configuration was changed.
The Android build also requires NDK **28.2.13676358**. On the new Android CLI,
install the exact package if needed (the legacy sdkmanager wrapper misparsed it here):

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\cmdline-tools\latest\bin\android.exe" --no-metrics --sdk="$env:LOCALAPPDATA\Android\Sdk" sdk install 'ndk/28.2.13676358'
```

Cold boot does not wipe AVD data. `r` reloads, `R` restarts; cold-start persistence acceptance
requires closing/reopening the Android app, not just Hot Reload.

Android integration test uses its own uniquely named SQLite file, with synthetic data:

```powershell
flutter test integration_test/stage1_test.dart -d emulator-5554
```

## Structure and data rules

- `lib/core/domain/money.dart`: pure Dart name/integer validation and formatting.
- `lib/features/onboarding/data`: Drift schema, transactions and durable checkpoints.
- `lib/features/onboarding/application`: Riverpod controller, ordered draft writes, submission guard.
- `lib/features/onboarding/presentation`: welcome, greeting, mandatory first account, completion.
- `lib/features/home/presentation`: default account/balance, prominent +/− with honest unavailable feedback.

Amounts: **−999,999,999,999 through 999,999,999,999 MNT inclusive**. ASCII integer digits,
optional leading minus, outer whitespace accepted, no fractions/separators/exponents/rounding.
Parsing uses BigInt for validation before conversion; stored amounts are SQLite signed integers.
Names are trimmed, nonblank, single-line, at most 60 Unicode code points.

Only first-account creation is implemented. It atomically inserts the account, assigns the default,
and advances to completion. The final Home action marks onboarding complete only with a valid account.
Retries are idempotent. SQLite foreign keys and a trigger enforce the completed-profile prerequisite.
Draft fields and step are saved in order after each change; an interrupted write retains the last
committed checkpoint. Completed data is never reset automatically on startup failure.

Database schema v1. No destructive migration fallback. No cloud, tracking, or financial logging.
Android automatic backup is disabled pending the approved Stage 6 backup/restore design.
Android platform defaults come from this pinned Flutter template; minimum supported OS is not yet a product commitment.

After schema changes during development:

```powershell
dart run build_runner build
```

Commit generated `app_database.g.dart`, review schema changes and add explicit migrations.
Never commit actual financial databases, notes, credentials or device exports.

## Founder review

1. Fresh app: “Сайн уу? 👋”, blank/whitespace validation, preferred Mongolian name.
2. Personalized greeting; back navigation preserves input.
3. Required account name and integer opening balance; try 0, negative, invalid fraction/overflow.
4. Close/reopen mid-account entry; the last committed partial input returns.
5. Completion screen; first account becomes default; Home shows its exact balance.
6. Close/reopen Home; state persists. Tap both +/−: feedback only, no financial posting.
7. Review keyboard scrolling, small screen, large text, Mongolian typography and friendly copy.

Comfortaa is bundled offline under SIL OFL, including Mongolian Cyrillic, Ө/Ү and ₮.
Font source: [Google Fonts](https://github.com/google/fonts/tree/main/ofl/comfortaa).
Persistence follows [Drift setup](https://drift.simonbinder.eu/setup/).
