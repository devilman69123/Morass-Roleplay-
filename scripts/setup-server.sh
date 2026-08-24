#!/usr/bin/env bash
# Install a standalone GMod dedicated server and link this repo's gamemodes.
# Run on a Linux VPS or home server (not required when using Docker).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="${SERVER_DIR:-$HOME/gmod-server}"
STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME/steamcmd}"
APP_ID=4020

echo "==> Morass Roleplay server setup"
echo "    Repo:   $REPO_ROOT"
echo "    Server: $SERVER_DIR"

if ! command -v steamcmd >/dev/null 2>&1; then
  if [[ ! -x "$STEAMCMD_DIR/steamcmd.sh" ]]; then
    echo "==> Installing SteamCMD..."
    mkdir -p "$STEAMCMD_DIR"
    curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
      | tar -xz -C "$STEAMCMD_DIR"
  fi
  STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"
else
  STEAMCMD="steamcmd"
fi

echo "==> Installing / updating Garry's Mod dedicated server..."
"$STEAMCMD" +force_install_dir "$SERVER_DIR" \
  +login anonymous \
  +app_update "$APP_ID" validate \
  +quit

GMOD_DIR="$SERVER_DIR/garrysmod"
mkdir -p "$GMOD_DIR/gamemodes" "$GMOD_DIR/addons" "$GMOD_DIR/cfg" "$GMOD_DIR/data"

echo "==> Linking gamemodes from repo..."
ln -sfn "$REPO_ROOT/gamemodes/helix" "$GMOD_DIR/gamemodes/helix"
ln -sfn "$REPO_ROOT/gamemodes/morass" "$GMOD_DIR/gamemodes/morass"

if [[ -d "$REPO_ROOT/addons" ]]; then
  for addon in "$REPO_ROOT/addons"/*; do
    [[ -d "$addon" ]] || continue
    name="$(basename "$addon")"
    ln -sfn "$addon" "$GMOD_DIR/addons/$name"
  done
fi

if [[ -f "$REPO_ROOT/cfg/server.cfg" ]]; then
  cp -f "$REPO_ROOT/cfg/server.cfg" "$GMOD_DIR/cfg/server.cfg"
fi

echo "==> Initializing Helix submodule (if needed)..."
cd "$REPO_ROOT"
git submodule update --init --recursive gamemodes/helix

echo ""
echo "Setup complete."
echo "Start the server with: $REPO_ROOT/scripts/start-server.sh"
echo "Or set SERVER_DIR if you used a custom path: SERVER_DIR=$SERVER_DIR"
