-- Boss System (GDD section 11): registered on the boss monster instance by
-- globalevents/auto_boss.lua when it spawns. Resets the "alive" flag so the
-- auto-boss global event can roll for a new spawn again, and announces the
-- boss's defeat to all online players.

local cfg = CampaignConfig.boss

local bossDeath = CreatureEvent("CampaignBossDeath")

function bossDeath.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if creature:getName() ~= cfg.name then
		return true
	end

	Game.setStorageValue(cfg.aliveStorage, 0)

	for _, target in ipairs(Game.getPlayers()) do
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, cfg.name .. " has been defeated!")
	end

	return true
end

bossDeath:type("death")
bossDeath:register()
