#!/bin/bash

BRANCH=ivpn-ios-app
IN_LIBOQS=lib/Release/liboqs.a
OUT_LIBOQS_IPHONEOS=../../IVPNClient/liboqs/liboqs-iphoneos.a
OUT_LIBOQS_IPHONESIMULATOR=../../IVPNClient/liboqs/liboqs-iphonesimulator.a

set -e

# Clone liboqs
echo "=> Clone liboqs"
mkdir -p submodules
cd submodules
if [ ! -d "liboqs" ] ; then
    git clone  --depth 1 --branch ${BRANCH} https://github.com/ivpn/liboqs
fi
cd liboqs

# liboqs for iphoneos
echo "=> Build liboqs-iphoneos.a"
cmake -G Xcode -DOQS_USE_OPENSSL=OFF -DOQS_BUILD_ONLY_LIB=ON -DOQS_DIST_BUILD=ON -DOQS_MINIMAL_BUILD="KEM_kyber_1024;" -DCMAKE_TOOLCHAIN_FILE=.CMake/toolchain_ios.cmake -DPLATFORM=OS64
cmake --build . --config Release

echo "=> Copy liboqs.a to ${OUT_LIBOQS_IPHONEOS}"
cp -f $IN_LIBOQS $OUT_LIBOQS_IPHONEOS

echo "=> Clean files"
rm -rf $IN_LIBOQS
git clean -fd

echo "=> Build completed for ${OUT_LIBOQS_IPHONEOS}"

# liboqs for iphonesimulator
echo "=> Build liboqs-iphonesimulator.a"
cmake -G Xcode -DOQS_USE_OPENSSL=OFF -DOQS_BUILD_ONLY_LIB=ON -DOQS_DIST_BUILD=ON -DOQS_MINIMAL_BUILD="KEM_kyber_1024;" -DCMAKE_TOOLCHAIN_FILE=.CMake/toolchain_ios.cmake -DPLATFORM=SIMULATORARM64
cmake --build . --config Release

echo "=> Copy liboqs.a to ${OUT_LIBOQS_IPHONESIMULATOR}"
cp -f $IN_LIBOQS $OUT_LIBOQS_IPHONESIMULATOR

echo "=> Clean files"
rm -rf $IN_LIBOQS
git clean -fd

echo "=> Build completed for ${OUT_LIBOQS_IPHONESIMULATOR}"


echo "=> BUILD SUCCESSFUL"
