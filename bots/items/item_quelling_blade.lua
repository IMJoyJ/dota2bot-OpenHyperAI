local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 450 + aetherRange
	local sCastType = 'tree'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )
	
	-- 解开先知的树框
	if bot:HasModifier('modifier_furion_sprout_damage') then
		local nearbyTrees = bot:GetNearbyTrees( 280 )
		if nearbyTrees ~= nil and #nearbyTrees >= 8
			and IsLocationVisible( GetTreeLocation( nearbyTrees[1] ) )
			and IsLocationPassable( GetTreeLocation( nearbyTrees[1] ) )
		then
			hEffectTarget = nearbyTrees[1]
			sCastMotive = '吃先知的树'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if DotaTime() < 0 and not thereBeMonkey
	then
		for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
		do
			if GetSelectedHeroName( id ) == 'npc_dota_hero_monkey_king'
			then
				thereBeMonkey = true
			end
		end
	end

	if thereBeMonkey
	then
		local theMonkeyKing = nil
		for _, enemy in pairs( hNearbyEnemyHeroList )
		do
			if enemy:IsAlive()
				and enemy:GetUnitName() == "npc_dota_hero_monkey_king"
			then
				theMonkeyKing = enemy
				break
			end
		end

		if theMonkeyKing ~= nil
			and J.IsInRange( bot, theMonkeyKing, nCastRange )
		then
			local nTrees = bot:GetNearbyTrees( nCastRange )
			for _, tree in pairs( nTrees )
			do
				local treeLoc = GetTreeLocation( tree )
				if GetUnitToLocationDistance( theMonkeyKing, treeLoc ) < 30
				then
					sCastMotive = '砍大圣的树'
					return BOT_ACTION_DESIRE_HIGH, tree, sCastType, sCastMotive
				end
			end
		end
	end

	--开视野
	if DotaTime() > lastQuellingBladeUseTime + 0.8
		and ( J.IsGoingOnSomeone( bot ) or J.IsFarming( bot ) or J.IsRetreating( bot ) )
	then
		lastQuellingBladeUseTime = DotaTime()

		local nBladeRange = 350
		local nTrees = bot:GetNearbyTrees( nBladeRange )
		local nTreeCount = #nTrees
		if nTreeCount >= 1
		then
			for treeID = 1, nTreeCount
			do
				local tree = nTrees[treeID]
				if bot:IsFacingLocation( GetTreeLocation( tree ), 7 )
				then
					sCastMotive = '开视野'
					return BOT_ACTION_DESIRE_HIGH, tree, sCastType, sCastMotive
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
