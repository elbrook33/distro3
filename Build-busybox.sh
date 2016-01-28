#!/bin/sh

installPath=$1

if [ `grep -c busybox Installed.list` -gt 0 ] ; then
	echo "Skipping busybox"
else
	tar -xf ../Packages/busybox-*
	cd busybox-*
		# Patch and copy config
		patch -p1 < ../../Patches/busybox.patch
		cp ../../Patches/busybox-config .config

		# Build
		make && echo "busybox" >> ../Installed.list

		# Install
		mkdir --parents /Software/Command-line
		cp busybox /Software/Command-line/busybox
		for i in `./busybox --list` ; do
			ln -s busybox /Software/Command-line/$i
		done
		
		# Extra links
		cp busybox $installPath/Shell/bin/sh
		mkdir --parents $installPath/Software/Command-line/Settings
		cp ../Patches/busybox-profile $installPath/Software/Command-line/Settings/profile
	cd ..
	rm -R busybox-*
fi