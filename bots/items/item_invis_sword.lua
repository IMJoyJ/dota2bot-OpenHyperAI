--隐刀
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList
	local hNearbyEnemyTowerList = ctx.hNearbyEnemyTowerList


	if bot:IsInvisible()
		or #hNearbyEnemyTowerList > 0
		or bot:HasModifier( "modifier_item_dustofappearance" )
		or bot:HasModifier( "modifier_slardar_amplify_damage" )
	then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.IsRetreating( bot )
		and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		and #hNearbyEnemyHeroList > 0
	then
		hEffectTarget = bot
		sCastMotive = '撤退了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.GetHP( bot ) < 0.166
		and ( #hNearbyEnemyHeroList > 0 or bot:WasRecentlyDamagedByAnyHero( 5.0 ) )
	then
		hEffectTarget = bot
		sCastMotive = '残血了'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.IsGoingOnSomeone( bot )
	then
		if 	J.IsValidHero( botTarget )
			and J.CanCastOnMagicImmune( botTarget )
			and not J.IsInRange( bot, botTarget, botTarget:GetCurrentVisionRange() )
			and J.IsInRange( bot, botTarget, 2600 )
		then
			local hEnemyCreepList = bot:GetNearbyLaneCreeps( 800, true )
			if #hEnemyCreepList == 0 and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = botTarget
				sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
