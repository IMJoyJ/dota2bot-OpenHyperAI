-- TIER 3

-- Craggy Coat
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

	local nRadius = 1200

	if J.IsInTeamFight(bot)
	then
		local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

        if realEnemyCount ~= nil and #realEnemyCount >= 2
		and bot:WasRecentlyDamagedByAnyHero(1.5)
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
	end

    if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)

        if J.IsValidTarget(botTarget)
        and J.IsAttacking(botTarget)
		and bot:WasRecentlyDamagedByAnyHero(1.3)
        and J.IsInRange(bot, botTarget, 600)
        and not J.IsSuspiciousIllusion(botTarget)
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
            end
        end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

return X
