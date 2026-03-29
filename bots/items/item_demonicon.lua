-- Book of the Dead
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

	local nCastRange = 750
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if J.IsPushing(bot)
	then
		local nEnemyTowers = bot:GetNearbyTowers(900, true)
		local nLaneCreeps = bot:GetNearbyLaneCreeps(900, false)

		if nEnemyTowers ~= nil and #nEnemyTowers >= 1
		and nLaneCreeps ~= nil and #nLaneCreeps >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	if J.IsValidTarget(botTarget)
	and J.IsInRange(bot, botTarget, 1000)
	and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
	then
		local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

		if nTargetInRangeAlly ~= nil
		then
			if #nTargetInRangeAlly == 0
			-- and J.IsCore(botTarget)
			then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end

			if #nTargetInRangeAlly >= 1
			then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
