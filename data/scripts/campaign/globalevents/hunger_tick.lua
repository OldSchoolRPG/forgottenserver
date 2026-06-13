-- Hunger System (GDD section 4)
-- Runs every tickIntervalMs (default 60s) for every online player.
-- States: Fed -> Hungry -> Starving (10min) -> Exhausted (30min)

local cfg = CampaignConfig.hunger

local hungerEvent = GlobalEvent("CampaignHungerTick")

function hungerEvent.onThink(interval, lastExecution, now)
	for _, player in ipairs(Game.getPlayers()) do
		local ticks = player:getStorageValue(cfg.foodTicksStorage)
		if ticks < 0 then
			ticks = 0
		end

		if ticks > 0 then
			-- Fed: consume ticks, clear hungry timer
			player:setStorageValue(cfg.foodTicksStorage, ticks - cfg.ticksPerInterval)
			if player:getStorageValue(cfg.hungrySinceStorage) > 0 then
				player:setStorageValue(cfg.hungrySinceStorage, -1)
				player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You are no longer hungry.")
			end
		else
			-- Hungry or worse
			local hungrySince = player:getStorageValue(cfg.hungrySinceStorage)
			if hungrySince <= 0 then
				hungrySince = os.time()
				player:setStorageValue(cfg.hungrySinceStorage, hungrySince)
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are getting hungry. Find food soon.")
			end

			local hungryFor = os.time() - hungrySince

			if hungryFor >= cfg.exhaustedAfter then
				player:addHealth(-cfg.exhaustedDamagePerTick)
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are exhausted from hunger! Movement is slowed and your health is draining.")
			elseif hungryFor >= cfg.starvingAfter then
				player:addHealth(-cfg.starvingDamagePerTick)
				player:sendTextMessage(MESSAGE_STATUS_WARNING, "You are starving! Your health is draining.")
			end
		end
	end
	return true
end

hungerEvent:interval(cfg.tickIntervalMs)
hungerEvent:register()
