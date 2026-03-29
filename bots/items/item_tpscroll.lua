local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local team = ctx.team
	local botName = ctx.botName


	if nMode == BOT_MODE_RUNE
		or ( bot:IsRooted() )
		or ( bot:HasModifier( "modifier_item_armlet_unholy_strength" ) )
		or ( bot:HasModifier( "modifier_kunkka_x_marks_the_spot" ) )
		or ( bot:HasModifier( "modifier_teleporting" ) )
		or ( bot:HasModifier( "modifier_sniper_assassinate" ) )
		or ( bot:HasModifier( "modifier_viper_nethertoxin" ) )
		or ( bot:HasModifier( "modifier_oracle_false_promise_timer" ) and J.GetModifierTime( bot, "modifier_oracle_false_promise_timer" ) <= 3.2 )
		or ( bot:HasModifier( "modifier_jakiro_macropyre_burn" ) and J.GetModifierTime( bot, "modifier_jakiro_macropyre_burn" ) >= 1.4 )
		or ( bot:HasModifier( "modifier_arc_warden_tempest_double" ) and bot:GetRemainingLifespan() < 3.3 )
		or (J.IsDoingRoshan(bot) and GetUnitToLocationDistance(bot, J.GetCurrentRoshanLocation()) <= 2800)
	then return BOT_ACTION_DESIRE_NONE end

	if bot:GetHealth() < 240
	then
		local nProDamage = J.GetAttackProjectileDamageByRange( bot, 1600 ) * 2
		if bot:GetHealth() < bot:GetActualIncomingDamage( nProDamage, DAMAGE_TYPE_PHYSICAL )
		then return BOT_ACTION_DESIRE_NONE end
	end

	if bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
	or bot.healInBase
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nNearbyEnemyTowers = bot:GetNearbyTowers( 888, true )
	if #nNearbyEnemyTowers > 0 then return BOT_ACTION_DESIRE_NONE end

	local tpLoc = nil
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil

	local nMinTPDistance = 5500
	local nMode = bot:GetActiveMode()
	local nModeDesire = bot:GetActiveModeDesire()
	local botLocation = bot:GetLocation()
	local botHP = J.GetHP( bot )
	local botMP = J.GetMP( bot )
	local nEnemyCount = Common.GetNumHeroWithinRange( bot, 1600 )
	local nAllyCount = J.GetAllyCount( bot, 1600 )
	local itemFlask = J.IsItemAvailable( "item_flask" )

	if bot:GetLevel() > 12 and bot:DistanceFromFountain() < 600 then nMinTPDistance = nMinTPDistance + 600 end

	if nMode == BOT_MODE_LANING
	then
		hEffectTarget, shouldTp = Common.GetLaningTPLocation(bot, nMinTPDistance, botLocation)
		sCastMotive = '出去发育'
		if shouldTp
		then
			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	-- Go complete items
	if Common.IsInvFull(bot) and Common.GetNumStashItem(bot) >= 1
	and (Common.IsThereRecipeInStash(bot) or (bot:GetStashValue() >= 1000 and bot:GetGold() > 1100))
	and (bot:GetActiveMode() ~= BOT_MODE_PUSH_TOWER_TOP or bot:GetActiveMode() ~= BOT_MODE_PUSH_TOWER_MID or bot:GetActiveMode() ~= BOT_MODE_PUSH_TOWER_BOT or bot:GetActiveMode() ~= BOT_MODE_ATTACK)
	and not J.IsInTeamFight(bot, 1000)
	and nEnemyCount == 0
	then
		hEffectTarget = J.GetTeamFountain()
		sCastMotive = '撤退:1'

		if botName == 'npc_dota_hero_furion'
		then
			local Teleportation = bot:GetAbilityByName('furion_teleportation')
			if Teleportation:IsTrained()
			and Teleportation:IsFullyCastable()
			then
				bot.useProphetTP = true
				bot.ProphetTPLocation = hEffectTarget
				return BOT_ACTION_DESIRE_NONE
			end
		end

		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	-- Roshan
	if J.IsDoingRoshan(bot)
	and nEnemyCount == 0
	and not J.IsRoshanCloseToChangingSides()
	then
		local roshanLoc = J.GetCurrentRoshanLocation()
		local targetLoc = J.GetNearbyLocationToTp(roshanLoc)

		local tpLocDist = GetUnitToLocationDistance(bot, targetLoc)
		local roshanLocDist = GetUnitToLocationDistance(bot, roshanLoc)

		if tpLocDist > 8000
		and roshanLocDist > 8000
		and roshanLocDist > tpLocDist
		then
			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = targetLoc
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, targetLoc, 'ground', 'tp_roshan'
		end
	end

	--Tormentor
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP
	and nEnemyCount == 0
	and (not J.IsInTeamFight(bot, 1200)
		or not J.IsGoingOnSomeone(bot)
		or not J.IsDefending(bot))
	then
		local torLoc = J.GetTormentorLocation(team)
		if GetUnitToLocationDistance(bot, torLoc) > 8000 then
			hEffectTarget = J.GetNearbyLocationToTp(torLoc)
			sCastMotive = 'tormentor'
			if J.GetLocationToLocationDistance(bot:GetLocation(), hEffectTarget) > 4400
			then
				if botName == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot.useProphetTP = true
						bot.ProphetTPLocation = hEffectTarget
						return BOT_ACTION_DESIRE_NONE
					end
				end
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	--守塔
	if J.IsDefending( bot )
		and nModeDesire > BOT_MODE_DESIRE_MODERATE
		and nEnemyCount == 0
	then
		local nDefendLane, sLane = LANE_MID, 'tower_mid'
		if nMode == BOT_MODE_DEFEND_TOWER_TOP then nDefendLane, sLane = LANE_TOP, 'tower_top' end
		if nMode == BOT_MODE_DEFEND_TOWER_BOT then nDefendLane, sLane = LANE_BOT, 'tower_bot' end

		local botAmount = GetAmountAlongLane( nDefendLane, botLocation )
		local laneFront = GetLaneFrontAmount( team, nDefendLane, false )
		if botAmount.distance > nMinTPDistance
			or botAmount.amount < laneFront / 5
		then
			tpLoc = Common.GetDefendTPLocation( nDefendLane )
		end

		if tpLoc ~= nil
			and GetUnitToLocationDistance( bot, tpLoc ) > nMinTPDistance - 500
		then
			hEffectTarget = tpLoc
			sCastMotive = '前往守塔:'..sLane

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_ABSOLUTE, hEffectTarget, sCastType, sCastMotive
		end
	end


	--推塔
	if J.IsPushing( bot )
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and nEnemyCount == 0
	then
		local nPushLane, sLane = LANE_MID, 'tower_mid'
		if nMode == BOT_MODE_PUSH_TOWER_TOP then nPushLane, sLane = LANE_TOP, 'tower_top' end
		if nMode == BOT_MODE_PUSH_TOWER_BOT then nPushLane, sLane = LANE_BOT, 'tower_bot' end

		local botAmount = GetAmountAlongLane( nPushLane, botLocation )
		local laneFront = GetLaneFrontAmount( team, nPushLane, false )
		if botAmount.distance > nMinTPDistance
			or botAmount.amount < laneFront / 5
		then
			tpLoc = Common.GetPushTPLocation( nPushLane )
		end

		if tpLoc ~= nil
			and GetUnitToLocationDistance( bot, tpLoc ) > nMinTPDistance - 600
		then
			hEffectTarget = tpLoc
			sCastMotive = '前往推塔:'..sLane

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	--保人
	if nMode == BOT_MODE_DEFEND_ALLY
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and J.Role.CanBeSupport( botName )
		and nEnemyCount == 0
	then
		local target = bot:GetTarget()
		if target ~= nil
			and target:IsHero()
			and GetUnitToUnitDistance( bot, target ) > nMinTPDistance
		then
			local bestTpLoc = J.GetNearbyLocationToTp( target:GetLocation() )
			if bestTpLoc ~= nil
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance - 800
			then
				tpLoc = bestTpLoc
			end
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '支援队友:'..J.Chat.GetNormName( target )

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	--塔下保人



	--撤退
	if nMode == BOT_MODE_RETREAT
		and nModeDesire >= BOT_MODE_DESIRE_MODERATE
		and bot:GetLevel() >= 3
		and not bot:HasModifier( "modifier_arc_warden_tempest_double" )
	then

		--第一种情况:无敌人无大药回家恢复
		if botHP < 0.19
			and ( bot:WasRecentlyDamagedByAnyHero( 8.0 ) or botHP < 0.12 )
			and botName ~= 'npc_dota_hero_huskar'
			and ( botName ~= 'npc_dota_hero_slark' or bot:GetLevel() <= 5 )
			and nEnemyCount == 0
			and itemFlask == nil
			and not bot:HasModifier( "modifier_tango_heal" )
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and bot:DistanceFromFountain() > nMinTPDistance
		then
			tpLoc = J.GetTeamFountain()
			sCastMotive = '撤退:1'

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
		end


		--第二种情况:有多个敌人但可以卡视野TP
		local nAttackAllyList = J.GetNearbyHeroes(bot, 1500, false, BOT_MODE_ATTACK )
		if botHP < ( 0.15 + 0.24 * nEnemyCount )
			and #nAttackAllyList == 0
			and bot:WasRecentlyDamagedByAnyHero( 6.0 )
			and Common.CanJuke(bot)
			and nEnemyCount <= ( botHP < 0.4 and 2 or 3 )
			and nAllyCount <= 2
			and itemFlask == nil
			and not bot:HasModifier( "modifier_tango_heal" )
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and bot:DistanceFromFountain() > nMinTPDistance - 600
		then
			tpLoc = J.GetTeamFountain()
			sCastMotive = '撤退:2'

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
		end


		--第三种情况:只有一个敌人直接T回家
		if ( botHP < 0.34 or botHP + botMP < 0.43 )
			and #nAttackAllyList == 0
			and bot:GetLevel() >= 9
			and Common.CanJuke(bot)
			and nEnemyCount <= 1
			and nAllyCount <= 2
			and itemFlask == nil
			and bot:GetAttackTarget() == nil
			and botName ~= 'npc_dota_hero_huskar'
			and botName ~= 'npc_dota_hero_slark'
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_clarity_potion" )
			and not bot:HasModifier( "modifier_filler_heal" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not bot:HasModifier( "modifier_bottle_regeneration" )
			and not bot:HasModifier( "modifier_tango_heal" )
			and bot:DistanceFromFountain() > nMinTPDistance - 600
		then
			tpLoc = J.GetTeamFountain()
			sCastMotive = '撤退:3'

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
		end
	end


	--TP出去发育
	if nMode == BOT_MODE_FARM
		and bot:DistanceFromFountain() < 800
		and not Common.IsBaseTowerDestroyed()
		and botHP > 0.9
		and botMP > 0.8
	then
		local mostFarmDesireLane, mostFarmDesire = J.GetMostFarmLaneDesire(bot)

		if mostFarmDesire > 0.1
		then
			farmTpLoc = GetLaneFrontLocation( team, mostFarmDesireLane, 0 )
			local bestTpLoc = J.GetNearbyLocationToTp( farmTpLoc )
			if bestTpLoc ~= nil and farmTpLoc ~= nil
				and J.IsLocHaveTower( 2000, false, farmTpLoc )
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance
			then
				tpLoc = farmTpLoc
			end
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '出去发育'

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_ABSOLUTE, hEffectTarget, sCastType, sCastMotive
		end

	end


	--TP发育带线
	if bot:GetLevel() >= 10
		and nMode ~= BOT_MODE_ROSHAN
		and not Common.IsBaseTowerDestroyed()
		and J.GetAllyCount( bot, 1600 ) <= 2
		and J.Role.ShouldTpToFarm()
		and not J.Role.IsAllyHaveAegis()
		and not J.Role.CanBeSupport( botName )
		and not J.IsEnemyHeroAroundLocation( GetAncient( team ):GetLocation(), 3300 )
	then
		local nAttackAllyList = J.GetNearbyHeroes(bot, 1600, false, BOT_MODE_ATTACK )
		local nNearEnemyList = J.GetNearbyHeroes(bot, 1400, true, BOT_MODE_NONE )
		local nCreeps= bot:GetNearbyCreeps( 1600, true )
		local mostFarmDesireLane, mostFarmDesire = J.GetMostFarmLaneDesire(bot)
		
		local isTravelBootsAvailable = false
		if J.IsItemAvailable( "item_travel_boots" )
			or J.IsItemAvailable( "item_travel_boots_2" )
		then
			isTravelBootsAvailable = true
		end

		if mostFarmDesire > ( isTravelBootsAvailable and 0.7 or 0.8 )
			and #nNearEnemyList == 0
			and #nCreeps == 0
			and #nAttackAllyList == 0
		then

			if isTravelBootsAvailable
			then
				tpLoc = GetLaneFrontLocation( team, mostFarmDesireLane, - 600 )
				local nNearAllyList = J.GetAlliesNearLoc( tpLoc, 1600 )
				if GetUnitToLocationDistance( bot, tpLoc ) > nMinTPDistance - 1500
					and #nNearAllyList == 0
				then
					J.Role['lastFarmTpTime'] = DotaTime()
					sCastMotive = '飞鞋带线'

					if botName == 'npc_dota_hero_furion'
					then
						local Teleportation = bot:GetAbilityByName('furion_teleportation')
						if Teleportation:IsTrained()
						and Teleportation:IsFullyCastable()
						then
							bot.useProphetTP = true
							bot.ProphetTPLocation = tpLoc
							return BOT_ACTION_DESIRE_NONE
						end
					end

					return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
				end
			end

			tpLoc = GetLaneFrontLocation( team, mostFarmDesireLane, 0 )
			local bestTpLoc = J.GetNearbyLocationToTp( tpLoc )
			local nNearAllyList = J.GetAlliesNearLoc( tpLoc, 1600 )
			if bestTpLoc ~= nil
				and J.IsLocHaveTower( 1850, false, tpLoc )
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance - 800
				and #nNearAllyList == 0
			then
				J.Role['lastFarmTpTime'] = DotaTime()
				sCastMotive = '线上打钱'

				if botName == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot.useProphetTP = true
						bot.ProphetTPLocation = bestTpLoc
						return BOT_ACTION_DESIRE_NONE
					end
				end

				return BOT_ACTION_DESIRE_HIGH, bestTpLoc, sCastType, sCastMotive
			end
		end
	end


	--支援团战和守家
	if bot:GetLevel() > 10
		and nMode ~= BOT_MODE_SECRET_SHOP
		and nMode ~= BOT_MODE_ROSHAN
		and nMode ~= BOT_MODE_ATTACK
		and ( botTarget == nil or not botTarget:IsHero() )
		--and J.GetAllyCount( bot, 1600 ) <= 3 --守护遗迹bug
	then
		local nNearEnemyList = J.GetNearbyHeroes(bot, 1400, true, BOT_MODE_NONE )
		local nTeamFightLocation = J.GetTeamFightLocation( bot )
		local isTravelBootsAvailable = false
		if J.IsItemAvailable( "item_travel_boots" )
			or J.IsItemAvailable( "item_travel_boots_2" )
		then
			isTravelBootsAvailable = true
		end

		if botName == 'npc_dota_hero_spectre'
		then
			local ShadowStep = bot:GetAbilityByName('spectre_shadow_step')
			local Haunt = bot:GetAbilityByName('spectre_haunt')

			if (ShadowStep:IsFullyCastable())
			or (Haunt:IsTrained() and Haunt:IsFullyCastable())
			then
				return BOT_ACTION_DESIRE_NONE
			end
		end
		
		if #nNearEnemyList == 0
			and nTeamFightLocation ~= nil
			and GetUnitToLocationDistance( bot, nTeamFightLocation ) > nMinTPDistance - 1200
		then

			if isTravelBootsAvailable
			then
				sCastMotive = '飞鞋支援团战距离:'..GetUnitToLocationDistance( bot, nTeamFightLocation )

				if botName == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot.useProphetTP = true
						bot.ProphetTPLocation = nTeamFightLocation
						return BOT_ACTION_DESIRE_NONE
					end
				end

				return BOT_ACTION_DESIRE_HIGH, nTeamFightLocation, sCastType, sCastMotive
			end

			local bestTpLoc = J.GetNearbyLocationToTp( nTeamFightLocation )
			if bestTpLoc ~= nil
				and J.GetLocationToLocationDistance( bestTpLoc, nTeamFightLocation ) < 1800
				and GetUnitToLocationDistance( bot, bestTpLoc ) > nMinTPDistance - 1200
			then
				sCastMotive = '支援团战:'..GetUnitToLocationDistance( bot, nTeamFightLocation )

				if botName == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot.useProphetTP = true
						bot.ProphetTPLocation = bestTpLoc
						return BOT_ACTION_DESIRE_NONE
					end
				end

				return BOT_ACTION_DESIRE_HIGH, bestTpLoc, sCastType, sCastMotive
			end
		end

		--守护遗迹
		local nAncient = GetAncient( team )
		if bot:GetLevel() >= 15	
			and #nNearEnemyList == 0
			and J.Role.ShouldTpToFarm()
			and bot:DistanceFromFountain() > 2000
			and GetUnitToUnitDistance( bot, nAncient ) > nMinTPDistance - 200
			and J.GetAroundTargetAllyHeroCount( nAncient, 1400 ) == 0
		then
			local nEnemyLaneFront = J.GetNearestLaneFrontLocation( nAncient:GetLocation(), true, 400 )
			if nEnemyLaneFront ~= nil
				and GetUnitToLocationDistance( nAncient, nEnemyLaneFront ) <= 1600
			then

				J.Role['lastFarmTpTime'] = DotaTime()
				sCastMotive = '守护遗迹'

				if botName == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot.useProphetTP = true
						bot.ProphetTPLocation = nAncient:GetLocation()
						return BOT_ACTION_DESIRE_NONE
					end
				end

				return BOT_ACTION_DESIRE_HIGH, nAncient:GetLocation(), sCastType, sCastMotive
			end
			
			local ancientTower1 = GetTower(team, 9)
			local ancientTower2 = GetTower(team, 10)
			if ancientTower1 == nil and ancientTower2 == nil
--				and nAncient:WasRecentlyDamagedByCreep( 5.0 )
			then
				local nAllEnemyCreeps = GetUnitList( UNIT_LIST_ENEMY_CREEPS )
				for _, creep in pairs( nAllEnemyCreeps )
				do
					if J.IsValid(creep)
					and GetUnitToUnitDistance( nAncient, creep ) <= 800
					and ( creep:GetAttackTarget() == nAncient or bot:GetLevel() >= 15 )
					then
						J.Role['lastFarmTpTime'] = DotaTime()
						sCastMotive = '保护遗迹'

						if botName == 'npc_dota_hero_furion'
						then
							local Teleportation = bot:GetAbilityByName('furion_teleportation')
							if Teleportation:IsTrained()
							and Teleportation:IsFullyCastable()
							then
								bot.useProphetTP = true
								bot.ProphetTPLocation = nAncient:GetLocation()
								return BOT_ACTION_DESIRE_NONE
							end
						end

						return BOT_ACTION_DESIRE_HIGH, nAncient:GetLocation(), sCastType, sCastMotive
					end
				end
			end
			
		end

	end

	--回复状态
	if ( botHP + botMP < 0.3 or botHP < 0.2 )
		and bot:GetLevel() >= 6
		and botName ~= 'npc_dota_hero_huskar'
		and botName ~= 'npc_dota_hero_slark'
		and not bot:HasModifier( "modifier_arc_warden_tempest_double" )
	then
		if	Common.CanJuke(bot)
			and bot:DistanceFromFountain() > nMinTPDistance + 200
			and nEnemyCount <= 1 and nAllyCount <= 1
			and J.GetProperTarget( bot ) == nil
			and itemFlask == nil
			and bot:GetAttackTarget() == nil
			and not bot:HasModifier( "modifier_flask_healing" )
			and not bot:HasModifier( "modifier_clarity_potion" )
			and not bot:HasModifier( "modifier_filler_heal" )
			and not bot:HasModifier( "modifier_item_urn_heal" )
			and not bot:HasModifier( "modifier_item_spirit_vessel_heal" )
			and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not bot:HasModifier( "modifier_bottle_regeneration" )
			and not bot:HasModifier( "modifier_tango_heal" )
		then
			tpLoc = J.GetTeamFountain()
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '回复状态'

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--血魔大
	if bot:HasModifier( 'modifier_bloodseeker_rupture' ) and nEnemyCount <= 1
		and J.GetModifierTime( bot, "modifier_bloodseeker_rupture" ) >= 3.1
	then
		local nAllyCount = J.GetNearbyHeroes(bot, 1000, false, BOT_MODE_NONE )
		if #nAllyCount <= 1 and Common.CanJuke(bot)
		then
			tpLoc = J.GetTeamFountain()
		end

		if tpLoc ~= nil
		then
			hEffectTarget = tpLoc
			sCastMotive = '躲血魔大'

			if botName == 'npc_dota_hero_furion'
			then
				local Teleportation = bot:GetAbilityByName('furion_teleportation')
				if Teleportation:IsTrained()
				and Teleportation:IsFullyCastable()
				then
					bot.useProphetTP = true
					bot.ProphetTPLocation = hEffectTarget
					return BOT_ACTION_DESIRE_NONE
				end
			end

			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--处理特殊情况一
	if Common.IsFarmingAlways( bot )
	then
		tpLoc = GetAncient( team ):GetLocation()
		sCastMotive = '处理特殊情况一'

		if botName == 'npc_dota_hero_furion'
		then
			local Teleportation = bot:GetAbilityByName('furion_teleportation')
			if Teleportation:IsTrained()
			and Teleportation:IsFullyCastable()
			then
				bot.useProphetTP = true
				bot.ProphetTPLocation = tpLoc
				return BOT_ACTION_DESIRE_NONE
			end
		end

		return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
	end

	--处理特殊情况二
	if J.IsStuck( bot ) --and nEnemyCount == 0
	then
		tpLoc = GetAncient( team ):GetLocation()
		sCastMotive = '处理特殊情况二'

		if botName == 'npc_dota_hero_furion'
		then
			local Teleportation = bot:GetAbilityByName('furion_teleportation')
			if Teleportation:IsTrained()
			and Teleportation:IsFullyCastable()
			then
				bot.useProphetTP = true
				bot.ProphetTPLocation = tpLoc
				return BOT_ACTION_DESIRE_NONE
			end
		end

		return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
	end
	
	if J.Role.ShouldTpToDefend()
	and bot:DistanceFromFountain() > 3800
	then
		tpLoc = GetAncient( team ):GetLocation()
		sCastMotive = '立即TP守家'
		return BOT_ACTION_DESIRE_HIGH, tpLoc, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
