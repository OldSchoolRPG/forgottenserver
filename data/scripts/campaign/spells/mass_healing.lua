-- Magic System (GDD section 3): "Mass Healing" is taught permanently by
-- reading grimoire item 8917 (data/scripts/campaign/actions/grimoire.lua)
-- and can be inscribed onto a blank rune with "!inscribe Mass Healing"
-- (data/scripts/campaign/talkactions/rune_inscribe.lua), producing an
-- Ultimate Healing Rune (item 2273, already registered by the engine).
--
-- Unlike the single-target Ultimate Healing Rune, casting the spell directly
-- heals the caster and every ally standing in a 3x3 area around them.

local combat = Combat()
combat:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
combat:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
combat:setParameter(COMBAT_PARAM_AGGRESSIVE, false)

local area = createCombatArea({
	{1, 1, 1},
	{1, 3, 1},
	{1, 1, 1},
})
combat:setArea(area)

function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 4.0) + 30
	local max = (level / 5) + (magicLevel * 6.5) + 60
	return min, max
end

combat:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")

local spell = Spell(SPELL_INSTANT)

function spell.onCastSpell(creature, variant)
	return combat:execute(creature, variant)
end

spell:group("healing")
spell:id(90002)
spell:name("Mass Healing")
spell:words("exura vita mas")
spell:level(10)
spell:mana(140)
spell:isAggressive(false)
spell:isSelfTarget(true)
spell:cooldown(8000)
spell:groupCooldown(2000)
spell:vocation("sorcerer;true", "druid;true", "paladin;true", "knight;true", "master sorcerer;true", "elder druid;true", "royal paladin;true", "elite knight;true")
spell:register()
