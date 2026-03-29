-- Seeds of Serenity
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

	local nRadius = 400
	local nInRangeEnemy = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
	local nInRangeTower = bot:GetNearbyTowers(700, true)

	if J.IsFarming(bot)
	then	
		if J.IsAttacking(bot)
		then
			local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
			if nNeutralCreeps ~= nil
			and ((#nNeutralCreeps >= 3)
				or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end

			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end

	if J.IsPushing(bot)
	then
		if nInRangeTower ~= nil and #nInRangeTower >= 1
		and J.IsValidBuilding(botTarget)
		and J.IsValidBuilding(nInRangeTower[1])
		and J.IsAttacking(bot)
		and botTarget == nInRangeTower[1]
		then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation(), 'ground', nil
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation(), 'ground', nil
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot:GetLocation(), 'ground', nil
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

return X
