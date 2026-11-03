param(
    [string]$DeviceId = 'emulator-5556',
    [ValidateSet('stage1_test','stage2_test','stage3_test','stage4_test','migration_test')]
    [string[]]$Tests = @('stage1_test','stage2_test','stage3_test','stage4_test','migration_test')
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Set-Location -LiteralPath $repo
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$aapt = Join-Path $sdk 'build-tools\37.0.0\aapt.exe'
$expectedPackage = 'mn.hadgaly.hadgaly.sandbox'
$mainPackage = 'mn.hadgaly.hadgaly'
function Confirm-Disposable {
    $avd = @(& $adb -s $DeviceId emu avd name)
    if ($LASTEXITCODE -ne 0 -or $avd[0].Trim() -ne 'Hadgaly_Stage2_Disposable') {
        throw 'Refusing device: only Hadgaly_Stage2_Disposable is authorized for tests.'
    }
    $packages = & $adb -s $DeviceId shell pm list packages
    if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect device packages.' }
    if ($packages -contains "package:$mainPackage") { throw 'Main app found on test device. Refusing tests.' }
}
Confirm-Disposable
$fixtureHashes = Get-Content -LiteralPath (Join-Path $repo 'test\fixtures\stage1_fixture_sha256.json') -Raw | ConvertFrom-Json
$v3Hashes = Get-Content -LiteralPath (Join-Path $repo 'test\fixtures\stage3_fixture_sha256.json') -Raw | ConvertFrom-Json
foreach ($entry in $v3Hashes.PSObject.Properties) {
    $fixtureHashes | Add-Member -NotePropertyName $entry.Name -NotePropertyValue $entry.Value
}
$v2Hashes = Get-Content -LiteralPath (Join-Path $repo 'test\fixtures\stage2_fixture_sha256.json') -Raw | ConvertFrom-Json
foreach ($entry in $v2Hashes.PSObject.Properties) {
    $fixtureHashes | Add-Member -NotePropertyName $entry.Name -NotePropertyValue $entry.Value
}
foreach ($entry in $fixtureHashes.PSObject.Properties) {
    $fixture = Join-Path $repo ('test\fixtures\' + $entry.Name)
    if ((Get-FileHash -LiteralPath $fixture -Algorithm SHA256).Hash -ne $entry.Value) {
        throw "Preserved fixture changed: $($entry.Name)"
    }
}
$evidenceDir = Join-Path $repo ('build\android-safety\' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $evidenceDir | Out-Null
foreach ($test in $Tests) {
    & flutter build apk --debug --flavor sandbox --target "integration_test/$test.dart"
    if ($LASTEXITCODE -ne 0) { throw "Build failed: $test" }
    $built = Join-Path $repo 'build\app\outputs\flutter-apk\app-sandbox-debug.apk'
    $badging = & $aapt dump badging $built
    if ($LASTEXITCODE -ne 0) { throw 'APK inspection failed.' }
    $packageLine = $badging | Where-Object { $_ -match '^package:' } | Select-Object -First 1
    if ($packageLine -notmatch "^package: name='([^']+)'") { throw 'No verified APK applicationId.' }
    $actual = $Matches[1]
    if ($actual -ne $expectedPackage -or $actual -eq $mainPackage) { throw "Unsafe APK applicationId: $actual" }
    $apk = Join-Path $evidenceDir "$test.apk"
    Copy-Item -LiteralPath $built -Destination $apk
    $hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash
    $badging | Set-Content -LiteralPath (Join-Path $evidenceDir "$test.badging.txt")
    Confirm-Disposable
    $before = @(& $adb -s $DeviceId shell pm list packages | Sort-Object)
    if ((Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash -ne $hash) { throw 'Verified APK changed.' }
    Write-Output "VERIFIED BEFORE INSTALL: $actual; device=$DeviceId; SHA256=$hash"
    # Drive installs this exact verified binary. It does not rebuild a generated test target.
    $driverLog = Join-Path $evidenceDir "$test.driver.log"
    & flutter drive --debug --flavor sandbox --target "integration_test/$test.dart" --driver test_driver/integration_test.dart --use-application-binary "$apk" -d $DeviceId *> $driverLog
    if ($LASTEXITCODE -ne 0) {
        Get-Content -LiteralPath $driverLog -Tail 30
        throw "Device test failed: $test"
    }
    Write-Output "PASS: $test; driver log: $driverLog"
    Confirm-Disposable
    $after = @(& $adb -s $DeviceId shell pm list packages | Sort-Object)
    $unrelatedBefore = @($before | Where-Object { $_ -ne "package:$expectedPackage" })
    $unrelatedAfter = @($after | Where-Object { $_ -ne "package:$expectedPackage" })
    if (@(Compare-Object $unrelatedBefore $unrelatedAfter).Count -ne 0) { throw 'Unexpected package change.' }
    [ordered]@{test=$test; device=$DeviceId; avd='Hadgaly_Stage2_Disposable'; applicationId=$actual;
        sha256=$hash; cleanupTarget=$expectedPackage; mainAppAbsent=$true; unrelatedPackagesUnchanged=$true; passed=$true} |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $evidenceDir "$test.result.json")
}
Write-Output "Device checks passed. Evidence: $evidenceDir"
