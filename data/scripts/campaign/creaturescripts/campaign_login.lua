-- Initializes campaign-specific player storage values on first login.
-- NOTE: depending on the engine version, "login" CreatureEvents may need to be
-- registered explicitly for each player (see data/scripts/creaturescripts/player/login.lua).
-- If so, add: player:registerEvent("CampaignLogin")

local cfg = CampaignConfig.hunger
local STARTING_FOOD_TICKS = 60 -- new characters start "Fed" for 1 minute

local loginEvent = CreatureEvent("CampaignLogin")

function loginEvent.onLogin(player)
	if player:getStorageValue(cfg.foodTicksStorage) < 0 then
		player:setStorageValue(cfg.foodTicksStorage, STARTING_FOOD_TICKS)
	end
	player:setStorageValue(cfg.hungrySinceStorage, -1)
	return true
end

loginEvent:type("login")
loginEvent:register()
