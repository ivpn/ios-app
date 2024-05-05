#!/bin/bash

set -e

echo "=> Get gomobile.."
cd V2RayControl
PATH=$PATH:~/go/bin
go get golang.org/x/mobile/cmd/gomobile

echo "=> Build iOS library.."
OUT_XCFRAMEWORK=../Frameworks/V2RayControl.xcframework
gomobile bind -trimpath -ldflags "-s -w" --target=ios -o ${OUT_XCFRAMEWORK}
echo "=> iOS build completed (out: ${OUT_XCFRAMEWORK})"
echo " !!!!!!!!!!!!!!!! "
echo " NOTE! The iOS project required the 'libresolv.tbd' library to be added to the project when using ${OUT_XCFRAMEWORK}"
echo " (Project->Build Phases->Link Binary With Libraries->Add Other->/usr/lib/libresolv.tbd)"
echo " !!!!!!!!!!!!!!!! "