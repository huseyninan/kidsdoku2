#!/usr/bin/env bash
# Captures every app screen in light and dark mode using Maestro.
#
# Usage: scripts/screenshots.sh [simulator name] [--no-build]
# Output: screenshots/light/*.png and screenshots/dark/*.png
set -euo pipefail

SIM_NAME="${1:-iPhone 15}"
BUILD=1
[[ "${2:-}" == "--no-build" ]] && BUILD=0

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

BUNDLE_ID="kidsdoku.hinan.kidsdoku"
DERIVED="$ROOT/build/DerivedData"
APP="$DERIVED/Build/Products/Debug-iphonesimulator/kidsdoku2.app"

command -v maestro >/dev/null || { echo "maestro not found. Install: curl -Ls https://get.maestro.mobile.dev | bash" >&2; exit 1; }
command -v xcrun   >/dev/null || { echo "Xcode command line tools required (macOS only)." >&2; exit 1; }

# Boot the simulator (no-op if already booted).
UDID="$(xcrun simctl list devices available | grep -F "$SIM_NAME (" | head -1 | grep -oE '[0-9A-F-]{36}')"
[[ -n "$UDID" ]] || { echo "Simulator '$SIM_NAME' not found." >&2; exit 1; }
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null
# Clean status bar for consistent screenshots.
xcrun simctl status_bar "$UDID" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 || true

if [[ "$BUILD" == 1 ]]; then
  xcodebuild -project kidsdoku2.xcodeproj -scheme kidsdoku2 -configuration Debug \
    -destination "id=$UDID" -derivedDataPath "$DERIVED" build -quiet
fi
xcrun simctl install "$UDID" "$APP"

for MODE in light dark; do
  OUT="screenshots/$MODE"
  rm -rf "$OUT"; mkdir -p "$OUT"
  xcrun simctl ui "$UDID" appearance "$MODE"
  echo "==> $MODE mode"
  maestro --device "$UDID" test -e SHOT_DIR="$OUT" .maestro/
done

xcrun simctl ui "$UDID" appearance light
echo "Done. See screenshots/light and screenshots/dark."
