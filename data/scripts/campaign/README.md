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

## New monsters (`data/monster/monsters/`)

| Monster | Used by |
|---|---|
| `skeleton_rat.xml` | Rises from an unburned rat corpse (item 5964) |
| `troll_bones.xml` | Rises from an unburned troll corpse (item 5960) |
| `player_shade.xml` | Base template for the Death & Permadeath system (GDD section 9, upcoming) |
| `familiar.xml` | Summoned by "Summon Familiar" |

The built-in `Skeleton` monster (already in the engine) now also rises from
unburned human/bandit corpses (item 20331). All four are registered at the
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
