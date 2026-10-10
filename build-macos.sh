#!/bin/bash
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
    printf '%s\n' '此脚本需要 macOS 和完整 Xcode；Windows 无法编译 iOS App。' >&2
    exit 1
fi

cd "$(dirname "$0")"
xcodebuild -version
xcrun --sdk iphoneos --show-sdk-path >/dev/null
swift test

mkdir -p build
taskStage=$(mktemp -d "$PWD/build/staging.XXXXXX")
trap 'rm -rf "$taskStage"' EXIT

xcodebuild \
    -project DriveFly.xcodeproj \
    -scheme DriveFly \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -derivedDataPath "$taskStage/DerivedData" \
    CODE_SIGNING_ALLOWED=NO \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    DEVELOPMENT_TEAM="" \
    build

taskApp="$taskStage/DerivedData/Build/Products/Release-iphoneos/DriveFly.app"
if [ ! -f "$taskApp/DriveFly" ]; then
    printf '%s\n' '未找到 iOS 真机 App，停止打包。' >&2
    exit 1
fi

mkdir "$taskStage/Payload"
ditto "$taskApp" "$taskStage/Payload/DriveFly.app"
# This integrity signature needs no Apple account; AltServer must replace it before installation.
codesign --force --sign - --timestamp=none "$taskStage/Payload/DriveFly.app"
codesign --verify --strict "$taskStage/Payload/DriveFly.app"
ditto -c -k --keepParent "$taskStage/Payload" "$taskStage/DriveFly-iOS.ipa"
mv "$taskStage/DriveFly-iOS.ipa" "$PWD/build/DriveFly-iOS.ipa"

printf '%s\n' '已生成 build/DriveFly-iOS.ipa。此包需要 AltServer 使用本人 Apple 账号重新签名，不能直接安装。'
