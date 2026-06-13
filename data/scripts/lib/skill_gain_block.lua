-- Hunger System (GDD section 4): pause skill gains while Hungry/Starving/Exhausted.
-- NOTE: verify the EventCallback signature against the engine version in use
-- (data/scripts/lib/event_callbacks.lua). This follows the TFS 1.x revscriptsys
-- convention for the "onGainSkillTries" callback.

local cfg = CampaignConfig.hunger

local skillGainCallback = EventCallback

function skillGainCallback.onGainSkillTries(player, skill, tries)
	local ticks = player:getStorageValue(cfg.foodTicksStorage)
	if ticks <= 0 then
		return 0
	end
	return tries
end

skillGainCallback:register()
