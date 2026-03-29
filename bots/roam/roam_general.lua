-- mode_roam sub-module: general roaming logic and utilities
return function(bot, J, S, recordAction)

local Customize = require( GetScriptDirectory()..'/Customize/general' )
local botName = bot:GetUnitName()
local MoveOutsideFountainDistance = 1500
local TwinGates = J.Utils.GameStates.twinGates
local gateWarp = bot:GetAbilityByName("twin_gate_portal_warp")
local enableGateUsage = false
local gankDecisionHoldTime = 1.5 * 60
local gankTimeAfterArrival = 0.55 * 60
local gankGapTime = 6 * 60
local laneAndT1s = {
	{LANE_TOP, TOWER_TOP_1},
	{LANE_MID, TOWER_MID_1},
	{LANE_BOT, TOWER_BOT_1}
}

function ThinkGeneralRoaming()
	-- Get out of fountain if in item mode
	if S.ShouldMoveOutsideFountain
	then
		bot:Action_AttackMove(J.Utils.GetOffsetLocationTowardsTargetLocation(J.GetTeamFountain(), J.GetEnemyFountain(), MoveOutsideFountainDistance))
		return
	end

	if S.shouldGoBackToFountain then
		if bot:HasModifier('modifier_fountain_aura_buff')
		   or (J.GetHP(bot) > 0.8 and J.GetMP(bot) > 0.7) then
			S.shouldGoBackToFountain = false
		end
	end

	if S.AnyUnitAffectedByChainFrost then
		J.Utils.SmartSpreadOut(bot, S.nChainFrostBounceDistance, S.nChainFrostBounceDistance, S.nInRangeEnemy, false)
		return
	end

	if S.HasPossibleWallOfReplicaAround then
		J.Utils.MoveBotSafely(bot)
		return
	end

	if S.ShouldBotsSpreadOut then
		J.Utils.SmartSpreadOut(bot, 450, 450, S.nInRangeEnemy, false)
		return
	end

	if bot:GetActiveMode() == BOT_MODE_ITEM
	and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH
	and (botName == 'npc_dota_hero_lone_druid_bear' or bot:HasModifier('modifier_arc_warden_tempest_double') or J.IsMeepoClone(bot))
	then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_item_mask_of_madness_berserk") then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValid(S.botTarget) then
			if GetUnitToUnitDistance(bot, S.botTarget) > bot:GetAttackRange() + 200
			then
				bot:Action_MoveToLocation(S.botTarget:GetLocation())
				return
			else
				bot:Action_AttackUnit(S.botTarget, false)
				return
			end
		end
	end

	if J.GetModifierTime(bot, "modifier_flask_healing") >= 1 then
		if #bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE) >= 1 and J.GetHP(bot) < 0.8 then
			bot:Action_MoveToLocation(J.GetTeamFountain())
			return
		end
	end

	if bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") or bot:HasModifier("modifier_item_helm_of_the_undying_active") then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValid(S.botTarget) then
			if GetUnitToUnitDistance(bot, S.botTarget) > bot:GetAttackRange() + 200
			then
				bot:Action_MoveToLocation(S.botTarget:GetLocation())
				return
			else
				bot:Action_AttackUnit(S.botTarget, false)
				return
			end
		end
	end

	if bot:HasModifier("modifier_nevermore_shadowraze_debuff") then
		MoveAwayFromTarget(GetTargetEnemy("npc_dota_hero_nevermore"), 1350)
		return
	end

	if bot:HasModifier("modifier_razor_static_link_debuff") then
		MoveAwayFromTarget(GetTargetEnemy("npc_dota_hero_razor"), 1200)
		return
	end

	if bot:HasModifier("modifier_primal_beast_trample") then
		MoveAwayFromTarget(GetTargetEnemy("npc_dota_hero_primal_beast"), 1200)
		return
	end

	if botName == 'npc_dota_hero_lone_druid' then
		if J.GetHP(bot) < 0.65 or J.GetMP(bot) < 0.35 then
			bot:Action_MoveToLocation(J.GetTeamFountain()); return
		end
	end

	if bot:HasModifier("modifier_ursa_fury_swipes_damage_increase") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_monkey_king_quadruple_tap_counter") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_slark_essence_shift_debuff_counter") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_silencer_glaives_of_wisdom_debuff_counter") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_dazzle_poison_touch") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_maledict") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_viper_poison_attack_slow") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if J.GetModifierCount(bot, "modifier_huskar_burning_spear_debuff") >= 3 then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if J.GetModifierCount(bot, "modifier_batrider_sticky_napalm") >= 3 then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if bot:HasModifier("modifier_undying_tombstone_zombie_deathstrike_slow") then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if J.GetModifierCount(bot, "modifier_bristleback_quill_spray") >= 3 then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if S.trySeduce then
		S.allyTowers = bot:GetNearbyTowers(1600, false)
		if S.allyTowers[1] then
			local distanceFromFountain = GetUnitToLocationDistance(bot, J.GetTeamFountain())
			local towerFromFountain = GetUnitToLocationDistance(S.allyTowers[1], J.GetTeamFountain())
			local distanceToTower = GetUnitToUnitDistance(bot, S.allyTowers[1])
			if distanceFromFountain > towerFromFountain and distanceToTower > 300 then
				bot:Action_MoveToLocation(S.allyTowers[1]:GetLocation() + RandomVector(150))
			else
				bot:Action_MoveToLocation(J.GetTeamFountain())
			end
			return
		end
	end

	if S.shouldTempRetreat then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	if S.shouldGoBackToFountain then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end
end

function GeneralReactToStackedDebuff(enemyHeroName)
	local enemy = GetTargetEnemy(enemyHeroName)
	if enemy ~= nil then -- nil check is enough here
		if J.GetHP(bot) > 0.6 and not J.Utils.NumActionTypeInQueue(BOT_ACTION_TYPE_ATTACK) <= 2 then
			bot:ActionImmediate_Ping(enemy:GetLocation().x, enemy:GetLocation().y, true)
			recordAction("attack", enemy)
			bot:ActionQueue_AttackUnit(enemy, false)
		else
			local fountainLoc = J.GetTeamFountain()
			recordAction("move", fountainLoc)
			bot:Action_MoveToLocation(fountainLoc)
		end
	end
end

function MoveAwayFromTarget(target, keepDistance)
	if J.IsValidHero(target) and GetUnitToUnitDistance(bot, target) < keepDistance then
		if GetUnitToLocationDistance(target, J.GetTeamFountain()) > GetUnitToLocationDistance(bot, J.GetTeamFountain()) then
			bot:Action_MoveToLocation(J.GetTeamFountain())
		else
			bot:Action_MoveToLocation(J.Utils.GetOffsetLocationTowardsTargetLocation(target:GetLocation(), bot:GetLocation(), keepDistance * 2))
		end
	end
end

function ActualGankDesire()
	SetupTwinGates()

	if J.IsInLaningPhase()
	and not bot:WasRecentlyDamagedByAnyHero(2)
	and (S.botTarget == nil or #S.nInRangeEnemy <= 0 or S.nInRangeEnemy[1] ~= S.botTarget) then
		local botLvl = bot:GetLevel()
		if (J.GetPosition(bot) == 2 and botLvl >= 6 and J.GetHP(bot) > 0.7 and J.GetMP(bot) > 0.5) -- mid player roaming
		or (J.GetPosition(bot) > 3 and botLvl > 3 and J.GetHP(bot) > 0.6 and J.GetMP(bot) > 0.5) -- supports roaming
		then
			return CheckLaneToGank(J.GetPosition(bot))
		end
	end
	return BOT_MODE_DESIRE_NONE
end

function SetupTwinGates()
	if #TwinGates == 0 then
		for _, unit in pairs(GetUnitList(UNIT_LIST_ALL))
		do
			local name = unit:GetUnitName()
			if name == 'npc_dota_unit_twin_gate'
			then
				table.insert(TwinGates, unit)
				print("Twin gate: " .. name .. ". " .. tostring(unit:GetLocation()))
			end
			if #TwinGates >= 2 then
				break
			end
		end
	end
end

function ThinkActualGankingInLanes()
	if S.laneToGank ~= nil then
		local targetLoc = GetLaneFrontLocation(GetTeam(), S.laneToGank, -300)
		local distanceToGankLoc = GetUnitToLocationDistance(bot, targetLoc)
		if distanceToGankLoc > 5000 then
			if J.GetPosition(bot) > 3
			and S.targetGate ~= nil
			and enableGateUsage
			then
				print('Trying to use gate '..botName)
				local distanceToGate = GetUnitToUnitDistance(bot, S.targetGate)
				if distanceToGate > 350 then
					bot:Action_MoveToLocation(S.targetGate:GetLocation())
					return
				elseif gateWarp:IsFullyCastable()
				then
					bot:Action_UseAbilityOnEntity(gateWarp, S.targetGate)
					return
				end
			end
		end

		if distanceToGankLoc > bot:GetAttackRange() + 300 and bot:WasRecentlyDamagedByAnyHero(1.5) then
			bot:Action_MoveToLocation(targetLoc)
		end
		if distanceToGankLoc < 600 and DotaTime() - S.arriveGankLocTime > gankTimeAfterArrival * 1.1 then
			S.arriveGankLocTime = DotaTime()
		end
		if DotaTime() - S.arriveGankLocTime > gankTimeAfterArrival then
			S.laneToGank = nil
		end
	end
end

function CheckLaneToGank(botPosition)

	if #J.GetEnemiesNearLoc(bot:GetLocation(), 800) > 0 then
		return BOT_MODE_DESIRE_NONE
	end

	if DotaTime() - S.lastGankDecisionTime <= gankDecisionHoldTime and S.laneToGank ~= nil then
		return BOT_ACTION_DESIRE_VERYHIGH
	end

	local botLvlTooLow = (J.GetPosition(bot) == 1 and botLevel < 6) or
		(J.GetPosition(bot) == 2 and botLevel < 6) or
		(J.GetPosition(bot) == 3 and botLevel < 5) or
		(J.GetPosition(bot) == 4 and botLevel < 4) or
		(J.GetPosition(bot) == 5 and botLevel < 4)

	if J.IsInLaningPhase()
		and ((DotaTime() - S.lastGankDecisionTime < gankGapTime and S.lastGankDecisionTime ~= 0)
			or botLvlTooLow) then
		return BOT_MODE_DESIRE_NONE
	end

	if not HasSufficientMana(300) then -- idelaly should have mana at least able to use 2 abilities + tp.
		return BOT_MODE_DESIRE_NONE
	end
	for _, lane in pairs(laneAndT1s)
	do
		local enemyCountInLane = J.GetEnemyCountInLane(lane[1])
		if enemyCountInLane > 0
		then
			local tTower = GetTower(GetTeam(), lane[2])
			if tTower ~= nil then
				local laneFront = GetLaneFrontLocation(GetTeam(), lane[1], 0)
				local laneFrontToT1Dist = GetUnitToLocationDistance(tTower, laneFront)
				local nInRangeAlly = J.GetAlliesNearLoc(laneFront, 1200)

				if enableGateUsage
				and laneFrontToT1Dist < 800
				then
					S.targetGate = GetGateNearLane(laneFront)
					if enemyCountInLane >= #S.nInRangeAlly
					then
						S.laneToGank = lane[1]
						return RemapValClamped(GetUnitToUnitDistance(bot, S.targetGate), 5000, 600, BOT_ACTION_DESIRE_HIGH, BOT_ACTION_DESIRE_ABSOLUTE )
					end
				end

				if enemyCountInLane >= 1 then
					S.laneToGank = lane[1]
					return RemapValClamped(laneFrontToT1Dist, 5000, 600, BOT_ACTION_DESIRE_HIGH, BOT_ACTION_DESIRE_ABSOLUTE * 0.96 )
				end
			end

		end
	end

	return BOT_MODE_DESIRE_NONE
end

function HasSufficientMana(nMana)
	return bot:GetMana() > nMana and botName ~= 'npc_dota_hero_huskar'
end

function GetGateNearLane(laneLoc)
	local minDis = 99999
	local tGate
	for _, gate in pairs(TwinGates)
	do
		local distanceToGate = GetUnitToLocationDistance(gate, laneLoc)
		if distanceToGate < minDis then
			tGate = gate
			minDis = distanceToGate
		end
	end
	return tGate
end


function TinkerWaitInBaseAndHeal()
	if botName == 'npc_dota_hero_tinker'
	and bot.healInBase
	and GetUnitToLocationDistance(bot, J.GetTeamFountain()) < 500
	then
		return true
	end

	return false
end

function ConsiderUseTango()
	if bot:HasModifier('modifier_tango_heal') then return BOT_ACTION_DESIRE_NONE, nil end

	S.tangoDesire = 0
	S.tangoSlot = J.FindItemSlotNotInNonbackpack(bot, "item_tango")
	if S.tangoSlot < 0 then
		S.tangoSlot = J.FindItemSlotNotInNonbackpack(bot, "item_tango_single")
	end
	if S.tangoSlot >= 0
	and bot:OriginalGetMaxHealth() - bot:OriginalGetHealth() > 250
	and J.GetHP(bot) < 0.6
	and not J.IsAttacking(bot)
	and not bot:WasRecentlyDamagedByAnyHero(2) then
		local trees = bot:GetNearbyTrees( 800 )
		local targetTree = trees[1]
		local nearEnemyList = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
		local nearestEnemy = nearEnemyList[1]
		local nearTowerList = bot:GetNearbyTowers( 1400, true )
		local nearestTower = nearTowerList[1]
		if targetTree ~= nil
		then
			local targetTreeLoc = GetTreeLocation( targetTree )
			if IsLocationVisible( targetTreeLoc )
				and IsLocationPassable( targetTreeLoc )
				-- and ( #nearEnemyList == 0 or not J.IsInRange( bot, nearestEnemy, 800 ) )
				and ( #nearEnemyList == 0 or GetUnitToLocationDistance( bot, targetTreeLoc ) * 1.6 < GetUnitToUnitDistance( bot, nearestEnemy ) )
				and ( #nearTowerList == 0 or GetUnitToLocationDistance( nearestTower, targetTreeLoc ) > 920 )
			then
				return BOT_ACTION_DESIRE_HIGH, targetTree
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE
end

-- Just for TP. Too much back and forth when "forcing" them try to walk to fountain; <- not reliable and misses farm.
function ConsiderWaitInBaseToHeal()
	local ProphetTP = nil
	if botName == 'npc_dota_hero_furion'
	then
		ProphetTP = bot:GetAbilityByName('furion_teleportation')
	end

	if not J.IsInLaningPhase()
	and not (J.IsFarming(bot) and J.IsAttacking(bot))
	and S.nInRangeEnemy ~= nil and #S.nInRangeEnemy == 0
	and GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam())) > 2400
	and (  (S.TPScroll ~= nil and S.TPScroll:IsFullyCastable())
		or (ProphetTP ~= nil and ProphetTP:IsTrained() and ProphetTP:IsFullyCastable()))
	then
		if (J.GetHP(bot) < 0.25
			and bot:GetHealthRegen() < 15
			and botName ~= 'npc_dota_hero_huskar'
			and botName ~= 'npc_dota_hero_slark'
			and botName ~= 'npc_dota_hero_necrolyte'
			and not bot:HasModifier('modifier_tango_heal')
			and not bot:HasModifier('modifier_flask_healing')
			and not bot:HasModifier('modifier_alchemist_chemical_rage')
			and not bot:HasModifier('modifier_arc_warden_tempest_double')
			and not bot:HasModifier('modifier_juggernaut_healing_ward_heal')
			and not bot:HasModifier('modifier_oracle_purifying_flames')
			and not bot:HasModifier('modifier_warlock_fatal_bonds')
			and not bot:HasModifier('modifier_item_satanic_unholy')
			and not bot:HasModifier('modifier_item_spirit_vessel_heal')
			and not bot:HasModifier('modifier_item_urn_heal'))
		or (((J.IsCore(bot) and J.GetMP(bot) < 0.25 and (J.GetHP(bot) < 0.75 and bot:GetHealthRegen() < 10))
				or ((not J.IsCore(bot) and J.GetMP(bot) < 0.25 and bot:GetHealthRegen() < 10)))
			and botName ~= 'npc_dota_hero_necrolyte'
			and not (J.IsPushing(bot) and #J.GetAlliesNearLoc(bot:GetLocation(), 900) >= 3))
		then
			S.ShouldWaitInBaseToHeal = true
			return true
		end
	end

	return false
end

function CanBeAffectedByChainFrost()
	if bot:HasModifier("modifier_black_king_bar_immune") or bot:IsMagicImmune() then
		return false
	end
	local searchRange = S.nChainFrostBounceDistance
	if J.HasEnemyIceSpireNearby(bot, searchRange) then return true end
	if bot:HasModifier('modifier_lich_chainfrost_slow') then
		local allyCreeps = bot:GetNearbyCreeps(searchRange, false)
		if #allyCreeps > 0 then return true end
		local allyHeores = bot:GetNearbyHeroes(searchRange, false, BOT_MODE_NONE)
		if #allyHeores > 1 then return true end
	end
	return J.AnyAllyAffectedByChainFrost(bot, searchRange)
end

function ConsiderGeneralRoamingInConditions()
	if J.GetHP(bot) < 0.35 then
		return BOT_ACTION_DESIRE_NONE
	end

	-- if not botTarget then
	-- 	botTarget = J.GetAttackableWeakestUnit( bot, 1500, true, true )
	-- 	bot:SetTarget( botTarget )
	-- end

	if bot:HasModifier("modifier_item_mask_of_madness_berserk") then
		if J.IsValid(S.botTarget) and J.GetHP(bot) > 0.3 then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end

	if J.GetModifierTime(bot, "modifier_flask_healing") >= 1.5 then
		if #S.nInCloseRangeEnemy >= 1 and J.GetHP(bot) < 0.8 then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end

	if bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") or bot:HasModifier("modifier_item_helm_of_the_undying_active") then
		if not J.IsValidHero(S.botTarget) then
			S.botTarget = J.GetAttackableWeakestUnit( bot, 1600, true, true )
		end
		if J.IsValidHero(S.botTarget) then
			bot:SetTarget( S.botTarget )
			return BOT_ACTION_DESIRE_ABSOLUTE * 2
		end
	end

	if bot:HasModifier("modifier_razor_static_link_debuff") then
		local staticLinkDebuffStack = J.GetModifierCount( bot, "modifier_razor_static_link_debuff" )
		if staticLinkDebuffStack > S.lastStaticLinkDebuffStack then
			local enemy = GetTargetEnemy("npc_dota_hero_razor")
			if enemy ~= nil and J.GetHP(bot) - 0.2 < J.GetHP(enemy) and GetUnitToUnitDistance(bot, enemy) <= 850 then
				return BOT_ACTION_DESIRE_ABSOLUTE * 1.1
			end
		end
	end

	if bot:HasModifier("modifier_bloodseeker_rupture") then
		if J.IsRunning(bot) and not J.IsAttacking(bot) then
			return 0.6
		end
		if not S.nInCloseRangeEnemy or #S.nInCloseRangeEnemy == 0 then
			return 0.7
		end
	end

	if botName == 'npc_dota_hero_lone_druid'
	and not bot:HasModifier("modifier_lone_druid_true_form") then
		if S.nInRangeEnemy and J.IsValidHero(S.nInRangeEnemy[1])
		and J.IsInRange(bot, S.nInRangeEnemy[1], math.max(bot:GetAttackRange(), S.nInRangeEnemy[1]:GetAttackRange()) - 250) then
			return 0.6
		end
	end

	local quillSparyStack = J.GetModifierCount(bot, "modifier_bristleback_quill_spray")
	if quillSparyStack >= 3 then -- 14s
		local enemy = GetTargetEnemy("npc_dota_hero_bristleback")
		if enemy ~= nil
		and (#S.nInRangeEnemy >= #S.nInRangeAlly or enemy:GetLevel() >= bot:GetLevel())
		and J.GetHP(bot) < J.GetHP(enemy) + 0.2
		and GetUnitToUnitDistance(bot, enemy) <= 900
		and GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 1000 then
			return RemapValClamped(quillSparyStack / J.GetHP(bot), 10, 50, BOT_ACTION_DESIRE_LOW, BOT_ACTION_DESIRE_ABSOLUTE)
		end
	end

	if bot:HasModifier("modifier_primal_beast_trample") then
		local enemy = GetTargetEnemy("npc_dota_hero_primal_beast")
		local distanceToEnemy =  GetUnitToUnitDistance(bot, enemy)
		if enemy ~= nil and J.GetHP(bot) - 0.2 < J.GetHP(enemy) and distanceToEnemy <= 500 and distanceToEnemy > 250 then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end

	S.AnyUnitAffectedByChainFrost = CanBeAffectedByChainFrost()
	if S.AnyUnitAffectedByChainFrost then
		local hasLowHpEnemy = false
		for _, enemy in pairs(S.nInCloseRangeEnemy) do
			if J.Utils.IsValidHero(enemy)
			and not J.IsSuspiciousIllusion(enemy)
			and J.GetHP(enemy) < 0.2 then
				hasLowHpEnemy = true
			end
		end
		if not hasLowHpEnemy then
			local crowd = #S.nInCloseRangeAlly
			local hp = J.GetHP(bot)
			return Clamp(0.35 + 0.35 * (crowd >= 2 and 1 or 0) + 0.3 * (hp < 0.6 and 1 or 0), 0.35, 0.85)
			-- return RemapValClamped(hp, 0, 0.6, BOT_ACTION_DESIRE_NONE, 0.98)
		end
		S.AnyUnitAffectedByChainFrost = false
	end

	-- HasPossibleWallOfReplicaAround = J.Utils.HasPossibleWallOfReplicaAround(bot)
	-- if HasPossibleWallOfReplicaAround then
	-- 	local hasLowHpEnemy = false
	-- 	for _, enemy in pairs(nInCloseRangeEnemy) do
	-- 		if J.Utils.IsValidHero(enemy)
	-- 		and not J.IsSuspiciousIllusion(enemy)
	-- 		and J.GetHP(enemy) < 0.2 then
	-- 			hasLowHpEnemy = true
	-- 		end
	-- 	end
	-- 	if not hasLowHpEnemy then
	-- 		return BOT_ACTION_DESIRE_ABSOLUTE
	-- 	end
	-- end

	if bot:GetActiveMode() == BOT_MODE_ITEM
	and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH
	and (botName == 'npc_dota_hero_lone_druid_bear' or bot:HasModifier('modifier_arc_warden_tempest_double') or J.IsMeepoClone(bot))
	then
		for _, droppedItem in pairs(GetDroppedItemList()) do
            if droppedItem ~= nil
            and droppedItem.item:GetName() == 'item_aegis'
            and GetUnitToLocationDistance(bot, droppedItem.location) < 300
            then
                return BOT_ACTION_DESIRE_ABSOLUTE
            end
        end
	end

	-- 留一个bot抵御超级兵 看家
	-- if J.GetHP(GetAncient(bot:GetTeam())) < 0.99 then
		
	-- end

	-- 目前可能会导致bot往敌方队伍里走或者浪费时间乱走被团灭
	local isBotTryingHardToAttack = J.IsAttacking(bot) or (bot:GetActiveMode() == BOT_MODE_ATTACK and bot:GetActiveModeDesire() > 0.7)
	S.ShouldBotsSpreadOut = not isBotTryingHardToAttack and J.Utils.ShouldBotsSpreadOut(bot, 450)
	if S.ShouldBotsSpreadOut then
		return 0.91
	end

	if J.IsInLaningPhase() then

		-- 状态不好 回泉水补给
		if not bot:WasRecentlyDamagedByAnyHero(1.5)
		and not J.HasHealingItem(bot)
		and not botName == 'npc_dota_hero_huskar'
		and (
			(S.shouldGoBackToFountain and not IsInHealthyState())
			or (J.GetHP(bot) < 0.22 or (J.GetHP(bot) < 0.3 and J.GetMP(bot) < 0.22))
		) then
			S.shouldGoBackToFountain = true
			return BOT_ACTION_DESIRE_ABSOLUTE * 1.5
		end

		if J.GetModifierCount(bot, "modifier_nevermore_shadowraze_debuff") >= 2 then -- 7s
			local enemy = GetTargetEnemy("npc_dota_hero_nevermore")
			if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) and GetUnitToUnitDistance(bot, enemy) <= 1200 then
				return BOT_ACTION_DESIRE_VERYHIGH * 1.2
			end
		end

		if J.GetModifierCount(bot, "modifier_monkey_king_quadruple_tap_counter") >= 2 then -- 7 - 10s
			local enemy = GetTargetEnemy("npc_dota_hero_monkey_king")
			if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 3 then
				return BOT_ACTION_DESIRE_VERYHIGH * 1.2
			end
		end

		if J.GetModifierCount(bot, "modifier_viper_poison_attack_slow") >= 2 then -- 4s
			local enemy = GetTargetEnemy("npc_dota_hero_viper")
			if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 2 then
				return BOT_ACTION_DESIRE_VERYHIGH * 1.2
			end
		end

		if J.GetModifierCount(bot, "modifier_huskar_burning_spear_debuff") >= 3 then -- 9s
			local enemy = GetTargetEnemy("npc_dota_hero_huskar")
			if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) + 0.2 and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 2 then
				return BOT_ACTION_DESIRE_VERYHIGH * 1.2
			end
		end

		if J.GetModifierCount(bot, "modifier_batrider_sticky_napalm") >= 3 then -- 6s
			local enemy = GetTargetEnemy("npc_dota_hero_batrider")
			if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) + 0.2 and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 3 then
				return BOT_ACTION_DESIRE_VERYHIGH * 1.2
			end
		end

		if bot:HasModifier("modifier_undying_tombstone_zombie_deathstrike_slow") then
			S.cachedTombstoneZombieSlowState = DotaTime()
			if J.IsValidTarget(S.botTarget) and not J.Utils.IsUnitWithName(S.botTarget, "tombstone") then
				local enemy = J.FindEnemyUnit("tombstone")
				if not enemy then
					enemy = GetTargetEnemy("npc_dota_hero_undying")
				end
				if J.GetHP(bot) < 0.8
				and ((J.IsValid(enemy) and GetUnitToUnitDistance(enemy, bot) < 1200) or (DotaTime() - S.cachedTombstoneZombieSlowState < 3))
				and J.IsValidHero(S.nInRangeEnemy[1]) and J.GetHP(S.nInRangeEnemy) > 0.35 then
					return BOT_ACTION_DESIRE_VERYHIGH * 1.2
				end
			end
		end

		-- long duration debuff
		if not J.WeAreStronger(bot, 1200) then
			if J.GetModifierCount(bot, "modifier_slark_essence_shift_debuff_counter") >= 2 then -- 20 - 80s
				local enemy = GetTargetEnemy("npc_dota_hero_slark")
				if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) + 0.1 and GetUnitToUnitDistance(bot, enemy) <= 750 then
					return BOT_ACTION_DESIRE_ABSOLUTE * 1.1
				end
			end

			if J.GetModifierCount(bot, "modifier_silencer_glaives_of_wisdom_debuff_counter") >= 2 then -- 20 - 35s
				local enemy = GetTargetEnemy("npc_dota_hero_silencer")
				if enemy ~= nil and J.GetHP(bot) < 0.5 and J.GetHP(bot) < J.GetHP(enemy) + 0.1 and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 2.5 then
					return BOT_ACTION_DESIRE_HIGH
				end
			end

			if J.GetModifierCount(bot, "modifier_ursa_fury_swipes_damage_increase") >= 2 then -- 8 - 20s
				local enemy = GetTargetEnemy("npc_dota_hero_ursa")
				if enemy ~= nil and J.GetHP(bot) < J.GetHP(enemy) + 0.1 and GetUnitToUnitDistance(bot, enemy) <= 450 then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end

			if bot:HasModifier("modifier_dazzle_poison_touch") then -- 5s - forever
				local enemy = GetTargetEnemy("npc_dota_hero_dazzle")
				if enemy ~= nil and J.GetHP(bot) < 0.6 and J.GetHP(bot) < J.GetHP(enemy) + 0.1 and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 2 then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end

			if bot:HasModifier("modifier_maledict") then -- 5s - forever
				local enemy = GetTargetEnemy("npc_dota_hero_witch_doctor")
				if enemy ~= nil and J.GetHP(bot) < 0.6 and J.GetHP(bot) < J.GetHP(enemy) + 0.1 and GetUnitToUnitDistance(bot, enemy) <= enemy:GetAttackRange() * 2 then
					return BOT_ACTION_DESIRE_VERYHIGH * 1.2
				end
			end
		end

		-- 尝试勾引
		if #S.nInRangeEnemy >= 1
		and #S.allyTowers >= 1
		and GetUnitToUnitDistance(S.allyTowers[1], bot) < 1600
		and bot:GetActiveModeDesire() < 0.9
		and #S.nInRangeAlly <= #S.nInRangeEnemy then
			for _, enemy in pairs(S.nInRangeEnemy) do
				if J.Utils.IsValidHero(enemy) then
					if enemy:IsFacingLocation(bot:GetLocation(), 45)
					and J.IsInRange(bot, enemy, enemy:GetAttackRange() * 1.5 + 550)
					and J.GetHP(enemy) > J.GetHP(bot) - 0.15
					and bot:WasRecentlyDamagedByAnyHero(5)
					and J.GetHP(bot) < 0.75 and J.GetHP(bot) > 0.3 -- don't block real retreat action
					then
						S.trySeduce = true
						return BOT_ACTION_DESIRE_VERYHIGH
					end
				end
			end
		end
	end

	if bot:WasRecentlyDamagedByTower(0.2) then
		if #S.nInCloseRangeAlly >= 2 and J.GetHP(S.nInCloseRangeAlly[2]) > J.GetHP(bot) then
			bot:Action_AttackUnit(S.nInCloseRangeAlly[2], true)
		else
			local allyCreeps = bot:GetNearbyCreeps(1000, false)
			if #allyCreeps >= 1 and J.IsValid(allyCreeps[1]) then
				bot:Action_AttackUnit(allyCreeps[1], true)
			end
		end
	end

	-- local actualGankingDesire = ActualGankDesire()
	-- if actualGankingDesire > 0 then
	-- 	lastGankDecisionTime = DotaTime()
	-- 	return actualGankingDesire
	-- end
	return BOT_ACTION_DESIRE_NONE
end

function GetTargetEnemy(unitName)
	for _, enemyHero in pairs(S.nInRangeEnemy)
	do
		if J.IsValidHero(enemyHero) and enemyHero:GetUnitName() == unitName then
			return enemyHero
		end
	end
	return nil
end

end
