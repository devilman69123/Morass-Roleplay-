# Morass Roleplay

A Garry's Mod roleplay server built on the [Helix](https://github.com/NebulousCloud/helix) framework. This repository is the **home** for your server — schema code, Helix framework, configuration, and deployment tooling all live here.

## Production server

| Setting | Value |
|---------|-------|
| **Game server** | `195.140.215.86:27095` |
| **FTP** | `195.140.215.86:8821` |
| **Gamemode** | `morass` |

### Deploy changes via FTP

After editing schema code locally, push to GitHub then upload to the live server:

```bash
git submodule update --init --recursive
./scripts/extract-glide-workshop.sh   # local Glide models (first time / after vehicle updates)
cp deploy.config.example deploy.config
# Edit deploy.config — add FTP username/password from your host panel

chmod +x scripts/deploy-ftp.sh
./scripts/deploy-ftp.sh
```

Glide vehicles are **local addons** (not Workshop). See [`docs/LOCAL_VEHICLE_FILES.md`](docs/LOCAL_VEHICLE_FILES.md).

Then **restart the server** from your host panel and confirm **Gamemode** is set to `morass`.

If uploads land in the wrong folder, browse FTP and adjust `FTP_REMOTE_GAMEMODES` in `deploy.config` (common paths: `garrysmod/gamemodes` or `gmod/garrysmod/gamemodes`).

### Host panel checklist

1. **Gamemode** → `morass`
2. **Port** → `27095` (usually pre-set by host)
3. **GSLT** → your Steam game server token (for public listing)
4. Restart after each FTP deploy

## Repository layout

```
├── gamemodes/
│   ├── helix/          # Helix framework (git submodule)
│   └── morass/         # Your custom schema — edit this to build Morass RP
├── addons/
│   ├── glide/              # Glide framework Lua (submodule)
│   ├── glide_content/      # Vehicle models/sounds (extracted, not in git)
│   ├── glide_helicopters/  # Helicopter entity Lua (extracted)
│   ├── morass_glide/       # Allowlist + optimization
│   └── morass_vehicles/    # Custom ported cars
├── cfg/
│   └── server.cfg      # Server configuration
├── data/               # Runtime data (Docker volume; not committed)
├── scripts/
│   ├── setup-server.sh # Install GMod + link this repo on a VPS
│   ├── start-server.sh # Start standalone server
│   ├── update-server.sh# git pull + update Helix + Steam validate
│   └── deploy-ftp.sh   # Upload to production via FTP
├── docs/
│   └── AI_DEVELOPER_CONTEXT.md  # Standards for AI/human developers
├── docker-compose.yml  # Run the server in Docker (recommended for local/dev)
└── .env.example        # Copy to .env and customize
```

## Quick start (Docker)

The easiest way to run the server locally:

```bash
# 1. Clone and initialize Helix submodule
git clone https://github.com/devilman69123/Morass-Roleplay-.git
cd Morass-Roleplay-
git submodule update --init --recursive

# 2. Configure
cp .env.example .env
# Edit .env — set GSLT for public listing, change map, etc.

# 3. Start
docker compose up -d

# 4. Attach to console (optional)
docker attach morass-gmod
# Detach without stopping: Ctrl+P then Ctrl+Q
```

Ports used:

| Port | Protocol | Purpose |
|------|----------|---------|
| 27095 | UDP/TCP | Game + RCON (production) |
| 27015 | UDP/TCP | Default local Docker if you override `PORT` |
| 27005 | UDP | Client port |

On Linux, match bind-mount permissions:

```bash
export PUID=$(id -u) PGID=$(id -g)
docker compose up -d
```

## Quick start (VPS / standalone)

For a traditional dedicated server on Linux:

```bash
git clone https://github.com/devilman69123/Morass-Roleplay-.git
cd Morass-Roleplay-
git submodule update --init --recursive

chmod +x scripts/*.sh
./scripts/setup-server.sh    # Installs GMod via SteamCMD + symlinks gamemodes
cp .env.example .env           # Optional: customize startup vars
./scripts/start-server.sh
```

The server installs to `~/gmod-server` by default. Override with `SERVER_DIR=/path/to/server`.

To deploy updates after pushing to GitHub:

```bash
./scripts/update-server.sh
# Then restart the server process
```

## Developing your schema

**AI and human developers:** read [`docs/AI_DEVELOPER_CONTEXT.md`](docs/AI_DEVELOPER_CONTEXT.md) before writing code. Glide vehicles: [`docs/GLIDE_SETUP.md`](docs/GLIDE_SETUP.md).

All Morass RP gameplay code lives in `gamemodes/morass/`. Key folders:

| Path | Purpose |
|------|---------|
| `schema/factions/` | Player factions |
| `schema/classes/` | Jobs / classes |
| `schema/items/` | Inventory items |
| `schema/attributes/` | Character attributes |
| `schema/languages/` | Localization |
| `schema/libs/` | Shared libraries (auto-loaded) |
| `schema/*_hooks.lua` | Gamemode hooks |

Helix docs: [https://docs.gethelix.co](https://docs.gethelix.co)

### Updating Helix

```bash
git submodule update --remote --merge gamemodes/helix
git add gamemodes/helix
git commit -m "Update Helix framework"
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `SERVER_NAME` | Morass Roleplay | Browser hostname |
| `GAMEMODE` | `morass` | Schema folder name |
| `MAP` | `gm_construct` | Starting map |
| `PORT` | `27095` | Game port |
| `MAXPLAYERS` | `32` | Player cap |
| `GSLT` | _(empty)_ | Steam GSLT for public listing |
| `PRODUCTION` | `1` | `1` disables Lua hot-reload (use `0` for local dev) |
| `SERVER_ARGS` | _(empty)_ | Extra `srcds` arguments |

### MySQL (optional)

By default Helix uses SQLite (`data/sv.db`). For MySQL:

1. Install [MySQLOO](https://github.com/FredyH/MySQLOO) into `lua/bin/`
2. Copy `gamemodes/helix/helix.example.yml` → `gamemodes/helix/helix.yml`
3. Set `adapter: "mysqloo"` and your database credentials

### Workshop content

Add a workshop collection to `.env`:

```bash
SERVER_ARGS=+host_workshop_collection YOUR_COLLECTION_ID
```

## Hosting providers

Most GMod hosts (Nexus, Zap, etc.) support Git deploy or SFTP. Point their **gamemodes** path to this repo:

- `gamemodes/helix` — submodule (run `git submodule update --init` on deploy)
- `gamemodes/morass` — this repo's schema

Set the panel **Gamemode** field to `morass`.

## License

Schema code follows the Helix skeleton license. Helix framework is licensed separately — see `gamemodes/helix/LICENSE.txt`.
