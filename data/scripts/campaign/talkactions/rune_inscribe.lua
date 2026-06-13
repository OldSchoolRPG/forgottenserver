-- Magic System (GDD section 3): Rune crafting.
-- Usage: "!inscribe <Spell Name>" while carrying a blank rune and a learned
-- rune spell. Consumes mana and a blank rune, produces a charged rune whose
-- charge count scales with Magic Level.

local cfg = CampaignConfig.runeCrafting

local inscribeTalk = TalkAction("!inscribe")

function inscribeTalk.onSay(player, words, param)
	local spellName = param:trim()
	local recipe = cfg.recipes[spellName]
	if not recipe then
		player:sendCancelMessage("Unknown rune spell.")
		return false
	end

	if not player:hasLearnedSpell(spellName) then
		player:sendCancelMessage("You have not learned the spell '" .. spellName .. "'.")
		return false
	end

	if player:getMana() < recipe.manaCost then
		player:sendCancelMessage("You do not have enough mana.")
		return false
	end

	local blankRune = player:getItemCount(cfg.blankRuneId)
	if blankRune < 1 then
		player:sendCancelMessage("You need a blank rune.")
		return false
	end

	player:removeItem(cfg.blankRuneId, 1)
	player:addMana(-recipe.manaCost)

	local charges = recipe.baseCharges + math.floor(player:getMagicLevel() / recipe.chargesPerMagicLevel)
	local rune = player:addItem(recipe.runeId, 1)
	if rune then
		rune:setAttribute(ITEM_ATTRIBUTE_CHARGES, charges)
	end

	player:sendTextMessage(MESSAGE_STATUS_DEFAULT, "You inscribe a " .. spellName .. " rune with " .. charges .. " charge(s).")
	player:getPosition():sendMagicEffect(CONST_ME_MAGIC_RED)
	return false
end

inscribeTalk:separator(" ")
inscribeTalk:register()
