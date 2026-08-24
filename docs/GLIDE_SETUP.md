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

## Adding non-Glide cars (one vehicle system)

Glide **does not** run Simfphys, LVS, SCars, or `prop_vehicle_jeep` through its base. Those are separate physics/input/camera stacks. Mounting them alongside Glide means **two vehicle systems** — more lag, split ownership rules, and Helix hooks that only understand one of them.

The Morass approach: **port the model into Glide** so it uses the same pipeline as every other car.

| Approach | Extra systems? | Morass recommendation |
|----------|----------------|------------------------|
| New entity with `ENT.Base = "base_glide_car"` (etc.) | No — same Glide base | **Yes** |
| Simfphys / LVS / Source jeep addon | Yes — full second framework | Avoid |
| Raw Workshop car pack without Glide port | Won't drive under Glide | Port or skip |

### What “porting” means

1. Workshop **models** stay in a content addon (or existing pack).
2. You add a thin **scripted entity** in `addons/morass_vehicles/lua/entities/` that derives from the right Glide base:

   - Cars → `base_glide_car`
   - Boats → `base_glide_boat`
   - Helicopters → `base_glide_heli` or `base_glide_aircraft`

3. Set `ENT.ChassisModel`, wheel offsets, camera, engine stream preset (copy from a similar official Glide car).
4. **Do not** define `Headlights` / `LightSprites` on citizen ports — Morass strips them anyway.
5. Register the class in `MorassGlide.Custom` in `sh_morass_glide_config.lua`:

```lua
MorassGlide.Custom = {
	morass_your_sedan = "citizen",
}
```

Or at runtime from schema: `MorassGlide.Register("morass_your_sedan", "citizen")`.

Glide auto-registers anything with `GlideCategory` into `GlideVehicles`, uses `Glide.VehicleFactory` for spawn/dupes, and fires `Glide_CanEnterVehicle` — same as official cars. `morass_glide` ownership, allowlist, and light stripping apply automatically.

### Template

See `addons/morass_vehicles/lua/entities/_template_glide_car.lua`.

### Porting effort

Tuning wheel positions and handling takes time per model, but it is **content work** — not a new garage/money/keys framework. For Helix you still only wire spawn/buy through existing Morass hooks (vendors, commands, garages) calling `ents.Create("your_class")`.

Glide wiki: [Editable Car Properties](https://github.com/StyledStrike/gmod-glide/wiki/Editable-Car-Properties)
