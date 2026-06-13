-- Item Durability (GDD section 5): repairing an item at an anvil restores
-- it to full durability/charges, consuming the materials defined in
-- CampaignConfig.repair.recipes. The target must be an item/tile with the
-- configured anvil action id (set via the map editor).

local cfg = CampaignConfig.repair

local repairAction = Action()

function repairAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or not target.getActionId or target:getActionId() ~= cfg.anvilActionId then
		player:sendCancelMessage("You must use this on an anvil.")
		return true
	end

	local recipe = cfg.recipes[item:getId()]
	if not recipe then
		player:sendCancelMessage("This item cannot be repaired here.")
		return true
	end

	for materialId, count in pairs(recipe.materials) do
		if player:getItemCount(materialId) < count then
			player:sendCancelMessage("You do not have the materials required to repair this item.")
			return true
		end
	end

	for materialId, count in pairs(recipe.materials) do
		player:removeItem(materialId, count)
	end

	local itemType = item:getType()
	item:setAttribute(ITEM_ATTRIBUTE_DURATION, itemType:getDuration())
	item:setAttribute(ITEM_ATTRIBUTE_CHARGES, itemType:getCharges())

	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You repair the item back to full durability.")
	target:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

for itemId in pairs(cfg.recipes) do
	repairAction:id(itemId)
end

repairAction:register()
