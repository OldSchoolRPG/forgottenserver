-- Campaign MVP configuration
-- Shared constants for the Hunger, Magic (Grimoire/Rune), Durability,
-- Crafting/Gathering and Death/Permadeath systems described in
-- docs/GDD-CoreSystems.md

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
	-- "Antidote" and "Mass Healing" / "Fireball" / "Summon Familiar" are taught
	-- as the *actual* registered spell names below (see
	-- data/scripts/spells/{attack,healing,conjuring}/ for the new ones, and
	-- data/scripts/spells/healing/cure_poison.lua for the built-in one).
	grimoires = {
		[8914] = { spell = "Light", minMagicLevel = 0, minLiteracy = 0 },
		[8915] = { spell = "Cure Poison", minMagicLevel = 2, minLiteracy = 1 }, -- "Antidote" grimoire
		[8916] = { spell = "Fireball", minMagicLevel = 5, minLiteracy = 2 },
		[8917] = { spell = "Mass Healing", minMagicLevel = 10, minLiteracy = 3 },
		[8918] = { spell = "Summon Familiar", minMagicLevel = 15, minLiteracy = 4 },
	},

	-- Rune crafting: spell name (must be a spell the player has learned via a
	-- grimoire) -> charged rune produced by "!inscribe <Spell Name>".
	-- All runeIds below are real, already-registered rune items/spells in the
	-- engine (data/scripts/runes/), so inscribed runes work out of the box:
	--   2266 = Cure Poison Rune, 2302 = Fireball Rune, 2273 = Ultimate Healing Rune
	-- blankRuneId 2260 is the item created by the built-in "Blank Rune" spell
	-- (data/scripts/spells/conjuring/blank_rune.lua).
	runeCrafting = {
		blankRuneId = 2260,
		recipes = {
			["Cure Poison"] = { runeId = 2266, manaCost = 200, baseCharges = 1, chargesPerMagicLevel = 5 },
			["Fireball"] = { runeId = 2302, manaCost = 600, baseCharges = 1, chargesPerMagicLevel = 8 },
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

	-- Crafting & Resources (GDD section 7/8): each station is a tile/item in
	-- the world with the listed actionId. A player "uses" a recipe item on
	-- the station to craft. See data/scripts/campaign/actions/cooking_fire.lua,
	-- alchemy_table.lua and workbench.lua.
	crafting = {
		cookingFireActionId = 9101,
		-- raw food itemId -> { result = cookedItemId, cookTimeMs = ms }
		cookingRecipes = {
			[2666] = { result = 2667, cookTimeMs = 4000 }, -- meat -> roasted meat (food tier: raw)
			[2671] = { result = 2696, cookTimeMs = 6000 }, -- ham -> meat stew (food tier: cooked)
		},

		alchemyTableActionId = 9102,
		-- itemId used on the table -> { result, resultCount, materials = { [itemId] = count } }
		alchemyRecipes = {
			-- empty potion flask + roasted meat + bread = hunter's feast
			[7636] = { result = 2693, resultCount = 1, materials = { [2667] = 1, [2689] = 1 } },
		},

		workbenchActionId = 9103,
		-- itemId used on the bench -> { result, resultCount, consumedCount, materials = { [itemId] = count } }
		workbenchRecipes = {
			-- 2 logs -> 1 torch (light source for dark areas)
			[5942] = { result = 2050, resultCount = 1, consumedCount = 2, materials = {} },
		},
	},

	-- Resource Gathering (GDD section 8): world tiles/items carry one of
	-- these actionIds. Using the node yields an item, optionally requires a
	-- tool in the player's inventory, and then needs `respawnSeconds` to
	-- recover. See data/scripts/campaign/actions/gather_resource.lua.
	gathering = {
		nodes = {
			[9201] = { name = "iron vein", tool = 5710, yield = 5910, yieldMin = 1, yieldMax = 3, respawnSeconds = 300 }, -- pickaxe -> iron ore (used by repair.lua)
			[9202] = { name = "tree", tool = 2550, yield = 5942, yieldMin = 1, yieldMax = 2, respawnSeconds = 180 }, -- hatchet -> logs (used by workbench)
			[9203] = { name = "herb patch", tool = nil, yield = 2789, yieldMin = 1, yieldMax = 1, respawnSeconds = 240 }, -- no tool -> cooking herb
		},
	},

	-- Death & Permadeath / PK System (GDD section 9). See
	-- data/scripts/campaign/creaturescripts/permadeath_convert.lua and
	-- permadeath_login.lua.
	permadeath = {
		enabled = true,
		-- if true, only PvP kills (mostDamageKiller is a player) trigger
		-- permadeath; ordinary PvE deaths use the engine's normal death rules.
		pvpOnly = true,
		-- storage value flag set on a character once it has permanently died
		shadeStorage = 60030,
		-- where permadead characters are teleported on next login. Placeholder
		-- coordinates - point this at a dedicated "shade limbo"/spectator area.
		shadePosition = { x = 1000, y = 1000, z = 7 },
	},

	-- Campaign Phase System (GDD section 10). Stored via Game.getStorageValue
	-- / Game.setStorageValue (world-global, not per-player).
	-- CAMPAIGN_PHASE_STORAGE is declared globally by
	-- data/npc/scripts/campaign/chronicler.lua; the talkaction
	-- (data/scripts/campaign/talkactions/campaign_phase.lua) lets GMs
	-- advance/inspect it.
	campaignPhase = {
		storage = 60020,
		maxPhase = 3,
		-- access level required to change the phase (2 = GM by default in TFS)
		gmAccessLevel = 2,
	},
}
