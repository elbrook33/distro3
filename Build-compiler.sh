#!/bin/sh

installPath=$1

. ../Env.sh
setInstallPaths "C-compiler"

# Dependencies
export CC=/Software/Temporary-C/musl-gcc
buildPkg gmp && findBuildPaths	2>>Log
buildPkg mpfr
buildPkg mpc

# Build
export crossTarget=x86_64-linux-musl
if [ `grep -c gcc-static Installed.list` -gt 0 ] ; then
	echo "Skipping gcc-static"
else
	# Expand a pre-built compiler
	tar -xf ../Packages/crossx86-$crossTarget-*
		PATH=$PATH:`pwd`/$crossTarget/bin
	
	# Make some symlinks so the build can complete
	mkdir --parents $installPath/Software/C-compiler/$crossTarget	2>>Log
	mkdir --parents $installPath/Software/C-compiler/Headers	2>>Log
	mkdir --parents $installPath/Software/C-compiler/Libraries	2>>Log
	ln -sf ../Headers $installPath/Software/C-compiler/$crossTarget/include	2>>Log
	ln -sf ../Libraries $installPath/Software/C-compiler/$crossTarget/lib	2>>Log
	
	# Get recipe for building a musl-gcc and run
	git clone https://github.com/GregorR/musl-cross
	cd musl-cross
		if [ ! -f .hasBeenPatched ] ; then
			patch -p1 < ../../Patches/gcc-static.patch && touch .hasBeenPatched
		fi
		mv config-static.sh config.sh
		sh build.sh
	cd ..
	
	echo "gcc-static" >> Installed.list
fi
