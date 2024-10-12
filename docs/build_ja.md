# How to build
- [はじめに](#はじめに)
- [Hardware](#hardware)
- [Kexts](#kexts)
- [Kernel](#kernel)
- [OpenCore config.plist](#opencore-configplist)
- [BIOS mod](#bios-mod)
- [BIOS settings](#bios-settings)

## はじめに
2024 年現在、Hackintosh は Apple Silicon の登場により終焉を待つ状況になっている。つまり、過去の傾向を考えると macOS 15 か 16 あたりが Intel macOS の最終バージョンになると思われる。

一方で、[OCLP](https://dortania.github.io/OpenCore-Legacy-Patcher/MODELS.html) では Leopard (10.5) 時代の Intel Mac であっても Sequoia (15) の動作がサポートされている。このことから、ハードウェアの構成次第では最初の Intel macOS である Tiger (10.4) から近い将来にリリースされる最後の Intel macOS までが動作する Hackintosh を構築することができるのでは？と考えた。

## Hardware
参考 : https://dortania.github.io/OpenCore-Install-Guide/macos-limits.html

### HCL
|macOS|i7-4790K|8800 GTS|E2205|88E8053|NVMe|AHCI|ATA|ALC1150|
|-----|--------|--------|-----|-------|----|----|---|-------|
|15   |✅      |☑️ 3.    |✅    |☑️ 5.   |✅  |✅  |❌  |✅     |
|14   |✅      |☑️ 3.    |✅    |☑️ 5.   |✅  |✅  |❌  |✅     |
|13   |✅      |☑️ 3.    |✅    |☑️ 5.   |✅  |✅  |❌  |✅     |
|12   |✅      |☑️ 3.    |✅    |☑️ 5.   |✅  |✅  |❌  |✅     |
|11   |✅      |☑️ 3.    |✅    |☑️ 5.   |✅  |✅  |☑️ 5.|✅     |
|10.15|✅      |☑️ 4.    |✅    |☑️ 5.   |✅  |✅  |☑️ 5.|✅     |
|10.14|✅      |☑️ 4.    |✅    |✅     |✅  |✅  |✅  |✅     |
|10.13|✅      |✅      |✅    |✅     |✅  |✅  |✅  |✅     |
|10.12|✅      |✅      |✅    |✅     |☑️ 6.|✅  |✅  |✅     |
|10.11|✅      |✅      |✅    |✅     |☑️ 6.|✅  |✅  |✅     |
|10.10|✅      |✅      |✅    |✅     |☑️ 7.|✅  |✅  |✅     |
|10.9 |✅      |✅      |✅    |✅     |❌  |✅  |✅  |✅     |
|10.8 |✅      |✅      |✅    |✅     |❌  |✅  |✅  |☑️ 8.   |
|10.7 |☑️ 1.    |✅      |✅    |✅     |❌  |✅  |✅  |☑️ 8.   |
|10.6 |☑️ 1.    |✅      |❌    |✅     |❌  |✅  |✅  |❌     |
|10.5 |☑️ 2.    |✅      |❌    |✅     |❌  |✅  |✅  |❌     |
|10.4 |☑️ 2.    |✅      |❌    |✅     |❌  |❌  |✅  |❌     |

1. CPUID を Nehalem (`0x0106A2`) に偽装
2. AppleIntelCPUPowerManagement を無効化
3. OCLP による root patch が必要
4. macOS Catalina / Mojave patcher による root patch が必要
5. Mojave の kext で動作
6. kernel patch または HackrNVMeFamily.kext で動作
7. NVMeGeneric.kext で動作
8. VoodooHDA.kext で動作

### CPU
Tiger をサポートする最後の CPU は Penryn ( Core 2 シリーズ ) となっている。しかし、他のハードウェアと異なり CPU は基本的に上位互換のはずであり、より新しい Intel CPU でも Tiger は動作するのでは？と考えた。

過去にメイン Hackintosh で使用していた i7-4790K を持っており、DDR3 メモリなどの余ったパーツを使用したかったこともあり、Haswell 世代の構成で構築できるか試すことにした。

### GPU
このビルドで最も重要なパーツとなる。なぜなら、Tiger で動作して最新の macOS でも動作する GPU 世代は非常に限られているため。試した限りでは、8800 GTS/GTX/Ultra の [G80](https://www.techpowerup.com/gpu-specs/?gpu=G80) 世代 GPU が唯一の選択肢だった。

Tiger では GeForce 7xxx、Radeon X1xxx が動作するが、これらは 32bit EFI の Mac にしか搭載されていなかった影響で Lion (10.7) までしかサポートされておらず、OCLP をもってしても最新の macOS で[利用することはできない](https://github.com/dortania/OpenCore-Legacy-Patcher/issues/108)。

一方で GeForce 9xxx、Radeon HD 3xxx は Leopard 以降にしかドライバが含まれておらず、Tiger では動作しないはず。

Tiger にドライバが含まれており、OCLP でもサポートされている GPU として下記を試したが、少なくとも自分は 8800 GTS しか Tiger での動作を確認できなかった。
* GeForce 8800 GTS
* GeForce 8600 GT
* Radeon HD 2400 PRO
* Radeon HD 2600 XT

MacBookPro (2007) が 8600M GT を搭載しているため、8600 GT は Tiger で動作するのではないかと考えたが、Leopard まででは動作したものの、Tiger で動作させることができなかった。

Radeon HD 2400 / 2600 は iMac (2007) が搭載しているためこれも動作するはずだが、DeviceProperties の設定が上手くできていないのか Tiger に限らず動作させることができなかった。

ちなみに、VRAM が 512MB の 8800 GTS は 8800 GT と同じ G92 コアであり Tiger では動作しないはず。320MB・640MB のモデルが必要。

#### Black screen problem on Tiger
Tiger では普通に起動すると画面が暗転し何も表示されなくなってしまう問題がある。これを解決するためには起動時にディスプレイケーブルの抜き差しが必要になる。

具体的には、OpenCore の picker で Tiger のボリュームを選択したらディスプレイケーブルを抜き、起動が完了するのに十分な時間 ( 10 秒程度 ) 待ってからケーブルを再接続することでデスクトップが正常に表示される。

自分の環境では DVI-HDMI アダプタを利用し HDMI モニタに接続しているが、他の接続方法で解決するかどうかは不明。

参考 :
* https://www.insanelymac.com/forum/topic/65849-geforce-8800-g80-only-easy-installer-tutorial/
* https://aquamac.proboards.com/thread/454/g80-working-hackintosh?page=1&scrollTo=2244

### NIC
32bit kernel である Tiger, Leopard で動作する NIC の kext は非常に限られている。

Z97M Gaming のオンボード NIC は Atheros Killer E2205 だが、これは Lion (10.7) までしか動作しなかった。Intel NIC + IntelSnowMausi であっても 32bit kernel では動作しない。

Realtek RTL8111 シリーズは Tiger でも動作する可能性がある。ただ、Haswell のような新しいマザーボードでは RTL8111 のリビジョンが上がっているので、Tiger で動作するかは不明。

Marvell Yukon 88E8053 は Tiger から kext が OOB で用意されている 1Gbps NIC である。オンボードで搭載されている例は少ないが、PCIe 拡張カードとして以前は流通していた。88E8053 の kext は Mojave (10.14) まで提供されており、Mojave の kext を利用することで Sequoia (15) であっても動作する優れた NIC である。

### SSD
NVMe SSD は Yosemite (10.10) 以降でしか動作しないため、Mavericks (10.9) 以前では AHCI が必要になる。通常の SATA SSD でも問題ないが、XP941 / SM951 といった PCIe AHCI SSD が最良の選択肢となる。

Tiger においては、少なくとも Haswell 世代のマザーボードでは AppleAHCIPort.kext が panic するという問題がありなんと AHCI が使えない。そのため、SATA コントローラーを IDE モードにして AppleIntelPIIXATA.kext を使う必要がある。AppleIntelPIIXATA.kext には当然 Haswell チップセットの device id などは記載されていないので、ATAPortInjector.kext を用意した。

### Audio
オンボードオーディオは ALC1150 だが、VoodooHDA を持ってしても 10.6 以前で動作しなかった。オーディオは適当な USB DAC で機能すると考えられるので、あまり気にしない。

ちなみに 8800 GTS には HDMI オーディオ機能はないため、Hackintosh に関係なく動作しない。

## Kexts
### List
|kext               |source|memo|
|-------------------|------|----|
|Lilu.kext          |https://github.com/acidanthera/Lilu|32bit カーネルでは panic する|
|VirtualSMC.kext    |https://github.com/acidanthera/VirtualSMC||
|FakeSMC-32.kext    |https://github.com/khronokernel/Legacy-Kexts|32bit カーネル用|
|AMFIPass.kext      |[https://github.com/dortania/OpenCore-Legacy-Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher/tree/main/payloads/Kexts/Acidanthera)|OCLP root patch 用|
|RestrictEvents.kext|https://github.com/acidanthera/RestrictEvents|macOS 11 以降での OTA 用|
|AppleALC.kext      |https://github.com/acidanthera/AppleALC||
|VoodooHDA.kext     |https://www.insanelymac.com/forum/topic/314406-voodoohda-302/|10.7, 10.8 用|
|NVinject.kext      |[XxX OS x86 10.4.11](https://archive.org/details/xxxosx8610point4point11rev2_202007) から抽出|10.4 用|
|USBToolBox.kext    |https://github.com/USBToolBox/kext|10.11 以降用|
|UTBMap.kext        |https://github.com/USBToolBox/tool から作成||
|GenericUSBXHCI.kext|https://sourceforge.net/projects/genericusbxhci/files/|ASM1142 用、10.7 向け|
|PXHCD.kext         |https://www.tonymacx86.com/threads/unlocked-latest-pxhcd-kext-version-1-0-11.79468/#post-494143|ASM1142 用、10.6 向け|
|NVMeFix.kext       |https://github.com/acidanthera/NVMeFix||
|HackrNVMeFamily-10_11_6.kext|https://github.com/RehabMan/patch-nvme より生成|10.11 用|
|NVMeGeneric.kext|[http://www.macvidcards.com/nvme-driver1.html](https://web.archive.org/web/20160614135522/http://www.macvidcards.com/nvme-driver1.html)|10.10 用|
|AppleIntelPIIXATA.kext|10.14 より抽出|10.15, 11 用|
|ATAPortInjector.kext|https://github.com/khronokernel/Legacy-Kexts を Z97 向けに修正|10.4 - 11 用|
|AppleYukon2.kext|10.14 より抽出|10.15 以降用|
|AtherosE2200Ethernet-2.3.3.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|10.13 以降用|
|AtherosE2200Ethernet-2.2.2.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|10.10 - 10.12 用|
|AtherosE2200Ethernet-2.1.0.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|10.9 用|
|AtherosE2200Ethernet-1.0.1.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|10.7, 10.8 用|
|BlueToolFixup.kext|https://github.com/acidanthera/BrcmPatchRAM|macOS 12 以降用|

## Kernel
残念ながら、Tiger については vanilla kernel で動作させることができていない ( panic せず起動はするが、青い画面が表示されデスクトップに進まない )。そのため、Hackintosh 黎明期の custom kernel を使う必要がある。

現在 Tiger の custom kernel を入手することは難しいが、例えば archive.org から入手できる [XxX OS x86 10.4.11](https://archive.org/details/xxxosx8610point4point11rev2_202007) から custom kernel を取り出すことができる。

本ビルドでは [8.9.1 kernel SSE3 apr18](../Kernels/mach_kernel) を利用しており、これは 10.4.9 の custom kernel となるが、10.4.10 / 10.4.11 も起動することができる。8.10.1 以降の custom kernel では vanilla kernel と同じ症状になり利用できなかった。また、10.4.9 の vanilla kernel も同様に利用できない。

ESP に `Kernels/mach_kernel` のディレクトリ構造で custom kernel を配置し、config.plist で `CustomKernel` を有効にすることで適用できるが、Tiger 以外のバージョンにも適用され起動できなくなってしまうので、`CustomKernel` は使用せず直接 Tiger のボリュームに配置する。

## OpenCore config.plist
config.plist を作成するにあたり、特に古い macOS を起動するためにいくつか注意する点があるので記載する。あくまで Z97M Gaming においての設定であり、どのマザーボードにも適用できるわけではないことに注意。

### Booter
#### Patch
`-no_compat_check` の使用を避けるため、[このパッチ](https://github.com/dortania/OpenCore-Legacy-Patcher/blob/432736eb98d7f8f69b5db229fcec861aceb356a4/payloads/Config/config.plist#L220-L267)を適用する。

参考 :
* https://github.com/5T33Z0/OC-Little-Translated/tree/main/09_Board-ID_VMM-Spoof
* https://dortania.github.io/OpenCore-Legacy-Patcher/PATCHEXPLAIN.html#opencore-settings

#### Quirks
10.6 以前を起動するために `RebuildAppleMemoryMap` が、10.5 以前を起動するために `DevirtualiseMmio` が必要だった。

また、BIOS 1.9 では `ForceExitBootServices` が 10.8 以下を起動するために必要だった。BIOS 1.4 では不要。

#### MmioWhitelist
`DevirtualiseMmio` を有効化すると、今度は 10.6 以降が起動しなくなる。これを回避するために、`MmioWhitelist` の調整が必要となった。

参考 : https://dortania.github.io/OpenCore-Install-Guide/extras/kaslr-fix.html#using-devirtualisemmio

ただ、`DevirtualiseMmio` と `MmioWhitelist` の組み合わせで全ての macOS を起動できたのはどうやら幸運だったようで、自分が試したいくつかの環境では 10.5 以前のみ起動する設定と 10.6 以降のみ起動する設定しか作ることができなかった。

### DeviceProperties
参考 : https://dortania.github.io/OpenCore-Post-Install/gpu-patching/nvidia-patching/

ただし、このパッチは 10.4 に対しては効かず、NVinject.kext を使う必要があった。

### Kernel
#### Add
Lilu.kext は 32bit でも動作するはずだが panic を起こしてしまったので、Lilu とそのプラグインは `x86_64` でのみロードされるように設定している。

#### Block
10.4 / 10.5 では panic を起こす kext があるのでブロックしている。これにより 10.4 で AHCI が使えなくなるため、IDE モードの使用が必要となる。

#### Force
IONetworkingFamily.kext を強制ロードしないと AtherosE2200Ethernet.kext が動かないケースがあるため設定する。

#### Patch
`DummyPowerManagement` が 10.4 / 10.5 でのみ必要となるため、`Emulate` では設定せず同等のパッチを記載している。

また、10.12 においては HackrNVMeFamily.kext を利用する代わりに IONVMeFamily.kext にパッチを当てている。

#### Emulate
10.7 以前は Haswell に対応していないため Nehalem (`0x0106A2`) の CPUID に偽装している。なぜか Ivy Bridge / Sandy Bridge ではなく Nehalem の CPUID にすることで `DummyPowerManagement` が不要になる。

また、10.4 / 10.5 は CPUID の偽装が必要なかったため、10.6 / 10.7 にのみ適用している。

#### Quirks
10.4 では `ProvideCurrentCpuInfo` が必要。

### Misc
#### Boot
本質的ではないが、`PickerVariant` に `GoldenGate_16_9` を指定している。これは、8800 GTS には GOP が無いことでブートローダーでは 1280x1024 までしか表示できないことにより 16:9 ディスプレイで表示が歪んでしまうので、アイコンの縦横比を調整したもの。画面を引き伸ばさず表示できるディスプレイであれば、`GoldenGate` に切り替える。

### NVRAM
#### Add
`revpatch=sbvmm` については [RestrictEvents](https://github.com/acidanthera/RestrictEvents) を参照のこと。

### PlatformInfo
#### Generic
[config_noserial.plist](../EFI/OC/config_noserial.plist) では `SystemSerialNumber` を設定していないため、[OCAuxiliaryTools](https://github.com/ic005k/OCAuxiliaryTools) などを利用して設定すること。

## BIOS mod
BIOS バージョン 1.6 以降では、SATA を IDE モードにすると PCIe AHCI SSD が OpenCore から見えなくなるという問題がある。BIOS 1.4 ではこの問題は発生しない。

この問題を解決するため、[このガイド](https://winraid.level1techs.com/t/guide-how-to-get-m-2-pcie-connected-samsung-ahci-ssds-bootable/31221)に従って BIOS 1.9 に PCIe AHCI SSD 用モジュールを導入した mod BIOS を作成して利用している。

各種ファイルは[こちら](../bios)に用意した。

## BIOS settings
* SATA Mode - IDE Mode
* XHCI Hand-off - Enabled
* EHCI Hand-off - Enabled
* Fast Boot - Disabled
* Boot mode select - UEFI
* Intel VT-D Tech - Disabled
* CFG Lock - Disabled

CSM に関するメニューはないが、GPU が UEFI に対応していないため CSM を無効にすることはできない。
