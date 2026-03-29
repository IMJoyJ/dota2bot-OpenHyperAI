-- TIER 5

-- Force Boots
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local team = ctx.team

	local nCastRange = 700 + aetherRange
	local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH, bot, 'unit', nil
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 900)
		and Common.IsWithoutSpellShield(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsLocationInChrono(botTarget:GetLocation())
		and not J.IsLocationInBlackHole(botTarget:GetLocation())
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = J.GetNearbyHeroes(bot,1200, false, BOT_MODE_NONE)
			local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			then
				if bot:IsFacingLocation(botTarget:GetLocation(), 15)
				and #nInRangeAlly >= #nTargetInRangeAlly + 1
				then
					return BOT_ACTION_DESIRE_HIGH, bot, 'unit', nil
				end

				local allyCenterLocation = J.GetCenterOfUnits(nInRangeAlly)
				if botTarget:IsFacingLocation(allyCenterLocation, 15)
				and GetUnitToLocationDistance(bot, allyCenterLocation ) >= 750
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget, 'unit', nil
				end	
			end		
		end
	end

	if J.IsRetreating(bot)
	then
		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		and bot:IsFacingLocation(J.GetEscapeLoc(), 30)
		and bot:DistanceFromFountain() > 600
		and not J.IsRealInvisible(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'unit', nil
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
			and allyHero:IsFacingLocation(J.GetEscapeLoc(), 30)
			and allyHero:DistanceFromFountain() > 600
			and allyHero:WasRecentlyDamagedByAnyHero(2.2)
			and not J.IsRealInvisible(allyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit', nil
			end

			if J.IsGoingOnSomeone(allyHero)
			then
				local allyTarget = J.GetProperTarget(allyHero)

				if J.IsValidHero(allyTarget)
				and J.CanCastOnNonMagicImmune(allyTarget)
				and allyHero:IsFacingLocation(allyTarget:GetLocation(), 15 )
				and GetUnitToUnitDistance(allyHero, allyTarget) > allyHero:GetAttackRange() + 50
				and GetUnitToUnitDistance(allyHero, allyTarget) < allyHero:GetAttackRange() + 700
				and J.IsRunning(allyTarget)
				and J.GetEnemyCount(allyHero, 1600) <= 3
				and not allyTarget:IsFacingLocation(allyHero:GetLocation(), 40)
				and not J.IsSuspiciousIllusion(allyTarget)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit', nil
				end
			end

			if J.IsStuck(allyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero, 'unit', nil
			end
		end

	end

	if bot:DistanceFromFountain() < 2800
	then
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidHero(enemyHero)
			and J.CanCastOnMagicImmune(enemyHero)
			and enemyHero:IsFacingLocation(GetAncient(team):GetLocation(), 30)
			and GetUnitToLocationDistance(enemyHero, GetAncient(team):GetLocation()) < 1600
			and not J.IsSuspiciousIllusion(enemyHero)
			then
				local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1000, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and #nInRangeAlly >= #nTargetInRangeAlly
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit', nil
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
