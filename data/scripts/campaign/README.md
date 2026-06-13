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

## Load order

`lib/campaign_config.lua` must be loaded before every other file in this
folder, since `CampaignConfig` is a global table they all read from. TFS's
script loader generally loads `data/scripts/lib/**` first; if your engine
build loads folders strictly alphabetically, move `campaign_config.lua` and
`skill_gain_block.lua` into the engine's existing `lib/` folder instead of
`campaign/lib/`.

## Known engine-version caveats

These scripts were written against the common TFS 1.x revscriptsys API
(`Action`, `TalkAction`, `GlobalEvent`, `CreatureEvent`, `EventCallback`).
Two areas should be double-checked against the exact engine commit used for
the campaign server (this repo's `server` submodule, forked at
`OldSchoolRPG/forgottenserver`):

1. **`EventCallback.onGainSkillTries`** (`lib/skill_gain_block.lua`) — confirm
   the callback name/signature in `data/scripts/lib/event_callbacks.lua`.
2. **`CreatureEvent:type("death")` / `type("login")`** (`creaturescripts/*`) —
   confirm whether these need to be registered per-player/monster via the
   default registration scripts, or fire globally out of the box.

## Item/asset IDs

All item IDs in `campaign_config.lua` (grimoires, runes, food, repair
materials, corpses) are **placeholders** taken from the default 7.x/8.x
client item set as examples. Replace them with the final IDs once the
campaign's custom `items.xml` / `.dat`/`.spr` (for OTClientV8) are finalized.
