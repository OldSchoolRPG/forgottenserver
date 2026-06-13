-- World Map Design (GDD section 15): Inn / Innkeeper.
-- Sells basic food and offers a "rent room" service that fully restores the
-- player and resets the Hunger System (GDD section 4) to "Fed".

local ROOM_COST = 20 -- gold coins
local REST_FOOD_TICKS = 600 -- 10 hours of in-game "Fed" time

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "Welcome, traveler! Ask me for a {room} if you'd like to rest."},
}
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addSellableItem({'bread'}, 2689, 2, 'bread')
shopModule:addSellableItem({'cheese'}, 2696, 3, 'cheese')
shopModule:addSellableItem({'meat'}, 2666, 2, 'meat')
shopModule:addBuyableItem({'bread'}, 2689, 5, 'bread')
shopModule:addBuyableItem({'cheese'}, 2696, 8, 'cheese')

keywordHandler:addKeyword({'stuff'}, StdModule.say, {npcHandler = npcHandler, text = 'Just ask me for a {trade} to see my food, or for a {room} to rest.'})
keywordHandler:addAliasKeyword({'food'})

function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	local player = Player(cid)

	if msgcontains(msg, 'room') or msgcontains(msg, 'rent') then
		selfSay('A room costs ' .. ROOM_COST .. ' gold. It will tend your wounds and fill your stomach. Do you want one? {yes}/{no}', cid)
		npcHandler.topic[cid] = 1
	elseif msgcontains(msg, 'yes') and npcHandler.topic[cid] == 1 then
		if player:removeMoney(ROOM_COST) then
			player:addHealth(player:getMaxHealth())
			player:addMana(player:getMaxMana())

			local hungerCfg = CampaignConfig.hunger
			player:setStorageValue(hungerCfg.foodTicksStorage, REST_FOOD_TICKS)
			player:setStorageValue(hungerCfg.hungrySinceStorage, -1)

			selfSay('There you go, all rested up. Safe travels!', cid)
		else
			selfSay('You do not have enough gold for a room.', cid)
		end
		npcHandler.topic[cid] = 0
	elseif msgcontains(msg, 'no') and npcHandler.topic[cid] == 1 then
		selfSay('Suit yourself.', cid)
		npcHandler.topic[cid] = 0
	end

	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
