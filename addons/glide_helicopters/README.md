# Helicopter entity scripts from Glide // GTAV: Helicopters (workshop 3389795738).

The main Glide repo (GitHub) does not include helicopter entity Lua. After running
`scripts/extract-glide-workshop.sh`, copy only the allowlisted helicopters here:

| Class (verify in spawn menu) | Source in workshop extract |
|------------------------------|----------------------------|
| `gtav_frogger` | `lua/entities/gtav_frogger.lua` (+ shared/cl/init if split) |
| `gtav_maverick` | `lua/entities/gtav_maverick.lua` |
| `gtav_swift` | `lua/entities/gtav_swift.lua` |

Copy matching `models/gta5/vehicles/<name>/` into `addons/glide_content/`.

Do not copy armed helicopters or unused packs.
