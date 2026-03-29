-- Psychic Headband
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange

	local nCastRange = 600 + aetherRange
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)

	if J.IsRetreating(bot)
	then	
		if J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsRunning(nInRangeEnemy[1])
		and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		then
			return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1], 'unit', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
