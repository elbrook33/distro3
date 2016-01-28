#!/bin/sh

CFLAGS="-fPIC -static"
CXXFLAGS="-fPIC -static"
LDFLAGS="-static"
LC_ALL=POSIX
export CFLAGS CXXFLAGS LDFLAGS LC_ALL

setInstallPaths() {
	export pathOptions="\
		--prefix=/Software/$1	\
		--bindir=/Software/$1	\
		--sbindir=/Software/$1	\
		--libexecdir=/Software/$1/Internal	\
		--sysconfdir=/Software/$1/Settings	\
		--sharedstatedir=/Software/$1/Settings	\
		--localstatedir=/Software/$1/Settings	\
		--libdir=/Software/$1/Libraries	\
		--includedir=/Software/$1/Headers	\
		--datarootdir=/Software/$1/Resources	\
		--mandir=/Software/$1/Resources/man"
	installCategory=Software/$1
}

fixInstallPath() {
	if [ -d /$installCategory/$1 ] ; then
		mkdir --parents /$installCategory/$2	2>>install.log
		mv /$installCategory/$1/* /$installCategory/$2	2>>install.log
		rmdir /$installCategory/$1
	fi
}

fixInstallPaths() {
	fixInstallPath bin
	fixInstallPath sbin
	fixInstallPath include Headers
	fixInstallPath lib Libraries
	fixInstallPath lib64 Libraries
	fixInstallPath libexec Internal
	fixInstallPath man Resources/man
	fixInstallPath share Resources
}

buildBase() {
# Parameters:
# $1 - Package
# $2 - inTree/outOfTree
# $3 - Extra configure options
	packageName=$1
	packageDir=`tar -tf ../Packages/$packageName-* | head -n 1 | cut -d "/" -f 1`
	
	# Check if already installed
	if [ `grep -c $packageDir Installed.list` -gt 0 ] ; then
		echo "Skipping $packageName"
		return
	else
		echo "Building $packageName"
	fi

	# Extract package
	if [ ! -d $packageDir ] ; then
		tar -xf ../Packages/$1-*
	fi
	if [ $2 = "outOfTree" ] && [ ! -d $packageName-build ] ; then
		mkdir $packageName-build
	fi
	
	# Patch
	cd $packageDir
		if [ -f ../../Patches/$packageName.patch ] && [ ! -f .hasBeenPatched ] ; then
			patch -p1 < ../../Patches/$packageName.patch \
			&& touch .hasBeenPatched
		fi
	cd ..
	
	# Build
	[ $2 = "outOfTree" ] && cd $packageName-build || cd $packageDir
		../$packageDir/configure $pathOptions $3	>>config.log
		make -j3 CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS"	>>make.log
		if make install DESTDIR=$installPath	>> install.log ; then
			fixInstallPaths
			cd ..
			rm -Rf $packageDir && rm -Rf $packageName-build
			echo $packageDir >> Installed.list
		else
			cd ..
	fi
}

buildPkg() {
	buildBase "$1" "outOfTree" "$2"
}
buildInTree() {
	buildBase "$1" "inTree" "$2"
}

findBuildPaths() {
	CPATHS="-I/System/Headers"
	CPATHS="$CPATHS `find /Apps/*/Headers -maxdepth 0 -type d -printf " -I%p"`"
	CPATHS="$CPATHS `find /Software/*/Headers -maxdepth 0 -type d -printf " -I%p"`"
	export CFLAGS="-fPIC -static $CPATHS"
	export CXXFLAGS="-fPIC -static $CPATHS"

	LDPATHS="-static"
	LDPATHS="$LDPATHS `find /Apps/*/Libraries -maxdepth 0 -type d -printf " -L%p"`"
	LDPATHS="$LDPATHS `find /Software/*/Libraries -maxdepth 0 -type d -printf " -L%p"`"
	export LDFLAGS="$LDPATHS"
}
