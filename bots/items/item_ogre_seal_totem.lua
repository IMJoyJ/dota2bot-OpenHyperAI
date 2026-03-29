-- Ogre Seal Totem
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

	local nFlopRadius = 275
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nFlopRadius * 2)

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and bot:IsFacingLocation(botTarget:GetLocation(), 5)
		and J.IsInRange(bot, botTarget, nFlopRadius * 2)
		and not J.IsInRange(bot, botTarget, nFlopRadius - 75)
		and not J.IsSuspiciousIllusion(botTarget)
		and not bot:HasModifier('modifier_abaddon_borrowed_time')
		and not bot:HasModifier('modifier_necrolyte_reapers_scythe')
		and not J.IsLocationInChrono(botTarget:GetLocation())
		and not J.IsLocationInBlackHole(botTarget:GetLocation())
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			then
				return BOT_ACTION_DESIRE_HIGH, bot, 'unit', nil
			end
		end
	end

	if J.IsRetreating(bot)
	then	
		if J.IsValidHero(nInRangeEnemy[1])
		and J.IsRunning(nInRangeEnemy[1])
		and bot:IsFacingLocation(J.GetEscapeLoc(), 15)
		and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
