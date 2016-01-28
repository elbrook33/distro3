#!/bin/sh

#
# BUILD DISTRO
#
# Usage:
# ./Build.sh TARGET-DEVICE MOUNT-PATH
#

if [ -z $2 ] ; then
	installDevice=/dev/sda7
	installPath=~/Desmond/Mount
else
	installDevice=$1
	installPath=$2
fi

echo "Installing to $installDevice (via $installPath)"
sudo mount $installDevice $installPath

cd Build
	echo > Log
	touch Installed.list

	# Set up partition
	mkdir $installPath	2>>Log
	mkdir $installPath/Apps	2>>Log
	mkdir $installPath/Documents		2>>Log
	mkdir $installPath/Documents/Temporary	2>>Log
	mkdir $installPath/Documents/Trash	2>>Log
	mkdir $installPath/Shell	2>>Log
	mkdir $installPath/Shell/Apps	2>>Log
	mkdir $installPath/Shell/Documents	2>>Log
	mkdir $installPath/Shell/Software	2>>Log
	mkdir $installPath/Shell/System	2>>Log
	mkdir $installPath/Shell/bin	2>>Log	# For /bin/sh (copy of bash)
	mkdir $installPath/Shell/dev	2>>Log
	mkdir $installPath/Shell/proc	2>>Log
	mkdir $installPath/Shell/sys	2>>Log
	mkdir $installPath/Software	2>>Log
	mkdir $installPath/System	2>>Log
	mkdir $installPath/System/Headers	2>>Log
	mkdir $installPath/System/Libraries	2>>Log
	mkdir $installPath/System/Settings	2>>Log

	# Symlinks
	ln -sf .	$installPath/Shell/Shell	2>>Log
	ln -sf Documents/Temporary	$installPath/Shell/tmp	2>>Log

	# Copy settings
	cp ../Patches/etc-fstab	$installPath/System/Settings/fstab	2>>Log

	# Build and install
	sudo ln -s $installPath/Software /
	../Build-kernel.sh $installPath
	../Build-busybox.sh $installPath
	../Build-tools.sh $installPath
	../Build-compiler.sh $installPath
	sudo rm /Software
cd ..

# Boot
sudo ./Boot.sh $installDevice $installPath
