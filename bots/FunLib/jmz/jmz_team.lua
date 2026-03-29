-- jmz_func sub-module: jmz_team
return function(J)

local bDebugMode = ( 1 == 10 )
local PosXHuman = {}
local hAllyTeamList = {}
local hEnemyTeamList = {}



function J.GetMostUltimateCDUnit()

	local unit = nil
	local maxCD = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if member ~= nil and member:IsAlive()
				and member:GetUnitName() ~= "npc_dota_hero_nevermore"
				and member:GetUnitName() ~= "npc_dota_hero_arc_warden"
			then
				if member:GetUnitName() == "npc_dota_hero_silencer" or member:GetUnitName() == "npc_dota_hero_warlock"
				then
					return member
				end
				local ult = J.GetUltimateAbility( member )
				if ult ~= nil
					and ult:IsPassive() == false
					and ult:GetCooldown() >= maxCD
				then
					unit = member
					maxCD = ult:GetCooldown()
				end
			end
		end
	end

	return unit

end



function J.GetPickUltimateScepterUnit()

	local unit = nil
	local maxNetWorth = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if member ~= nil and member:IsAlive()
				and not member:HasScepter()
				and ( member:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
					 or not member:IsBot() )
			then
				if not member:IsBot()
				then
					return member
				end

				if member:GetUnitName() ~= "npc_dota_hero_warlock"
					and member:GetUnitName() ~= "npc_dota_hero_zuus"
					and ( member:GetItemInSlot( 8 ) == nil or member:GetItemInSlot( 7 ) == nil )
				then
					local mNetWorth = member:GetNetWorth()
					if mNetWorth >= maxNetWorth
					then
						unit = member
						maxNetWorth = mNetWorth
					end
				end
			end
		end
	end

	return unit

end


function J.GetClosestTeamLane(unit)
	local v_top_lane = GetLocationAlongLane(LANE_TOP, GetLaneFrontAmount(GetTeam(), LANE_TOP, false))
	local v_mid_lane = GetLocationAlongLane(LANE_MID, GetLaneFrontAmount(GetTeam(), LANE_MID, false))
	local v_bot_lane = GetLocationAlongLane(LANE_BOT, GetLaneFrontAmount(GetTeam(), LANE_BOT, false))

	local dist_from_top = GetUnitToLocationDistance(unit, v_top_lane)
	local dist_from_mid = GetUnitToLocationDistance(unit, v_mid_lane)
	local dist_from_bot = GetUnitToLocationDistance(unit, v_bot_lane)

	if dist_from_top < dist_from_mid and dist_from_top < dist_from_bot
	then
		return v_top_lane
	elseif dist_from_mid < dist_from_top and dist_from_mid < dist_from_bot
	then
		return v_mid_lane
	elseif dist_from_bot < dist_from_top and dist_from_bot < dist_from_mid
	then
		return v_bot_lane
	end

	return v_mid_lane
end


function J.GetFirstBotInTeam()
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local ally = GetTeamMember(i)
		if ally ~= nil
		and ally:IsBot()
		then
			return ally
		end
	end
end



function J.IsOtherAllysTarget( unit )

	local bot = GetBot()
	local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )

	if #hAllyList <= 1 then return false end

	for _, ally in pairs( hAllyList )
	do
		if J.IsValid( ally )
			and ally ~= bot
			and not ally:IsIllusion()
			and ( J.GetProperTarget( ally ) == unit
					or ( not ally:IsBot() and ally:IsFacingLocation( unit:GetLocation(), 20 ) ) )
		then
			return true
		end
	end

	return false

end



function J.IsAllysTarget( unit )

	local bot = GetBot()
	local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )

	for _, ally in pairs( hAllyList )
	do
		if J.IsValid( ally )
			and not ally:IsIllusion()
			and ( J.GetProperTarget( ally ) == unit
					or ( not ally:IsBot() and ally:IsFacingLocation( unit:GetLocation(), 12 ) ) )
		then
			return true
		end
	end

	return false

end



function J.IsTeamActivityCount( bot, nCount )

	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if J.GetAllyCount( member, 1600 ) >= nCount
			then
				return true
			end
		end
	end

	return false

end



function J.GetSpecialModeAllies( bot, nDistance, nMode )

	local allyList = {}
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		then
			if member:GetActiveMode() == nMode
				and GetUnitToUnitDistance( member, bot ) <= nDistance
			then
				table.insert( allyList, member )
			end
		end
	end

	return allyList

end



function J.GetSpecialModeAlliesCount( nMode )

	local allyList = J.GetSpecialModeAllies( GetBot(), 99999, nMode )

	return #allyList

end



function J.GetTeamFightLocation( bot )

	local team = GetTeam()

	-- local res = J.Utils.GetCachedVars('GetTeamFightLocation'..tostring(team), 0.5)
	-- if res ~= nil then return res end

	local targetLocation = nil
	local numPlayer = GetTeamPlayers( team )

	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and J.IsInTeamFight( member, 1500 )
			and J.GetEnemyCount( member, 1400 ) >= 2
		then
			local allyList = J.GetSpecialModeAllies( member, 1400, BOT_MODE_ATTACK )
			targetLocation = J.GetCenterOfUnits( allyList )
			break
		end
	end

	-- J.Utils.SetCachedVars('GetTeamFightLocation', targetLocation)
	return targetLocation

end



function J.GetTeamFightAlliesCount( bot )

	local numPlayer = GetTeamPlayers( GetTeam() )
	local nCount = 0
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
			and J.IsInTeamFight( member, 1200 )
			and J.GetEnemyCount( member, 1400 ) >= 2
		then
			nCount = J.GetSpecialModeAlliesCount( BOT_MODE_ATTACK )
			break
		end
	end

	return nCount

end



function J.GetCenterOfUnits( nUnits )

	if #nUnits == 0
	then
		return Vector( 0.0, 0.0 )
	end

	local sum = Vector( 0.0, 0.0 )
	local num = 0

	for _, unit in pairs( nUnits )
	do
		if J.IsValid(unit)
		then
			sum = sum + unit:GetLocation()
			num = num + 1
		end
	end

	if num == 0 then return Vector( 0.0, 0.0 ) end

	return sum / num

end


function J.GetMostFarmLaneDesire(bot)

	local nTopDesire = GetFarmLaneDesire( LANE_TOP )
	local nMidDesire = GetFarmLaneDesire( LANE_MID )
	local nBotDesire = GetFarmLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	if DotaTime() < 8 * 60 then
		return bot:GetAssignedLane(), 0.667
	end

	return LANE_MID, nMidDesire

end



function J.GetMostDefendLaneDesire()

	local nTopDesire = J.GetDefendLaneDesire( LANE_TOP )
	local nMidDesire = J.GetDefendLaneDesire( LANE_MID )
	local nBotDesire = J.GetDefendLaneDesire( LANE_BOT )

	if nMidDesire > nTopDesire and nMidDesire > nBotDesire then
		return LANE_MID, nMidDesire
	end

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end


function J.GetDefendLaneDesire(lane)
	local defaultDefDesire, newDefDesire = GetDefendLaneDesire(lane), GetBot().DefendLaneDesire
	if newDefDesire ~= nil and newDefDesire[lane] > defaultDefDesire
	then
		return newDefDesire[lane]
	end
	return defaultDefDesire
end


function J.IsT3TowerDown(team, lane)
	local t3 = {
		[LANE_TOP] = TOWER_TOP_3,
		[LANE_MID] = TOWER_MID_3,
		[LANE_BOT] = TOWER_BOT_3,
	}

	return GetTower(team, t3[lane]) == nil
end


function J.IsPingCloseToValidTower(nTeam, ping, nRadius, fInterval)
	if ping and ping.location then
		local unitList = UNIT_LIST_ALLIED_BUILDINGS
		if nTeam == GetOpposingTeam() then
			unitList = UNIT_LIST_ENEMY_BUILDINGS
		end
		for _, unit in pairs(GetUnitList(unitList)) do
			if unit ~= nil
			and unit:IsAlive()
			and unit:CanBeSeen()
			and not unit:IsInvulnerable()
			and not unit:HasModifier('modifier_backdoor_protection')
			and not unit:HasModifier('modifier_backdoor_protection_in_base')
			and not unit:HasModifier('modifier_backdoor_protection_active')
			and not string.find(unit:GetUnitName(), 'fillers')
			then
				local sUnitName = unit:GetUnitName()
				if J.GetDistance(unit:GetLocation(), ping.location) <= nRadius and GameTime() < ping.time + fInterval then
					local nLane = LANE_MID
					if string.find(sUnitName, '_fort') then
						nLane = LANE_MID
					elseif string.find(sUnitName, '_top') then
						nLane = LANE_TOP
					elseif string.find(sUnitName, '_mid') then
						nLane = LANE_MID
					elseif string.find(sUnitName, '_bot') then
						nLane = LANE_BOT
					end
					return true, nLane
				end
			end
		end
	end

	return false, -1
end


function J.GetMostPushLaneDesire()

	local nTopDesire = GetPushLaneDesire( LANE_TOP )
	local nMidDesire = GetPushLaneDesire( LANE_MID )
	local nBotDesire = GetPushLaneDesire( LANE_BOT )

	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire
	end

	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire
	end

	return LANE_MID, nMidDesire

end



function J.IsHaveAegis( bot )
	return bot:FindItemSlot( "item_aegis" ) >= 0
end


function J.DoesTeamHaveAegis()
	-- local cacheKey = tostring(GetTeam())
	-- local res = J.Utils.GetCachedVars('DoesTeamHaveAegis'..cacheKey, 1)
	-- if res ~= nil then return res end

	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and J.IsHaveAegis(member)
		then
			-- J.Utils.SetCachedVars('DoesTeamHaveAegis'..cacheKey, true)
			return true
		end
	end

	-- J.Utils.SetCachedVars('DoesTeamHaveAegis'..cacheKey, false)
	return false
end



function J.GetCoresAverageNetworth()
	-- local cacheKey = 'GetCoresAverageNetworth'..tostring(GetTeam())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 2)
	-- if cache ~= nil then return cache end

	local totalNetWorth = 0
	local coreCount = 0
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and J.IsCore(member)
		then
			totalNetWorth = totalNetWorth + member:GetNetWorth()
			coreCount = coreCount + 1
		end
	end

	local res = totalNetWorth / coreCount
	-- J.Utils.SetCachedVars(cacheKey, res)
	return res
end


function J.GetCoresMaxNetworth()
	local cacheKey = 'GetCoresMaxNetworth'..tostring(GetTeam())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 2)
	if cache ~= nil then return cache end

	local maxNetWorth = 0
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember(i)
		if J.IsValidHero(member)
		and J.IsCore(member) then
			local networth = member:GetNetWorth()
			if networth > maxNetWorth
			then
				maxNetWorth = networth
			end
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, maxNetWorth)
	return maxNetWorth
end



function J.IsAnyAllyHeroSurroundedByManyAllies()

	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local npcAlly = GetTeamMember( i )
		if npcAlly ~= nil
			and npcAlly:IsAlive()
			and #J.GetNearbyHeroes(npcAlly, 1600, false, BOT_MODE_NONE) >= 3
		then
			return true
		end
	end

	return false

end


function J.GetNumOfAliveHeroes( bEnemy )
	local count = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	-- local cacheKey = 'GetNumOfAliveHeroes'..tostring(nTeam)
	-- local cache = J.Utils.GetCachedVars(cacheKey, 1)
	-- if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		if IsHeroAlive( id )
		then
			count = count + 1
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, count)
	return count

end


function J.GetNumOfHeroesNearLocation( bEnemy, location, distance )
	local count = 0
	local heroList = bEnemy and GetUnitList( UNIT_LIST_ENEMY_HEROES ) or GetUnitList( UNIT_LIST_ALLIED_HEROES )
	for _, hero in pairs( heroList )
	do
		if hero ~= nil and hero:IsAlive() and hero:CanBeSeen() and GetUnitToLocationDistance(hero, location) <= distance then
			count = count + 1
		end
	end
	return count
end


function J.GetHeroesNearLocation( bEnemy, location, distance )
	local heroes = { }
	local heroList = bEnemy and GetUnitList( UNIT_LIST_ENEMY_HEROES ) or GetUnitList( UNIT_LIST_ALLIED_HEROES )
	for _, hero in pairs( heroList )
	do
		if hero ~= nil and hero:IsAlive() and hero:CanBeSeen() and GetUnitToLocationDistance(hero, location) <= distance then
			table.insert(heroes, hero)
		end
	end
	return heroes

end


function J.GetAverageLevel( bEnemy )
	local count = 0
	local sum = 0
	local nTeam = GetTeam()
	if bEnemy then nTeam = GetOpposingTeam() end

	-- local cacheKey = 'GetAverageLevel'..tostring(nTeam)
	-- local cache = J.Utils.GetCachedVars(cacheKey, 1)
	-- if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		sum = sum + GetHeroLevel( id )
		count = count + 1
	end

	local res = sum / count

	-- J.Utils.SetCachedVars(cacheKey, res)
	return res

end


function J.GetNumOfTeamTotalKills( bEnemy )

	local count = 0
	local nTeam = GetOpposingTeam()
	if bEnemy then nTeam = GetTeam() end

	-- local cacheKey = 'GetNumOfTeamTotalKills'..tostring(nTeam)
	-- local cache = J.Utils.GetCachedVars(cacheKey, 1)
	-- if cache ~= nil then return cache end

	for i, id in pairs( GetTeamPlayers( nTeam ) )
	do
		count = count + GetHeroDeaths( id )
	end

	-- J.Utils.SetCachedVars(cacheKey, count)
	return count

end


function J.IsEarlyGame()
	if DotaTime() < (J.IsModeTurbo() and 8 * 60 or 15 * 60) then
		return true
	end
	return false
end


function J.IsMidGame()
	if DotaTime() > (J.IsModeTurbo() and 8 * 60 or 15 * 60) and DotaTime() < (J.IsModeTurbo() and 18 * 60 or 30 * 60) then
		return true
	end
	return false
end


function J.IsLateGame()
	if DotaTime() > (J.IsModeTurbo() and 18 * 60 or 30 * 60) then
		return true
	end
	return false
end


function J.ConsiderForMkbDisassembleMask( bot )

	if bot.maskDismantleDone == nil then bot.maskDismantleDone = false end
	if bot.staffUnlockDone == nil then bot.staffUnlockDone = false end
	if bot.lifestealUnlockDone == nil then bot.lifestealUnlockDone = false end
	if bot.dismantleCheckTime == nil then bot.dismantleCheckTime = 600 end

	if bot.staffUnlockDone then return end

	if bot.dismantleCheckTime < DotaTime() + 1.0
	then
		bot.dismantleCheckTime = DotaTime()

		local mask	 = bot:FindItemSlot( "item_mask_of_madness" )
		local claymore = bot:FindItemSlot( "item_claymore" )
		local reaver	= bot:FindItemSlot( "item_reaver" )

		if not bot.maskDismantleDone
			and ( bot:GetItemInSlot( 6 ) == nil or bot:GetItemInSlot( 7 ) == nil or bot:GetItemInSlot( 8 ) == nil )
		then

			if mask >= 0 and mask <= 8
				and ( ( reaver >= 0 and reaver <= 8 ) or ( claymore >= 0 and claymore <= 8 ) )
				and ( bot:GetGold() >= 1400 or bot:GetStashValue() >= 1400 or bot:GetCourierValue() >= 1400 )
			then
				if bDebugMode then print( bot:GetUnitName().." mask Dismantle1" ) end
				bot.maskDismantleDone = true
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot( mask ) )
				return
			end

			if mask >= 0 and mask <= 8
				and claymore >= 0 and reaver >= 0
			then
				if bDebugMode then print( bot:GetUnitName().." mask Dismantle2" ) end
				bot.maskDismantleDone = true
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot( mask ) )
				return
			end
		end

		if not bot.maskDismantleDone then return end

		local lifesteal = bot:FindItemSlot( "item_lifesteal" )
		local staff = bot:FindItemSlot( "item_quarterstaff" )

		if lifesteal >= 0
			and not bot.lifestealUnlockDone
		then
			if bDebugMode then print( bot:GetUnitName().." lifestealUnlockDone" ) end
			bot.lifestealUnlockDone = true
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot( lifesteal ), false )
			return
		end

		local satanic = bot:FindItemSlot( "item_satanic" )

		if satanic >= 0 and staff >= 0 and not bot.staffUnlockDone
		then
			if bDebugMode then print( bot:GetUnitName().." staffUnlockDone" ) end
			bot.staffUnlockDone = true
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot( staff ), false )
			return
		end

	end
end


function J.IsCore(bot)
	return J.GetPosition(bot) <= 3
end


function J.IsPosxHuman(x)
	if PosXHuman[x] ~= nil then return PosXHuman[x] end
	for _, ally in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(ally) and J.GetPosition(ally) == x and not ally:IsBot()
		then
			PosXHuman[x] = true
			return true
		end
	end
	PosXHuman[x] = false
	return false
end


function J.GetCoresTotalNetworth()
	local totalNetworth = GetTeamMember(1):GetNetWorth()
				  	    + GetTeamMember(2):GetNetWorth()
				  		+ GetTeamMember(3):GetNetWorth()
	return totalNetworth
end


-- returns 1, 2, 3, 4, or 5 as the position of the hero in the team
function J.GetPosition(bot)
	if bot.isBear then
		return J.GetPosition(J.Utils.GetLoneDruid(bot).hero)
	end
	local role = J.Role.GetPosition(bot)
	if role == nil then
		-- print('[ERROR] Failed to get role for bot: '..bot:GetUnitName())
		role = 2
	end
	return role
end


function J.GetAliveAllyCoreCount()
	local count = 0
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsCore(allyHero)
		and not allyHero:IsIllusion()
		then
			count = count + 1
		end
	end

	return count
end


-- count the number of human vs bot players in the team. returns: #humen, #bots
function J.NumHumanBotPlayersInTeam()
	local nHuman, nBot = 0, 0
	for _, member in pairs(GetTeamPlayers(GetTeam()))
	do
		if not IsPlayerBot(member)
		then
			nHuman = nHuman + 1
		else
			nBot = nBot + 1
		end
	end

	return nHuman, nBot
end


function J.GetInventoryNetworth()
	local allyInventoryNet = 0
	local enemyInventoryNet = 0
	if math.floor(DotaTime()) % 2 == 0 then
		for i = 1, #GetTeamPlayers( GetTeam() ) do
			local ally = GetTeamMember(i)
			if ally then
				local itemsCost = 0
				for j = 0, 8 do
					local item = ally:GetItemInSlot(j)
					if item then
						itemsCost = itemsCost + GetItemCost(item:GetName())
					end
				end
				local id = ally:GetPlayerID()
				if hAllyTeamList[id] == nil then hAllyTeamList[id] = 0 end
				if hAllyTeamList[id] < itemsCost then
					hAllyTeamList[id] = itemsCost
				end
			end
		end
		for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
			if J.IsValidHero(enemy)
			and not J.IsSuspiciousIllusion(enemy)
			and not enemy:HasModifier('modifier_arc_warden_tempest_double')
			and not string.find(enemy:GetUnitName(), 'lone_druid_bear')
			and not J.IsMeepoClone(enemy)
			then
				local id = enemy:GetPlayerID()
				local itemsCost = 0
				for i = 0, 8 do
					local item = enemy:GetItemInSlot(i)
					if item then
						itemsCost = itemsCost + GetItemCost(item:GetName())
					end
				end
				if hEnemyTeamList[id] == nil then hEnemyTeamList[id] = 0 end
				if hEnemyTeamList[id] < itemsCost then
					hEnemyTeamList[id] = itemsCost
				end
			end
		end
	end
	for _, networth in pairs(hAllyTeamList) do allyInventoryNet = allyInventoryNet + networth end
	for _, networth in pairs(hEnemyTeamList) do enemyInventoryNet = enemyInventoryNet + networth end

	return allyInventoryNet, enemyInventoryNet
end


function J.GetAliveCoreCount(nEnemy)
	-- local cacheKey = 'GetAliveCoreCount'..tostring(GetTeam())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	local count = 0
	if nEnemy then
		for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
		do
			if J.IsValidHero(enemyHero) and not J.IsSuspiciousIllusion(enemyHero) and J.IsCore(enemyHero) then
				count = count + 1
			end
		end
	else
		for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
		do
			if J.IsValidHero(allyHero) and not allyHero:IsIllusion() and J.IsCore(allyHero) then
				count = count + 1
			end
		end
	end

	-- J.Utils.SetCachedVars(cacheKey, count)
	return count
end


function J.GetEnemyCountInLane(lane)
	local count = 0
	local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
	for _, id in pairs( GetTeamPlayers( GetOpposingTeam()))
	do
		if IsHeroAlive(id)
		then
			local info = GetHeroLastSeenInfo(id)

			if info ~= nil
			then
				local dInfo = info[1]

				if dInfo ~= nil
				and J.GetDistance(laneFront, dInfo.location) < 1600
				and dInfo.time_since_seen < 6
				then
					count = count + 1
				end
			end
		end
	end

	return count
end


function J.GetAllyCountInLane(lane, nRadius) -- not including self.
	local count = 0
	local laneFront = GetLaneFrontLocation(GetTeam(), lane, 0)
	for i, id in pairs(GetTeamPlayers(GetTeam()))
	do
		local member = GetTeamMember(i)
		if member:IsAlive()
		and member ~= GetBot()
		and not member:IsIllusion()
		and GetUnitToLocationDistance(member, laneFront) <= nRadius
		then
			count = count + 1
		end
	end
	return count
end

end
