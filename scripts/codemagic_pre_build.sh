#!/usr/bin/env bash
# Codemagic pre-build: drop stale Podfile.lock and refresh CocoaPods specs.
# Flutter's later `pod install` will resolve sqlite3 to match sqlite3_flutter_libs.
set -euo pipefail
rm -f ios/Podfile.lock
pod repo update
