$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $repo
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$aapt = Join-Path $sdk 'build-tools\37.0.0\aapt.exe'
$package = 'mn.hadgaly.hadgaly'
$avd = @(& $adb -s emulator-5554 emu avd name)
if ($LASTEXITCODE -ne 0 -or $avd[0].Trim() -ne 'Medium_Phone_API_37.0') { throw 'Unexpected founder device' }
$packages = @(& $adb -s emulator-5554 shell pm list packages)
if ($LASTEXITCODE -ne 0 -or $packages -notcontains "package:$package") { throw 'Existing main installation required; refusing a fresh install' }
& flutter build apk --debug --flavor production
if ($LASTEXITCODE -ne 0) { throw 'Production build failed' }
$apk = Join-Path $repo 'build\app\outputs\flutter-apk\app-production-debug.apk'
$badging = & $aapt dump badging $apk
if ($LASTEXITCODE -ne 0) { throw 'APK inspection failed' }
$identity = $badging | Where-Object { $_ -match '^package:' } | Select-Object -First 1
if ($identity -notmatch "^package: name='([^']+)'") { throw 'No APK package ID' }
if ($Matches[1] -cne $package) { throw 'Unexpected APK ID; refusing installation' }
$hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash
& $adb -s emulator-5554 shell am force-stop $package
if ($LASTEXITCODE -ne 0) { throw 'Could not stop app for consistent private backup' }
$evidence = Join-Path $env:LOCALAPPDATA ('HadgalyDev\stage4-update-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
& python tool/verify_production_data.py before $evidence
if ($LASTEXITCODE -ne 0) { throw 'Private preservation failed; no installation attempted' }
if ((Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash -ne $hash) { throw 'Verified APK changed' }
Write-Output "VERIFIED PRODUCTION UPDATE: $package; SHA256=$hash"
& $adb -s emulator-5554 install -r $apk
if ($LASTEXITCODE -ne 0) { throw 'Update failed. Do not uninstall or clear data.' }
& $adb -s emulator-5554 shell am start -W -n "$package/.MainActivity"
if ($LASTEXITCODE -ne 0) { throw 'Main launch failed; preserve backup and inspect logs' }
# am start can return exit 0 while printing Status: timeout. Verify rendered app
# content and enabled controls, not just the shell exit code or a fixed sleep.
& python tool/verify_production_data.py ready $evidence
if ($LASTEXITCODE -ne 0) { throw 'Main UI not ready; do not claim demo success' }
& $adb -s emulator-5554 shell am force-stop $package
& python tool/verify_production_data.py after $evidence
if ($LASTEXITCODE -ne 0) { throw 'Data comparison failed. Do not restore automatically.' }
& $adb -s emulator-5554 shell am start -W -n "$package/.MainActivity"
if ($LASTEXITCODE -ne 0) { throw 'Demo launch failed' }
& python tool/verify_production_data.py ready $evidence
if ($LASTEXITCODE -ne 0) { throw 'Final main UI not ready' }
Write-Output "PASS main demo update; private evidence: $evidence; APK SHA256=$hash"
