-- Death & Permadeath / PK System (GDD section 9): when a player dies under
-- the configured conditions (by default, only PvP kills), their entire
-- equipment and backpack are dropped at the death position, the character
-- is permanently flagged as a "shade" (see permadeath_login.lua), and a
-- hostile "Player Shade" monster (data/monster/monsters/player_shade.xml)
-- rises in their place - the "NPC conversion" of the fallen player.
--
-- NOTE: "death" CreatureEvents must be registered for players to fire this
-- hook - see the campaign README's "Known engine-version caveats".

local cfg = CampaignConfig.permadeath

local permadeathEvent = CreatureEvent("CampaignPermadeath")

function permadeathEvent.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if not cfg.enabled then
		return true
	end

	local player = creature:getPlayer()
	if not player then
		return true
	end

	if cfg.pvpOnly then
		local attacker = mostDamageKiller and mostDamageKiller:getPlayer()
		if not attacker then
			return true -- PvE death: normal respawn rules apply
		end
	end

	local position = player:getPosition()

	-- Drop the player's entire equipment (backpacks drop with their contents).
	for slot = CONST_SLOT_FIRST, CONST_SLOT_LAST do
		local slotItem = player:getSlotItem(slot)
		if slotItem then
			slotItem:moveTo(position)
		end
	end

	player:setStorageValue(cfg.shadeStorage, 1)

	local shade = Game.createMonster("Player Shade", position, true, true)
	if shade then
		position:sendMagicEffect(CONST_ME_MORTAREA)
	end

	return true
end

permadeathEvent:type("death")
permadeathEvent:register()
