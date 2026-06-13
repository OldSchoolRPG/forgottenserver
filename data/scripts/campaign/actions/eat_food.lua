-- Hunger System (GDD section 4): eating food restores food ticks based on
-- the recipe tier defined in CampaignConfig.food.

local hungerCfg = CampaignConfig.hunger

local eatAction = Action()

function eatAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local ticks = CampaignConfig.food[item:getId()]
	if not ticks then
		return false
	end

	local current = player:getStorageValue(hungerCfg.foodTicksStorage)
	if current < 0 then
		current = 0
	end

	player:setStorageValue(hungerCfg.foodTicksStorage, current + ticks)
	player:setStorageValue(hungerCfg.hungrySinceStorage, -1)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You eat the food. (+" .. ticks .. " food ticks)")
	player:say("Munch munch...", TALKTYPE_MONSTER_SAY)

	item:remove(1)
	return true
end

for itemId in pairs(CampaignConfig.food) do
	eatAction:id(itemId)
end

eatAction:register()
