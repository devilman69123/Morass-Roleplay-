#!/usr/bin/env bash
# Pull latest schema + Helix framework from git and update the GMod install.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="${SERVER_DIR:-$HOME/gmod-server}"
STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME/steamcmd}"
APP_ID=4020

echo "==> Pulling latest repo changes..."
cd "$REPO_ROOT"
git pull
git submodule update --remote --merge gamemodes/helix

if [[ -x "$SERVER_DIR/srcds_run" ]]; then
  if command -v steamcmd >/dev/null 2>&1; then
    STEAMCMD="steamcmd"
  elif [[ -x "$STEAMCMD_DIR/steamcmd.sh" ]]; then
    STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"
  else
    echo "SteamCMD not found — skipping GMod binary update."
    exit 0
  fi

  echo "==> Updating GMod dedicated server binaries..."
  "$STEAMCMD" +force_install_dir "$SERVER_DIR" \
    +login anonymous \
    +app_update "$APP_ID" validate \
    +quit
fi

echo "==> Update complete. Restart the server to apply changes."
