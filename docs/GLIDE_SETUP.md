# Glide setup — Morass Roleplay (lean)

Morass does **not** use the full Glide // Vehicle Collection. Mount only what you need and let `addons/morass_glide` strip visuals and block stray spawns.

## Workshop (subscribe on the server host)

| Addon | Workshop ID | Mount |
|-------|-------------|--------|
| Glide // Styled's Vehicle Base | [3389728250](https://steamcommunity.com/sharedfiles/filedetails/?id=3389728250) | **Required** |
| Glide // GTAV: Helicopters | [3389795738](https://steamcommunity.com/sharedfiles/filedetails/?id=3389795738) | **Required** (2–3 civ helis) |

**Do not mount** (unless you explicitly expand the allowlist):

- Glide // Vehicle Collection (3389823726) — bundles experiments, Kiowa, extra packs
- Glide // AW-119 Kiowa — armed
- Glide // Styled's Experiments

Create a **custom Steam collection** with only Base + Helicopters, then set:

```bash
SERVER_ARGS=+host_workshop_collection YOUR_COLLECTION_ID
```

## Morass vehicle allowlist

Configured in `addons/morass_glide/lua/autorun/sh_morass_glide_config.lua`.

| Pack | Classes | Notes |
|------|---------|--------|
| **Boats** (base) | `gtav_dinghy`, `gtav_seashark` | Default Glide boats |
| **Citizen** (base) | `gtav_blazer`, `gtav_dukes`, `gtav_gauntlet_classic`, `gtav_infernus`, `gtav_speedo` | No bikes (ragdoll fall-off cost) |
| **Emergency** (base) | `gtav_police_cruiser` | Sirens kept |
| **Helicopters** (heli pack) | `gtav_frogger`, `gtav_maverick`, `gtav_swift` | Verify names in spawn menu after first mount |

To change helicopters: open spawn menu → find 3 civilian helis → copy entity class names into `MorassGlide.Helicopters`.

## What `morass_glide` optimizes

### Content scope

- Allowlist blocks spawning any other Glide vehicle (admins spawning disallowed classes get blocked).
- Stray Glide ents removed on map load if not on the list.

### Citizen / boat / helicopter (not emergency)

- Headlights, light sprites, sirens, exhaust smoke strips removed at registration and on spawn.
- Auto-headlight timer disabled.
- Client Glide config forced to minimal: no HUD, no tips, no skybox indicators, low skid marks, reduced tire particles.

### Helicopters

- Weapon slots stripped serverside (transport only).

### Emergency (`gtav_police_cruiser`)

- Keeps sirens/lights for police roleplay.

## Core driving only

What remains: engine, steering, seats, damage, Glide camera, horns (emergency sirens on police cruiser).

What is removed or disabled for citizens: projected headlights, turn signals, brake light sprites, auto headlights, Glide HUD clutter, skybox wall indicators.

## Faction access (next step)

`Glide_CanEnterVehicle` currently only requires a loaded character. Tie factions/classes to categories in `gamemodes/morass/schema/sv_hooks.lua` when garages are built.

## Deploy

`morass_glide` is in `addons/` and deploys with `./scripts/deploy-ftp.sh`.
