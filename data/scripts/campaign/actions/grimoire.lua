-- Magic System (GDD section 3): Grimoires permanently teach a spell when read.
-- The grimoire item is consumed on a successful read and cannot be reused.
--
-- "Literacy" is tracked as a player storage value (set via quests/NPCs/world
-- events). Adjust LITERACY_STORAGE to match the campaign's literacy tracking.

local LITERACY_STORAGE = 60010

local grimoireAction = Action()

function grimoireAction.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	local data = CampaignConfig.grimoires[item:getId()]
	if not data then
		return false
	end

	if player:getMagicLevel() < data.minMagicLevel then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You do not have enough magic level to understand this grimoire.")
		return true
	end

	local literacy = player:getStorageValue(LITERACY_STORAGE)
	if literacy < data.minLiteracy then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You cannot read this grimoire. Your literacy is too low.")
		return true
	end

	if player:hasLearnedSpell(data.spell) then
		player:sendTextMessage(MESSAGE_STATUS_SMALL, "You already know this spell. The grimoire crumbles to dust.")
	else
		player:learnSpell(data.spell)
		player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You have learned the spell '" .. data.spell .. "'!")
	end

	item:remove(1)
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
	return true
end

for itemId in pairs(CampaignConfig.grimoires) do
	grimoireAction:id(itemId)
end

grimoireAction:register()
