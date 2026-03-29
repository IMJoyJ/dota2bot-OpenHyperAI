-- Shared utility functions for item modules
-- These functions were originally part of ability_item_usage_generic.lua
-- and are used by multiple item files.

local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Common = {}


function Common.IsWithoutSpellShield( npcEnemy )

	return not npcEnemy:HasModifier( "modifier_item_sphere_target" )
			and not npcEnemy:HasModifier( "modifier_antimage_spell_shield" )
			and not npcEnemy:HasModifier( "modifier_item_lotus_orb_active" )

end


function Common.IsInvFull( bot )

	for i = 0, 8
	do
		if bot:GetItemInSlot( i ) == nil
		then
			return false
		end
	end

	return true

end


function Common.GetNumStashItem( unit )

	local amount = 0
	for i = 9, 14
	do
		if unit:GetItemInSlot( i ) ~= nil
		then
			amount = amount + 1
		end
	end

	return amount

end


function Common.IsThereRecipeInStash( unit )
	local amount = 0

	for i = 9, 14
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil
		then
			if string.find(item:GetName(), "item_recipe_")
			then
				amount = amount + 1
			end
		end
	end

	return amount > 0
end


function Common.GetLaningTPLocation( bot, nMinTPDistance, botLocation )

	-- overridding for mid only modes
	if GetGameMode() == GAMEMODE_1V1MID or GetGameMode() == GAMEMODE_MO then
		return nil, false
	end

	local team = GetTeam()
	local laneToTP
	local tp = false
	local position = J.GetPosition(bot)

	if team == TEAM_RADIANT then
		if position == 1 then
			laneToTP = LANE_BOT
		elseif position == 2 then
			laneToTP = LANE_MID
		elseif position == 3 or position == 4 then
			laneToTP = LANE_TOP
		elseif position == 5 then
			laneToTP = LANE_BOT
		end
	elseif team == TEAM_DIRE then
		if position == 1 then
			laneToTP = LANE_TOP
		elseif position == 2 then
			laneToTP = LANE_MID
		elseif position == 3 or position == 4 then
			laneToTP = LANE_BOT
		elseif position == 5 then
			laneToTP = LANE_TOP
		end
	end

	local botAmount = GetAmountAlongLane(laneToTP, botLocation)
	local laneFront = GetLaneFrontAmount(team, laneToTP, false)
	if botAmount.distance > nMinTPDistance
	or botAmount.amount < laneFront / 5
	then
		tp = true
	end

	return GetLaneFrontLocation(team, laneToTP, 100), tp
end


function Common.GetDefendTPLocation( nLane )

	local team = GetTeam()
	return GetLaneFrontLocation( team, nLane, -950 )

end


function Common.GetPushTPLocation( nLane )

	local team = GetTeam()
	local laneFront = GetLaneFrontLocation( team, nLane, 0 )
	local bestTpLoc = J.GetNearbyLocationToTp( laneFront )
	if J.GetLocationToLocationDistance( laneFront, bestTpLoc ) < 2000
	then
		return bestTpLoc
	end

end


function Common.CanJuke( bot )

	local allyTowers = bot:GetNearbyTowers( 350, false )

	if allyTowers[1] ~= nil
		and allyTowers[1]:DistanceFromFountain() > bot:DistanceFromFountain() + 100
		and J.GetEnemyCount( bot, 700 ) == 0
	then return true end

	if J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 3.0
		or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 3.0
	then return true end

	local enemyPids = GetTeamPlayers( GetOpposingTeam() )

	local heroHG = GetHeightLevel( bot:GetLocation() )
	for i = 1, #enemyPids
	do
		local info = GetHeroLastSeenInfo( enemyPids[i] )
		if info ~= nil then
			local dInfo = info[1]
			if dInfo ~= nil
				and dInfo.time_since_seen < 2.0
			then
				if GetUnitToLocationDistance( bot, dInfo.location ) < 1300
					and GetHeightLevel( dInfo.location ) < heroHG
				then
					return false
				end

				if GetUnitToLocationDistance( bot, dInfo.location ) < 600
				then
					local hNearbyEnemyHeroList = J.GetNearbyHeroes(bot, 600, true, BOT_MODE_NONE )
					if #hNearbyEnemyHeroList == 0
					then
						return false
					end
				end
			end
		end
	end

	local totalDamage = 0
	local nEnemies = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemies )
	do
		local enemyDamage = enemy:GetEstimatedDamageToTarget( true, bot, 4.0, DAMAGE_TYPE_ALL )
		totalDamage = totalDamage + enemyDamage
		if bot:OriginalGetHealth() <= totalDamage
		then
			return false
		end
	end

	return true

end


function Common.GetNumHeroWithinRange( bot, nRange )

	local enemyPids = GetTeamPlayers( GetOpposingTeam() )

	local cHeroes = 0
	for i = 1, #enemyPids
	do
		local info = GetHeroLastSeenInfo( enemyPids[i] )
		if info ~= nil then
			local dInfo = info[1]
			if dInfo ~= nil and dInfo.time_since_seen < 2.0
				and GetUnitToLocationDistance( bot, dInfo.location ) < nRange
			then
				cHeroes = cHeroes + 1
			end
		end
	end

	return cHeroes

end


function Common.GetNumEnemyNearby( building )

	local nearbynum = 0
	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil
			then
				local dInfo = info[1]
				if dInfo ~= nil
					and GetUnitToLocationDistance( building, dInfo.location ) <= 3000
					and dInfo.time_since_seen < 1.0
				then
					nearbynum = nearbynum + 1
				end
			end
		end
	end

	return nearbynum

end


function Common.IsFarmingAlways( bot )

	local team = GetTeam()
	local botName = bot:GetUnitName()

	local nTarget = bot:GetAttackTarget()
	if J.IsValid( nTarget )
		and nTarget:GetTeam() == TEAM_NEUTRAL
		and not J.IsRoshan( nTarget )
		and not J.IsKeyWordUnit( "warlock", nTarget )
		and Common.GetNumEnemyNearby( GetAncient( team ) ) >= 2
	then
		return true
	end

	local nNearAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )
	if J.IsValid( nTarget )
		and nTarget:IsAncientCreep()
		and not J.IsRoshan( nTarget )
		and not J.IsKeyWordUnit( "warlock", nTarget )
		and bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
		and botName ~= 'npc_dota_hero_ogre_magi'
		and #nNearAllyList < 2
	then
		return true
	end

	if Common.GetNumEnemyNearby( GetAncient( team ) ) >= 4
		and bot:DistanceFromFountain() >= 4800
		and #nNearAllyList < 2
	then
		return true
	end

	return false
end


function Common.IsBaseTowerDestroyed()

	local team = GetTeam()
	for i = 9, 10, 1
	do
		local tower = GetTower( team, i )
		if tower == nil
			or tower:GetHealth() / tower:GetMaxHealth() < 0.99
		then
			return true
		end
	end

	return false

end


return Common
