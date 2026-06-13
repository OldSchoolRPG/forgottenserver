-- Campaign MVP configuration
-- Shared constants for the Hunger, Magic (Grimoire/Rune), Durability and
-- Corpse & Undead systems described in docs/GDD-CoreSystems.md

CampaignConfig = {
	hunger = {
		-- storage value tracking remaining food ticks
		foodTicksStorage = 60001,
		-- storage value tracking the timestamp (os.time) since the player
		-- entered the "Hungry" state (0 = not hungry)
		hungrySinceStorage = 60002,
		-- how often the global event runs
		tickIntervalMs = 60 * 1000,
		-- ticks consumed per interval while fed
		ticksPerInterval = 1,
		-- thresholds, in seconds of continuous hunger
		starvingAfter = 10 * 60,
		exhaustedAfter = 30 * 60,
		-- HP loss per tick (60s) once starving / exhausted
		starvingDamagePerTick = 2, -- ~ -1 every 30s
		exhaustedDamagePerTick = 8, -- ~ -2 every 15s
	},

	-- Grimoires: itemId -> { spell = "Spell Name", minMagicLevel = X, minLiteracy = Y }
	grimoires = {
		[8914] = { spell = "Light", minMagicLevel = 0, minLiteracy = 0 },
		[8915] = { spell = "Antidote", minMagicLevel = 2, minLiteracy = 1 },
		[8916] = { spell = "Fireball", minMagicLevel = 5, minLiteracy = 2 },
		[8917] = { spell = "Mass Healing", minMagicLevel = 10, minLiteracy = 3 },
		[8918] = { spell = "Summon Familiar", minMagicLevel = 15, minLiteracy = 4 },
	},

	-- Rune crafting: blank rune item id -> charged rune item id produced.
	-- Requires the player to have learned the matching spell via a grimoire.
	runeCrafting = {
		blankRuneId = 16125,
		recipes = {
			["Antidote"] = { runeId = 2273, manaCost = 200, baseCharges = 1, chargesPerMagicLevel = 5 },
			["Fireball"] = { runeId = 2304, manaCost = 600, baseCharges = 1, chargesPerMagicLevel = 8 },
			["Mass Healing"] = { runeId = 2273, manaCost = 1200, baseCharges = 1, chargesPerMagicLevel = 10 },
		},
	},

	-- Item durability: itemId -> { skill = "smithing"|"woodworking", materials = { [itemId] = count } }
	repair = {
		anvilActionId = 9100,
		recipes = {
			[2400] = { materials = { [2148] = 5 } }, -- example: plate armor repaired with 5 gold-cost metal bars
			[2376] = { materials = { [5910] = 2 } }, -- example: sword repaired with 2 iron ore
		},
	},

	-- Cooking System (GDD section 7): food itemId -> ticks restored
	food = {
		[2667] = 10, -- roasted rat (raw tier)
		[2689] = 30, -- bread (basic tier)
		[2696] = 60, -- meat stew (cooked tier)
		[2693] = 120, -- hunter's feast (special tier)
		[2787] = 200, -- dragon broth (magical tier)
	},

	-- Corpse & Undead system
	corpse = {
		-- corpse itemId -> { undeadName = "monster name in monsters/", riseAfter = seconds }
		rules = {
			[2853] = { undeadName = "Skeleton Rat", riseAfter = 240 }, -- rat corpse
			[2859] = { undeadName = "Skeleton", riseAfter = 300 }, -- human corpse
			[2862] = { undeadName = "Troll Bones", riseAfter = 300 }, -- troll corpse
		},
		-- item attribute key (string) set on the corpse once it has been burned
		burnedAttribute = "campaign_burned",
		-- itemIds that can be used to burn a corpse (torches)
		burningTools = { 2050, 2051, 2052 },
	},
}
