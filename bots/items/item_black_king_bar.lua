--BKB
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	if bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff') then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = 1300
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if #nInRangeEnmyList > 0
		and not bot:IsMagicImmune()
		and not bot:IsInvulnerable()
		and not bot:HasModifier( 'modifier_item_lotus_orb_active' )
		and not bot:HasModifier( 'modifier_antimage_spell_shield' )
		and ( J.IsGoingOnSomeone( bot ) or J.IsRetreating( bot ) )
	then
		local nearEnemyCount = J.GetEnemyCount( bot, 600 )
		if bot:IsRooted()
		then
			sCastMotive = '解缠绕'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if bot:IsSilenced()
			and bot:GetMana() > 100
			and not bot:HasModifier( "modifier_item_mask_of_madness_berserk" )
			and nearEnemyCount >= 2
		then
			sCastMotive = '解沉默'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.IsNotAttackProjectileIncoming( bot, 350 )
		and nearEnemyCount >= 1
		then
			sCastMotive = '防御弹道'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.IsWillBeCastUnitTargetSpell( bot, nCastRange )
		and nearEnemyCount >= 1
		then
			sCastMotive = '防御指向技能'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.IsWillBeCastPointSpell( bot, nCastRange )
		and nearEnemyCount >= 1
		then
			sCastMotive = '防御地点技能'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

		if J.GetEnemyCount( bot, 800 ) >= 3
		then
			sCastMotive = '先开BKB切入'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
		end

	end

	return BOT_ACTION_DESIRE_NONE

end

return X
