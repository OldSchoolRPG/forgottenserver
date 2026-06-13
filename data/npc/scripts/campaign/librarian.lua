-- World Map Design (GDD section 15): Library / Librarian.
-- Explains the Literacy/Grimoire system (GDD section 3,
-- data/scripts/campaign/actions/grimoire.lua) and lends grimoires to
-- qualifying players for testing.
--
-- LITERACY_STORAGE must match the value used in
-- data/scripts/campaign/actions/grimoire.lua.

local LITERACY_STORAGE = 60010

local GRIMOIRES_BY_KEYWORD = {
	['light'] = 8914,
	['antidote'] = 8915,
	['fireball'] = 8916,
	['mass healing'] = 8917,
	['familiar'] = 8918,
}

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "Shhh. Ask me about {literacy} or a {grimoire} if you wish to study magic."},
}
npcHandler:addModule(VoiceModule:new(voices))

keywordHandler:addKeyword({'literacy'}, StdModule.say, {npcHandler = npcHandler, text =
	'Literacy is measured in levels. Each grimoire requires both a minimum magic level and a minimum literacy level to study. Ask me for a {grimoire} by name - light, antidote, fireball, mass healing, or familiar.'})

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if msgcontains(msg, 'grimoire') then
		selfSay('Which grimoire? I have: {light}, {antidote}, {fireball}, {mass healing}, and {familiar}.', cid)
		return true
	end

	for keyword, itemId in pairs(GRIMOIRES_BY_KEYWORD) do
		if msgcontains(msg, keyword) then
			local data = CampaignConfig.grimoires[itemId]
			if player:getMagicLevel() < data.minMagicLevel then
				selfSay('Your magic level is too low for the ' .. keyword .. ' grimoire.', cid)
				return true
			end

			if player:getStorageValue(LITERACY_STORAGE) < data.minLiteracy then
				selfSay('Your literacy is too low for the ' .. keyword .. ' grimoire. Come back once you have studied more.', cid)
				return true
			end

			if player:hasLearnedSpell(data.spell) then
				selfSay('You already know that spell, no need to lend you the grimoire again.', cid)
				return true
			end

			player:addItem(itemId, 1)
			selfSay('Here, study this grimoire. Use it to learn the spell permanently.', cid)
			return true
		end
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
