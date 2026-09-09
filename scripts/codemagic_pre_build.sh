#!/usr/bin/env bash
# Codemagic pre-build: drop stale Podfile.lock and refresh CocoaPods specs.
set -euo pipefail
rm -f ios/Podfile.lock
pod repo update
echo "Use Codemagic Build Mode = Release. Debug TestFlight IPAs crash on launch."
