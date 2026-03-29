-- jmz_func sub-module: jmz_mode
return function(J)


function J.IsRetreating( bot )

	local mode = bot:GetActiveMode()
	local modeDesire = bot:GetActiveModeDesire()
	local bDamagedByAnyHero = bot:WasRecentlyDamagedByAnyHero( 2.0 )

	return ( mode == BOT_MODE_RETREAT and modeDesire > BOT_MODE_DESIRE_MODERATE and bot:DistanceFromFountain() > 0 )
		 or ( mode == BOT_MODE_EVASIVE_MANEUVERS and bDamagedByAnyHero )
		 or ( bot:HasModifier( 'modifier_bloodseeker_rupture' ) and bDamagedByAnyHero )
		 or ( mode == BOT_MODE_FARM and modeDesire > BOT_MODE_DESIRE_ABSOLUTE )
		
end



function J.IsGoingOnSomeone( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_ROAM
		or mode == BOT_MODE_TEAM_ROAM
		or mode == BOT_MODE_GANK
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY

end


function J.IsDefending( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT

end


function J.IsAnyAllyDefending(bot, lane)
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsNotSelf(bot, allyHero)
		then
			local mode = allyHero:GetActiveMode()
			if (mode == BOT_MODE_DEFEND_TOWER_TOP and lane == LANE_TOP)
			or (mode == BOT_MODE_DEFEND_TOWER_MID and lane == LANE_MID)
			or (mode == BOT_MODE_DEFEND_TOWER_BOT and lane == LANE_BOT)
			then
				return true
			end
		end
	end
	return false
end


function J.IsPushing( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_PUSH_TOWER_TOP
		or mode == BOT_MODE_PUSH_TOWER_MID
		or mode == BOT_MODE_PUSH_TOWER_BOT

end


function J.MultipleAlliesArePushing()
	local pushingAlly = 0
	for i, id in pairs( GetTeamPlayers( GetTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local member = GetTeamMember( i )
			if J.IsValidHero(member) and J.IsPushing( member ) then
				pushingAlly = pushingAlly + 1
			end
		end
	end
	return pushingAlly >= 2
end


function J.IsLaning( bot )
	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_LANING

end


function J.IsDoingRoshan( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_ROSHAN

end



function J.IsFarming( bot )

	local mode = bot:GetActiveMode()
	local nTarget = J.GetProperTarget( bot )

	return mode == BOT_MODE_FARM
			or ( nTarget ~= nil
					and nTarget:IsAlive()
					and nTarget:GetTeam() == TEAM_NEUTRAL
					and not J.IsRoshan( nTarget ) )
end



function J.IsShopping( bot )

	local mode = bot:GetActiveMode()

	return mode == BOT_MODE_RUNE
		or mode == BOT_MODE_SECRET_SHOP
		or mode == BOT_MODE_SIDE_SHOP

end


function J.ShouldGoFarmDuringLaning(bot)
	-- laning is too hard for the bot, try go farming somewhere else.
	local lane = bot:GetAssignedLane()
	return J.IsInLaningPhase()
	and GetHeroDeaths(bot:GetPlayerID()) >= 4
	and (GetHeroKills(bot:GetPlayerID()) == 0 or GetHeroKills(bot:GetPlayerID()) / GetHeroDeaths(bot:GetPlayerID()) < 0.5)
	and J.IsCore(bot)
	and bot:GetLevel() >= 4
	and bot:GetLevel() < 10
	and J.GetEnemyCountInLane(lane) >= 1
end


function J.IsInLaningPhase()
	return (
		(J.IsModeTurbo() and DotaTime() < 8 * 60)
		or DotaTime() < 12 * 60
	)
	and GetBot():GetNetWorth() < 5000
end


function J.IsDoingTormentor(bot)
	return bot:GetActiveMode() == BOT_MODE_SIDE_SHOP
end

end
