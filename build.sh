#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "=> ⬇️  Clone V2Ray sources.."
git submodule update --init

echo "=> ⬇️  Get gomobile.."
cd vendor/v2ray-core
PATH=$PATH:~/go/bin
go get golang.org/x/mobile/cmd/gomobile

echo "=> 🍏 Build iOS library.."
gomobile bind --target=ios -o ../../Frameworks/V2Ray.xcframework
echo "=> ✅ iOS build completed"
