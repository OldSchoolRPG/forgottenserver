-- Corpse & Undead System (GDD section 6): if a corpse is not burned within
-- its timer, it rises as an undead creature at the same position.
--
-- NOTE: "death" CreatureEvents must be registered for monsters to fire this
-- hook. Depending on the engine version this may require registering
-- "CampaignCorpseRise" in the default monster death registration script
-- (data/scripts/creaturescripts/monster/death.lua or equivalent).

local cfg = CampaignConfig.corpse

local function checkCorpse(corpseUid, position, undeadName)
	local corpse = Item(corpseUid)
	if not corpse then
		return -- corpse already gone (looted/decayed)
	end

	if corpse:getCustomAttribute(cfg.burnedAttribute) then
		return -- safely burned, do not rise
	end

	corpse:remove()

	local monster = Game.createMonster(undeadName, position, true, true)
	if monster then
		position:sendMagicEffect(CONST_ME_MORTAREA)
	end
end

local riseEvent = CreatureEvent("CampaignCorpseRise")

function riseEvent.onDeath(creature, corpse, killer, mostDamageKiller, unjustified, mostDamageUnjustified)
	if not corpse then
		return true
	end

	local rule = cfg.rules[corpse:getId()]
	if not rule then
		return true
	end

	addEvent(checkCorpse, rule.riseAfter * 1000, corpse:getUniqueId(), corpse:getPosition(), rule.undeadName)
	return true
end

riseEvent:type("death")
riseEvent:register()
