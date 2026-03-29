-- jmz_func sub-module: jmz_unit_query
return function(J)

local SpecialUnits = {
	['npc_dota_clinkz_skeleton_archer'] = 0.75,
	['npc_dota_juggernaut_healing_ward'] = 0.9,
	['npc_dota_invoker_forged_spirit'] = 0.9,
	['npc_dota_grimstroke_ink_creature'] = 1,
	['npc_dota_ignis_fatuus'] = 1,
	['npc_dota_lone_druid_bear1'] = 0.9,
	['npc_dota_lone_druid_bear2'] = 0.9,
	['npc_dota_lone_druid_bear3'] = 0.9,
	['npc_dota_lone_druid_bear4'] = 0.9,
	['npc_dota_lycan_wolf_1'] = 0.75,
	['npc_dota_lycan_wolf_2'] = 0.75,
	['npc_dota_lycan_wolf_3'] = 0.75,
	['npc_dota_lycan_wolf_4'] = 0.75,
	['npc_dota_observer_wards'] = 1,
	['npc_dota_phoenix_sun'] = 1,
	['npc_dota_venomancer_plague_ward_1'] = 0.75,
	['npc_dota_venomancer_plague_ward_2'] = 0.75,
	['npc_dota_venomancer_plague_ward_3'] = 0.75,
	['npc_dota_venomancer_plague_ward_4'] = 0.75,
	['npc_dota_rattletrap_cog'] = 0.9,
	['npc_dota_sentry_wards'] = 1,
	['npc_dota_unit_tombstone1'] = 1,
	['npc_dota_unit_tombstone2'] = 1,
	['npc_dota_unit_tombstone3'] = 1,
	['npc_dota_unit_tombstone4'] = 1,
	['npc_dota_warlock_golem_1'] = 0.9,
	['npc_dota_warlock_golem_2'] = 0.9,
	['npc_dota_warlock_golem_3'] = 0.9,
	['npc_dota_warlock_golem_scepter_1'] = 0.9,
	['npc_dota_warlock_golem_scepter_2'] = 0.9,
	['npc_dota_warlock_golem_scepter_3'] = 0.9,
	['npc_dota_weaver_swarm'] = 0.9,
	['npc_dota_zeus_cloud'] = 0.75,
}
local nearByHeroCacheDuration = 0.1 -- 0.xxx = xxx ms. if you have 60 frames per second, it's 1000/60 = 16.7ms per frame. higher fps, smaller ms per frame.
local printN = 0


--友军生物数量
function J.GetUnitAllyCountAroundEnemyTarget( target, nRadius )

	local targetLoc = target:GetLocation()
	local heroCount = J.GetNearbyAroundLocationUnitCount( false, true, nRadius, targetLoc )
	local creepCount = J.GetNearbyAroundLocationUnitCount( false, false, nRadius, targetLoc )

	return heroCount + creepCount

end



--敌军生物数量
function J.GetAroundTargetEnemyUnitCount( target, nRadius )
	local targetLoc = target:GetLocation()
	return J.GetAroundTargetLocEnemyUnitCount( targetLoc, nRadius )
end


function J.GetAroundTargetLocEnemyUnitCount( targetLoc, nRadius )
	local heroCount = J.GetNearbyAroundLocationUnitCount( true, true, nRadius, targetLoc )
	local creepCount = J.GetNearbyAroundLocationUnitCount( true, false, nRadius, targetLoc )
	return heroCount + creepCount
end


--敌军英雄数量
function J.GetAroundTargetEnemyHeroCount( target, nRadius )

	return J.GetNearbyAroundLocationUnitCount( true, true, nRadius, target:GetLocation() )

end



--通用数量
function J.GetNearbyAroundLocationUnitCount( bEnemy, bHero, nRadius, vLoc )
	-- local cacheKey = 'GetNearbyAroundLocationUnitCount'..tostring(nRadius) ..'-'..tostring(bEnemy)..'-'..tostring(bHero)..'-'..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local nCount = 0

	if bHero
	then
		if bEnemy then
			nCount = #J.GetEnemiesNearLoc(vLoc, nRadius)
		else
			nCount = #J.GetAlliesNearLoc( vLoc, nRadius )
		end
	else
		if bEnemy then
			for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
			do
				if J.IsValid(unit)
				and GetUnitToLocationDistance(unit, vLoc) <= nRadius
				then
					nCount = nCount + 1
				end
			end
		else
			for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIES))
			do
				if J.IsValid(unit)
				and GetUnitToLocationDistance(unit, vLoc) <= nRadius
				then
					nCount = nCount + 1
				end
			end
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, nCount)
	return nCount

end



function J.GetAttackEnemysAllyCreepCount( target, nRadius )

	local bot = GetBot()
	local nAllyCreeps = bot:GetNearbyCreeps( nRadius, false )
	local nAttackEnemyCount = 0
	for _, creep in pairs( nAllyCreeps )
	do
		if creep:IsAlive()
			and creep:CanBeSeen()
			and creep:GetAttackTarget() == target
		then
			nAttackEnemyCount = nAttackEnemyCount + 1
		end
	end

	return nAttackEnemyCount

end



function J.GetRetreatingAlliesNearLoc( vLoc, nRadius )
	-- local cacheKey = 'GetRetreatingAlliesNearLoc'..tostring(nRadius) ..tostring(J.ToNearest500(vLoc.x))..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local allies = {}
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToLocationDistance( member, vLoc ) <= nRadius
			and J.IsRetreating( member )
		then
			table.insert( allies, member )
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, allies)

	return allies

end


function J.GetAlliesNearLoc( vLoc, nRadius )
	local allies = {}
	-- local cacheKey = 'GetAlliesNearLoc'..tostring(nRadius) ..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member:IsAlive()
			and GetUnitToLocationDistance( member, vLoc ) <= nRadius
		then
			table.insert( allies, member )
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, allies)

	return allies

end


function J.GetEnemiesNearLoc(vLoc, nRadius)
	-- local cacheKey = 'GetEnemiesNearLoc'..tostring(nRadius) ..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local enemies = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		and not J.IsSuspiciousIllusion(enemyHero)
		and not J.IsMeepoClone(enemyHero)
		and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
		then
			table.insert(enemies, enemyHero)
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, enemies)

	return enemies
end


function J.GetAnyEnemiesNearLoc(vLoc, nRadius)
	-- local cacheKey = 'GetAnyEnemiesNearLoc'..tostring(nRadius) ..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local enemies = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		then
			table.insert(enemies, enemyHero)
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, enemies)

	return enemies
end


function J.GetIllusionsNearLoc(vLoc, nRadius)
	-- local cacheKey = 'GetIllusionsNearLoc'..tostring(nRadius) ..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local illusions = {}
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and GetUnitToLocationDistance(enemyHero, vLoc) <= nRadius
		and J.IsSuspiciousIllusion(enemyHero)
		and not J.IsMeepoClone(enemyHero)
		then
			table.insert(illusions, enemyHero)
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, illusions)

	return illusions
end



function J.GetHeroesTargetingUnit(tUnits, hUnit)
    local tAttackingUnits = {}
    for _, enemyHero in pairs(tUnits) do
        if J.IsValidHero(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
        and (enemyHero:GetAttackTarget() == hUnit or J.IsChasingTarget(enemyHero, hUnit))
        then
            table.insert(tAttackingUnits, enemyHero)
        end
    end

    return tAttackingUnits
end


function J.GetSameUnitType(hUnit, nRadius, sUnitName, bAttacking)
    local tAttackingUnits = {}
    local unitList = GetUnitList(UNIT_LIST_ALL)
    for _, unit in pairs(unitList) do
        if J.IsValid(unit)
        and unit:GetUnitName() == sUnitName
        and GetUnitToUnitDistance(unit, hUnit) <= nRadius
        then
			if bAttacking then
				if (unit:GetAttackTarget() == hUnit or J.IsChasingTarget(unit, hUnit)) then
					table.insert(tAttackingUnits, unit)
				end
			else
				table.insert(tAttackingUnits, unit)
			end
        end
    end

    return tAttackingUnits
end

function J.GetUnitListTotalAttackDamage(bot, tUnits, fTimeInterval)
    local dmg = 0
	for _, unit in pairs(tUnits) do
		if J.IsValid(unit) then
            local nAttackDamage = unit:GetAttackDamage()
			local sUnitName = unit:GetUnitName()

            if J.IsSuspiciousIllusion(unit) then
                if string.find(sUnitName, 'phantom_lancer') then
                    nAttackDamage = nAttackDamage * 0.19
                elseif string.find(sUnitName, 'naga_siren') then
                    nAttackDamage = nAttackDamage * 0.4
                elseif string.find(sUnitName, 'chaos_knight') then
                    -- full
                elseif string.find(sUnitName, 'terrorblade') then
                    if J.IsUnitNearby(bot, tUnits, 1200, sUnitName, true) then
                        nAttackDamage = nAttackDamage * (0.6 + 0.25)
                    else
                        nAttackDamage = nAttackDamage * (0.6 - 0.50)
                    end
                elseif unit:HasModifier('modifier_darkseer_wallofreplica_illusion') then
                    nAttackDamage = nAttackDamage * 0.9
                elseif unit:HasModifier('modifier_grimstroke_scepter_buff') then
                    nAttackDamage = nAttackDamage * 1.5
                else
					if unit:GetAttackRange() > 300 then
						nAttackDamage = nAttackDamage * 0.28
					else
						nAttackDamage = nAttackDamage * 0.33
					end
                end
            end

            dmg = dmg + nAttackDamage * unit:GetAttackSpeed() * fTimeInterval
		end
	end

	return dmg
end

function J.GetSpecialUnits()
	return SpecialUnits
end



function J.GetInvUnitInLocCount( bot, nRadius, nFindRadius, vLocation, pierceImmune )

	local nUnits = 0
	if nRadius > 1600 then nRadius = 1600 end
	local unitList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	for _, u in pairs( unitList ) do
		if ( ( pierceImmune and J.CanCastOnMagicImmune( u ) )
			 or ( not pierceImmune and J.CanCastOnNonMagicImmune( u ) ) )
			and GetUnitToLocationDistance( u, vLocation ) <= nFindRadius
		then
			nUnits = nUnits + 1
		end
	end

	return nUnits

end



function J.GetInLocLaneCreepCount( bot, nRadius, nFindRadius, vLocation )

	local nUnits = 0
	if nRadius > 1600 then nRadius = 1600 end
	local unitList = bot:GetNearbyLaneCreeps( nRadius, true )
	for _, u in pairs( unitList ) do
		if GetUnitToLocationDistance( u, vLocation ) <= nFindRadius
		then
			nUnits = nUnits + 1
		end
	end

	return nUnits

end



function J.GetInvUnitCount( pierceImmune, unitList )

	local nUnits = 0
	if unitList ~= nil
	then
		for _, u in pairs( unitList )
		do
			if ( pierceImmune and J.CanCastOnMagicImmune( u ) )
				or ( not pierceImmune and J.CanCastOnNonMagicImmune( u ) )
			then
				nUnits = nUnits + 1
			end
		end
	end

	return nUnits

end



function J.GetAroundTargetAllyHeroCount( target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )

	return #heroList

end



function J.GetAroundTargetOtherAllyHeroCount( bot, target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )

	if GetUnitToUnitDistance( bot, target ) <= nRadius
	then
		return #heroList - 1
	end

	return #heroList

end



function J.GetAllyCreepNearLoc( bot, vLoc, nRadius )

	local AllyCreepsAll = bot:GetNearbyCreeps( 1600, false )
	local allyCreepList = { }

	for _, creep in pairs( AllyCreepsAll )
	do
		if creep ~= nil
			and creep:IsAlive()
			and GetUnitToLocationDistance( creep, vLoc ) <= nRadius
		then
			table.insert( allyCreepList, creep )
		end
	end

	return allyCreepList

end



function J.GetAllyUnitCountAroundEnemyTarget( bot, target, nRadius )

	local heroList = J.GetAlliesNearLoc( target:GetLocation(), nRadius )
	local creepList = J.GetAllyCreepNearLoc( bot, target:GetLocation(), nRadius )

	return #heroList + #creepList

end



-- local NearbyHeroMap = {
	-- 'hero_unit_name' = {
	-- 	'enemy' = {
	-- 		'1600' = { 
	-- 			'time' = DotaTime(),
	-- 			'heroes' = {}
	-- 		},
	-- 		'1000' = { },
	-- 	},
	-- 	'ally' = {
	-- 		'1600' = { },
	-- 		'1000' = { },
	-- 	}
	-- }
-- }
-- Cache duration in seconds
-- Check the current time
local currentTime
local cacheNearbyTable

-- Method to refresh and cache nearby hero lists for each hero unit
-- Unknown why but it seems to cause dota2 to crash due to changing the caching frequence, or maybe it's due to some nil exceptions.
function J.GetNearbyHeroes(bot, nRadius, bEnemy, bBotMode)
	if not bBotMode then bBotMode = BOT_MODE_NONE end
	-- local nearbyHeroes = bot:GetNearbyHeroes(nRadius, bEnemy, bBotMode)
	-- if printN <= 100000 then
	-- 	printN = printN + 1
	-- 	J.Utils.PrintTable(nearbyHeroes)
	-- end
	local nearby = bot:GetNearbyHeroes(nRadius, bEnemy, bBotMode)
	if not nearby then
		return nearby
	end

	local heroes = {}
	for _, hero in pairs( nearby )
	do
		if J.IsValidHero(hero)
		and not J.IsMeepoClone(hero)
		and not bot:HasModifier('modifier_arc_warden_tempest_double') then
			table.insert(heroes, hero)
		end
	end
	return heroes

    -- Cap the radius to a maximum value
    -- if nRadius > 1600 then nRadius = 1600 end

    -- -- Initialize the bot's cache table if it doesn't exist
    -- bot.nearbyHeroes = bot.nearbyHeroes or { ally = {}, enemy = {} }

    -- -- Select the appropriate cache based on whether we're looking for enemies or allies
    -- cacheNearbyTable = bEnemy and bot.nearbyHeroes.enemy or bot.nearbyHeroes.ally

    -- -- Check the current time
    -- currentTime = DotaTime()

    -- -- Initialize or update the cache for the specific radius
	-- if cacheNearbyTable[nRadius] == nil or
	-- 	currentTime - cacheNearbyTable[nRadius].time >= nearByHeroCacheDuration
	-- then
	-- 	cacheNearbyTable[nRadius] = {
	-- 		time = currentTime,
	-- 		heroes = bot:GetNearbyHeroes(nRadius, bEnemy, BOT_MODE_NONE)
	-- 	}
	-- end

	-- -- J.Utils.PrintTable(cacheNearbyTable[nRadius].heroes)
    -- -- Return the cached nearby heroes
    -- return cacheNearbyTable[nRadius].heroes
end


function J.GetAroundBotUnitList( bot, nRadius, bEnemy )

	if nRadius > 1600 then nRadius = 1600 end

	local heroList = J.GetNearbyHeroes(bot, nRadius, bEnemy, BOT_MODE_NONE )
	local creepList = bot:GetNearbyCreeps( nRadius, bEnemy )
	local unitList = {}

	if #heroList > 0 and #creepList > 0
	then
		unitList = heroList
		for i = 1, #creepList
		do
			table.insert( unitList, creepList[1] )
		end
	elseif #heroList == 0
	then
		unitList = creepList
	elseif #creepList == 0
	then
		unitList = heroList
	end

	return unitList

end



function J.GetAllyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local nRealAllyList = {}
	local nCandidate = J.GetNearbyHeroes(bot, nRadius, false, BOT_MODE_NONE )
	if #nCandidate <= 1 then return nCandidate end

	for _, ally in pairs( nCandidate )
	do
		if ally ~= nil and ally:IsAlive()
			and not ally:IsIllusion()
		then
			table.insert( nRealAllyList, ally )
		end
	end

	return nRealAllyList

end



function J.GetAllyCount( bot, nRadius )

	local nRealAllyList = J.GetAllyList( bot, nRadius )

	return #nRealAllyList

end



function J.GetAroundEnemyHeroList( nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	return J.GetNearbyHeroes(GetBot(), nRadius, true, BOT_MODE_NONE )

end



function J.GetAroundCreepList( nRadius, bEnemy, bNeutral, bLaneCreep )

	local bot = GetBot()
	if nRadius > 1600 then nRadius = 1600 end
	local creepList = {}

	if bNeutral
	then
		creepList = bot:GetNearbyNeutralCreeps( nRadius )
	elseif bLaneCreep
	then
		creepList = bot:GetNearbyLaneCreeps( nRadius, bEnemy )
	else
		creepList = bot:GetNearbyCreeps( nRadius, bEnemy )
	end

	return creepList

end



function J.GetAroundBuildingList( nRadius, bEnemy, bTower, bShrine, bFiller, bBarrack, bAcient )

	local bot = GetBot()
	if nRadius > 1600 then nRadius = 1600 end
	local buildingList = {}

	-- GetNearbyBarracks( nRadius, bEnemies )
	-- GetNearbyTowers( nRadius, bEnemies )
	-- GetNearbyShrines( nRadius, bEnemies )
	-- GetNearbyFillers( nRadius, bEnemies )
	-- GetAncient( nTeam )

	return buildingList

end



function J.GetEnemyList( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nRealEnemyList = {}
	local nCandidate = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	if nCandidate[1] == nil then return nCandidate end

	for _, enemy in pairs( nCandidate )
	do
		if enemy ~= nil and type(enemy) == "table" and enemy:IsAlive()
			and not J.IsSuspiciousIllusion( enemy )
		then
			table.insert( nRealEnemyList, enemy )
		end
	end

	return nRealEnemyList

end



function J.GetEnemyCount( bot, nRadius )

	local nRealEnemyList = J.GetEnemyList( bot, nRadius )

	return #nRealEnemyList

end


function J.GetLastSeenEnemiesNearLoc(vLoc, nRadius)
	-- local cacheKey = 'GetLastSeenEnemiesNearLoc'..tostring(nRadius) ..'-'..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local enemies = {}

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id ) then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
					and J.GetLocationToLocationDistance( vLoc, dInfo.location ) <= nRadius
					and dInfo.time_since_seen < 5.0
				then
					table.insert(enemies, id)
				end
			end
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, enemies)
	return enemies
end


function J.GetEnemiesAroundAncient(bot, nRadius)
	if bot == nil then bot = GetBot() end
	return J.GetEnemiesAroundLoc(GetAncient(bot:GetTeam()):GetLocation(), nRadius)
end


function J.GetEnemiesAroundLoc(vLoc, nRadius)
	if not nRadius then nRadius = 2000 end
	-- local cacheKey = 'GetEnemiesAroundLoc'..tostring(nRadius) ..'-'..tostring(J.ToNearest500(vLoc.x))..'-'..tostring(J.ToNearest500(vLoc.y))
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local nUnitCount = 0
	local ancientLoc = GetAncient(GetBot():GetTeam()):GetLocation()

	-- Check Heroes. 
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id)
			if info ~= nil then
				local dInfo = info[1]
				if dInfo ~= nil
				and J.GetLocationToLocationDistance(vLoc, dInfo.location) <= nRadius
				and dInfo.time_since_seen < 5.0
				then
					nUnitCount = nUnitCount + GetHeroLevel(id) / 3
					if J.GetLocationToLocationDistance(ancientLoc, vLoc) < 1600 then
						nUnitCount = nUnitCount + 2 -- Increase weight for critical defense.
					end
				end
			end
		end
	end

	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		and GetUnitToLocationDistance(unit, vLoc) <= nRadius
		then
			local unitName = unit:GetUnitName()
			if unit:IsCreep() then
				nUnitCount = nUnitCount + 1
				if unit:IsAncientCreep()
				or unit:HasModifier('modifier_chen_holy_persuasion')
				or unit:HasModifier('modifier_dominated') then
					nUnitCount = nUnitCount + 1
				end
			elseif string.find(unit:GetUnitName(), 'spiderling') then nUnitCount = nUnitCount + 0.1
			elseif string.find(unit:GetUnitName(), 'eidolon') then nUnitCount = nUnitCount + 0.3
			elseif string.find(unitName, 'siege') and not string.find(unitName, 'upgraded') then
				nUnitCount = nUnitCount + 0.6
			elseif string.find(unitName, 'upgraded') then nUnitCount = nUnitCount + 1
			elseif string.find(unitName, 'warlock_golem') then
				if DotaTime() < 10 * 60 then nUnitCount = nUnitCount + 3
				elseif DotaTime() < 20 * 60 then nUnitCount = nUnitCount + 2.5
				elseif DotaTime() < 30 * 60 then nUnitCount = nUnitCount + 2
				else nUnitCount = nUnitCount + 1.5 end
			elseif string.find(unitName, 'lone_druid_bear') then nUnitCount = nUnitCount + 3
			elseif string.find(unitName, 'shadow_shaman_ward') then nUnitCount = nUnitCount + 2
			elseif string.find(unit:GetUnitName(), "tombstone") then nUnitCount = nUnitCount + 2
			elseif J.IsSuspiciousIllusion(unit) then
				if unit:HasModifier('modifier_arc_warden_tempest_double')
					or string.find(unit:GetUnitName(), 'chaos_knight')
					or string.find(unit:GetUnitName(), 'naga_siren') then nUnitCount = nUnitCount + 2 end
			elseif not (string.find(unitName, 'observer_wards') or string.find(unitName, 'sentry_wards')) then nUnitCount = nUnitCount + 1 end
			if J.GetLocationToLocationDistance(ancientLoc, vLoc) < 1600 then nUnitCount = nUnitCount + 2 end
		end
	end

	-- J.Utils.SetCachedVars('GetEnemiesAroundLoc'..cacheKey, nUnitCount)
	return nUnitCount
end


function J.FindEnemyUnit(name)
	for _, unit in pairs(GetUnitList(UNIT_LIST_ENEMIES))
	do
		if J.IsValid(unit)
		then
			if string.find(unit:GetUnitName(), name) then
				return unit
			end
		end
	end
	return nil
end


function J.GetHeroCountAttackingTarget(nUnits, target)
	local count = 0
	for _, hero in pairs(nUnits)
	do
		if J.IsValidHero(hero)
		and J.IsInRange(hero, target, 1600)
		and J.IsGoingOnSomeone(hero)
		and hero:CanBeSeen()
		and (hero:GetAttackTarget() == target or hero:GetTarget() == target)
		and not J.IsSuspiciousIllusion(hero)
		then
			count = count + 1
		end
	end

	return count
end

end
