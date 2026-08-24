#!/usr/bin/env bash
# Start the Morass Roleplay GMod server (standalone install, not Docker).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_DIR="${SERVER_DIR:-$HOME/gmod-server}"
GMOD_DIR="$SERVER_DIR/garrysmod"

if [[ ! -x "$SERVER_DIR/srcds_run" ]]; then
  echo "GMod server not found at $SERVER_DIR"
  echo "Run scripts/setup-server.sh first."
  exit 1
fi

# Load optional .env from repo root
if [[ -f "$REPO_ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$REPO_ROOT/.env"
  set +a
fi

SERVER_NAME="${SERVER_NAME:-Morass Roleplay}"
GAMEMODE="${GAMEMODE:-morass}"
MAP="${MAP:-gm_construct}"
PORT="${PORT:-27095}"
MAXPLAYERS="${MAXPLAYERS:-32}"
GSLT="${GSLT:-}"
SERVER_ARGS="${SERVER_ARGS:-}"

cd "$SERVER_DIR"

ARGS=(
  -game garrysmod
  +maxplayers "$MAXPLAYERS"
  +hostname "$SERVER_NAME"
  +gamemode "$GAMEMODE"
  +map "$MAP"
  +port "$PORT"
  +exec server.cfg
)

if [[ -n "$GSLT" ]]; then
  ARGS+=(+sv_setsteamaccount "$GSLT")
fi

if [[ -n "$SERVER_ARGS" ]]; then
  # shellcheck disable=SC2206
  ARGS+=($SERVER_ARGS)
fi

echo "==> Starting Morass Roleplay ($GAMEMODE on $MAP)"
exec ./srcds_run "${ARGS[@]}"
