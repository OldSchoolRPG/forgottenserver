-- Corpse & Undead System (GDD section 6): using a torch on a fresh corpse
-- marks it as "burned" so it will not rise as undead.

local cfg = CampaignConfig.corpse

local burnAction = Action()

function burnAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if not target or not target.getId or not cfg.rules[target:getId()] then
		player:sendCancelMessage("You can only burn a corpse with this.")
		return true
	end

	if target:getCustomAttribute(cfg.burnedAttribute) then
		player:sendCancelMessage("This corpse has already been burned.")
		return true
	end

	target:setCustomAttribute(cfg.burnedAttribute, 1)
	target:getPosition():sendMagicEffect(CONST_ME_FIREAREA)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You set the corpse ablaze. It will not rise.")
	return true
end

for _, toolId in ipairs(cfg.burningTools) do
	burnAction:id(toolId)
end

burnAction:register()
