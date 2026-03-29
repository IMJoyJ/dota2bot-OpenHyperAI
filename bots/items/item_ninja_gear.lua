-- TIER 4

-- Ninja Gear
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require(GetScriptDirectory()..'/FunLib/utils')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local team = ctx.team

	local nCastRange = 1600

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.CanCastOnMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, 2800)
		and not J.IsInRange(bot, botTarget, botTarget:GetCurrentVisionRange() + 200)
		and not J.IsSuspiciousIllusion(botTarget)
		then
			local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(800, true)
			local nEnemyTowers = bot:GetNearbyTowers(700, true)

			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps == 0
			and nEnemyTowers ~= nil and #nEnemyTowers == 0
			then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end
		end
	end

	if J.IsDefending(bot)
	then
		local nMode = bot:GetActiveMode()
		local nLane = LANE_MID

		if nMode == BOT_MODE_PUSH_TOWER_TOP then nLane = LANE_TOP end
		if nMode == BOT_MODE_PUSH_TOWER_BOT then nLane = LANE_BOT end

		local nPushLoc = GetLaneFrontLocation(team, nLane, 0)
		if GetUnitToLocationDistance(bot, nPushLoc) > 3200
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.CheckTimeOfDay() == 'day'
        and GetUnitToLocationDistance(bot, J.Utils.RadiantRoshanLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end

		if J.CheckTimeOfDay() == 'night'
        and GetUnitToLocationDistance(bot, J.Utils.DireRoshanLoc) > 3200
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

return X
