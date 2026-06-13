-- Boss System (GDD section 11): periodically checks whether
-- CampaignConfig.boss is currently alive (Game.getStorageValue), and if not,
-- rolls spawnChance to bring it back at spawnPosition. Death is tracked via
-- creaturescripts/boss_death.lua, registered on the spawned monster.

local cfg = CampaignConfig.boss

local autoBoss = GlobalEvent("CampaignAutoBoss")

function autoBoss.onThink(interval)
	if Game.getStorageValue(cfg.aliveStorage) == 1 then
		return true
	end

	if math.random(100) > cfg.spawnChance then
		return true
	end

	local pos = cfg.spawnPosition
	local boss = Game.createMonster(cfg.name, Position(pos.x, pos.y, pos.z), true, true)
	if not boss then
		return true
	end

	Game.setStorageValue(cfg.aliveStorage, 1)
	boss:registerEvent("CampaignBossDeath")

	for _, target in ipairs(Game.getPlayers()) do
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, cfg.name .. " has awoken somewhere in the world...")
	end

	return true
end

autoBoss:interval(cfg.intervalMs)
autoBoss:register()
