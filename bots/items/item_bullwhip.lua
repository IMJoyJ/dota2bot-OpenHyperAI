-- TIER 2

-- Vambrace
-- X.ConsiderItemDesire["item_vambrace"] = function(hItem)
-- 	return X.ConsiderItemDesire["item_power_treads"](hItem)
-- end

-- Bullwhip
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange

	local nCastRange = 850 + aetherRange

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsChasingTarget(bot, botTarget)
		and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit', nil
		end
	end

	local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
	for _, allyHero in pairs(nInRangeAlly)
	do
		if J.IsValidHero(allyHero)
		and J.CanCastOnNonMagicImmune(allyHero)
		then
			local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

			if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
			and J.IsRetreating(allyHero)
			and allyHero:DistanceFromFountain() > 1200
			and not J.IsRealInvisible(allyHero)
			and not J.IsDisabled(allyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit', nil
			end
		end
	end

	if hItem:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_HIGH, bot, 'unit', nil
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
