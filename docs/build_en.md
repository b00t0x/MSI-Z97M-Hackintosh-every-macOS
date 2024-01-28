# How to Build
( Translated from [Japanese](./build_ja.md) )

## Introduction
As of 2024, Hackintosh is facing its demise with the transition to Apple Silicon. In other words, considering past trends, macOS 15 or 16 is expected to be the final version of Intel macOS.

On the other hand, [OCLP](https://dortania.github.io/OpenCore-Legacy-Patcher/MODELS.html) supports Sonoma (14) even on Intel Macs from the Leopard (10.5) era. From this, I wondered if it would be possible to build a Hackintosh that runs from the first Intel macOS, Tiger (10.4), to the last Intel macOS released in the near future, depending on the hardware configuration.

## Hardware
Reference: https://dortania.github.io/OpenCore-Install-Guide/macos-limits.html

### HCL
|macOS|i7-4790K|8800 GTS|E2205|88E8053|NVMe|AHCI|ATA|ALC1150|
|-----|--------|--------|-----|-------|----|----|---|-------|
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

1. Spoof CPUID to Nehalem (`0x0106A2`)
2. Disable AppleIntelCPUPowerManagement
3. OCLP root patch is required
4. Root patch with macOS Catalina/Mojave patcher is required
5. Works with Mojave kext
6. Works with kernel patch or HackrNVMeFamily.kext
7. Works with NVMeGeneric.kext
8. Works with VoodooHDA.kext

### CPU
The last CPU to support Tiger is Penryn (Core 2 series). However, unlike other hardware, CPUs are generally expected to have backward compatible, newer Intel CPUs should also work with Tiger. Since I had an i7-4790K that I used in my main Hackintosh in the past and wanted to use spare parts like DDR3 memory, I decided to try building with a Haswell generation.

### GPU
GPU is the most crucial component of this build. Because GPUs that work with Tiger and also work with the latest macOS are very limited. As far as I tried, the [G80](https://www.techpowerup.com/gpu-specs/?gpu=G80) generation GPU ( 8800 GTS/GTX/Ultra ) is the only option.

While GeForce 7xxx and Radeon X1xxx work on Tiger, they are only supported up to Lion (10.7) due to being installed only on 32-bit EFI Macs. Moreover, even with OCLP, it's not possible to use them on the latest macOS as reported [here](https://github.com/dortania/OpenCore-Legacy-Patcher/issues/108).

On the other hand, GeForce 9xxx and Radeon HD 3xxx drivers included only from Leopard onwards so expected not to work on Tiger.

I tested the following GPUs supported by OCLP and have drivers for Tiger:
* GeForce 8800 GTS
* GeForce 8600 GT
* Radeon HD 2400 PRO
* Radeon HD 2600 XT

I thought the 8600 GT might work on Tiger because MacBook Pro (2007) has an 8600M GT. While it worked up to Leopard, I couldn't get it to work on Tiger.

Radeon HD 2400/2600 are built in the iMac (2007), so it should work, but for some reason, I couldn't get it to work on Tiger or any other macOS perhaps DeviceProperties settings were not set properly.

In addition, 8800 GTS with 512MB VRAM has the same G92 core as the 8800 GT and is not expected to work on Tiger. You need the 320MB or 640MB models.

#### Black Screen Problem on Tiger
There has an issue where the screen goes black and nothing is displayed when boots up. To resolve this, perform the following steps:

1. Select the Tiger volume in OpenCore picker.
2. Disconnect the display cable.
3. Wait for a sufficient time (about 10 seconds) after selecting the volume and reconnect the cable.

This should result in the desktop being displayed correctly.

I'm using an HDMI display with a DVI-HDMI adapter, it is unknown if the issue is resolved with alternative connection methods.

References:
* https://www.insanelymac.com/forum/topic/65849-geforce-8800-g80-only-easy-installer-tutorial/
* https://aquamac.proboards.com/thread/454/g80-working-hackintosh?page=1&scrollTo=2244

### NIC
There are limited kexts for NICs that work on 32-bit kernels like Tiger and Leopard.

* The onboard NIC Atheros Killer E2205 on Z97M Gaming only works up to Lion (10.7).
  * Even Intel NIC + IntelSnowMausi doesn't work on 32-bit kernels.
* Realtek RTL8111 series might work on Tiger, but compatibility is uncertain with updated RTL8111 revisions on newer motherboards.

Marvell Yukon 88E8053 is a 1Gbps NIC with an OOB kext in Tiger. It had limited onboard implementations but was available as a PCIe expansion card. The kext works up to Mojave (10.14), and using Mojave's kext allows it to work on Sonoma (14).

### SSD
NVMe SSDs only work from Yosemite (10.10) onwards, requiring AHCI for Mavericks (10.9) and earlier. While regular SATA SSDs work, there's an issue with AppleAHCIPort.kext panic on Tiger, making AHCI unusable. Thus, using SATA controllers in IDE mode with AppleIntelPIIXATA.kext is necessary, with the inclusion of ATAPortInjector.kext for Haswell chipset support.

### Audio
The onboard ALC1150 audio doesn't work on 10.6 and earlier even with VoodooHDA. Consider using a USB DAC for audio functionality.

Note that the 8800 GTS lacks HDMI audio functionality, so it won't work regardless of Hackintosh setup.

## Kexts
### List
|kext               |source|memo|
|-------------------|------|----|
|Lilu.kext          |https://github.com/acidanthera/Lilu|Panic with 32-bit kernel|
|VirtualSMC.kext    |https://github.com/acidanthera/VirtualSMC||
|FakeSMC-32.kext    |https://github.com/khronokernel/Legacy-Kexts|For 32-bit kernel|
|AMFIPass.kext      |[https://github.com/dortania/OpenCore-Legacy-Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher/tree/main/payloads/Kexts/Acidanthera)|For OCLP root patch|
|RestrictEvents.kext|https://github.com/acidanthera/RestrictEvents|For OTA on macOS 11 and later|
|AppleALC.kext      |https://github.com/acidanthera/AppleALC||
|VoodooHDA.kext     |https://www.insanelymac.com/forum/topic/314406-voodoohda-302/|For 10.7, 10.8|
|NVinject.kext      |Extracted from [XxX OS x86 10.4.11](https://archive.org/details/xxxosx8610point4point11rev2_202007)|For 10.4|
|USBToolBox.kext    |https://github.com/USBToolBox/kext|For 10.11 and later|
|UTBMap.kext        |Generated from https://github.com/USBToolBox/tool||
|GenericUSBXHCI.kext|https://sourceforge.net/projects/genericusbxhci/files/|For ASM1142, with 10.7|
|PXHCD.kext         |https://www.tonymacx86.com/threads/unlocked-latest-pxhcd-kext-version-1-0-11.79468/#post-494143|For ASM1142, with 10.6|
|NVMeFix.kext       |https://github.com/acidanthera/NVMeFix||
|HackrNVMeFamily-10_11_6.kext|Generated from https://github.com/RehabMan/patch-nvme|For 10.11|
|NVMeGeneric.kext|[http://www.macvidcards.com/nvme-driver1.html](https://web.archive.org/web/20160614135522/http://www.macvidcards.com/nvme-driver1.html)|For 10.10|
|AppleIntelPIIXATA.kext|Extracted from 10.14|For 10.15, 11|
|ATAPortInjector.kext|Modified for Z97 from https://github.com/khronokernel/Legacy-Kexts|For 10.4 - 11|
|AppleYukon2.kext|Extracted from 10.14|For 10.15 and later|
|AtherosE2200Ethernet-2.3.3.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|For 10.13 and later|
|AtherosE2200Ethernet-2.2.2.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|For 10.10 - 10.12|
|AtherosE2200Ethernet-2.1.0.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|For 10.9|
|AtherosE2200Ethernet-1.0.1.kext|https://www.insanelymac.com/forum/files/file/313-atherose2200ethernet/|For 10.7, 10.8|
|BlueToolFixup.kext|https://github.com/acidanthera/BrcmPatchRAM|For macOS 12 and later|

## Kernel
Unfortunately, I couldn't make run Tiger on a vanilla kernel (it boots without panic but gets stuck on a blue screen). Custom kernels from the early Hackintosh days are necessary.

While obtaining Tiger custom kernels is challenging, one example is extracting the custom kernel from [XxX OS x86 10.4.11](https://archive.org/details/xxxosx8610point4point11rev2_202007). My build uses the [8.9.1 kernel SSE3 apr18](../Kernels/mach_kernel), which works for 10.4.10 and 10.4.11. Custom kernels from 8.10.1 onwards and vanilla kernels (including 10.4.9) aren't usable.

Custom kernel can be used by placing it on `Kernels/mach_kernel` path in the ESP and enabling `CustomKernel` in config.plist. But it causes boot failure with other macOS versions, so place the custom kernel directly in the Tiger volume without using `CustomKernel`.

## OpenCore config.plist
When creating the config.plist, there are several considerations for booting older macOS versions. The settings provided are specific to the Z97M Gaming motherboard and may not be universally applicable.

### Booter
#### Patch
To avoid using `-no_compat_check`, apply [this patch](https://github.com/dortania/OpenCore-Legacy-Patcher/blob/432736eb98d7f8f69b5db229fcec861aceb356a4/payloads/Config/config.plist#L220-L267).

References:
* https://github.com/5T33Z0/OC-Little-Translated/tree/main/09_Board-ID_VMM-Spoof
* https://dortania.github.io/OpenCore-Legacy-Patcher/PATCHEXPLAIN.html#opencore-settings

#### Quirks
`RebuildAppleMemoryMap` is required for 10.6 and earlier, and `DevirtualiseMmio` is required for 10.4 / 10.5.

#### MmioWhitelist
When enabling `DevirtualiseMmio`, 10.6 and later stop working. Adjustments to `MmioWhitelist` are required to prevent conflicts.

Reference: https://dortania.github.io/OpenCore-Install-Guide/extras/kaslr-fix.html#using-devirtualisemmio

However, achieving a configuration that boots all macOS versions with the combination of `DevirtualiseMmio` and `MmioWhitelist` seems fortunate. Some environments might need separate configurations for booting only 10.5 and earlier or 10.6 and later.

### DeviceProperties
Reference: https://dortania.github.io/OpenCore-Post-Install/gpu-patching/nvidia-patching/

However, this patch is not effective for 10.4, NVinject.kext is required.

### Kernel
#### Add
While Lilu.kext should work on 32-bit, it caused panic, so it's configured to load only in `x86_64` mode.

#### Block
Blocks kexts that panic in 10.4 and 10.5. This results in AHCI being unusable in 10.4, requiring the use of IDE mode.

#### Force
Force loads IONetworkingFamily.kext to make AtherosE2200Ethernet.kext working.

#### Patch
`DummyPowerManagement` is required only for 10.4 and 10.5. Instead of enabling it in `Emulate`, an equivalent patch is applied.

For 10.12, a patch is applied to IONVMeFamily.kext instead of using HackrNVMeFamily.kext.

#### Emulate
Haswell is unsupported in 10.7 and earlier, so spoof Nehalem (`0x0106A2`) CPUID. Interestingly, using Nehalem's CPUID instead of Ivy Bridge or Sandy Bridge avoids the need for `DummyPowerManagement`.

CPUID spoof is applied only for 10.6 and 10.7 because 10.4 and 10.5 don't need the spoof.

#### Quirks
`ProvideCurrentCpuInfo` is required for 10.4.

### Misc
#### Boot
Not essential, but `PickerVariant` is set to `GoldenGate_16_9`. This adjustment is made because the 8800 GTS lacks GOP, limiting the bootloader to display only up to 1280x1024. This causes distortion on a 16:9 display, so the icon aspect ratio is modified. If using a display that can show without stretching, switch to `GoldenGate`.

### NVRAM
#### Add
For details on `revpatch=sbvmm`, refer to [RestrictEvents](https://github.com/acidanthera/RestrictEvents).

### PlatformInfo
#### Generic
In [config_noserial.plist](../EFI/OC/config_noserial.plist), `SystemSerialNumber` is not set. Use tools like [OCAuxiliaryTools](https://github.com/ic005k/OCAuxiliaryTools) to configure it.

## UEFI settings
* SATA Mode - IDE Mode
* XHCI Hand-off - Enabled
* EHCI Hand-off - Enabled
* Fast Boot - Disabled
* Boot mode select - UEFI
* Intel VT-D Tech - Disabled
* CFG Lock - Disabled

There is no option related to CSM, but since the GPU does not support UEFI, disabling CSM is not possible.
