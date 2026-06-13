-- World Map Design (GDD section 15): Alchemist Shop.
-- Sells potions and blank runes, and explains the rune crafting system
-- (GDD section 3, data/scripts/campaign/talkactions/rune_inscribe.lua).

local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

function onCreatureAppear(cid)				npcHandler:onCreatureAppear(cid)			end
function onCreatureDisappear(cid)			npcHandler:onCreatureDisappear(cid)			end
function onCreatureSay(cid, type, msg)		npcHandler:onCreatureSay(cid, type, msg)	end
function onThink()							npcHandler:onThink()						end

local voices = {
	{text = "Potions, blank runes, and a bit of arcane advice. Ask me about {runes} if you've learned a spell from a grimoire."},
}
npcHandler:addModule(VoiceModule:new(voices))

local shopModule = ShopModule:new()
npcHandler:addModule(shopModule)

shopModule:addBuyableItem({'blank rune', 'rune'}, 2260, 25, 'blank rune')
shopModule:addBuyableItem({'health potion'}, 7618, 45, 1, 'health potion')
shopModule:addBuyableItem({'mana potion'}, 7620, 50, 1, 'mana potion')
shopModule:addBuyableItem({'small health'}, 8704, 20, 1, 'small health potion')
shopModule:addBuyableItem({'antidote potion'}, 8474, 50, 1, 'antidote potion')

shopModule:addSellableItem({'empty potion flask', 'empty flask'}, 7636, 5, 'empty potion flask')

keywordHandler:addKeyword({'stuff'}, StdModule.say, {npcHandler = npcHandler, text = 'Just ask me for a {trade} to see my potions and runes.'})
keywordHandler:addAliasKeyword({'wares'})

keywordHandler:addKeyword({'rune'}, StdModule.say, {npcHandler = npcHandler, text =
	'If you have learned a spell from a grimoire, buy a blank rune from me and say "!inscribe <Spell Name>" - for example "!inscribe Fireball" - to channel it into a charged rune. It costs mana and scales with your magic level.'})
keywordHandler:addAliasKeyword({'runes'})
keywordHandler:addAliasKeyword({'inscribe'})

npcHandler:addModule(FocusModule:new())
