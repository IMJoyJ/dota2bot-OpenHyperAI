-- Book of Shadows
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange

	local nCastRange = 700 + aetherRange
	local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

	for _, allyHero in pairs(nInRangeAlly)
	do
		if J.IsValidHero(allyHero)
		and J.CanCastOnNonMagicImmune(allyHero)
		and allyHero:WasRecentlyDamagedByAnyHero(3)
		then
			local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

			if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
			and J.IsRetreating(allyHero)
			and not J.IsRealInvisible(allyHero)
			and not J.IsDisabled(allyHero)
			and allyHero:DistanceFromFountain() > 1200
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit', nil
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
