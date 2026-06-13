-- World Map Design (GDD section 15): Temple / Cleric.
-- Heals the player and cures poison for a small donation, and sells
-- antidote potions.

local GOLD_PER_HEALTH = 2
local CURE_POISON_COST = 20

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "May the light watch over you. Ask me to {heal} your wounds, or {cure} a poison, for a small donation."},
}
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({'antidote potion', 'antidote'}, 8474, 50, 1, 'antidote potion')
shopModule:addBuyableItem({'small health'}, 8704, 20, 1, 'small health potion')

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if msgcontains(msg, 'heal') then
		local missing = player:getMaxHealth() - player:getHealth()
		if missing <= 0 then
			selfSay('You are already at full health.', cid)
			return true
		end

		local cost = math.max(1, missing * GOLD_PER_HEALTH)
		if player:removeMoney(cost) then
			player:addHealth(missing)
			selfSay('Be well.', cid)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		else
			selfSay('A full heal would cost ' .. cost .. ' gold. Come back when you can afford it.', cid)
		end
		return true
	elseif msgcontains(msg, 'cure') or msgcontains(msg, 'poison') then
		if not player:hasCondition(CONDITION_POISON) then
			selfSay('You are not poisoned.', cid)
			return true
		end

		if player:removeMoney(CURE_POISON_COST) then
			player:removeCondition(CONDITION_POISON)
			selfSay('The poison fades from your veins.', cid)
			player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
		else
			selfSay('Curing poison costs ' .. CURE_POISON_COST .. ' gold.', cid)
		end
		return true
	end

	return false
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
