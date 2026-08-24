#!/usr/bin/env bash
# Download Glide Workshop packs and copy assets into local addons (no Workshop on server).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STEAMCMD_DIR="${STEAMCMD_DIR:-$HOME/steamcmd}"
GMOD_APP_ID=4020
WORKSHOP_APP_ID=4000

BASE_ID=3389728250
HELI_ID=3389795738

CONTENT_DIR="$REPO_ROOT/addons/glide_content"
HELI_LUA_DIR="$REPO_ROOT/addons/glide_helicopters/lua/entities"
WORKSHOP_ROOT="$STEAMCMD_DIR/steamapps/workshop/content/$WORKSHOP_APP_ID"

if ! command -v steamcmd >/dev/null 2>&1; then
  if [[ ! -x "$STEAMCMD_DIR/steamcmd.sh" ]]; then
    echo "Installing SteamCMD to $STEAMCMD_DIR..."
    mkdir -p "$STEAMCMD_DIR"
    curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
      | tar -xz -C "$STEAMCMD_DIR"
  fi
  STEAMCMD="$STEAMCMD_DIR/steamcmd.sh"
else
  STEAMCMD="steamcmd"
fi

mkdir -p "$CONTENT_DIR" "$HELI_LUA_DIR"

download_item() {
  local id="$1"
  echo "==> Workshop download $id"
  "$STEAMCMD" +login anonymous \
    +force_install_dir "$STEAMCMD_DIR" \
    +workshop_download_item "$WORKSHOP_APP_ID" "$id" \
    +quit
}

copy_tree() {
  local src="$1"
  local dest="$2"
  local name="$3"
  if [[ -d "$src/$name" ]]; then
    mkdir -p "$dest"
    rsync -a --delete "$src/$name/" "$dest/$name/"
    echo "    copied $name/"
  fi
}

copy_heli_entities() {
  local src="$1"
  local classes=(gtav_frogger gtav_maverick gtav_swift)
  for class in "${classes[@]}"; do
    if [[ -f "$src/lua/entities/$class.lua" ]]; then
      cp -f "$src/lua/entities/$class.lua" "$HELI_LUA_DIR/"
      echo "    copied lua/entities/$class.lua"
    else
      echo "    WARN: missing $class.lua in heli pack — verify class name"
    fi
  done
}

echo "==> Morass Glide local extract"
echo "    Content:  $CONTENT_DIR"
echo "    Heli lua: $HELI_LUA_DIR"

cd "$REPO_ROOT"
git submodule update --init addons/glide

download_item "$BASE_ID"
download_item "$HELI_ID"

BASE_PATH="$WORKSHOP_ROOT/$BASE_ID"
HELI_PATH="$WORKSHOP_ROOT/$HELI_ID"

if [[ ! -d "$BASE_PATH" ]]; then
  echo "Base pack not found at $BASE_PATH"
  exit 1
fi

echo "==> Copying base pack assets (models/materials/sounds only; Lua from addons/glide submodule)"
copy_tree "$BASE_PATH" "$CONTENT_DIR" models
copy_tree "$BASE_PATH" "$CONTENT_DIR" materials
copy_tree "$BASE_PATH" "$CONTENT_DIR" sound
copy_tree "$BASE_PATH" "$CONTENT_DIR" sounds

if [[ -d "$HELI_PATH" ]]; then
  echo "==> Copying helicopter pack assets + entity scripts"
  copy_tree "$HELI_PATH" "$CONTENT_DIR" models
  copy_tree "$HELI_PATH" "$CONTENT_DIR" materials
  copy_tree "$HELI_PATH" "$CONTENT_DIR" sound
  copy_tree "$HELI_PATH" "$CONTENT_DIR" sounds
  copy_heli_entities "$HELI_PATH"
else
  echo "WARN: Helicopter pack not found at $HELI_PATH"
fi

echo ""
echo "Done. Remove +host_workshop_collection from server args."
echo "Deploy with: ./scripts/deploy-ftp.sh"
