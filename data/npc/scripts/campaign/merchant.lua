-- World Map Design (GDD section 15): Market.
-- Buys and sells the food tiers from the Cooking System (GDD section 7,
-- CampaignConfig.food) so players have a reliable place to convert gathered
-- ingredients and cooked meals into gold and back.

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "Fresh goods, fair prices! Ask for a {trade} to see what I'm buying and selling."},
}
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

-- Sell price scales with the food's hunger-tick value (CampaignConfig.food);
-- buy price (what the merchant pays the player) is half that.
for itemId, ticks in pairs(CampaignConfig.food) do
	local sellPrice = math.max(1, math.floor(ticks / 2))
	local buyPrice = math.max(1, math.floor(ticks / 4))
	local name = ItemType(itemId):getName()
	shopModule:addBuyableItem({name}, itemId, sellPrice, 1, name)
	shopModule:addSellableItem({name}, itemId, buyPrice, name)
end

shopModule:addBuyableItem({'backpack'}, 1988, 20, 'backpack')
shopModule:addSellableItem({'bone'}, 2230, 1, 'bone')

keywordHandler:addKeyword({'stuff'}, StdModule.say, {npcHandler = npcHandler, text = 'Just ask me for a {trade} to see my goods.'})
keywordHandler:addAliasKeyword({'wares'})
keywordHandler:addAliasKeyword({'offer'})

npcHandler:addModule(FocusModule:new())
