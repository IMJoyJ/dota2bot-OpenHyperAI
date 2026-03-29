-- jmz_func sub-module: jmz_targeting
return function(J)


function J.GetVulnerableWeakestUnit( bot, bHero, bEnemy, nRadius )
	local unitList = {}
	if bHero
	then
		unitList = J.GetNearbyHeroes(bot, nRadius, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	end
    return J.GetAttackableWeakestUnitFromList( bot, unitList )
end



function J.GetVulnerableUnitNearLoc( bot, bHero, bEnemy, nCastRange, nRadius, vLoc )

	local unitList = {}
	local weakest = nil
	local weakestHP = 10000

	if bHero
	then
		unitList = J.GetNearbyHeroes(bot, nCastRange, bEnemy, BOT_MODE_NONE )
	else
		unitList = bot:GetNearbyLaneCreeps( nCastRange, bEnemy )
	end

	for _, u in pairs( unitList )
	do
		if GetUnitToLocationDistance( u, vLoc ) < nRadius
			and u:GetHealth() < weakestHP
			and J.CanCastOnNonMagicImmune( u )
		then
			weakest = u
			weakestHP = u:GetHealth()
		end
	end

	return weakest

end



function J.GetAoeEnemyHeroLocation( bot, nCastRange, nRadius, nCount )
	-- local cacheKey = 'GetAoeEnemyHeroLocation'..tostring(bot:GetPlayerID())..'-'..tostring(nCastRange) --..'-'..tostring(nRadius)..'-'..tostring(nCount)
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.2)
	-- if cache ~= nil then return cache end

	local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )

	if nAoe.count >= nCount
	then
		local nEnemyHeroList = J.GetEnemyList( bot, 1600 )
		local nTrueCount = 0
		for _, enemy in pairs( nEnemyHeroList )
		do
			if GetUnitToLocationDistance( enemy, nAoe.targetloc ) <= nRadius
				and not enemy:IsMagicImmune()
			then
				nTrueCount = nTrueCount + 1
			end
		end

		if nTrueCount >= nCount
		then
			-- J.Utils.SetCachedVars(cacheKey, nAoe.targetloc)
			return nAoe.targetloc
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, nil)
	return nil

end



function J.IsWithoutTarget( bot )

	return bot:CanBeSeen()
			and bot:GetAttackTarget() == nil
			and ( bot:GetTeam() == GetBot():GetTeam() and bot:GetTarget() == nil ) 
end



function J.GetProperTarget( bot )

	local target = nil
	
	if ( bot:GetTeam() == GetBot():GetTeam() )
	then
		target = bot:GetTarget()
	end

	if target == nil and bot:CanBeSeen()
	then
		target = bot:GetAttackTarget()
	end

	if target ~= nil
		and target:GetTeam() == bot:GetTeam()
		and ( target:IsHero() or target:IsBuilding() )
	then
		target = nil
	end

	return target

end



function J.GetMostHpUnit( unitList )

	local mostHpUnit = nil
	local maxHP = 0
	for _, unit in pairs( unitList )
	do
		local uHp = unit:GetHealth()
		if unit ~= nil
		and not J.IsRoshan(unit)
		and not J.IsTormentor(unit)
		and uHp > maxHP
		then
			mostHpUnit = unit
			maxHP = uHp
		end
	end

	return mostHpUnit

end



function J.GetLeastHpUnit( unitList )

	local leastHpUnit = nil
	local minHP = 999999

	for _, unit in pairs( unitList )
	do
		local uHp = unit:GetHealth()
		if uHp < minHP
		then
			leastHpUnit = unit
			minHP = uHp
		end
	end

	return leastHpUnit

end


function J.GetClosestAlly(bot, nRadius)
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and member ~= bot
		and GetUnitToUnitDistance(bot, member) <= nRadius
		and not J.IsSuspiciousIllusion(member)
		then
			return member
		end
	end

	return nil
end


function J.GetAttackableWeakestUnit( bot, nRadius, bHero, bEnemy )
    local unitList = {}
	if nRadius > 1600 then nRadius = 1600 end
    if bHero then
        unitList = J.GetNearbyHeroes(bot, nRadius, bEnemy, BOT_MODE_NONE )
    else
        unitList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
    end
    return J.GetAttackableWeakestUnitFromList( bot, unitList )
end


-- The arg `bot` here can be nil
function J.GetAttackableWeakestUnitFromList( bot, unitList )
	if bot == nil then bot = GetBot() end

    local weakest = nil
    local bestScore = math.huge
	local attackRange = bot:GetAttackRange()

    for _, unit in pairs( unitList ) do
		if J.IsValidTarget(unit) then
			local hp = unit:GetHealth()
			local offensivePower = 0
			local distance = GetUnitToUnitDistance(bot, unit)
			if J.IsValidHero(unit) then
				offensivePower = unit:GetRawOffensivePower()
			end
			if J.IsValid( unit )
				and not unit:IsAttackImmune()
				and not unit:IsInvulnerable()
				and not J.HasForbiddenModifier( unit )
				and not J.IsSuspiciousIllusion( unit )
				--and not J.IsAllyCanKill( unit )
				and not J.CannotBeKilled(bot, unit)
			then
				-- Calculate score: lower score is better
				-- Can adjust the weight factors for hp and offensive power to tune the behavior
				local hpWeight = 0.7
				local powerWeight = 0.3
				local score = (hp * hpWeight) - (offensivePower * powerWeight) -- - math.min(1, attackRange / distance) * 100
	
				-- If the new score is lower, choose this unit as the weakest
				if score < bestScore then
					bestScore = score
					weakest = unit
				end
			end
		end
    end

    return weakest
end


function J.ConsiderTarget()

	local bot = GetBot()

	if not J.IsRunning( bot )
		or bot:HasModifier( "modifier_item_hurricane_pike_range" )
	then return end

	local npcTarget = J.GetProperTarget( bot )
	if not J.IsValidHero( npcTarget ) then return end

	local nAttackRange = bot:GetAttackRange() + 69
	if nAttackRange > 1600 then nAttackRange = 1600 end
	if nAttackRange < 300 then nAttackRange = 350 end

	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange, true, true )

	if J.IsValidHero( nInAttackRangeWeakestEnemyHero )
		and ( GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange or J.HasForbiddenModifier( npcTarget ) )
	then
		bot:SetTarget( nInAttackRangeWeakestEnemyHero )
		return
	end

end


function J.GetLowestHPUnit(tUnits, bIgnoreImmune)
	local lowestHP   = 100000;
	local lowestUnit = nil; 
	for _,unit in pairs(tUnits)
	do
		local hp = unit:GetHealth()
		if hp < lowestHP and ( bIgnoreImmune or not unit:IsMagicImmune() ) then
			lowestHP   = hp;
			lowestUnit = unit;
		end
	end
	return lowestUnit;
end


function J.GetCanBeKilledUnit(units, nDamage, nDmgType, magicImmune)
	local target = nil
	for _,unit in pairs(units)
	do
		if ((magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit)))
			   and J.CanKillTarget(unit, nDamage, nDmgType)
		then
			target = unit
		end
	end
	return target
end


function J.GetClosestUnit(units)
	local target = nil;
	if units ~= nil and #units >= 1 then
		return units[1];
	end
	return target;
end


function J.GetStrongestUnit(nRange, hUnit, bEnemy, bMagicImune, fTime)
	local units = J.GetNearbyHeroes(hUnit,nRange, bEnemy, BOT_MODE_NONE)
	local strongest = nil
	local maxPower = 0

	for i = 1, #units do
		if J.IsValidTarget(units[i])
		and J.IsValidTarget(hUnit)
		and ((bMagicImune == true and J.CanCastOnMagicImmune(units[i]) == true) or (bMagicImune == false and J.CanCastOnNonMagicImmune(units[i]) == true))
		then
			local power = units[i]:GetEstimatedDamageToTarget(true, hUnit, fTime, DAMAGE_TYPE_ALL)

			if power > maxPower
			then
				maxPower = power
				strongest = units[i]
			end
		end
	end
	return strongest
end


function J.GetStrongestEnemyHero(enemies)
	local strongestenemy = nil
	local highesthealth = 0

	for v, enemy in pairs(enemies) do
		if J.IsValidTarget(enemy) and J.IsNotImmune(enemy) and not J.IsSuspiciousIllusion(enemy) then
			if enemy:GetHealth() > highesthealth then
				strongestenemy = enemy
				highesthealth = enemy:GetHealth()
			end
		end
	end
	return strongestenemy
end


function J.GetClosestCore(bot, nRadius)
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if  member ~= nil
		and member:IsAlive()
		and member ~= bot
		and J.IsCore(bot)
		and GetUnitToUnitDistance(bot, member) <= nRadius
		and not J.IsSuspiciousIllusion(member)
		then
			return member
		end
	end

	return nil
end


function J.GetWeakestUnit(nEnemyUnits)
	return J.GetAttackableWeakestUnitFromList( nil, nEnemyUnits )
end


function J.GetHighestRightClickDamageHero(nUnits)
	local target = nil
	local dmg = 0
	for _, hero in pairs(nUnits)
	do
		if J.IsValidHero(hero)
		and not J.IsMeepoClone(hero)
		and not J.IsSuspiciousIllusion(hero)
		then
			if dmg < hero:GetAttackDamage()
			then
				dmg = hero:GetAttackDamage()
				target = hero
			end
		end
	end

	return target
end


function J.GetClosestAllyHero(bot)
	local closestHeroDistance = 999999
	local closestHero = nil
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsNotSelf(bot, allyHero)
		then
			local diffDistance = J.GetLocationToLocationDistance(allyHero:GetLocation(), bot:GetLocation())
			if diffDistance < closestHeroDistance then
				closestHero = allyHero
				closestHeroDistance = diffDistance
			end
		end
	end
	return closestHero, closestHeroDistance
end

end
