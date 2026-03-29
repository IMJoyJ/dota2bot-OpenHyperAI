-- jmz_func sub-module: jmz_status
return function(J)

local killTime = 0.0



function J.IsStuck2( bot )

	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil
	then
		local EAd = GetUnitToUnitDistance( bot, GetAncient( GetOpposingTeam() ) )
		if DotaTime() > bot.stuckTime + 5.0 and GetUnitToLocationDistance( bot, bot.stuckLoc ) < 25
			and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and EAd > 2200
		then
			print( bot:GetUnitName().." is stuck" )
			--DebugPause()
			return true
		end
	end

	return false

end



function J.IsStuck( bot )

	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil and bot:CanBeSeen()
	then
		local attackTarget = bot:GetAttackTarget()
		local EAd = GetUnitToUnitDistance( bot, GetAncient( GetOpposingTeam() ) )
		local TAd = GetUnitToUnitDistance( bot, GetAncient( GetTeam() ) )
		local Et = bot:GetNearbyTowers( 450, true )
		local At = bot:GetNearbyTowers( 450, false )
		if bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO
			and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0
			and DotaTime() > bot.stuckTime + 5.0
			and GetUnitToLocationDistance( bot, bot.stuckLoc ) < 25
		then
			print( bot:GetUnitName().." is stuck" )
			return true
		end
	end

	return false

end



function J.IsMoving( bot )

	if not bot:IsAlive() then return false end

	local vLocation = bot:GetExtrapolatedLocation( 0.6 )
	if GetUnitToLocationDistance( bot, vLocation ) > bot:GetCurrentMovementSpeed() * 0.45
	then
		return true
	end

	return false

end



function J.IsRunning( bot )

	if not bot:IsAlive() then return false end

	return bot:GetAnimActivity() == ACTIVITY_RUN

end



function J.IsAttacking( bot )

	local nAnimActivity = bot:GetAnimActivity()

	if nAnimActivity ~= ACTIVITY_ATTACK
		and nAnimActivity ~= ACTIVITY_ATTACK2
	then
		return false
	end

	if bot:GetAttackPoint() > bot:GetAnimCycle() * 0.99
	then
		return true
	end

	return false
end



function J.IsChasingTarget( bot, nTarget )

	if J.IsRunning( bot )
		and J.IsRunning( nTarget )
		and bot:IsFacingLocation( nTarget:GetLocation(), 20 )
		and not nTarget:IsFacingLocation( bot:GetLocation(), 150 )
	then
		return true
	end

	return false

end



function J.IsRealInvisible( bot )

	local enemyTowerList = bot:GetNearbyTowers( 880, true )

	if bot:IsInvisible()
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
		and not bot:HasModifier( 'modifier_bloodseeker_thirst_vision' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_sniper_assassinate' )
		and not bot:HasModifier( 'modifier_bounty_hunter_track' )
		and not bot:HasModifier( 'modifier_faceless_void_chronosphere_freeze' )
		and #enemyTowerList == 0
	then
		return true
	end


	return false

end



function J.IsRoshanCloseToChangingSides()
    return DotaTime() % 300 >= 300 - 30
end



function J.GetHP( unit )
	local nCurHealth = unit:GetHealth()
    local nMaxHealth = unit:GetMaxHealth()
	if GetTeam() == unit:GetTeam() then
		nCurHealth = unit:OriginalGetHealth()
		nMaxHealth = unit:OriginalGetMaxHealth()
	end
	if nCurHealth <= 0 then return 0 end
	return nCurHealth / nMaxHealth
end


function J.GetEffectiveHP( bot )
	if not J.IsValid(bot) then return 0 end

	local nCurHealth = bot:GetHealth()
	if nCurHealth <= 0 then return 0 end

	if bot:GetUnitName() == 'npc_dota_hero_medusa'
    then
		local mana = bot:GetMana()
		-- Assuming max level Mana Shield (95% absorption and 2.5 damage absorbed per point of mana)
		local manaAbsorptionRate = 0.95
		local damagePerMana = 2.6
		-- Calculate how much damage her current mana can absorb
		local manaEffectiveHP = mana * damagePerMana * manaAbsorptionRate
		-- Effective HP is her base HP plus the effective HP from her mana shield
		nCurHealth = nCurHealth + manaEffectiveHP
    end

	return nCurHealth
end



function J.GetMP( bot )
	if bot:GetUnitName() == 'npc_dota_hero_huskar' then
		return bot:GetHealth() / bot:GetMaxHealth()
	end
	return bot:GetMana() / bot:GetMaxMana()
end



function J.IsEnemyFacingUnit( bot, nRadius, nDegrees )

	local nLoc = bot:GetLocation()

	if nRadius > 1600 then nRadius = 1600 end
	local nEnemyHeroes = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValid( enemy )
			and enemy:IsFacingLocation( nLoc, nDegrees )
		then
			return true
		end
	end

	return false

end



function J.IsAllyFacingUnit( bot, nRadius, nDegrees )

	local nLoc = bot:GetLocation()
	local numPlayer = GetTeamPlayers( GetTeam() )
	for i = 1, #numPlayer
	do
		local member = GetTeamMember( i )
		if member ~= nil
			and member ~= bot
			and GetUnitToUnitDistance( member, bot ) <= nRadius
			and member:IsFacingLocation( nLoc, nDegrees )
		then
			return true
		end
	end

	return false

end



function J.IsEnemyTargetUnit( nUnit, nRadius )

	if nRadius > 1600 then nRadius = 1600 end
	local nEnemyHeroes = J.GetNearbyHeroes(GetBot(), nRadius, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemyHeroes )
	do
		if J.IsValid( enemy )
			and J.GetProperTarget( enemy ) == nUnit
		then
			return true
		end
	end

	return false

end



function J.IsCastingUltimateAbility( bot )

	if bot:CanBeSeen() and (bot:IsCastingAbility() or bot:IsUsingAbility())
	then
		local nAbility = bot:GetCurrentActiveAbility()
		if nAbility ~= nil
			and nAbility:IsUltimate()
		then
			return true
		end
	end

	return false

end


function J.CountVulnerableUnit(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() then
				count = count + 1;
			end
		end
	end
	return count;
end


function J.CountNotStunnedUnits(tUnits, locAOE, nRadius, nUnits)
	local count = 0;
	if locAOE.count >= nUnits then
		for _,unit in pairs(tUnits)
		do
			if GetUnitToLocationDistance(unit, locAOE.targetloc) <= nRadius and not unit:IsInvulnerable() and not J.IsDisabled(unit) then
				count = count + 1;
			end
		end
	end
	return count;
end


function J.CountInvUnits(pierceImmune, units)
	local nUnits = 0;
	if units ~= nil then
		for _,u in pairs(units) do
			if ( pierceImmune and J.CanCastOnMagicImmune(u) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) )  then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end


function J.GetMostHPPercent(listUnits, magicImmune)
	local mostPHP = 0;
	local mostPHPUnit = nil;
	for _,unit in pairs(listUnits)
	do
		local uPHP = unit:GetHealth() / unit:GetMaxHealth()
		if ( ( magicImmune and J.CanCastOnMagicImmune(unit) ) or ( not magicImmune and J.CanCastOnNonMagicImmune(unit) ) ) 
			and uPHP > mostPHP  
		then
			mostPHPUnit = unit;
			mostPHP = uPHP;
		end
	end
	return mostPHPUnit;
end


function J.IsModeTurbo()
	for _, u in pairs(GetUnitList(UNIT_LIST_ALLIES))
	do
		if u ~= nil
		and u:GetUnitName() == 'npc_dota_courier'
		then
			if u:GetCurrentMovementSpeed() == 1100
			then
				return true
			end
		end
	end

    return false
end


function J.CheckTimeOfDay()
    local cycle = 600
    local time = DotaTime() % cycle
    local night = 300

    if time < night then return "day", time
    else return "night", time
    end
end


function J.IsRoshanAlive()
	if GetRoshanKillTime() > killTime
    then
        killTime = GetRoshanKillTime()
    end

    if GetRoshanKillTime() == 0
	or DotaTime() - killTime > (J.IsModeTurbo() and (6 * 60) or (11 * 60))
    then
        return true
    end

    return false
end


function J.IsUnitTargetedByTower(hUnit, bTeam)
	local nUnitType = (bTeam and UNIT_LIST_ALLIED_BUILDINGS) or UNIT_LIST_ENEMY_BUILDINGS
	local nUnitList = GetUnitList(nUnitType)

	for _, building in pairs(nUnitList) do
		if J.IsValidBuilding(building) and building:GetAttackTarget() == hUnit then
			return true
		end
	end

	return false
end

end
