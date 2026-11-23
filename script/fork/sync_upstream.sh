#!/usr/bin/env bash
set -euo pipefail

# Fast-forwards `main` to upstream, rebases the telemetry removal on top, and proves it still holds.
# Run this after every upstream release (or whenever you want the latest main).
#
# Usage: script/fork/sync_upstream.sh          # track upstream/main
#        TAG=v0.8.1 script/fork/sync_upstream.sh  # pin to a release tag

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

git diff --quiet && git diff --cached --quiet \
  || { echo "error: commit or stash your changes first" >&2; exit 1; }

echo "==> fetching upstream"
git fetch upstream --tags

OLD_BASE="$(git rev-parse no-telemetry)"

echo "==> updating main"
git switch main
if [ -n "${TAG:-}" ]; then
  git reset --hard "$TAG"
else
  git merge --ff-only upstream/main
fi

echo "==> rebasing no-telemetry"
git switch no-telemetry
git rebase main

echo "==> verifying"
./script/fork/verify_no_telemetry.sh
swift build

echo "==> comparing the stack"
git range-diff "$OLD_BASE~5..$OLD_BASE" 'no-telemetry~5..no-telemetry'

cat <<'EOF'

Synced. Rebuild and reinstall:

  ./script/fork/build_personal.sh build
EOF
