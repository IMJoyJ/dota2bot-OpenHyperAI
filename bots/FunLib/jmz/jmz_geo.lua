-- jmz_func sub-module: jmz_geo
return function(J)

local RadiantFountain = Vector( -6619, -6336, 384 )
local DireFountain = Vector( 6928, 6372, 392 )
local RadiantTormentorLoc = Vector(7499, -7847, 256)
local DireTormentorLoc = Vector(-7229, 7933, 256)



function J.GetTeamFountain()

	local Team = GetTeam()
	if Team == TEAM_DIRE
	then
		return DireFountain
	else
		return RadiantFountain
	end

end



function J.GetEnemyFountain()

	local Team = GetTeam()

	if Team == TEAM_DIRE
	then
		return RadiantFountain
	else
		return DireFountain
	end

end



function J.GetCorrectLoc( npcTarget, fDelay )

	local nStability = npcTarget:GetMovementDirectionStability()

	local vFirst = npcTarget:GetLocation()
	local vFuture = npcTarget:GetExtrapolatedLocation( fDelay )
	local vMidFutrue = ( vFirst + vFuture ) * 0.5
	local vLowFutrue = ( vFirst + vMidFutrue ) * 0.5
	local vHighFutrue = ( vFuture + vMidFutrue ) * 0.5


	if nStability < 0.5
	then
		return vLowFutrue
	elseif nStability < 0.7
	then
		return vMidFutrue
	elseif nStability < 0.9
	then
		return vHighFutrue
	end

	return vFuture
end


function J.GetDistanceFromLaneFront(bot)
	return J.GetDistance(GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0), bot:GetLocation())
end


function J.GetEscapeLoc()

	local bot = GetBot()
	local team = GetTeam()

	if bot:DistanceFromFountain() > 2500
	then
		return GetAncient( team ):GetLocation()
	else
		if team == TEAM_DIRE
		then
			return DireFountain
		else
			return RadiantFountain
		end
	end

end


--------------------------------------------------ew functions 2018.12.7

function J.GetDistanceFromEnemyFountain( bot )

	local EnemyFountain = J.GetEnemyFountain()
	local Distance = GetUnitToLocationDistance( bot, EnemyFountain )

	return Distance

end



function J.GetDistanceFromAllyFountain( bot )

	local OurFountain = J.GetTeamFountain()
	local Distance = GetUnitToLocationDistance( bot, OurFountain )

	return Distance

end



function J.GetDistanceFromAncient( bot, bEnemy )

	local targetAncient = GetAncient( GetTeam() )

	if bEnemy then targetAncient = GetAncient( GetOpposingTeam() ) end

	return GetUnitToUnitDistance( bot, targetAncient )

end


function J.GetLocationToLocationDistance( fLoc, sLoc )

	local x1 = fLoc.x
	local x2 = sLoc.x
	local y1 = fLoc.y
	local y2 = sLoc.y

	return math.sqrt( math.pow( ( y2-y1 ), 2 ) + math.pow( ( x2-x1 ), 2 ) )

end



function J.GetUnitTowardDistanceLocation( bot, towardTarget, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardTarget:GetLocation() - npcBotLocation ) / GetUnitToUnitDistance( bot, towardTarget )

	return npcBotLocation + nDistance * tempVector

end



function J.GetLocationTowardDistanceLocation( bot, towardLocation, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempVector = ( towardLocation - npcBotLocation ) / GetUnitToLocationDistance( bot, towardLocation )

	return npcBotLocation + nDistance * tempVector

end



function J.GetFaceTowardDistanceLocation( bot, nDistance )

	local npcBotLocation = bot:GetLocation()
	local tempRadians = bot:GetFacing() * math.pi / 180
	local tempVector = Vector( math.cos( tempRadians ), math.sin( tempRadians ) )

	return npcBotLocation + nDistance * tempVector

end



function J.GetCastLocation( bot, npcTarget, nCastRange, nRadius )

	local nDistance = GetUnitToUnitDistance( bot, npcTarget )

	if nDistance <= nCastRange
	then
		return npcTarget:GetLocation()
	end

	if nDistance <= nCastRange + nRadius - 120
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange )
	end

	if nDistance < nCastRange + nRadius - 18
		and ( ( J.IsDisabled( npcTarget ) or npcTarget:GetCurrentMovementSpeed() <= 160 )
				or npcTarget:IsFacingLocation( bot:GetLocation(), 45 )
				or ( bot:IsFacingLocation( npcTarget:GetLocation(), 45 ) and npcTarget:GetCurrentMovementSpeed() <= 220 ) )
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange +18 )
	end

	if nDistance < nCastRange + nRadius + 28
		and npcTarget:IsFacingLocation( bot:GetLocation(), 30 )
		and bot:IsFacingLocation( npcTarget:GetLocation(), 30 )
		and npcTarget:GetMovementDirectionStability() > 0.95
		and npcTarget:GetCurrentMovementSpeed() >= 300
	then
		return J.GetUnitTowardDistanceLocation( bot, npcTarget, nCastRange + 18 )
	end

	return nil

end



function J.GetDelayCastLocation( bot, npcTarget, nCastRange, nRadius, nTime )

	local nFutureLoc = J.GetCorrectLoc( npcTarget, nTime )
	local nDistance = GetUnitToLocationDistance( bot, nFutureLoc )

	if nDistance > nCastRange + nRadius - 16
	then
		return nil
	end

	if nDistance > nCastRange - nRadius * 0.38
	then
		return J.GetLocationTowardDistanceLocation( bot, nFutureLoc, nCastRange +8 )
	end

	return nFutureLoc

end


function J.GetNearestLaneFrontLocation( nUnitLoc, bEnemy, fDeltaFromFront )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	local nTopLoc = GetLaneFrontLocation( nTeam, LANE_TOP, fDeltaFromFront )
	local nMidLoc = GetLaneFrontLocation( nTeam, LANE_MID, fDeltaFromFront )
	local nBotLoc = GetLaneFrontLocation( nTeam, LANE_BOT, fDeltaFromFront )

	local nTopDist = J.GetLocationToLocationDistance( nUnitLoc, nTopLoc )
	local nMidDist = J.GetLocationToLocationDistance( nUnitLoc, nMidLoc )
	local nBotDist = J.GetLocationToLocationDistance( nUnitLoc, nBotLoc )

	if nTopDist < nMidDist and nTopDist < nBotDist
	then
		return nTopLoc
	end

	if nBotDist < nMidDist and nBotDist < nTopDist
	then
		return nBotLoc
	end

	return nMidLoc

end


function J.IsLocHaveTower( nRadius, bEnemy, nLoc )

	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	if ( not bEnemy and J.GetLocationToLocationDistance( nLoc, J.GetTeamFountain() ) < 2500 )
		or ( bEnemy and J.GetLocationToLocationDistance( nLoc, J.GetEnemyFountain() ) < 2500 )
	then
		return true
	end

	for i = 0, 10
	do
		local tower = GetTower( nTeam, i )
		if tower ~= nil and GetUnitToLocationDistance( tower, nLoc ) <= nRadius
		then
			 return true
		end
	end

	return false

end



function J.GetNearbyLocationToTp( nLoc )

	local nTeam = GetTeam()
	local nFountain = J.GetTeamFountain()

	if J.GetLocationToLocationDistance( nLoc, nFountain ) <= 2500
	then
		return nLoc
	end

	local targetTower = nil
	local minDist = 99999
	for i=0, 10, 1 do
		local tower = GetTower( nTeam, i )
		if tower ~= nil
			and GetUnitToLocationDistance( tower, nLoc ) < minDist
		then
			 targetTower = tower
			 minDist = GetUnitToLocationDistance( tower, nLoc )
		end
	end

	local watchTowerList = J.Site.GetAllWatchTower()
	for _, watchTower in pairs( watchTowerList )
	do
		if watchTower ~= nil
			and watchTower:GetTeam() == nTeam
			and GetUnitToLocationDistance( watchTower, nLoc ) < minDist - 1300
			and ( not J.IsEnemyHeroAroundLocation( watchTower:GetLocation(), 600 )
					or J.IsAllyHeroAroundLocation( watchTower:GetLocation(), 600 ) )
		then
			 targetTower = watchTower
			 minDist = GetUnitToLocationDistance( watchTower, nLoc ) + 1300
		end
	end

	if targetTower ~= nil
	then
		return J.GetLocationTowardDistanceLocation( targetTower, nLoc, 575 )
	end

	return nFountain

end



function J.IsInAllyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hAllyAcient ) + 768 < GetUnitToUnitDistance( bot, hEnemyAcient )
	then
		return true
	end
	
	return false

end



function J.IsInEnemyArea( bot )

	local hAllyAcient = GetAncient( GetTeam() )
	local hEnemyAcient = GetAncient( GetOpposingTeam() )
	
	if GetUnitToUnitDistance( bot, hEnemyAcient ) + 1280 < GetUnitToUnitDistance( bot, hAllyAcient )
	then
		return true
	end
	
	return false

end


function J.IsAllyHeroAroundLocation( vLoc, nRadius )

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and GetUnitToLocationDistance( npcAlly, vLoc ) <= nRadius
		then
			return true
		end
	end

	return false

end



function J.IsEnemyHeroAroundLocation( vLoc, nRadius )
	-- local cacheKey = 'IsEnemyHeroAroundLocation'..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))..'-'..tostring(nRadius)
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id ) then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
					and J.GetLocationToLocationDistance( vLoc, dInfo.location ) <= nRadius
					and dInfo.time_since_seen < 2.0
				then
					-- J.Utils.SetCachedVars(cacheKey, true)
					return true
				end
			end
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, false)
	return false

end


function J.DotProduct(A, B)
	return A.x * B.x + A.y * B.y + A.z * B.z
end


function J.GetProperLocation(hUnit, nDelay)
	if hUnit:GetMovementDirectionStability() >= 0.5 then
		return hUnit:GetExtrapolatedLocation(nDelay);
	end
	return hUnit:GetLocation();
end


function J.RandomForwardVector(length)

    local offset = RandomVector(length)

    if GetTeam() == TEAM_RADIANT then
        offset.x = offset.x > 0 and offset.x or -offset.x
        offset.y = offset.y > 0 and offset.y or -offset.y
    end

    if GetTeam() == TEAM_DIRE then
        offset.x = offset.x < 0 and offset.x or -offset.x
        offset.y = offset.y < 0 and offset.y or -offset.y
    end

    return offset
end


function J.GetUnitWithMinDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local minUnit = cUnits;
	local minVal = fMinDist;
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and J.CanCastOnNonMagicImmune(hUnits[i]) 
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc);
			if dist < minVal then
				minVal = dist;
				minUnit = hUnits[i];	
			end
		end	
	end
	
	return minVal, minUnit;
end


function J.GetUnitWithMaxDistanceToLoc(hUnit, hUnits, cUnits, fMinDist, vLoc)
	local maxUnit = cUnits
	local maxVal = fMinDist
	
	for i=1, #hUnits do
		if hUnits[i] ~= nil and hUnits[i] ~= hUnit and J.CanCastOnNonMagicImmune(hUnits[i])
		then
			local dist = GetUnitToLocationDistance(hUnits[i], vLoc)
			if dist > maxVal then
				maxVal = dist
				maxUnit = hUnits[i]
			end
		end	
	end
	
	return maxVal, maxUnit
end


function J.GetFurthestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = J.GetNearbyHeroes(hUnit,nRange, false, BOT_MODE_NONE)
	local eHeroes = J.GetNearbyHeroes(hUnit,nRange, true, BOT_MODE_NONE)
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false)
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true)

	local botDist = GetUnitToLocationDistance(hUnit, vLoc)
	local furthestUnit = hUnit
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, aHeroes, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, eHeroes, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, aCreeps, furthestUnit, botDist, vLoc)
	botDist, furthestUnit = J.GetUnitWithMaxDistanceToLoc(hUnit, eCreeps, furthestUnit, botDist, vLoc)

	if furthestUnit ~= hUnit then
		return furthestUnit
	end

	return nil

end


function J.GetClosestUnitToLocationFrommAll(hUnit, nRange, vLoc)
	local aHeroes = J.GetNearbyHeroes(hUnit,nRange, false, BOT_MODE_NONE);
	local eHeroes = J.GetNearbyHeroes(hUnit,nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local closestUnit = hUnit;
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= hUnit then
		return closestUnit;
	end
	
	return nil;
	
end


function J.GetClosestUnitToLocationFrommAll2(hUnit, nRange, vLoc)
	local aHeroes = J.GetNearbyHeroes(hUnit,nRange, false, BOT_MODE_NONE);
	local eHeroes = J.GetNearbyHeroes(hUnit,nRange, true, BOT_MODE_NONE);
	local aCreeps = hUnit:GetNearbyLaneCreeps(nRange, false);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = 10000;
	local closestUnit = nil;
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, aCreeps, closestUnit, botDist, vLoc);
	botDist, closestUnit = J.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= nil then
		return closestUnit;
	end
	
	return nil;
	
end


function J.GetDistance(s, t)
    return math.sqrt((s[1] - t[1]) * (s[1]-t[1]) + (s[2] - t[2]) * (s[2] - t[2]))
end


function J.AdjustLocationWithOffset(vLoc, offset, target)
	local targetLoc = vLoc

	local facingDir = target:GetFacing()
	local offsetX = offset * math.cos(facingDir)
	local offsetY = offset * math.sin(facingDir)

	targetLoc = targetLoc + Vector(offsetX, offsetY)

	return targetLoc
end


function J.AdjustLocationWithOffsetTowardsFountain(loc, distance)
	return J.Utils.GetOffsetLocationTowardsTargetLocation(loc, J.GetTeamFountain(), distance)
end


function J.GetCurrentRoshanLocation()
	if J.CheckTimeOfDay() == 'day'
	then
		return J.Utils.RadiantRoshanLoc
	else
		return J.Utils.DireRoshanLoc
	end
end


function J.GetTormentorLocation(team)
	if J.CheckTimeOfDay() == 'day'
	then
		return DireTormentorLoc
	else
		return RadiantTormentorLoc
	end
end


function J.GetTormentorWaitingLocation(team)
	local timeOfday = J.CheckTimeOfDay()
	if timeOfday == 'day' then
		return Vector(-7041, 6796, 256)
	else
		return Vector(6792, -6815, 256)
	end
end


function J.GetXUnitsTowardsLocation2(iLoc, tLoc, nUnits)
    local dir = (tLoc - iLoc):Normalized()
    return iLoc + dir * nUnits
end


function J.GetPushTPLocation(nLane)
	local laneFront = GetLaneFrontLocation(GetTeam(), nLane, 0)
	local bestTpLoc = J.GetNearbyLocationToTp(laneFront)
	if J.GetLocationToLocationDistance(laneFront, bestTpLoc) < 1600
	then
		return bestTpLoc
	end
end


function J.GetDefendTPLocation(nLane)
	return GetLaneFrontLocation(GetTeam(), nLane, -950)
end


function J.GetRandomLocationWithinDist(sLoc, minDist, maxDist)
	local randomAngle = math.random() * 2 * math.pi
	local randomDist = math.random(minDist, maxDist)
	local newX = sLoc.x + randomDist * math.cos(randomAngle)
	local newY = sLoc.y + randomDist * math.sin(randomAngle)
	return Vector(newX, newY, sLoc.z)
end


function J.AreTreesBetween(bot, loc, r)
	local nTrees = bot:GetNearbyTrees(GetUnitToLocationDistance(bot, loc))

	for _, tree in pairs(nTrees)
	do
		local x = GetTreeLocation(tree)
		local y = bot:GetLocation()
		local z = loc

		if x ~= y
		then
			local a = 1
			local b = 1
			local c = 0

			if x.x - y.x == 0
			then
				b = 0
				c = -x.x
			else
				a = -(x.y - y.y) / (x.x - y.x)
				c = -(x.y + x.x * a)
			end

			local d = math.abs((a*z.x+b*z.y+c)/math.sqrt(a*a+b*b))

			if d <= r
			and GetUnitToLocationDistance(bot,loc) > J.GetDistance(x, loc) + 50
			then
				return true
			end
		end
	end

	return false
end


function J.VectorTowards(vStart, vTowards, nDistance)
	local vDirection = (vTowards - vStart):Normalized()
	return vStart + (vDirection * nDistance)
end


function J.VectorAway(vStart, vTowards, nDistance)
	local vDirection = (vStart - vTowards):Normalized()
	return vStart + (vDirection * nDistance)
end


function J.GetAngleFromDotProduct(dot)
	return math.deg(math.acos(dot))
end


function J.GetBestRetreatTree(bot, nCastRange)
	local nTrees = bot:GetNearbyTrees(nCastRange)
	local dest = J.VectorTowards(bot:GetLocation(), J.GetTeamFountain(), 1000)

	local bestRetreatTree = nil
	local maxDist = 0

	for _, tree in pairs(nTrees)
	do
		local nTreeLoc = GetTreeLocation(tree)

		if not J.AreTreesBetween(bot, nTreeLoc, 100)
		and GetUnitToLocationDistance(bot, nTreeLoc) > maxDist
		and GetUnitToLocationDistance(bot, nTreeLoc) < nCastRange
		and J.GetDistance(nTreeLoc, dest) < 880
		then
			maxDist = GetUnitToLocationDistance(bot, nTreeLoc)
			bestRetreatTree = loc
		end
	end

	if bestRetreatTree ~= nil
	and maxDist > bot:GetAttackRange()
	then
		return bestRetreatTree
	end

	return bestRetreatTree
end


function J.GetBestTree(bot, enemyLoc, enemy, nCastRange, hitRadios)
	local bestTree = nil
	local nTrees = bot:GetNearbyTrees(nCastRange)
	local dist = 10000

	for _, tree in pairs(nTrees)
	do
		local x = GetTreeLocation(tree)
		local y = bot:GetLocation()
		local z = enemyLoc

		if x ~= y
		then
			local a = 1
			local b = 1
			local c = 0

			if x.x - y.x == 0
			then
				b = 0
				c = -x.x
			else
				a=-(x.y-y.y)/(x.x-y.x);
				c=-(x.y + x.x*a);
			end

			local d = math.abs((a * z.x + b * z.y + c) / math.sqrt(a * a + b * b))
			if d <= hitRadios
			and dist > GetUnitToLocationDistance(enemy, x)
			and (GetUnitToLocationDistance(enemy, x) <= GetUnitToLocationDistance(bot, x))
			then
				bestTree = tree
				dist = GetUnitToLocationDistance(enemy, x)
			end
		end
	end

	return bestTree
end


function J.GetUltLoc(bot, target, nManaCost, nCastRange, s)
	local v = target:GetVelocity()
	local sv = J.GetDistance(Vector(0,0), v)
	if sv > 800
	then
		v = (v / sv) * target:GetCurrentMovementSpeed()
	end

	local x= bot:GetLocation()
	local y= target:GetLocation()

	local a = v.x * v.x + v.y * v.y - s * s
	local b = -2 * (v.x * (x.x - y.x) + v.y * (x.y - y.y))
	local c = (x.x - y.x) * (x.x - y.x) + (x.y - y.y) * (x.y - y.y)

	local t = math.max((-b + math.sqrt(b * b - 4 * a * c)) / (2 * a), (-b - math.sqrt(b * b - 4 * a * c)) / (2 * a))
	local dest = (t + 0.35) * v + y

	if GetUnitToLocationDistance(bot, dest) > nCastRange
	or bot:GetMana() < 100 + nManaCost
	then
		return nil
	end

	if target:GetMovementDirectionStability() < 0.4
	or not bot:IsFacingLocation(target:GetLocation(), 60)
	then
		dest = J.VectorTowards(y, J.GetEnemyFountain(), 180)
	end

	if J.IsDisabled(target)
	then
		dest = target:GetLocation()
	end

	return dest
end

end
