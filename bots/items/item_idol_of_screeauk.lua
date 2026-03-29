local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	if J.IsGoingOnSomeone(bot) then
		if bot:WasRecentlyDamagedByAnyHero(2.0) and J.IsRunning(bot) then
			return BOT_ACTION_DESIRE_HIGH, nil, ITEM_TARGET_TYPE_NONE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
