-- Campaign Phase System (GDD section 10): GM command to inspect or advance
-- the world-global campaign phase. Players can read the current phase from
-- the Chronicler NPC (data/npc/scripts/campaign/chronicler.lua).
--
-- Usage: "!campaignphase" to view the current phase, or
--        "!campaignphase <0-N>" to set it (requires gmAccessLevel).

local cfg = CampaignConfig.campaignPhase

local phaseTalk = TalkAction("!campaignphase")

function phaseTalk.onSay(player, words, param)
	if player:getAccessLevel() < cfg.gmAccessLevel then
		return false
	end

	param = param:trim()
	if param == "" then
		local phase = Game.getStorageValue(cfg.storage)
		if phase < 0 then
			phase = 0
		end
		player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Current campaign phase: " .. phase)
		return false
	end

	local phase = tonumber(param)
	if not phase or phase < 0 or phase > cfg.maxPhase then
		player:sendCancelMessage("Phase must be a number between 0 and " .. cfg.maxPhase .. ".")
		return false
	end

	Game.setStorageValue(cfg.storage, phase)
	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "Campaign phase set to " .. phase .. ".")

	for _, target in ipairs(Game.getPlayers()) do
		target:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The campaign has entered a new phase. Visit the Town Hall to learn more.")
	end

	return false
end

phaseTalk:separator(" ")
phaseTalk:register()
