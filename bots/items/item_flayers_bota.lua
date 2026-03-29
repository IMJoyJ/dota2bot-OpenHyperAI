local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	if J.IsGoingOnSomeone(bot) then
		if  J.IsValidHero(botTarget)
		and J.CanBeAttacked(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, nil, ITEM_TARGET_TYPE_NONE
		end
	end

	if J.IsDoingRoshan(bot) then
		if J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
		and J.IsInRange(bot, botTarget, botAttackRange + 150)
		and #nEnemyHeroes == 0
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, nil, ITEM_TARGET_TYPE_NONE
		end
	end

	if J.IsDoingTormentor(bot) then
		if J.IsTormentor(botTarget)
		and J.IsInRange(bot, botTarget, botAttackRange + 150)
		and #nEnemyHeroes == 0
		and bAttacking
		then
			return BOT_ACTION_DESIRE_HIGH, nil, ITEM_TARGET_TYPE_NONE
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
