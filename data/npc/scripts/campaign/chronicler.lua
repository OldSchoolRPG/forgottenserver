-- World Map Design (GDD section 15): Town Hall / Chronicle.
-- Reports the current Campaign Phase (GDD section 10).
--
-- CAMPAIGN_PHASE_STORAGE is the single source of truth for the active phase
-- and is shared with the future GM phase-control talkaction
-- (data/scripts/campaign/talkactions/campaign_phase.lua). Phase 0 is the
-- default for a freshly-started world.

CAMPAIGN_PHASE_STORAGE = 60020

local PHASES = {
	[0] = "Phase 0 - The Beginning: the world is young, the roads are unguarded, and the old ruins have not yet stirred.",
	[1] = "Phase 1 - First Tremors: corpses are rising in the wilds, and the town watch has put out a bounty on the undead.",
	[2] = "Phase 2 - The Long Hunger: supplies are running short; the Inn and Market are paying well for cooked food.",
	[3] = "Phase 3 - The Gathering Storm: a great threat is stirring. The Town Hall is calling for champions.",
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "Ask me for the {chronicle} to hear the latest news of the campaign."},
}
npcHandler:addModule(VoiceModule:new(voices))

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if msgcontains(msg, 'chronicle') or msgcontains(msg, 'phase') or msgcontains(msg, 'news') then
		local player = Player(cid)
		local phase = player:getStorageValue(CAMPAIGN_PHASE_STORAGE)
		if phase < 0 then
			phase = 0
		end

		selfSay(PHASES[phase] or 'The chronicle has nothing recorded for this phase yet.', cid)
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
