-- Crafting & Resources (GDD section 7/8): use the primary ingredient on an
-- alchemy table (a tile/item with actionId
-- CampaignConfig.crafting.alchemyTableActionId) to brew a potion or special
-- food, consuming the primary item plus any listed materials.

local cfg = CampaignConfig.crafting

local alchemyAction = Action()

function alchemyAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or target:getActionId() ~= cfg.alchemyTableActionId then
		player:sendCancelMessage("You need to use this on an alchemy table.")
		return true
	end

	local recipe = cfg.alchemyRecipes[item:getId()]
	if not recipe then
		return false
	end

	for materialId, count in pairs(recipe.materials) do
		if player:getItemCount(materialId) < count then
			player:sendCancelMessage("You are missing ingredients: " .. ItemType(materialId):getName() .. ".")
			return true
		end
	end

	item:remove(1)
	for materialId, count in pairs(recipe.materials) do
		player:removeItem(materialId, count)
	end

	player:addItem(recipe.result, recipe.resultCount or 1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_GREEN)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You brew " .. ItemType(recipe.result):getName() .. ".")
	return true
end

for itemId in pairs(cfg.alchemyRecipes) do
	alchemyAction:id(itemId)
end

alchemyAction:register()
