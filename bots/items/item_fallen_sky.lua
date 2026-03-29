--堕天斧
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local team = ctx.team


	local nCastRange = 1600
	local sCastType = 'ground'
	local nRadius = 315
	local nCastDelay = 0.5
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		local nAoeLocation = J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, 2 )
		if nAoeLocation ~= nil
		then
			hEffectTarget = nAoeLocation
			sCastMotive = 'Aoe'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			local nCastLocation = J.GetDelayCastLocation( bot, botTarget, nCastRange, nRadius, nCastDelay )
			if nCastLocation ~= nil
			then
				hEffectTarget = nCastLocation
				sCastMotive = "进攻"
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		local bLocation = J.GetLocationTowardDistanceLocation( bot, GetAncient( team ):GetLocation(), 1600 )
		local nAttackAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_ATTACK )
		if bot:DistanceFromFountain() > 800
			and IsLocationPassable( bLocation )
			and ( #nAttackAllyList == 0 or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH * 0.9 )
			and #nInRangeEnmyList >= 1
		then
			hEffectTarget = bLocation
			sCastMotive = "撤退"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
