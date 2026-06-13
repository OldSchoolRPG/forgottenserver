# Campaign MVP Scripts

This folder contains the first playable slice of the systems described in
[`docs/GDD-CoreSystems.md`](../../../docs/GDD-CoreSystems.md) (Phase 1 + Phase 2
of the implementation roadmap), built on top of TFS's revscriptsys
(`data/scripts/`).

## Contents

| File | System | GDD Section |
|---|---|---|
| `lib/campaign_config.lua` | Shared config/data tables for all systems below | - |
| `globalevents/hunger_tick.lua` | Hunger state machine (Fed/Hungry/Starving/Exhausted) | 4 |
| `lib/skill_gain_block.lua` | Pauses skill gain while hungry | 4 |
| `actions/eat_food.lua` | Eating food restores food ticks | 4, 7 |
| `creaturescripts/campaign_login.lua` | Initializes hunger storage on login | 4 |
| `actions/repair.lua` | Repairing equipment at an anvil | 5 |
| `creaturescripts/corpse_rise.lua` | Unburned corpses rise as undead | 6 |
| `actions/burn_corpse.lua` | Burning a corpse prevents it from rising | 6 |
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
| `globalevents/auto_boss.lua` | Periodically spawns "Grakthar the Bonecaller" if not already alive | 11 |
| `creaturescripts/boss_death.lua` | Resets the boss "alive" flag and announces its defeat | 11 |

## New monsters (`data/monster/monsters/`)

| Monster | Used by |
|---|---|
| `skeleton_rat.xml` | Rises from an unburned rat corpse (item 5964) |
| `troll_bones.xml` | Rises from an unburned troll corpse (item 5960) |
| `player_shade.xml` | Hostile monster a player permanently turns into on death (Death & Permadeath, GDD section 9) |
| `familiar.xml` | Summoned by "Summon Familiar" |
| `grakthar_the_bonecaller.xml` | World boss, periodically spawned by `globalevents/auto_boss.lua` (GDD section 11) |

The built-in `Skeleton` monster (already in the engine) now also rises from
unburned human/bandit corpses (item 20331). All five are registered at the
bottom of `data/monster/monsters.xml` under a "Campaign MVP additions"
comment.

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

## Boss system (GDD section 11)

A simple "auto boss" loop built on the same world-global storage pattern:

- `globalevents/auto_boss.lua` runs every `boss.intervalMs` (default 30 min).
  If `boss.aliveStorage` is not set, it rolls `boss.spawnChance` (default 10%)
  and, on success, spawns `boss.name` ("Grakthar the Bonecaller") at
  `boss.spawnPosition` (placeholder coordinates), sets the alive flag, and
  registers `creaturescripts/boss_death.lua` on that monster instance.
- `creaturescripts/boss_death.lua` (`type("death")`) clears the alive flag
  when the boss with that name dies and announces its defeat, allowing
  `auto_boss.lua` to spawn it again later.
- `data/monster/monsters/grakthar_the_bonecaller.xml` - an undead boss
  (~2000 HP, melee/lifedrain/area attacks, undead immunities) that drops gold,
  crystal coins, bones, and a "heavy old tome" (item 26642).

## Load order

`lib/campaign_config.lua` must be loaded before every other file in this
folder, since `CampaignConfig` is a global table they all read from. TFS's
script loader generally loads `data/scripts/lib/**` first; if your engine
build loads folders strictly alphabetically, move `campaign_config.lua` and
`skill_gain_block.lua` into the engine's existing `lib/` folder instead of
`campaign/lib/`.

## Known engine-version caveats

These scripts were written against the common TFS 1.x revscriptsys API
(`Action`, `TalkAction`, `GlobalEvent`, `CreatureEvent`, `EventCallback`,
`Spell`, `Combat`). Two areas should be double-checked against the exact
engine commit used for the campaign server (this repo's `server` submodule,
forked at `OldSchoolRPG/forgottenserver`):

1. **`EventCallback.onGainSkillTries`** (`lib/skill_gain_block.lua`) - confirm
   the callback name/signature in `data/scripts/lib/event_callbacks.lua`.
2. **`CreatureEvent:type("death")` / `type("login")`** (`creaturescripts/*`) -
   confirm whether these need to be registered per-player/monster via the
   default registration scripts, or fire globally out of the box.
3. **New spell IDs** (`spells/fireball.lua` id 90001, `mass_healing.lua` id
   90002, `summon_familiar.lua` id 90003) and **words** (`exevo pyra hur`,
   `exura vita mas`, `utori familiaris`) were chosen to avoid colliding with
   the engine's built-in spell list, but were not verified against a running
   build.
4. **`Creature:registerEvent("CampaignBossDeath")`** (`globalevents/auto_boss.lua`)
   - confirm this method exists on the monster userdata returned by
   `Game.createMonster` in your engine build; if not, register
   `boss_death.lua` globally (`type("death")`) and filter by
   `creature:getName()` as it already does.
5. **`<flag isboss="1" />`** (`monster/monsters/grakthar_the_bonecaller.xml`) -
   optional in most TFS 1.x builds; remove it if your engine's monster loader
   rejects unknown flags.

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
