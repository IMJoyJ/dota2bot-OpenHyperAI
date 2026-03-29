--撒旦
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	local nCastRange = bot:GetAttackRange() + 250
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if bot:OriginalGetHealth() / bot:OriginalGetMaxHealth() < 0.62
		and #nInRangeEnmyList > 0
		and ( J.IsValidHero( botTarget ) and J.IsInRange( bot, botTarget, nCastRange )
			 or ( J.IsValidHero( nInRangeEnmyList[1] ) and J.IsInRange( bot, nInRangeEnmyList[1], nCastRange) ) )
	then
		hEffectTarget = botTarget
		sCastMotive = '进攻'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
