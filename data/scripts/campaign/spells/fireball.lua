-- Magic System (GDD section 3): "Fireball" is taught permanently by reading
-- grimoire item 8916 (data/scripts/campaign/actions/grimoire.lua) and can be
-- inscribed onto a blank rune with "!inscribe Fireball"
-- (data/scripts/campaign/talkactions/rune_inscribe.lua), producing a
-- Fireball Rune (item 2302, already registered by the engine).
--
-- Custom words ("exevo pyra hur") are used so this does not collide with the
-- engine's built-in "Fire Wave" spell (exevo flam hur).

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_FIREDAMAGE)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_FIREATTACK)
combat:setParameter(COMBAT_PARAM_DISTANCEEFFECT, CONST_ANI_FIRE)

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 2.2) + 14
	local max = (level / 5) + (magicLevel * 3.6) + 22
	return -min, -max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:group("attack")
spell:id(90001)
spell:name("Fireball")
spell:words("exevo pyra hur")
spell:level(5)
spell:mana(20)
spell:range(4)
spell:needCasterTargetOrDirection(true)
spell:blockWalls(true)
spell:cooldown(2000)
spell:groupCooldown(2000)
spell:vocation("sorcerer;true", "druid;true", "paladin;true", "knight;true", "master sorcerer;true", "elder druid;true", "royal paladin;true", "elite knight;true")
spell:register()
