-- Light Collector
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nRadius = 325
	local nInRangeTrees = bot:GetNearbyTrees(nRadius)

	if J.IsGoingOnSomeone(bot)
	then
		if nInRangeTrees ~= nil and #nInRangeTrees >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
