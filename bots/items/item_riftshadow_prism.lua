local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local fHealthCostPct = hItem:GetSpecialValueInt('health_cost')

	if J.IsGoingOnSomeone(bot) then
		if bot:WasRecentlyDamagedByAnyHero(2.0) and J.GetHealthAfter(bot:GetHealth() * fHealthCostPct) > 0.2 then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
