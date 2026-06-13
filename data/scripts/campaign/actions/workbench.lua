-- Crafting & Resources (GDD section 7/8): use the primary material on a
-- workbench (a tile/item with actionId
-- CampaignConfig.crafting.workbenchActionId) to craft equipment/tools,
-- consuming `consumedCount` of the used item plus any listed materials.

local cfg = CampaignConfig.crafting

local workbenchAction = Action()

function workbenchAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or target:getActionId() ~= cfg.workbenchActionId then
		player:sendCancelMessage("You need to use this on a workbench.")
		return true
	end

	local recipe = cfg.workbenchRecipes[item:getId()]
	if not recipe then
		return false
	end

	local consumedCount = recipe.consumedCount or 1
	if player:getItemCount(item:getId()) < consumedCount then
		player:sendCancelMessage("You need " .. consumedCount .. "x " .. ItemType(item:getId()):getName() .. ".")
		return true
	end

	for materialId, count in pairs(recipe.materials) do
		if player:getItemCount(materialId) < count then
			player:sendCancelMessage("You are missing materials: " .. ItemType(materialId):getName() .. ".")
			return true
		end
	end

	player:removeItem(item:getId(), consumedCount)
	for materialId, count in pairs(recipe.materials) do
		player:removeItem(materialId, count)
	end

	player:addItem(recipe.result, recipe.resultCount or 1)
	player:getPosition():sendMagicEffect(CONST_ME_POFF)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You craft " .. ItemType(recipe.result):getName() .. ".")
	return true
end

for itemId in pairs(cfg.workbenchRecipes) do
	workbenchAction:id(itemId)
end

workbenchAction:register()
