$ErrorActionPreference = 'Stop'
$avdRoot = Join-Path $env:USERPROFILE '.android\avd'
$name = 'Hadgaly_Stage2_Disposable'
$directory = Join-Path $avdRoot "$name.avd"
$ini = Join-Path $avdRoot "$name.ini"
if ((Test-Path -LiteralPath $directory) -or (Test-Path -LiteralPath $ini)) {
    throw 'Disposable AVD already exists. Refusing to overwrite it.'
}
$image = Join-Path $env:LOCALAPPDATA 'Android\Sdk\system-images\android-37.0\google_apis_playstore\x86_64'
if (!(Test-Path -LiteralPath (Join-Path $image 'system.img'))) { throw 'Required installed system image not found.' }
New-Item -ItemType Directory -Path $directory | Out-Null
@"
avd.ini.encoding=UTF-8
path=$directory
path.rel=avd\$name.avd
target=android-37.0
"@ | Set-Content -LiteralPath $ini -Encoding ascii
@"
AvdId=$name
avd.ini.displayname=Hadgaly Stage2 Disposable
PlayStore.enabled=true
abi.type=x86_64
hw.cpu.arch=x86_64
hw.cpu.ncore=4
hw.ramSize=2048
hw.device.name=medium_phone
hw.keyboard=yes
hw.lcd.width=1080
hw.lcd.height=2400
hw.lcd.density=420
hw.gpu.enabled=yes
hw.gpu.mode=swiftshader
hw.camera.back=none
hw.camera.front=none
hw.sdCard=no
disk.dataPartition.size=4G
image.sysdir.1=system-images\android-37.0\google_apis_playstore\x86_64\
tag.id=google_apis_playstore
tag.display=Google Play
fastboot.forceColdBoot=yes
"@ | Set-Content -LiteralPath (Join-Path $directory 'config.ini') -Encoding ascii
'Synthetic data only. Do not copy user data into this AVD.' | Set-Content -LiteralPath (Join-Path $directory 'HADGALY_DISPOSABLE.txt') -Encoding ascii
Write-Output "Created new, empty disposable AVD: $name"
