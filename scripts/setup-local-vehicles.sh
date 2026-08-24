#!/usr/bin/env bash
# Initialize Glide submodule and optionally extract Workshop assets to local addons.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

git submodule update --init --recursive gamemodes/helix addons/glide

if [[ "${1:-}" == "--extract" ]]; then
  chmod +x "$REPO_ROOT/scripts/extract-glide-workshop.sh"
  "$REPO_ROOT/scripts/extract-glide-workshop.sh"
else
  echo "Glide Lua: addons/glide (submodule)"
  echo "Assets:    run ./scripts/extract-glide-workshop.sh or see docs/LOCAL_VEHICLE_FILES.md"
fi
