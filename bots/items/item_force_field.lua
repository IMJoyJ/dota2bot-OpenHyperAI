-- Arcanist's Armor
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nRadius = 1200
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)


	for _, enemyHero in pairs(nInRangeEnemy)
	do
		if J.IsValidHero(enemyHero)
		and enemyHero:GetAttackTarget() == bot
		and (bot:WasRecentlyDamagedByHero(enemyHero, 5)
			or J.IsAttackProjectileIncoming(bot, 500))
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
