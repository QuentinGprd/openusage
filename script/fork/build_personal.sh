#!/usr/bin/env bash
set -euo pipefail

# Builds a personal, telemetry-free drop-in with the official bundle id, so existing accounts, settings,
# and Keychain items keep working. Stages it under dist/ and, with `run`, launches it.
#
# This path (script/build_and_run.sh) never writes SUFeedURL, so the build cannot update itself into an
# upstream telemetry build. Do not use script/release.sh: it bakes the upstream feed.
#
# Usage: script/fork/build_personal.sh [build|run|verify]   (default: build)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MODE="${1:-build}"

cd "$ROOT_DIR"

BUNDLE_ID=com.robinebers.openusage CONFIG="${CONFIG:-release}" \
  ./script/build_and_run.sh "$MODE"

./script/fork/verify_no_telemetry.sh
