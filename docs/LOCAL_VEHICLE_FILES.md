# Local Glide vehicle files (no Workshop on server)

Morass serves vehicles from **addons on disk**, not `+host_workshop_collection`.

## Layout

| Addon | Purpose |
|-------|---------|
| `addons/glide/` | Glide framework + base vehicle **Lua** (Git submodule) |
| `addons/glide_content/` | Models, materials, sounds (extracted; not in git) |
| `addons/glide_helicopters/` | Helicopter entity Lua from GTAV heli pack (extracted) |
| `addons/morass_glide/` | Allowlist, optimization, Helix glue |
| `addons/morass_vehicles/` | Custom ported Glide cars |

## One-time setup

```bash
git submodule update --init --recursive addons/glide gamemodes/helix
chmod +x scripts/*.sh
./scripts/extract-glide-workshop.sh
```

This uses SteamCMD to download Workshop items **once on your machine**, then copies:

- **Base pack (3389728250)** → `glide_content/` (assets only; Lua already in `addons/glide`)
- **Heli pack (3389795738)** → `glide_content/` assets + 3 entity files → `glide_helicopters/lua/entities/`

You only need files for your allowlist (`docs/GLIDE_SETUP.md`). The script copies full model trees; unused vehicles cost disk/FastDL only, not RAM until spawned.

## Server configuration

**Remove** Workshop collection from startup:

```bash
# .env — do NOT use host_workshop_collection for Glide
SERVER_ARGS=
```

Restart the server after deploying addons.

## Deploy to production (195.140.215.86)

```bash
./scripts/deploy-ftp.sh
```

Uploads all of `addons/` including `glide`, `glide_content`, `glide_helicopters`, `morass_glide`.

Run `./scripts/extract-glide-workshop.sh` on the machine you deploy from so `glide_content` is populated before FTP.

## Clients without Workshop

Players must receive model files from the server:

1. **Default:** GMod downloads addon content from the game server when joining.
2. **FastDL (recommended at scale):** Host `garrysmod/` on HTTP and set in `cfg/server.cfg`:

```
sv_allowdownload 1
sv_allowupload 0
sv_downloadurl "https://your-fastdl-domain/gmod"
```

Mirror the whole `addons/` folder (or at least `glide`, `glide_content`, `glide_helicopters`) to FastDL.

## Updating Glide

```bash
cd addons/glide && git pull && cd ..
./scripts/extract-glide-workshop.sh   # if Workshop assets changed
./scripts/deploy-ftp.sh
```

## Legal note

GTA V–style models in Glide packs are third-party ports. Keep extraction on your server infrastructure; do not redistribute packs publicly unless you have rights to the assets.
