-- Pig Pole
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nCastRange = 1600
	local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

	if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
	and J.GetMP(bot) > 0.5
	and (J.IsRetreating(bot) or J.IsGoingOnSomeone(bot))
	then
		return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
