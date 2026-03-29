-- Martyrdom
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nRadius = 900

	if J.IsInTeamFight(bot)
	then
		local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nRadius)
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
		then
			if J.IsValidHero(nInRangeEnemy[1])
			and J.IsValidHero(nInRangeEnemy[2])
			and J.IsAttacking(nInRangeEnemy[1])
			and J.IsAttacking(nInRangeEnemy[2])
			and J.GetHP(bot) > 0.88
			and bot:GetHealth() >= 3800
			and not bot:WasRecentlyDamagedByAnyHero(0.8)
			then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
