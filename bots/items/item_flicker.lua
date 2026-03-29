--闪灵
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	if bot:DistanceFromFountain() < 600 or bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 600
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and ( bot:IsSilenced() or bot:IsRooted() )
		then
			hEffectTarget = bot
			sCastMotive = '驱散沉默或缠绕'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		and #nInRangeEnmyList >= 1
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
