-- jmz_func sub-module: jmz_util
return function(J)

local bDebugMode = ( 1 == 10 )
local AllyPIDs = nil



function J.IsInRange( bot, npcTarget, nRadius )
	if npcTarget == nil or not npcTarget:CanBeSeen() then
		return false
	end

	return GetUnitToUnitDistance( bot, npcTarget ) <= nRadius

end



function J.IsInLocRange( npcTarget, nLoc, nRadius )
	if not npcTarget:CanBeSeen() then
		return false
	end

	return GetUnitToLocationDistance( npcTarget, nLoc ) <= nRadius

end


function J.IsInTeamFight( bot, nRadius )

	if nRadius == nil or nRadius > 1600 then nRadius = 1600 end

	local attackModeAllyList = J.GetNearbyHeroes(bot, nRadius, false, BOT_MODE_ATTACK )

	return #attackModeAllyList >= 2 -- and bot:GetActiveMode() ~= BOT_MODE_RETREAT

end


function J.IsUnitNearby(bot, tUnits, nRadius, sUnitName, bHero)
    for _, unit in pairs(tUnits) do
        if J.IsValid(unit)
        and J.IsInRange(bot, unit, nRadius)
        and unit:GetUnitName() == sUnitName
        then
			if bHero then
				if J.IsValidHero(unit) and not J.IsSuspiciousIllusion(unit) then
					return true
				end
			else
				return true
			end
        end
    end

    return false
end



function J.IsExistInTable( u, tUnit )

	for _, t in pairs( tUnit )
	do
		if u == t
		then
			return true
		end
	end

	return false

end



function J.CombineTwoTable( tableA, tableB )

	local targetTable = tableA
	local Num = #tableA

	for i, u in pairs( tableB )
	do
		targetTable[Num + i] = u
	end

	return targetTable
end



function J.SetBotPing( vLoc )

	GetBot():ActionImmediate_Ping( vLoc.x, vLoc.y, false )

end



function J.SetBotPrint( sMessage, vLoc, bReport, bPing )

	local bot = GetBot()

	local nTime = J.GetOne( DotaTime() / 10 )* 10
	local sTime = ( J.GetOne( nTime / 600 )* 10 )..":"..( nTime%60 )
	local sTeam = GetTeam() == TEAM_DIRE and "夜魇" or "天辉"

	if bDebugMode
	then

		print( sTeam..sTime.." "..J.Chat.GetNormName( bot ).." "..sMessage )

		if bReport then bot:ActionImmediate_Chat( sTime.."_"..sMessage, true ) end

		if bPing then bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false ) end

	end

end



function J.SetReportMotive( bDebugFile, sMotive )

	if bDebugMode and bDebugFile and sMotive ~= nil
	then

		local nTime = J.GetOne( DotaTime() / 10 ) * 10
		local sTime = ( J.GetOne( nTime / 600 ) * 10 )..":"..( nTime%60 )
		local sTeam = GetTeam() == TEAM_DIRE and "夜魇 " or "天辉 "

		GetBot():ActionImmediate_Chat( sTime.."_"..sMotive, true )

		print( sTeam..sTime.." "..J.Chat.GetNormName( GetBot() ).." "..sMotive )

	end

end



function J.GetOne( number )

	return math.floor( number * 10 ) / 10

end



function J.GetTwo( number )

	return math.floor( number * 100 ) / 100

end


function J.ToNearest500(num)
    return math.floor(num / 500 + 0.5) * 500
end


--RoundToNearestThousand
function J.ToNearest1000(num)
    return math.floor(num / 1000 + 0.5) * 1000
end


function J.HasEnemyIceSpireNearby(bot, nRange)
	-- local cacheKey = 'HasEnemyIceSpireNearby'..tostring(bot:GetPlayerID())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 1)
	-- if cache ~= nil then return cache end

	-- should also consider neutral creeps etc. tba.
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMIES)) do
        if J.IsValid(enemy)
		and enemy:GetUnitName() == "npc_dota_lich_ice_spire"
		and J.IsInRange(bot, enemy, nRange) then
			-- J.Utils.SetCachedVars(cacheKey, true)
			return enemy
		end
	end
	-- J.Utils.SetCachedVars(cacheKey, false)
	return false
end


function J.AnyAllyAffectedByChainFrost(bot, nRange)
	-- local cacheKey = 'AnyAllyAffectedByChainFrost'..tostring(bot:GetPlayerID())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.15)
	-- if cache ~= nil then return cache end

	-- ally heroes, creeps, units.
	for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
        if J.IsValid(ally)
        and J.IsInRange(bot, ally, nRange)
		and ally ~= bot
        and ally:HasModifier('modifier_lich_chainfrost_slow') then
			-- J.Utils.SetCachedVars(cacheKey, true)
            return true
        end
    end
	-- J.Utils.SetCachedVars(cacheKey, false)
	return false
end


function J.IsLocationInChrono(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			return true
		end
	end

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and GetUnitToLocationDistance(allyHero, loc) < 300
		and (allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze'))
		then
			return true
		end
	end

	return false
end


function J.IsLocationInBlackHole(loc)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < 300
		and (enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			or enemyHero:HasModifier('modifier_enigma_black_hole_pull_scepter'))
		then
			return true
		end
	end

	return false
end


function J.IsEnemyChronosphereInLocation(loc)
	local nRadius = 500

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if J.IsValid(unit)
		and GetUnitToLocationDistance(unit, loc) <= nRadius
		and unit:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			return true
		end
	end

	return false
end


function J.IsEnemyBlackHoleInLocation(loc)
	local nRadius = 500

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if J.IsValid(unit)
		and GetUnitToLocationDistance(unit, loc) <= nRadius
		and (unit:HasModifier('modifier_enigma_black_hole_pull') or unit:HasModifier('modifier_enigma_black_hole_pull_scepter'))
		then
			return true
		end
	end

	return false
end



function J.IsLocationInArena(loc, radius)
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and GetUnitToLocationDistance(enemyHero, loc) < radius
		and (enemyHero:HasModifier('modifier_mars_arena_of_blood_leash')
			or enemyHero:HasModifier('modifier_mars_arena_of_blood_animation'))
		then
			return true
		end
	end

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and GetUnitToLocationDistance(allyHero, loc) < radius
		and (allyHero:HasModifier('modifier_mars_arena_of_blood_animation'))
		then
			return true
		end
	end

	return false
end


function J.GetHumanPing()
	local ping = nil

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)
		if  member ~= nil
		and not member:IsBot()
		then
			return member, member:GetMostRecentPing()
		end
	end

	return nil, ping
end


function J.IsHumanInLoc(vLoc, nRadius)
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if  member ~= nil and member:IsAlive() and not member:IsBot() and not member:IsIllusion()
		and not member:HasModifier("modifier_arc_warden_tempest_double")
		and not J.IsMeepoClone(member)
		and GetUnitToLocationDistance(member, vLoc) <= nRadius
		then
			return true
		end
	end

	return false
end


function J.IsClosestToDustLocation(bot, loc)
	if AllyPIDs == nil then AllyPIDs = GetTeamPlayers(GetTeam()) end

	local closest = nil
	local closestDist = 100000

	for _, id in pairs(AllyPIDs)
	do
		local member = GetTeamMember(id)

		if J.IsValidHero(member)		
		and member:GetItemSlotType(member:FindItemSlot('item_dust')) == ITEM_SLOT_TYPE_MAIN
		and member:GetItemInSlot(member:FindItemSlot('item_dust')):IsFullyCastable()
		and not J.IsSuspiciousIllusion(member)
		then
			local dist = GetUnitToLocationDistance(member, loc)

			if dist < closestDist
			then
				closest = member
				closestDist = dist
			end
		end
	end

	if closest ~= nil
	then
		return closest == bot
	end
end


function J.GetUnderlordPortal()
	local portal = {}

	for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if u:GetUnitName() == 'npc_dota_unit_underlord_portal'
		then
			if #portal == 1
			and portal[1] ~= u
			then
				table.insert(portal, u)
			end

			if #portal == 2
			then
				break
			end

			table.insert(portal, u)
		end
	end

	if #portal == 2
	then
		return portal
	end

	return nil
end


function J.GetCreepListAroundTargetCanKill(target, nRadius, damage, bEnemy, bNeutral, bLaneCreep)
	if nRadius > 1600 then nRadius = 1600 end
	local creepList = {}

	if target ~= nil
	then
		if bNeutral
		then
			for _, creep in pairs(GetUnitList(UNIT_LIST_NEUTRAL_CREEPS))
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end
		elseif bLaneCreep
		then
			local unitList = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
			if bEnemy
			then
				unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
			end

			for _, creep in pairs(unitList)
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end
		else
			local unitList = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
			if bEnemy
			then
				unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS)
			end

			for _, creep in pairs(unitList)
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end

			unitList = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS)
			for _, creep in pairs(unitList)
			do
				if J.IsValid(creep)
				and target ~= creep
				and GetUnitToUnitDistance(target, creep) <= nRadius
				and creep:GetHealth() <= damage
				then
					table.insert(creepList, creep)
				end
			end			
		end
	end

	return creepList
end


function J.IsBigCamp(nUnits)
	for _, creep in pairs(nUnits)
	do
		if J.IsValid(creep)
		then
			if creep:GetUnitName() == 'npc_dota_neutral_satyr_hellcaller'
			or creep:GetUnitName() == 'npc_dota_neutral_polar_furbolg_ursa_warrior'
			or creep:GetUnitName() == 'npc_dota_neutral_dark_troll_warlord'
			or creep:GetUnitName() == 'npc_dota_neutral_centaur_khan'
			or creep:GetUnitName() == 'npc_dota_neutral_enraged_wildkin'
			or creep:GetUnitName() == 'npc_dota_neutral_warpine_raider'
			then
				return true
			end
		end
	end
end


function J.GetETAWithAcceleration(dist, speed, accel)
	return (math.sqrt(2 * accel * dist + speed * speed) - speed) / accel
end


function J.GetTechiesMines()
	local nMinesList = {}

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
		if unit ~= nil
        and unit:GetUnitName() == 'npc_dota_techies_land_mine'
        then
			table.insert(nMinesList, unit)
		end
	end

	return nMinesList
end


function J.GetTechiesMinesInLoc(loc, nRadius)
	local nMinesList = {}

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
    do
		if unit ~= nil
        and unit:GetUnitName() == 'npc_dota_techies_land_mine'
		and GetUnitToLocationDistance(unit, loc) <= nRadius
        then
			table.insert(nMinesList, unit)
		end
	end

	return nMinesList
end


function J.CheckBitfieldFlag(bitfield, flag)
    return ((bitfield / flag) % 2) >= 1
end


function J.GetPowerCogsCountInLoc(loc, nRadius)
	local count = 0
	for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
	do
		if J.IsValid(unit)
		and string.find(unit:GetUnitName(), 'rattletrap_cog')
		and GetUnitToLocationDistance(unit, loc) <= nRadius
		then
			count = count + 1
		end
	end

	return count
end


function J.GetLanePartner(bot)
	if bot:GetAssignedLane() == LANE_MID
	then
		return nil
	end

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)

		if member ~= nil
		and member:IsAlive()
		and member ~= bot
		and member:GetAssignedLane() == bot:GetAssignedLane()
		then
			return member
		end
	end

	return nil
end


-- Adds an avoidance zone for use with GeneratePath(). Takes a Vector with x and y as a 2D location, and z as as radius. Returns a handle to the avoidance zone.
-- location as Vector(-7174.0, -6671.0, 10.0)
function J.AddAvoidanceZone(locationR, durationSec)
	local zone = AddAvoidanceZone(locationR, durationSec)
	-- J.Utils.StartCoroutine(function()
	-- 	local endTime = DotaTime() + durationSec
	-- 	while endTime >= DotaTime() do
	-- 		print('AddAvoidanceZone...'..' endtime='..endTime..', time='..DotaTime())
	-- 		coroutine.yield()
	-- 	end
	-- 	return RemoveAvoidanceZone(zone)
	-- end)
	return zone
end


-- check if a table contains a value
function J.hasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

end
