# Install guide
macOS バージョンごとに、インストールの手順や注意点を記載する。あくまで Z97M Gaming においての手順であり、どのマザーボードにも適用できるとは限らないことに注意。

各 macOS バージョンのインストーラー USB の作成方法については [OpenCore-Install-Guide](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/mac-install.html) を参照のこと。

- [High Sierra (10.13)](#high-sierra-1013)
- [Mojave (10.14)](#mojave-1014)
- [Catalina (10.15)](#catalina-1015)
- [Big Sur (11) to Sequoia (15)](#big-sur-11-to-sequoia-15)
- [Sierra (10.12)](#sierra-1012)
- [Yosemite (10.10) / El Capitan (10.11)](#yosemite-1010--el-capitan-1011)
- [Mavericks (10.9)](#mavericks-109)
- [Lion (10.7) / Mountain Lion (10.8)](#lion-107--mountain-lion-108)
- [Snow Leopard (10.6)](#snow-leopard-106)
- [Leopard (10.5)](#leopard-105)
- [Tiger (10.4)](#tiger-104)

## High Sierra (10.13)
[How to build](./build_ja.md) で示したように、全てのハードウェアと最も互換性の高い 10.13 からインストールしていくことをおすすめする。

10.13 は最も簡単であり、単純にインストーラー USB からインストールできる。

## Mojave (10.14)
インストール自体に特に注意点はないが、インストールしただけでは GPU アクセラレーションが動作せず、[macOS Mojave Patcher](http://dosdude1.com/mojave/) の post install patch を適用する必要がある。

post install patch はアップデートの度に再適用が必要になってしまうため、まず全てのアップデート・セキュリティアップデートを適用してから作業する。

対象のシステム上では適用できないので、再度 10.14 のインストーラー USB ( あるいは 10.14 のリカバリボリューム ) を起動し、Terminal から下記のように patcher を立ち上げる。
```
/path/to/macOS\ Mojave\ Patcher.app/Contents/Resources/macOS\ Post\ Install.app/Contents/MacOS/macOS\ Post\ Install
```
`Legacy Video Card Patch` にチェックを付け、10.14 のボリュームを選択してパッチを適用する。

## Catalina (10.15)
10.14 と同様に、全てのアップデート・セキュリティアップデートを適用してから [macOS Catalina Patcher](http://dosdude1.com/catalina/) の post install patch が必要だが、更に AMFI を事前に無効化する必要がある。

AMFI は config.plist に `amfi=0x80` を記述することで無効化できるが、全ての macOS バージョンに対して無効化されてしまうため、ここでは以下の方法で 10.15 でのみ無効化する。
```
# get volume uuid
UUID=`diskutil info / | grep 'Volume UUID' | awk '{print $4}'`; echo $UUID

# mount Preboot
diskutil mount `diskutil list | grep Preboot | awk '{print $7}'`

# edit plist
sudo vim /Volumes/Preboot/$UUID/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
```

```
	<key>Kernel Flags</key>
	<string></string>
```
この部分を
```
	<key>Kernel Flags</key>
	<string>amfi=0x80</string>
```
このように変更する。

変更を適用した後、10.15 のインストーラー USB ( あるいは 10.15 のリカバリボリューム ) を起動し、Terminal から下記のように patcher を立ち上げる。
```
/path/to/macOS\ Catalina\ Patcher.app/Contents/Resources/macOS\ Post\ Install.app/Contents/MacOS/macOS\ Post\ Install
```
`Legacy Video Card Patch` にチェックを付け、`Change...` から 10.15 のボリュームを選択してパッチを適用する。

## Big Sur (11) to Sequoia (15)
macOS 11 以降では [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher) (OCLP) が使用できるためむしろ 10.14 / 10.15 より簡単になる。

macOS インストール後、OCLP を起動し `Post-Install Root Patch` からパッチを適用すれば良い。

## Sierra (10.12)
10.12 では、インストーラー USB 作成時に fork bomb が発生するので[対策する](https://www.nicksherlock.com/2020/02/createinstallmedia-for-macos-sierra-is-a-fork-bomb/)。

また、10.12 以前は APFS に対応していないため、HFS+ のパーティションを作成してインストールする。

10.12 以前のインストーラーは署名の問題などにより通常のインストールに失敗するので、インストーラーを起動したら Terminal を起動し、以下のコマンドによりインストールを実行する。
```
installer -pkg /Volumes/Mac\ OS\ X\ Install\ DVD/Packages/OSInstall.mpkg -target /Volumes/Vol_Name_of_Sierra
```

## Yosemite (10.10) / El Capitan (10.11)
10.10 / 10.11 でも 10.12 と同様に Terminal からインストールを行う。

## Mavericks (10.9)
config.plist で設定している `iMac15,1` SMBIOS は 10.9 以前に対応しないため、インストール時のみ `MacBookPro5,3` に変更すること。`MacBookPro5,3` とする理由は 10.5 で説明する。

Mavericks は 2024 年現在 Apple からインストーラーをダウンロードできないため、過去に保存したインストーラーを使うか [archive.org などから入手](https://archive.org/details/os-x-mavericks_202202)する必要がある。自分は以前ダウンロードしたインストーラーを保持していたため、archive.org のものが利用できるかは確認していない。

インストール手順自体は 10.12 と同様に Terminal からインストールを行う。10.9 以前のバージョンは NVMe に対応していないため、AHCI の PCIe SSD か、SATA SSD にインストールする。

## Lion (10.7) / Mountain Lion (10.8)
10.9 と同様に SMBIOS を一時的に変更し、Terminal からインストールを行う。

## Snow Leopard (10.6)
10.6 以前は Apple からインストーラーが配布されていないため、[OpenCore-Install-Guide](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/mac-install-dmg.html) に沿ってインストーラーを用意する。

10.6 は Terminal を使わず通常の手順でインストールできる。

## Leopard (10.5)
10.5 も 10.6 と同様にインストールできるが、SMBIOS について注意が必要となる。[Acidanthera Image](https://archive.org/details/10.5.7-9-j-3050) の説明では "These installers are based off of the MacBookPro5,3 restore disks however support all models that natively ran 10.5.7." となっているが、実際はインストール時に `MacBookPro5,3` の SMBIOS を設定する必要があった。

`MacBookPro5,3` が設定されていれば、通常の手順でインストールできる。

## Tiger (10.4)
10.4 のインストールは 10.5 以前と比べて複雑な手順が必要となる。

Haswell 世代のマザーボードでは AppleAHCIPort.kext が panic するため、BIOS で SATA コントローラーの動作モードを AHCI ではなく IDE モードに変更する。

このビルドでは 10.5 - 10.9 を PCIe AHCI SSD に、10.10 以降を NVMe SSD にインストールしており、SATA SSD には 10.4 しかインストールしないためこの変更の影響を受けないが、IDE モードで動作する SATA SSD であっても 10.5 - 11 まではインストールができるため、PCIe AHCI SSD を入手できなくても SATA SSD と NVMe SSD が用意できれば問題ない。

※ ただし IDE モードと PCIe AHCI SSD の併用には[古い BIOS か BIOS mod が必要になる](./build_ja.md#bios-mod)。

10.4 のインストーラー USB を起動することができないため、10.5 が動作している環境からインストールを行う。

1. [Acidanthera Image](https://archive.org/details/10.4.10-8-r-4088-acdt) の 10.4.10-8R4088-ACDT.dmg をマウントする
2. `/Volumes/Mac\ OS\ X\ Install\ Disc\ 1/System/Installation/Packages/OSInstall.mpkg` を開く
3. インストール先のボリュームを選択しインストールする
4. [Mac OS X 10.4.11 Update (Intel)](https://support.apple.com/kb/DL171) を対象ボリュームにインストールする
5. [Security Update 2009-005 (Tiger Intel)](https://support.apple.com/kb/DL932) を対象ボリュームにインストールする
6. `mach_kernel` を [custom kernel](../Kernels/mach_kernel) に置換する  
`sudo cp /path/to/mach_kernel /Volumes/Vol_Name_of_Tiger/mach_kernel`

以上により起動するが、[ディスプレイケーブルの抜き差し](./build_ja.md#black-screen-problem-on-tiger)が必要になることに注意。
