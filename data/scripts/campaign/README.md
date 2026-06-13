# Campaign MVP Scripts

This folder contains the first playable slice of the systems described in
[`docs/GDD-CoreSystems.md`](../../../docs/GDD-CoreSystems.md) (Phase 1 + Phase 2
of the implementation roadmap), built on top of TFS's revscriptsys
(`data/scripts/`).

The initial MVP intentionally targets a simple, classic "Rookgard-style"
starting experience (basic hunger, equipment, magic, crafting and gathering
loops). The Corpse & Undead system and the world Boss system from the GDD are
**deferred** - see [Deferred systems](#deferred-systems-future-work) below.

## Contents

| File | System | GDD Section |
|---|---|---|
| `../lib/campaign_config.lua` (`data/scripts/lib/`) | Shared config/data tables for all systems below | - |
| `globalevents/hunger_tick.lua` | Hunger state machine (Fed/Hungry/Starving/Exhausted) | 4 |
| `../lib/skill_gain_block.lua` (`data/scripts/lib/`) | Pauses skill gain while hungry | 4 |
| `actions/eat_food.lua` | Eating food restores food ticks | 4, 7 |
| `creaturescripts/campaign_login.lua` | Initializes hunger storage on login | 4 |
| `actions/repair.lua` | Repairing equipment at an anvil | 5 |
| `actions/grimoire.lua` | Reading a grimoire permanently learns a spell | 3 |
| `talkactions/rune_inscribe.lua` | `!inscribe <Spell>` crafts a charged rune | 3 |
| `spells/fireball.lua` | New instant spell "Fireball" (grimoire 8916) | 3 |
| `spells/mass_healing.lua` | New instant spell "Mass Healing" (grimoire 8917), 3x3 AoE heal | 3 |
| `spells/summon_familiar.lua` | New instant spell "Summon Familiar" (grimoire 8918) | 3 |
| `actions/cooking_fire.lua` | Cooking raw food at a cooking-fire station | 7 |
| `actions/alchemy_table.lua` | Combining ingredients into special foods at an alchemy table | 7 |
| `actions/workbench.lua` | Crafting tools/items (e.g. logs -> torches) at a workbench | 7, 8 |
| `actions/gather_resource.lua` | Harvesting resource nodes (ore veins, trees, herb patches) | 8 |
| `creaturescripts/permadeath_convert.lua` | On death, drops equipment and converts the character into a "Player Shade" | 9 |
| `creaturescripts/permadeath_login.lua` | Banishes a "shade" character to limbo on next login | 9 |
| `talkactions/campaign_phase.lua` | `!campaignphase [0-3]` GM command to view/advance the world campaign phase | 10 |

## New monsters (`data/monster/monsters/`)

| Monster | Used by |
|---|---|
| `player_shade.xml` | Hostile monster a player permanently turns into on death (Death & Permadeath, GDD section 9) |
| `familiar.xml` | Summoned by "Summon Familiar" |

`skeleton_rat.xml` and `troll_bones.xml` (originally created for the deferred
Corpse & Undead system) and `grakthar_the_bonecaller.xml` (the deferred world
boss) remain in `data/monster/monsters/` for future use but are **not**
registered in `data/monster/monsters.xml`, so they will not load or spawn.
The four active monsters above are registered at the bottom of
`data/monster/monsters.xml` under a "Campaign MVP additions" comment.

## New NPCs (`data/npc/`, scripts in `data/npc/scripts/campaign/`)

Implements the GDD section 15 city layout with the existing `NpcSystem`
(`KeywordHandler` / `NpcHandler` / `ShopModule` / `VoiceModule` / `FocusModule`).
Each NPC has a `{trade}`/keyword-driven shop and dialogue:

| NPC | Location | Interface |
|---|---|---|
| `Campaign Innkeeper.xml` | Inn | `{room}` rents a bed for 20 gold: full HP/mana + resets Hunger to "Fed" (10h). Sells bread/cheese. |
| `Campaign Blacksmith.xml` | Forge | Sells weapons/armor, buys/sells iron ore. `{repair}`/`{anvil}` explains the durability/repair system. |
| `Campaign Alchemist.xml` | Alchemist Shop | Sells blank runes and potions. `{rune}`/`{inscribe}` explains `!inscribe <Spell Name>`. |
| `Campaign Librarian.xml` | Library | `{literacy}` explains the literacy gate; ask for a grimoire by name (`{light}`, `{antidote}`, `{fireball}`, `{mass healing}`, `{familiar}`) to be lent one if magic level + literacy qualify. |
| `Campaign Chronicler.xml` | Town Hall | `{chronicle}`/`{phase}`/`{news}` reports the current Campaign Phase from storage `CAMPAIGN_PHASE_STORAGE` (60020). |
| `Campaign Merchant.xml` | Market | Buys/sells every item in `CampaignConfig.food` at prices derived from its hunger-tick value. |
| `Campaign Cleric.xml` | Temple | `{heal}` restores HP for gold (2gp/HP); `{cure}`/`{poison}` removes poison for 20 gold. Sells antidote potions. |

All NPC `look` outfit ids are placeholder "citizen/worker/mage" type ids -
replace with campaign-specific NPC sprites later.

## Crafting stations (GDD section 7/8)

Each station is just a tile/item placed in the world with a specific
`actionId` (set in the map editor or via item attributes). A player "uses" a
recipe item on the station; the recipe tables live in
`CampaignConfig.crafting`, so new recipes never require script changes:

| Station | actionId | Recipes (`campaign_config.lua`) | Script |
|---|---|---|---|
| Cooking fire | 9101 | `crafting.cookingRecipes`: raw food -> cooked food (timed) | `actions/cooking_fire.lua` |
| Alchemy table | 9102 | `crafting.alchemyRecipes`: item + materials -> result | `actions/alchemy_table.lua` |
| Workbench | 9103 | `crafting.workbenchRecipes`: consume N of an item (+materials) -> result | `actions/workbench.lua` |

## Resource gathering (GDD section 8)

World tiles/items carry one of the `actionId`s listed in
`CampaignConfig.gathering.nodes`. Using the node (`actions/gather_resource.lua`)
checks for a required tool (if any), yields a random amount of the node's
item, and starts a `respawnSeconds` cooldown tracked via a custom item
attribute (`campaign_depleted_until`):

| actionId | Node | Tool required | Yields |
|---|---|---|---|
| 9201 | Iron vein | Pickaxe (5710) | Iron ore (5910), feeds `repair.lua` |
| 9202 | Tree | Hatchet (2550) | Logs (5942), feeds `workbench.lua` (-> torches) |
| 9203 | Herb patch | None | Cooking herb (2789) |

## Death & Permadeath / PK system (GDD section 9)

Controlled by `CampaignConfig.permadeath`. By default `pvpOnly = true`, so
normal PvE deaths use the engine's usual respawn rules.

1. `creaturescripts/permadeath_convert.lua` (`type("death")`) - if the killer
   is another player, drops the victim's entire equipment at the death
   position, flags the character (`shadeStorage`), and spawns a hostile
   `Player Shade` monster in their place.
2. `creaturescripts/permadeath_login.lua` (`type("login")`) - on every
   subsequent login, a flagged character is teleported to
   `permadeath.shadePosition` (placeholder coordinates - point this at a
   dedicated limbo/spectator area) and told the character has permanently
   perished.

## Campaign phase system (GDD section 10)

The active phase is a **world-global** counter (`Game.getStorageValue` /
`Game.setStorageValue`, storage key `CampaignConfig.campaignPhase.storage` =
60020) - not per-player.

- `talkactions/campaign_phase.lua` - `!campaignphase` (GM-only, access level
  >= `campaignPhase.gmAccessLevel`) reports the current phase; `!campaignphase
  <0-3>` sets it and broadcasts a notice to all online players.
- `npc/scripts/campaign/chronicler.lua` - the Town Hall Chronicler NPC reads
  the same global storage value via `{chronicle}`/`{phase}`/`{news}` and
  reports the matching entry from its `PHASES` table.

## Deferred systems (future work)

Two systems from `docs/GDD-CoreSystems.md` were removed from the initial MVP
to keep the first playable loop close to a classic Rookgard-style experience.
Both can be reintroduced later without touching the systems above:

- **Corpse & Undead system (GDD section 6)** - previously, unburned monster
  corpses would rise as undead (`creaturescripts/corpse_rise.lua`), and
  torches could burn a corpse to prevent that (`actions/burn_corpse.lua`).
  Both scripts and the `CampaignConfig.corpse` table were removed; the
  `skeleton_rat.xml` / `troll_bones.xml` monster files remain unregistered in
  `data/monster/monsters/` for future use. The implementation can be found in
  this repo's git history if needed as a starting point.
- **Boss system (GDD section 11)** - previously, `globalevents/auto_boss.lua`
  periodically spawned a world boss ("Grakthar the Bonecaller"), tracked via
  `creaturescripts/boss_death.lua` and `CampaignConfig.boss`. Both scripts and
  the config table were removed; `grakthar_the_bonecaller.xml` remains
  unregistered in `data/monster/monsters/` for future use.

## Load order

`CampaignConfig` is a global table every other file in this folder reads
from, so `campaign_config.lua` (and `skill_gain_block.lua`, which also reads
it at load time) must be loaded first. Verified against this fork's
`src/script.cpp`: `Scripts::loadScripts("scripts", false, false)` **skips any
directory literally named `lib`**, and the separate lib pass
(`loadScripts("scripts/lib", true, false)`) only scans `data/scripts/lib/`,
not arbitrary `lib/` subfolders. A `campaign/lib/` folder would therefore
never be loaded at all. Both files live directly in `data/scripts/lib/`
(alongside the engine's own libs) for this reason - **do not** move them back
under `campaign/`.

## Known engine-version caveats

These scripts were written against the common TFS 1.x revscriptsys API
(`Action`, `TalkAction`, `GlobalEvent`, `CreatureEvent`, `EventCallback`,
`Spell`, `Combat`). Two areas should be double-checked against the exact
engine commit used for the campaign server (this repo's `server` submodule,
forked at `OldSchoolRPG/forgottenserver`):

1. **`EventCallback.onGainSkillTries`** (`data/scripts/lib/skill_gain_block.lua`) -
   confirm the callback name/signature in `data/scripts/lib/event_callbacks.lua`.
2. **`CreatureEvent:type("death")` / `type("login")`** (`creaturescripts/*`) -
   confirm whether these need to be registered per-player/monster via the
   default registration scripts, or fire globally out of the box.
3. **New spell IDs** (`spells/fireball.lua` id 90001, `mass_healing.lua` id
   90002, `summon_familiar.lua` id 90003) and **words** (`exevo pyra hur`,
   `exura vita mas`, `utori familiaris`) were chosen to avoid colliding with
   the engine's built-in spell list, but were not verified against a running
   build.

## Item/asset IDs

Most rune, food, repair-material, and grimoire item IDs in
`campaign_config.lua` are reconciled with the engine's real `items.xml`
where it mattered for functionality (corpses, runes, blank rune). The
**grimoire item IDs (8914-8918)** and the **repair recipe item/material IDs**
are still placeholders from the original GDD draft and may collide with
existing rod/wand items in `items.xml` - replace them with dedicated
"grimoire"/"ore" items once the campaign's custom `items.xml` and
`.dat`/`.spr` (for OTClientV8) are finalized.

## Sprites and assets

This MVP intentionally ships **no** `.spr`/`.dat`/`.pic` client asset files.
Many community OT servers reuse original Tibia client sprites for local,
non-commercial prototyping; if you do this, keep those binary client files
**out of this repository** (drop them into your local `client/` checkout
only) and plan to replace them with original assets before any public or
commercial release.
