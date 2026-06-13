-- Cooking System (GDD section 7): use a raw food item on a cooking fire
-- (a tile/item with actionId CampaignConfig.crafting.cookingFireActionId)
-- to cook it. The result appears in the player's inventory after a short
-- delay.

local cfg = CampaignConfig.crafting

local cookAction = Action()

function cookAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or target:getActionId() ~= cfg.cookingFireActionId then
		player:sendCancelMessage("You need to use this on a cooking fire.")
		return true
	end

	local recipe = cfg.cookingRecipes[item:getId()]
	if not recipe then
		return false
	end

	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_FIREATTACK)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You start cooking...")

	local playerId = player:getId()
	local resultId = recipe.result
	addEvent(function()
		local cookPlayer = Player(playerId)
		if not cookPlayer then
			return
		end

		cookPlayer:addItem(resultId, 1)
		cookPlayer:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Your " .. ItemType(resultId):getName() .. " is ready!")
		cookPlayer:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	end, recipe.cookTimeMs)

	return true
end

for itemId in pairs(cfg.cookingRecipes) do
	cookAction:id(itemId)
end

cookAction:register()
