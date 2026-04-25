#!/usr/bin/env bash
set -euo pipefail

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "未检测到 XcodeGen。请先安装：brew install xcodegen"
  exit 1
fi

xcodegen generate
xcodebuild \
  -project EmbyWikiWebView.xcodeproj \
  -scheme EmbyWikiWebView \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  DEVELOPMENT_TEAM="" \
  clean build

rm -rf Payload EmbyWikiWebView-unsigned.ipa
mkdir -p Payload
cp -R build/Build/Products/Release-iphoneos/EmbyWikiWebView.app Payload/EmbyWikiWebView.app
/usr/bin/zip -qry EmbyWikiWebView-unsigned.ipa Payload

echo "已生成：EmbyWikiWebView-unsigned.ipa"
