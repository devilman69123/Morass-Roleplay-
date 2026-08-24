# Extracted Glide vehicle assets (models, materials, sounds).

Do not use Steam Workshop on the server when this folder is populated.

## Populate this folder

Run from the repo root:

```bash
./scripts/extract-glide-workshop.sh
```

Or copy manually from a Workshop extract of:

- Glide // Styled's Vehicle Base (3389728250) — all models used by your allowlist
- Glide // GTAV: Helicopters (3389795738) — only frogger, maverick, swift

Expected layout after extraction:

```
glide_content/
  models/gta5/vehicles/...
  materials/...
  sound/...   (or sounds/)
```

Binary assets are gitignored. Deploy via FTP with `./scripts/deploy-ftp.sh`.

## Client downloads

Players need these files without Workshop. Options:

1. **Same addon on server** — GMod sends addon content to clients (default for most hosts).
2. **FastDL** — mirror `addons/` to a web host; set `sv_downloadurl` on the server.

See `docs/LOCAL_VEHICLE_FILES.md`.
