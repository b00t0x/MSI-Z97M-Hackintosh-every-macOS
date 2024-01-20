#!/bin/bash

plist_src="EFI/OC/config.plist"
plist_dest="EFI/OC/config_noserial.plist"

if [ ! -e $plist_src ]; then
  echo "${plist_src} does not exist."
  exit 1
fi

cp $plist_src $plist_dest

/usr/libexec/PlistBuddy -c "set Misc:Boot:InstanceIdentifier" $plist_dest
/usr/libexec/PlistBuddy -c "delete Misc:Entries" $plist_dest
/usr/libexec/PlistBuddy -c "add Misc:Entries array" $plist_dest

for key in MLB ROM SystemSerialNumber SystemUUID; do \
  /usr/libexec/PlistBuddy -c "set PlatformInfo:Generic:${key}" $plist_dest
done

