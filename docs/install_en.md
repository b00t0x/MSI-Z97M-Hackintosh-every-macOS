# Install guide
( Translated from [Japanese](./install_ja.md) )

Installation procedures and notes for each macOS version. Note that these steps are specific to Z97M Gaming, and may not apply to all motherboards.

Refer to [OpenCore-Install-Guide](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/mac-install.html) for creating the installer USB for each macOS version.

- [High Sierra (10.13)](#high-sierra-1013)
- [Mojave (10.14)](#mojave-1014)
- [Catalina (10.15)](#catalina-1015)
- [Big Sur (11) to Sonoma (14)](#big-sur-11-to-sonoma-14)
- [Sierra (10.12)](#sierra-1012)
- [Yosemite (10.10) / El Capitan (10.11)](#yosemite-1010--el-capitan-1011)
- [Mavericks (10.9)](#mavericks-109)
- [Lion (10.7) / Mountain Lion (10.8)](#lion-107--mountain-lion-108)
- [Snow Leopard (10.6)](#snow-leopard-106)
- [Leopard (10.5)](#leopard-105)
- [Tiger (10.4)](#tiger-104)

## High Sierra (10.13)
As indicated in [How to build](./build_en.md), it is recommended to install from version 10.13, which has the highest compatibility with all hardware.

10.13 is the simplest and can be installed directly from the installer USB.

## Mojave (10.14)
There are no specific installation notes, but GPU acceleration does not work immediately after installation. You need to apply the post-install patch from [macOS Mojave Patcher](http://dosdude1.com/mojave/).

Since the post-install patch needs to be reapplied with each update, apply all updates and security updates first.

As the patcher cannot be run on the target system, boot the 10.14 installer USB (or 10.14 recovery volume) again, and launch the patcher from Terminal as follows:
```
/path/to/macOS\ Mojave\ Patcher.app/Contents/Resources/macOS\ Post\ Install.app/Contents/MacOS/macOS\ Post\ Install
```
Check `Legacy Video Card Patch` and select the 10.14 volume, then apply the patch.

## Catalina (10.15)
Similar to 10.14, apply all updates and security updates before applying the post-install patch from [macOS Catalina Patcher](http://dosdude1.com/catalina/). Additionally, disabling AMFI is required.

You can disable AMFI by adding `amfi=0x80` to the config.plist. Since this disables AMFI for all macOS versions, disable it only for 10.15 as follows:
```
# get volume uuid
UUID=`diskutil info / | grep 'Volume UUID' | awk '{print $4}'`; echo $UUID

# mount Preboot
diskutil mount `diskutil list | grep Preboot | awk '{print $7}'`

# edit plist
sudo vim /Volumes/Preboot/$UUID/Library/Preferences/SystemConfiguration/com.apple.Boot.plist
```

Change this part:
```
	<key>Kernel Flags</key>
	<string></string>
```
to:
```
	<key>Kernel Flags</key>
	<string>amfi=0x80</string>
```

After applying the change, boot the 10.15 installer USB (or 10.15 recovery volume) and launch the patcher from Terminal as follows:
```
/path/to/macOS\ Catalina\ Patcher.app/Contents/Resources/macOS\ Post\ Install.app/Contents/MacOS/macOS\ Post\ Install
```
Check `Legacy Video Card Patch` and select the 10.15 volume from `Change...`, then apply the patch.

## Big Sur (11) to Sonoma (14)
From macOS 11 onwards, you can use [OpenCore Legacy Patcher](https://github.com/dortania/OpenCore-Legacy-Patcher), making it easier than 10.14/10.15.

After macOS installation, launch OCLP and apply the patch from `Post-Install Root Patch`.

## Sierra (10.12)
In 10.12, a fork bomb occurs during USB installer creation, so [address it](https://www.nicksherlock.com/2020/02/createinstallmedia-for-macos-sierra-is-a-fork-bomb/).

Additionally, since 10.12 and earlier do not support APFS, create an HFS+ partition for installation.

Due to signature issues, 10.12 and earlier installers may fail. After launching the installer, open Terminal and execute the installation with the following command:
```
installer -pkg /Volumes/Mac\ OS\ X\ Install\ DVD/Packages/OSInstall.mpkg -target /Volumes/Vol_Name_of_Sierra
```

## Yosemite (10.10) / El Capitan (10.11)
Install from Terminal as in 10.12.

## Mavericks (10.9)
Change the SMBIOS set in config.plist to `MacBookPro5,3` during installation, as `iMac15,1` SMBIOS is not compatible with 10.9 or earlier. The choice of `MacBookPro5,3` is explained in 10.5 section.

As of 2024, Mavericks cannot be downloaded from Apple, so use a previously saved installer or obtain one from [archive.org](https://archive.org/details/os-x-mavericks_202202). I use the installer downloaded from Apple before, so I didn't confirm the one from archive.org usable.

The installation procedure is same to 10.12, done from Terminal. 10.9 and earlier do not support NVMe, so install on AHCI PCIe SSD or SATA SSD.

## Lion (10.7) / Mountain Lion (10.8)
Similar to 10.9, temporarily change SMBIOS and install from Terminal.

## Snow Leopard (10.6)
As Apple does not distribute installers for 10.6 or earlier, follow [OpenCore-Install-Guide](https://dortania.github.io/OpenCore-Install-Guide/installer-guide/mac-install-dmg.html) to prepare the installer.

10.6 can be installed using the normal procedure without using Terminal.

## Leopard (10.5)
10.5 can be installed similarly to 10.6, but be cautious about SMBIOS. The [Acidanthera Image](https://archive.org/details/10.5.7-9-j-3050) description says "These installers are based off of the MacBookPro5,3 restore disks however support all models that natively ran 10.5.7.", but `MacBookPro5,3` SMBIOS is needed during installation.

If `MacBookPro5,3` is set, installation can proceed normally.

## Tiger (10.4)
Installation of 10.4 is more complex than 10.5 and earlier.

For Haswell generation motherboards, AppleAHCIPort.kext panics, so change the SATA controller operation mode in the BIOS from AHCI to IDE.

In this build, 10.5 - 10.9 is installed on PCIe AHCI SSD, 10.10 and later on NVMe SSD, and only 10.4 is installed on SATA SSD. However, even if the SATA SSD operates in IDE mode, installation is possible from 10.5 - 11. Therefore, having SATA SSD and NVMe SSD is sufficient, even if PCIe AHCI SSD is unavailable.

Note: Using both IDE mode and PCIe AHCI SSD requires [an older BIOS or BIOS mod](./build_ja.md#bios-mod).

As the 10.4 installer USB cannot be booted, perform the installation from an environment running 10.5.

1. Mount 10.4.10-8R4088-ACDT.dmg from [Acidanthera Image](https://archive.org/details/10.4.10-8-r-4088-acdt).
2. Open `/Volumes/Mac\ OS\ X\ Install\ Disc\ 1/System/Installation/Packages/OSInstall.mpkg`.
3. Select the target volume for installation.
4. Install [Mac OS X 10.4.11 Update (Intel)](https://support.apple.com/kb/DL171) on the target volume.
5. Install [Security Update 2009-005 (Tiger Intel)](https://support.apple.com/kb/DL932) on the target volume.
6. Replace `mach_kernel` with [custom kernel](../Kernels/mach_kernel).  
`sudo cp /path/to/mach_kernel /Volumes/Vol_Name_of_Tiger/mach_kernel`

Note that after this, [disconnecting and reconnecting the display cable](./build_en.md#black-screen-problem-on-tiger) is required for booting.
