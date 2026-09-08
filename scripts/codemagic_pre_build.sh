#!/usr/bin/env bash
# Codemagic pre-build: refresh CocoaPods specs before Flutter runs pod install.
set -euo pipefail
pod repo update
