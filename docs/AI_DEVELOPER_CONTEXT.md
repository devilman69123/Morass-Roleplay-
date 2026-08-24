# Morass Roleplay — AI Developer Context

This document is the authoritative context for any AI or human developer working on **Morass Roleplay**: a Garry's Mod roleplay server on the **Helix** framework.

Read this before writing code. Prefer extending what Helix and this schema already provide over inventing parallel systems.

---

## Project

| | |
|---|---|
| **Schema** | `morass` (`gamemodes/morass/`) |
| **Framework** | Helix (`gamemodes/helix/`, git submodule — do not fork or duplicate framework code in the schema) |
| **Production** | `195.140.215.86:27095` |
| **FTP deploy** | `195.140.215.86:8821` — see `scripts/deploy-ftp.sh` |

Gameplay code lives under `gamemodes/morass/schema/`. Server config: `cfg/server.cfg`. Addons: `addons/` (Helix-adapted only).

---

## Core principles

### 1. Light and optimized — always

This server targets **large player counts**. Every feature must justify its CPU, network, and memory cost.

- Prefer **one server tick / one hook** over many small hooks doing the same job.
- Avoid `Think`, `HUDPaint`, and per-frame loops unless there is no cheaper option.
- Use **timers** with sensible intervals instead of polling every frame.
- Batch net messages; do not spam `net.Write` on frequent events.
- Cache lookups (`character`, faction, inventory) once per scope — do not re-fetch in nested loops.
- Keep **serverside** logic on the server; minimize client replication and HUD work.
- No decorative entities, particles, or effects that run for everyone when only one player needs them.

When two approaches work, pick the one with fewer hooks, fewer ents, and less net traffic.

### 2. Reuse Helix — do not build parallel systems

Helix already provides the structures you need. **Use them.**

| Need | Use this (not a custom system) |
|------|--------------------------------|
| Jobs / roles | `schema/factions/`, `schema/classes/` |
| Items / consumables / gear | `schema/items/` extending Helix item bases |
| Stats | `schema/attributes/` + Helix attribute plugin |
| Shared behaviour | `schema/libs/` (auto-loaded) |
| Player / character extensions | `schema/meta/sh_player.lua`, `schema/meta/sh_character.lua` |
| Lifecycle / events | `cl_hooks.lua`, `sh_hooks.lua`, `sv_hooks.lua` |
| Optional modular features | Helix **plugins** (`gamemodes/helix/plugins/`) or schema-local plugins — not random `lua/autorun` |
| UI | Helix derma / ix.gui patterns |
| Data on characters | `character:SetData` / `GetData`, inventories, flags |
| Chat / commands | Helix chat classes and `ix.command` |
| Persistence | Helix save hooks — do not roll custom SQL/file saves for standard RP data |

If Helix or an existing Morass lib already does 80% of the job, extend it — do not duplicate inventory, money, recognition, stamina, areas, vendors, containers, etc.

### 3. Code quality — human, not generated slop

Write code that looks like an experienced GMod/Lua developer wrote it.

**Do:**
- Match naming and layout of neighbouring files (`sh_`, `sv_`, `cl_` prefixes; `ITEM`, `FACTION`, `CLASS` tables).
- Keep functions short and purposeful.
- Use existing Helix APIs (`ix.util.Include`, `ix.char`, `ix.item`, `ix.faction`, etc.).
- Leave skeleton tutorial comments out of new files; remove them when touching old skeleton files.

**Do not (AI telltales):**
- Wall-of-text comments explaining obvious Lua/GMod behaviour.
- `---` section banners, numbered step comments, or “this function does X” narration.
- Defensive over-engineering: redundant nil checks on framework-guaranteed objects, try/catch-style patterns Lua doesn't need, or “security” layers beyond normal RP validation.
- Generic variable names (`data`, `result`, `handleEvent`) when domain names exist (`character`, `inventory`, `client`).
- Unused abstractions: helper files for one-liners, factory patterns, or config objects when a plain table suffices.
- Copy-paste blocks with only comments changed.

Normal RP checks are fine (distance, alive, character loaded, faction). Do not add enterprise-style validation, rate limiters, or audit logging unless explicitly requested.

### 4. Addons — Helix-first, stripped for performance

Raw Workshop addons are not dropped in as-is. Every addon must be **converted** for Helix and **stripped** of lag.

**Conversion checklist:**
1. Remove `lua/autorun` junk — fold into schema hooks, libs, or a single plugin entry point.
2. Replace DarkRP/Clockwork/custom inventory/money/chat with Helix equivalents.
3. Register weapons/items through `schema/items/` (or Helix weapon items), not duplicate spawn menus.
4. Move config into schema files or one small config table — not scattered convars and JSON loaders.
5. Delete client HUDs/overlays if Helix UI or a minimal replacement exists.
6. Remove features you do not need (extra commands, admin menus, cosmetic systems, debug modes).

**Strip for lag:**
- Client effects that run for all players → scope to local player or remove.
- `PostDrawTranslucentRenderables`, heavy `CalcView`, constant trace rays → reduce or remove.
- Think hooks on entities → timers or event-driven logic.
- Network strings broadcasting to everyone → filter recipients (`player.GetAll()` is expensive at scale — use faction/area/local PVS where possible).
- Physics-heavy ents, ragdoll spam, prop spawning loops.
- Workshop models with huge collision meshes when a simpler prop works.

If an addon cannot be made light enough, do not ship it.

---

## Schema layout (where code goes)

```
gamemodes/morass/
├── morass.txt              # Gamemode manifest — folder name must match
├── gamemode/
│   ├── init.lua            # DeriveGamemode("helix")
│   └── cl_init.lua
└── schema/
    ├── sh_schema.lua       # Schema info + ix.util.Include list
    ├── cl_schema.lua / sv_schema.lua
    ├── cl_hooks.lua / sh_hooks.lua / sv_hooks.lua
    ├── factions/           # FACTION tables
    ├── classes/            # CLASS tables
    ├── items/              # ITEM tables
    ├── attributes/
    ├── languages/
    ├── libs/               # Auto-loaded shared libs
    └── meta/               # Character/player meta extensions
```

New gameplay features should land in the correct folder — not new top-level `lua/` trees or unrelated directories.

---

## Performance checklist (before shipping)

- [ ] No new per-frame hooks without justification.
- [ ] Net messages use minimal fields and correct recipients.
- [ ] No `for _, v in ipairs(player.GetAll())` in hot paths without caching or event-driven triggers.
- [ ] Items/factions/classes use Helix registration — no duplicate registries.
- [ ] Addons stripped to required behaviour only.
- [ ] Tested with production mindset (`PRODUCTION=1` — no reliance on Lua hot-reload in live paths).

---

## Helix reference

- Docs: https://docs.gethelix.co
- Framework repo: `gamemodes/helix/` (submodule — update via git submodule, do not edit framework files for schema-specific behaviour; override in schema hooks/meta instead).

---

## Deployment reminder

After schema changes: `./scripts/deploy-ftp.sh` (credentials in `deploy.config`), then restart server. Gamemode must stay **`morass`**.

---

## Summary (one line)

**Extend Helix, stay lean, write human Lua, and cut anything that does not survive high player counts.**
