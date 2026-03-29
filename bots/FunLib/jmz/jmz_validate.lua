-- jmz_func sub-module: jmz_validate
return function(J)


function J.IsTier1(tower)
	local nTower = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
	}

	for i = 1, #nTower do if GetTower( GetTeam(), nTower[i] ) == tower then return true end end

	return false
end


function J.IsTier2(tower)
	local nTower = {
		TOWER_TOP_2,
		TOWER_MID_2,
		TOWER_BOT_2,
	}

	for i = 1, #nTower do if GetTower( GetTeam(), nTower[i] ) == tower then return true end end

	return false
end


function J.IsTier3p(tower)
	local nTower = {
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2,
	}

	for i = 1, #nTower do if GetTower( GetTeam(), nTower[i] ) == tower then return true end end

	return false
end


function J.IsKeyWordUnit( keyWord, uUnit )

	if string.find( uUnit:GetUnitName(), keyWord ) ~= nil
	then
		return true
	end

	return false
end



function J.IsHumanPlayer( nUnit )

	return not nUnit:IsBot() -- or IsPlayerBot( nUnit:GetPlayerID() )

end



function J.IsValid( nTarget )
	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and not nTarget:IsBuilding()
end


function J.IsValidTarget(nTarget)
	-- NOTE: return J.Utils.IsValidUnit(nTarget) -- ideally it should be IsValidUnit, but a lot of legacy usage causing some problems.
	return J.Utils.IsValidHero(nTarget)
end


function J.IsValidHero( nTarget )
	return J.Utils.IsValidHero(nTarget)
end


function J.IsValidBuilding( nTarget )
	return J.Utils.IsValidBuilding(nTarget)
end


function J.IsRoshan( nTarget )

	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and string.find( nTarget:GetUnitName(), "roshan" ) ~= nil

end


function J.IsNotSelf(bot, ally)
	if bot:GetUnitName() ~= ally:GetUnitName()
	then
		return true
	end

	return false
end


function J.IsTormentor(nTarget)
	return nTarget ~= nil
			and not nTarget:IsNull()
			and nTarget:CanBeSeen()
			and nTarget:IsAlive()
			and string.find(nTarget:GetUnitName(), 'miniboss') ~= nil
end


function J.IsEnemyHero(hero)
	if hero ~= nil
	and hero:GetTeam() ~= GetBot():GetTeam()
	then
		return true
	else
		return false
	end
end

end
