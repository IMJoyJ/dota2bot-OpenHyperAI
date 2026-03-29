-- Minotaur Horn
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	if bot:IsMagicImmune()
	or not J.CanBeAttacked(bot)
	or not bot:HasModifier('modifier_item_lotus_orb_active')
    or not bot:HasModifier('modifier_antimage_spell_shield')
	then
        return BOT_ACTION_DESIRE_NONE
    end

    local nEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

	if (J.IsGoingOnSomeone(bot) or (J.IsRetreating(bot) and not J.IsRealInvisible(bot)))
    and #nEnemyHeroes > 0
	then
		if bot:IsRooted() then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end

        nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 600)
		if bot:IsSilenced()
        and #nInRangeEnemy >= 2
        and not bot:HasModifier('modifier_item_mask_of_madness_berserk')
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end

		if J.IsNotAttackProjectileIncoming(bot, 300)
		or J.IsWillBeCastUnitTargetSpell(bot, 300)
		or J.IsWillBeCastPointSpell(bot, 300)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end

        nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		if #nInRangeEnemy > #nAllyHeroes
        and J.GetHP(bot) < 0.6
        and J.IsValidHero(nInRangeEnemy[1])
        and (J.IsChasingTarget(nInRangeEnemy[1], bot) or nInRangeEnemy[1]:GetAttackTarget() == bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

    if bot:HasModifier('modifier_jakiro_macropyre_burn')
    or bot:HasModifier('modifier_lich_chainfrost_slow')
    or bot:HasModifier('modifier_crystal_maiden_freezing_field_slow')
    or bot:HasModifier('modifier_puck_coiled')
    or bot:HasModifier('modifier_skywrath_mystic_flare_aura_effect')
    or bot:HasModifier('modifier_snapfire_magma_burn_slow')
    or bot:HasModifier('modifier_sand_king_epicenter_slow')
    then
        return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
    end

	return BOT_ACTION_DESIRE_NONE
end

return X
