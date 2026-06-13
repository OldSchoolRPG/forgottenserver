-- Magic System (GDD section 3): "Summon Familiar" is taught permanently by
-- reading grimoire item 8918 (data/scripts/campaign/actions/grimoire.lua).
-- Summons one "Familiar" creature (data/monster/monsters/familiar.xml) that
-- fights alongside the caster. Casting again while a familiar is alive does
-- nothing until the existing one is dismissed/killed.

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	if not creature:isPlayer() then
		return false
	end

	for _, summon in ipairs(creature:getSummons()) do
		if summon:getName() == "Familiar" then
			creature:sendCancelMessage("You already have a familiar.")
			return false
		end
	end

	local position = creature:getPosition()
	local monster = Game.createMonster("Familiar", position, true, true)
	if not monster then
		return false
	end

	monster:setMaster(creature)
	position:sendMagicEffect(CONST_ME_TELEPORT)
	return true
end

spell:group("support")
spell:id(90003)
spell:name("Summon Familiar")
spell:words("utori familiaris")
spell:level(15)
spell:mana(200)
spell:isAggressive(false)
spell:isSelfTarget(true)
spell:cooldown(10000)
spell:groupCooldown(2000)
spell:vocation("sorcerer;true", "druid;true", "paladin;true", "knight;true", "master sorcerer;true", "elder druid;true", "royal paladin;true", "elite knight;true")
spell:register()
