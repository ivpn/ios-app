#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

V2RAY_VER=v4.35.0

echo "=> ⬇️  Clone V2Ray sources.."
git submodule update --init

echo "=> ⬇️  Get gomobile.."
cd vendor/v2ray
git checkout ${V2RAY_VER}
PATH=$PATH:~/go/bin
go get golang.org/x/mobile/cmd/gomobile

echo "=> 🍏 Build iOS library.."
gomobile bind -trimpath -ldflags "-s -w" --target=ios -o ../../build/ios/V2Ray.xcframework
echo "=> ✅ iOS build completed"
