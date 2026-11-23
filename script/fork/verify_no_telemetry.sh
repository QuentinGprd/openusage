#!/usr/bin/env bash
set -euo pipefail

# Fails if telemetry makes it back into the tree or into a staged build. Run after every upstream sync,
# and before installing a build. Fork-owned: upstream never edits this file.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail() { echo "error: $*" >&2; exit 1; }

echo "==> checking the package manifest"
if grep -Ini 'posthog' Package.swift Package.resolved; then
  fail "PostHog is back in Package.swift / Package.resolved"
fi

echo "==> checking the sources"
if grep -RIni -e 'posthog' -e 'phc_' -e 'us\.i\.posthog\.com' Sources; then
  fail "telemetry references are back in Sources/"
fi

echo "==> checking the sink and the settings screen"
grep -q 'final class NoopTelemetrySink' Sources/OpenUsage/Services/Telemetry.swift \
  || fail "Sources/OpenUsage/Services/Telemetry.swift no longer defines NoopTelemetrySink"
grep -q 'NoopTelemetrySink()' Sources/OpenUsage/App/OpenUsageApp.swift \
  || fail "OpenUsageApp no longer wires NoopTelemetrySink"
if grep -q 'Help Make OpenUsage Better' Sources/OpenUsage/Views/SettingsScreen.swift; then
  fail "the analytics toggle is back in SettingsScreen.swift"
fi

echo "==> checking the staged build"
APP="$ROOT_DIR/dist/OpenUsage.app"
if [ -d "$APP" ]; then
  /usr/libexec/PlistBuddy -c 'Print :SUFeedURL' "$APP/Contents/Info.plist" >/dev/null 2>&1 \
    && fail "the staged build carries an SUFeedURL; it would install upstream telemetry builds"
  if strings "$APP/Contents/MacOS/OpenUsage" | grep -Eiq 'posthog|phc_'; then
    fail "the staged binary still contains PostHog identifiers"
  fi
else
  echo "    no staged build at dist/OpenUsage.app; skipping bundle checks"
fi

echo "OK: no telemetry in this tree"
