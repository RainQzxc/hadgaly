# CEO #015 — Home composition review

2026-11-03, Asia/Ulaanbaatar. Base commit: `14a5aed45fe5a9bdc7143d16a032f3375ced549d`.
Stage 2 remains NOT APPROVED. No Stage 3 or future-module changes.

## Correction

- Removed `MainAxisAlignment.spaceBetween` from Home's primary Column and removed its viewport-derived
  `minHeight`. The content now follows its natural height inside the existing scroll view.
- Empty-state text → total-balance label is **24dp**, independent of unused screen height. Related gaps
  remain 8/16dp. No extra cards, dividers, gradients, shadows or decorative content.
- Preserved normal 240dp donut/10dp stroke, period labels and zero totals. Existing responsive behavior
  remains: short screens may use 200–240dp, enlarged text can grow the ring and scroll.
- Preserved the 30dp/600 balance amount emphasis and 64dp normal-text buttons, expense left/income right.
  No invented activity; openings/anchors still affect combined balance only, not period totals.
- “Миний данс” is now a quiet **14dp/500 left-aligned navigation row** with a trailing 16dp chevron,
  existing route/semantics and **≥48dp touch height**. It is no longer another centered heading.
- All brand/font/shared components/navbar/onboarding/account management/business rules remain unchanged.

## Files

- `lib/features/home/presentation/home_screen.dart`: the only changed application source.
- `test/home_widget_test.dart`: replaces the old nav-proximity expectation (which encouraged stretching)
  with exact empty-state/balance spacing checks at **390×844 and 390×1000**, plus chevron/target checks.
  Existing financial amounts/anchor/audit/default/accessibility assertions remain.
- Project context, this report and previous Home review notice updated.

## Checks / safety

- Dart formatting verification passed; flutter analyze clean; full flutter test **84 passed**.
- Existing tests cover 320dp, 1.8× text, long Mongolian names, large negative/combined balances,
  keyboard/safe areas, semantics, contrast, navigation and financial/persistence/migration regressions.
- Android sandbox verification uses `tool/run_android_checks.ps1` only on Hadgaly_Stage2_Disposable /
  emulator-5556, synthetic data only. Actual APK ID is checked before every installation as
  `mn.hadgaly.hadgaly.sandbox`, different from main `mn.hadgaly.hadgaly`. No direct integration tests
  target the founder's emulator or app.
- Stage 1/2 Android scenarios and completed/partial v1→v2 synthetic migration **all passed**.
  Evidence: `build/android-safety/20261103-161104/`; unrelated packages remained unchanged.
- Protected financial/persistence source hashes remain unchanged. Current production fingerprints
  cover all profile/account/adjustment/audit fields and schema version before/after update.
- Production update uses inspected main package identity + `adb install -r` only. No uninstall,
  clear-data, database reset, migration change, snapshot restore or emulator wipe.

## Native visual review

The exact review SHA is supplied in the final report. Production APK is built from that clean commit;
the native screenshot and local review manifest record commit/APK/image identity under
`build/home-composition-015/`. Screenshots remain Git-ignored because they contain founder data.

Main app remains in Finance → Home. To reopen:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" -s emulator-5554 shell am start -W -n mn.hadgaly.hadgaly/.MainActivity
```

## Remaining visual limits / acceptance

- Tall displays retain neutral unused space **below** the content; nothing is stretched to fill it.
  This is intentional for a cohesive composition, not a missing feature/card.
- At 320dp and 1.8×, scrolling may be needed. Text is not shrunk/capped/clipped to force one viewport.
- Native screenshot uses the standard founder emulator size (1080×2400 px / 420dpi). Small-screen
  and enlarged-text verification is automated widget testing, not a new native settings change.
- Full human TalkBack and native iOS-device review were not run. Stage 2 still awaits founder visual
  review/explicit acceptance. Other audit recommendations remain outside this correction.
