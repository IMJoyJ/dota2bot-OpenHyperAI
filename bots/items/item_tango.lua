--吃树
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 300 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	--share tango
	local tCharge = hItem:GetCurrentCharges()
	if	bot:GetLevel() <= 12
			and ( #hNearbyEnemyHeroList == 0 or nMode == BOT_MODE_LANING )
			and tCharge >= 1
			and DotaTime() > 10
			and DotaTime() > J.Role['fLastGiveTangoTime'] + 40.0
		then
			local hAllyList = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_NONE )
			for _, npcAlly in pairs( hAllyList )
			do
				if npcAlly ~= bot
				then
					local tangoSlot = npcAlly:FindItemSlot( 'item_tango' )
					if tangoSlot == -1
						and not npcAlly:IsIllusion()
						and npcAlly:OriginalGetMaxHealth() - npcAlly:OriginalGetHealth() > 200
						and not npcAlly:HasModifier( "modifier_tango_heal" )
						and not npcAlly:HasModifier( "modifier_arc_warden_tempest_double" )
						and not J.IsMeepoClone(bot)
						and not J.IsMeepoClone(npcAlly)
						and J.Item.GetItemCount( npcAlly, "item_tango_single" ) == 0
						and J.Item.GetEmptyInventoryAmount( npcAlly ) >= 4
					then
						J.Role['fLastGiveTangoTime'] = DotaTime()
						hEffectTarget = npcAlly
						sCastMotive = '分享队友吃树'
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end
				end
			end
	end

	local hTangoSingle = J.IsItemAvailable( 'item_tango_single' )
	if hTangoSingle ~= nil and hTangoSingle:IsFullyCastable() then return 0 end

	--return X.ConsiderItemDesire["item_tango_single"]( hItem )
	-- [inlined from item_tango_single]

	if bot:DistanceFromFountain() < 3300 or bot:HasModifier( "modifier_tango_heal" ) then return 0 end

	local nCastRange = 300 + aetherRange
	local sCastType = 'tree'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nUseTangoLostHealth = ( hItem:GetName() == 'item_tango' ) and 200 or 160
	local nLostHealth = bot:OriginalGetMaxHealth() - bot:OriginalGetHealth()

	-- 解开先知的树框。bug: 因为先知的树不是正常的树。GetNearbyTrees 不会返回先知的树，此方式行不通
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
	
	if J.IsWithoutTarget( bot )
		and not bot:HasModifier( "modifier_flask_healing" )
		and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
	then
		local trees = bot:GetNearbyTrees( 800 )
		local targetTree = trees[1]
		local nearEnemyList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
		local nearestEnemy = nearEnemyList[1]
		local nearTowerList = bot:GetNearbyTowers( 1400, true )
		local nearestTower = nearTowerList[1]


		--常规吃树
		if targetTree ~= nil
		then
			local targetTreeLoc = GetTreeLocation( targetTree )
			if nLostHealth > nUseTangoLostHealth
				and IsLocationVisible( targetTreeLoc )
				and IsLocationPassable( targetTreeLoc )
				and ( #nearEnemyList == 0 or not J.IsInRange( bot, nearestEnemy, 800 ) )
				and ( #nearEnemyList == 0 or GetUnitToLocationDistance( bot, targetTreeLoc ) * 1.6 < GetUnitToUnitDistance( bot, nearestEnemy ) )
				and ( #nearTowerList == 0 or GetUnitToLocationDistance( nearestTower, targetTreeLoc ) > 920 )
			then
				hEffectTarget = targetTree
				sCastMotive = '800码内的树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end


		--塔下吃树
		local nAllyTowerList = bot:GetNearbyTowers( 1100, false )
		if #nAllyTowerList >= 1
			and nLostHealth > nUseTangoLostHealth + 20
		then
			local nAllyTower = nAllyTowerList[1]
			if nAllyTower ~= nil
			then
				local nFindTreeDistance = 1100 - GetUnitToUnitDistance( bot, nAllyTower )
				local nearTowerTrees = bot:GetNearbyTrees( nFindTreeDistance )
				local targetTree = nearTowerTrees[1]

				if targetTree ~= nil
				then
					local targetTreeLoc = GetTreeLocation( targetTree )
					if IsLocationVisible( targetTreeLoc )
						and IsLocationPassable( targetTreeLoc )
					then
						hEffectTarget = targetTree
						sCastMotive = '吃塔下的树'
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end
				end
			end
		end


		--吃近处的树
		local nearbyTrees = bot:GetNearbyTrees( 280 )
		if nearbyTrees[1] ~= nil
			and IsLocationVisible( GetTreeLocation( nearbyTrees[1] ) )
			and IsLocationPassable( GetTreeLocation( nearbyTrees[1] ) )
		then
			if nLostHealth > nUseTangoLostHealth
			then
				hEffectTarget = nearbyTrees[1]
				sCastMotive = '近处的树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if nLostHealth > nUseTangoLostHealth * 0.38
				and bot:WasRecentlyDamagedByAnyHero( 2.0 )
				and ( bot:GetActiveMode() == BOT_MODE_ATTACK
					 or ( bot:GetActiveMode() == BOT_MODE_RETREAT
						 and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH ) )
			then
				hEffectTarget = nearbyTrees[1]
				sCastMotive = '提前吃树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if DotaTime() > 4 * 60 + 30 and botTarget == nil
		and hItem:GetName() == 'item_tango_single'
		and bot:DistanceFromFountain() > 3000
		and nMode ~= BOT_MODE_RUNE
	then
		local tCount = J.Item.GetItemCount( bot, "item_tango_single" )
		local hNearbyEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		if tCount >= 2
		then
			local trees = bot:GetNearbyTrees( 1200 )
			if trees[1] ~= nil
				and IsLocationVisible( GetTreeLocation( trees[1] ) )
				and IsLocationPassable( GetTreeLocation( trees[1] ) )
				and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = trees[1]
				sCastMotive = '消耗共享吃树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		if DotaTime() > 7 * 60 + 30
		then
			local trees = bot:GetNearbyTrees( 1200 )
			if trees[1] ~= nil
				and IsLocationVisible( GetTreeLocation( trees[1] ) )
				and IsLocationPassable( GetTreeLocation( trees[1] ) )
				and nLostHealth > 60
				and #hNearbyEnemyHeroList == 0
			then
				hEffectTarget = trees[1]
				sCastMotive = '用掉共享吃树'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end

	return BOT_ACTION_DESIRE_NONE


end

return X
