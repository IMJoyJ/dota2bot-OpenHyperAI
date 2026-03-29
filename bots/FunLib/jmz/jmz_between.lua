-- jmz_func sub-module: jmz_between
return function(J)


function J.IsThereNonSelfCoreNearby(nRadius)
	local selfBot = GetBot()
	-- local cacheKey = 'IsThereNonSelfCoreNearby'..tostring(selfBot:GetPlayerID())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 2)
	-- if cache ~= nil then return cache end

    local nAllyHeroes = J.GetNearbyHeroes(selfBot, nRadius, false, BOT_MODE_NONE)

    for _, ally in pairs(nAllyHeroes) do
        if J.IsCore(ally) and selfBot ~= ally
        then
            -- J.Utils.SetCachedVars(cacheKey, true)
            return true
        end
    end

    -- J.Utils.SetCachedVars(cacheKey, false)
    return false
end


function J.IsHeroBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nAllyHeroes = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end


function J.IsEnemyBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end


function J.IsHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyHeroes = J.GetNearbyHeroes(hSource,1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
    do
		if allyHero ~= hTarget and allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within == true and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(hSource,1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
    do
		if enemyHero ~= hTarget and enemyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end


function J.IsCreepBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local bot = GetBot()

	local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nAllyLaneCreeps)
    do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nEnemyLaneCreeps)
    do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())

		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
	end

	return false
end


function J.IsUnitBetweenMeAndLocation(hSource, hTarget, vTargetLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vTargetLoc

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
	do
		if J.IsValid(unit)
		and GetUnitToUnitDistance(GetBot(), unit) <= 1600
		and not unit:IsBuilding()
		and not string.find(unit:GetUnitName(), 'ward')
		and hSource ~= unit
		and hTarget ~= unit
		then
			local nRadius__ = nRadius + unit:GetBoundingRadius()
			local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius__ then return true end end
	end

	return false
end


function J.IsNonSiegeCreepBetweenMeAndLocation(hSource, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, true)
	for _, creep in pairs(nAllyLaneCreeps)
    do
		if J.IsValid(creep)
		and not J.IsKeyWordUnit('siege', creep)
		then
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	local nEnemyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, false)
	for _, creep in pairs(nEnemyLaneCreeps)
    do
		if J.IsValid(creep)
		and not J.IsKeyWordUnit('siege', creep)
		then
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
		end
	end

	return false
end


function J.IsThereCoreNearby(nRadius)
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local allyHero = GetTeamMember(i)
		if allyHero ~= nil
		and allyHero ~= GetBot()
		and J.IsCore(allyHero)
		and J.IsInRange(GetBot(), allyHero, nRadius)
		then
			return true
		end
	end

    return false
end


function J.IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local creeps = hSource:GetNearbyCreeps(1600, false)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, true)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	creeps = hSource:GetNearbyCreeps(1600, true)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, false)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	return false
end


-- function J.IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
-- 	local vStart = hSource:GetLocation()
-- 	local vEnd = vLoc

-- 	local nAllyLaneCreeps = hTarget:GetNearbyLaneCreeps(1600, false)
-- 	for _, creep in pairs(nAllyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
-- 	end

-- 	local nEnemyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, true)
-- 	for _, creep in pairs(nEnemyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then return true end
-- 	end

-- 	return false
-- end

-- function J.IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
-- 	local vStart = hSource:GetLocation()
-- 	local vEnd = vLoc

-- 	local nAllyLaneCreeps = hSource:GetNearbyLaneCreeps(1600, false)
-- 	for _, creep in pairs(nAllyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then
-- 			return true
-- 		end
-- 	end

-- 	local nEnemyLaneCreeps = hTarget:GetNearbyLaneCreeps(1600, true)
-- 	for _, creep in pairs(nEnemyLaneCreeps)
-- 	do
-- 		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation())
-- 		if tResult ~= nil and tResult.within and tResult.distance < nRadius then
-- 			return true
-- 		end
-- 	end

-- 	return false
-- end

function J.IsAllyHeroBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc

	local nAllyHeroes = J.GetNearbyHeroes(hSource, 1600, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if allyHero ~= hSource
		then
			local tResult = PointToLineDistance(vStart, vEnd, allyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then return true end
		end
	end

	local nEnemyHeroes = J.GetNearbyHeroes(hTarget, 1600, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if enemyHero ~= hSource
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			local tResult = PointToLineDistance(vStart, vEnd, enemyHero:GetLocation())
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then return true end
		end
	end

	return false
end

end
