local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1000)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 1000)
		and J.GetHP(bot) > 0.8
		and J.GetMP(bot) < 0.5
		and currState == 'mana'
		and not J.IsSuspiciousIllusion(botTarget)
		then
			currState = 'health'
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	if J.IsRetreating(bot)
	then	
		if J.IsValidHero(nInRangeEnemy[1])
		and J.IsRunning(nInRangeEnemy[1])
		and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		and bot:WasRecentlyDamagedByAnyHero(1.5)
		and J.GetHP(bot) < 0.5
		and J.GetMP(bot) > 0.75
		and currState == 'health'
		then
			currState = 'mana'
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
