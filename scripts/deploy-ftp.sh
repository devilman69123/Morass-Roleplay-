#!/usr/bin/env bash
# Upload gamemodes, cfg, and addons to the production server via FTP.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="${DEPLOY_CONFIG:-$REPO_ROOT/deploy.config}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "Missing $CONFIG_FILE"
  echo "Copy deploy.config.example to deploy.config and add your FTP credentials."
  exit 1
fi

# shellcheck disable=SC1090
source "$CONFIG_FILE"

: "${FTP_HOST:?Set FTP_HOST in deploy.config}"
: "${FTP_PORT:?Set FTP_PORT in deploy.config}"
: "${FTP_USER:?Set FTP_USER in deploy.config}"
: "${FTP_PASSWORD:?Set FTP_PASSWORD in deploy.config}"
FTP_REMOTE_GAMEMODES="${FTP_REMOTE_GAMEMODES:-garrysmod/gamemodes}"
FTP_REMOTE_CFG="${FTP_REMOTE_CFG:-garrysmod/cfg}"
FTP_REMOTE_ADDONS="${FTP_REMOTE_ADDONS:-garrysmod/addons}"

echo "==> Initializing submodules (Helix + Glide)..."
cd "$REPO_ROOT"
git submodule update --init --recursive gamemodes/helix addons/glide

if [[ ! -d "$REPO_ROOT/addons/glide_content/models" ]]; then
  echo "WARN: addons/glide_content/models missing — run ./scripts/extract-glide-workshop.sh before deploy"
fi

echo "==> Deploying to $FTP_HOST:$FTP_PORT"
echo "    gamemodes -> $FTP_REMOTE_GAMEMODES"
echo "    cfg       -> $FTP_REMOTE_CFG"
echo "    addons    -> $FTP_REMOTE_ADDONS"

if command -v lftp >/dev/null 2>&1; then
  export LFTP_PASSWORD="$FTP_PASSWORD"
  lftp -u "$FTP_USER" -p "$FTP_PORT" "$FTP_HOST" <<EOF
set ssl:verify-certificate no
mirror -R --delete --verbose \
  --exclude-glob .git/ \
  --exclude-glob .git \
  --exclude-glob .gitmodules \
  "$REPO_ROOT/gamemodes/helix" "$FTP_REMOTE_GAMEMODES/helix"
mirror -R --delete --verbose \
  --exclude-glob .git/ \
  --exclude-glob .git \
  "$REPO_ROOT/gamemodes/morass" "$FTP_REMOTE_GAMEMODES/morass"
mirror -R --verbose \
  "$REPO_ROOT/cfg" "$FTP_REMOTE_CFG"
mirror -R --verbose \
  --exclude-glob .git/ \
  --exclude-glob .git \
  "$REPO_ROOT/addons" "$FTP_REMOTE_ADDONS"
bye
EOF
else
  python3 "$REPO_ROOT/scripts/deploy-ftp.py" "$CONFIG_FILE"
fi

echo ""
echo "==> Deploy complete."
echo "Connect: ${FTP_HOST}:27095 (set gamemode to morass in host panel if needed)"
echo "Restart the server from your host panel to load changes."
