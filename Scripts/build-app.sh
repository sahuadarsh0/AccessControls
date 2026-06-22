#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="RouteBar"
APP_DIR="$ROOT_DIR/build/${APP_NAME}.app"
EXECUTABLE_PATH="$ROOT_DIR/.build/release/${APP_NAME}"
STATUS_ICON_PATH="$ROOT_DIR/Sources/RouteBarApp/Resources/RouteBarStatusIcon.png"

cd "$ROOT_DIR"
swift build -c release --product "$APP_NAME"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$EXECUTABLE_PATH" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/AppBundle/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$ROOT_DIR/AppBundle/RouteBar.icns" "$APP_DIR/Contents/Resources/RouteBar.icns"
cp "$STATUS_ICON_PATH" "$APP_DIR/Contents/Resources/RouteBarStatusIcon.png"

plutil -lint "$APP_DIR/Contents/Info.plist"
codesign --force --deep --sign - "$APP_DIR" >/dev/null
touch "$APP_DIR" "$APP_DIR/Contents/Info.plist" "$APP_DIR/Contents/Resources/RouteBar.icns" "$APP_DIR/Contents/Resources/RouteBarStatusIcon.png"

echo "$APP_DIR"
