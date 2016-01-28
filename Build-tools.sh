#!/bin/sh

installPath=$1

. ../Env.sh

# Build (temporary) C-compiler
setInstallPaths "Temporary-C"
buildInTree musl "--syslibdir=/Software/C-compiler/Libraries"
export CC=/Software/Temporary-C/musl-gcc

# Build (build) tools
setInstallPaths "Build-tools"
buildPkg bison
buildPkg flex
buildPkg m4
buildPkg make
buildPkg pkg-config "--with-internal-glib"

# Build systemd
setInstallPaths "Services"
buildPkg systemd
