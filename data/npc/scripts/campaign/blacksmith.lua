-- World Map Design (GDD section 15): Blacksmith / Forge.
-- Sells basic weapons and armor, buys repair materials, and explains the
-- Item Durability / repair system (GDD section 5,
-- data/scripts/campaign/actions/repair.lua).

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "Need a blade or some armor? Or ask me about {repair} if your gear is worn out."},
}
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({'sword'}, 2376, 90, 'sword')
shopModule:addBuyableItem({'hand axe', 'axe'}, 2380, 60, 'hand axe')
shopModule:addBuyableItem({'studded armor', 'armor'}, 2418, 130, 'studded armor')
shopModule:addBuyableItem({'chain helmet', 'helmet'}, 2467, 70, 'chain helmet')

shopModule:addSellableItem({'sword'}, 2376, 45, 'sword')
shopModule:addSellableItem({'hand axe', 'axe'}, 2380, 30, 'hand axe')
shopModule:addBuyableItem({'iron ore', 'ore'}, 5910, 15, 'iron ore')
shopModule:addSellableItem({'iron ore', 'ore'}, 5910, 8, 'iron ore')

keywordHandler:addKeyword({'stuff'}, StdModule.say, {npcHandler = npcHandler, text = 'Just ask me for a {trade} to see my wares, or about {repair} for worn equipment.'})
keywordHandler:addAliasKeyword({'wares'})

keywordHandler:addKeyword({'repair'}, StdModule.say, {npcHandler = npcHandler, text =
	'See the anvil in my forge? Use a worn weapon or armor piece on it along with the right materials (iron ore for most blades) and it will be repaired. I sell iron ore if you need it.'})
keywordHandler:addAliasKeyword({'anvil'})
keywordHandler:addAliasKeyword({'durability'})

npcHandler:addModule(FocusModule:new())
