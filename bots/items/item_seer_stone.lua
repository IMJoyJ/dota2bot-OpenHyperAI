-- Seer Stone
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require(GetScriptDirectory()..'/FunLib/utils')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nRadius = 800

	-- In Fights
	if J.IsGoingOnSomeone(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), 1600, nRadius, 0, 0)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

		local targetHero = nil
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
			and J.IsInRange(bot, enemyHero, nRadius)
			and J.CanCastOnMagicImmune(enemyHero)
			and J.HasInvisibilityOrItem(enemyHero)
			and not enemyHero:HasModifier('modifier_slardar_amplify_damage')
			and not enemyHero:HasModifier('modifier_item_dustofappearance')
			and not J.Site.IsLocationHaveTrueSight(enemyHero:GetLocation())
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, 'ground', nil
			end
		end

	end

	-- For Roshan Scout
	local nInSightEnemy = 0
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			nInSightEnemy = nInSightEnemy + 1
		end
	end

	if J.IsRoshanAlive()
	and nInSightEnemy == 0
	then
		if J.CheckTimeOfDay() == 'day'
		and GetUnitToLocationDistance(bot, J.Utils.RadiantRoshanLoc) > 1600
		then
			return BOT_ACTION_DESIRE_HIGH, J.Utils.RadiantRoshanLoc, 'ground', nil
		end

		if J.CheckTimeOfDay() == 'night'
		and GetUnitToLocationDistance(bot, J.Utils.DireRoshanLoc) > 1600
		then
			return BOT_ACTION_DESIRE_HIGH, J.Utils.DireRoshanLoc, 'ground', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
