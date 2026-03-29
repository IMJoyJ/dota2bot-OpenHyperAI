-- mode_roam sub-module: hero-specific think/action handlers
return function(bot, J, S, recordAction)

local BearAttackLimitDistance = 1100
local TetherBreakDistance = 1000
local botName = bot:GetUnitName()

function ThinkIndividualRoaming()
	if S.tangoDesire and S.tangoDesire > 0 and S.tangoTarget then
		local hItem = bot:GetItemInSlot( S.tangoSlot )
		bot:Action_UseAbilityOnTree( hItem, S.tangoTarget )
		return
	end

	-- Heal in Base
	-- Just for TP. Too much back and forth when "forcing" them try to walk to fountain; <- not reliable and misses farm.
	if S.ShouldWaitInBaseToHeal
	then
		if GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 150
		then
			S.nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1400)
			if J.Item.GetItemCharges(bot, 'item_tpscroll') >= 1
			and S.nInRangeEnemy ~= nil and #S.nInRangeEnemy == 0
			then
				if botName == 'npc_dota_hero_furion'
				then
					local Teleportation = bot:GetAbilityByName('furion_teleportation')
					if Teleportation:IsTrained()
					and Teleportation:IsFullyCastable()
					then
						bot:Action_UseAbilityOnLocation(Teleportation, J.GetTeamFountain())
						return
					end
				end

				if S.TPScroll ~= nil
				and not S.TPScroll:IsNull()
				and S.TPScroll:IsFullyCastable()
				then
					bot:Action_UseAbilityOnLocation(S.TPScroll, J.GetTeamFountain())
					return
				end
			end
		else
			if J.GetHP(bot) < 0.85 or J.GetMP(bot) < 0.85
			then
				if J.Item.GetItemCharges(bot, 'item_tpscroll') <= 1
				and bot:GetGold() >= GetItemCost('item_tpscroll')
				then
					bot:ActionImmediate_PurchaseItem('item_tpscroll')
					return
				end

				bot:Action_MoveToLocation(bot:GetLocation() + 150)
				return
			else
				S.ShouldWaitInBaseToHeal = false
			end
		end
	end

	-- Tinker
	if S.TinkerShouldWaitInBaseToHeal
	then
		if J.GetHP(bot) < 0.8 or J.GetMP(bot) < 0.8
		then
			bot:Action_ClearActions(true)
			return
		end
	end

	-- Spirit Breaker
	if bot:HasModifier('modifier_spirit_breaker_charge_of_darkness')
	then
		bot:Action_ClearActions(false)
		if bot.chargeRetreat and #S.nInRangeEnemy == 0 then
			if IsLocationPassable(bot:GetLocation()) then
				bot.chargeRetreat = false
				bot:Action_MoveToLocation(bot:GetLocation() + RandomVector(150))
				return
			end
		end
		return
	end

	-- Batrider
	if bot:HasModifier('modifier_batrider_flaming_lasso_self')
	then
		bot:Action_MoveToLocation(J.GetTeamFountain())
		return
	end

	-- Nyx Assassin
	if bot.canVendettaKill
	then
		if J.IsValid(bot.vendettaTarget)
		then
			if GetUnitToUnitDistance(bot, bot.vendettaTarget) > bot:GetAttackRange() + 200
			then
				bot:Action_MoveToLocation(bot.vendettaTarget:GetLocation())
				return
			else
				bot:Action_AttackUnit(bot.vendettaTarget, true)
				return
			end
		end
	end

	-- Rolling Thunder
	if bot:HasModifier('modifier_pangolier_gyroshell')
	then
		if J.IsInTeamFight(bot, 1600)
		then
			local target = nil
			local hp = 0
			for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
			do
				if J.IsValidHero(enemyHero)
				and J.IsInRange(bot, enemyHero, 2200)
				and J.CanBeAttacked(enemyHero)
				and J.CanCastOnNonMagicImmune(enemyHero)
				and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and hp < enemyHero:GetHealth()
				then
					hp = enemyHero:GetHealth()
					target = enemyHero
				end
			end

			if target ~= nil
			then
				local moveLoc = J.GetCorrectLoc(target, 0.2)
				recordAction("move", moveLoc)
				bot:Action_MoveToLocation(moveLoc)
				return
			end
		end

		if J.IsRetreating(bot)
		then
			bot:Action_MoveToLocation(J.GetTeamFountain())
			return
		end

		local tEnemyHeroes = bot:GetNearbyHeroes(880, true, BOT_MODE_NONE)
		if J.IsValidHero(tEnemyHeroes[1])
		and not tEnemyHeroes[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		then
			bot:Action_MoveToLocation(J.GetCorrectLoc(tEnemyHeroes[1], 0.2))
			return
		end

		local tCreeps = bot:GetNearbyCreeps(880, true)
		if J.IsValid(tCreeps[1])
		then
			bot:Action_MoveToLocation(J.GetCorrectLoc(tCreeps[1], 0.2))
			return
		end
	end

	-- Primal Beast (Trample)
	if bot:HasModifier('modifier_primal_beast_trample') then
		local tAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), 1200)
		local tEnemyHeroes = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

		if #tEnemyHeroes > #tAllyHeroes + 1
		or (not J.WeAreStronger(bot, 800) and J.GetHP(bot) < 0.55)
		or (#tEnemyHeroes > 0 and J.GetHP(bot) < 0.3) then
			TrampleToBase()
			return
		end

		-- bot.trample_status {1 - type, 2 - location, 3 - target, if any}
		if bot.trample_status ~= nil and type(bot.trample_status) == "table" then
			if bot.trample_status[1] == 'engaging' then
				if J.IsValidHero(bot.trample_status[3]) then
					DoTrample(J.GetCorrectLoc( bot.trample_status[3], 0.2 ))
					return
				elseif #tEnemyHeroes > 0 then
					local target = nil
					local hp = 0
					for _, enemyHero in pairs(tEnemyHeroes) do
						if J.IsValidHero(enemyHero)
						and J.IsInRange(bot, enemyHero, 2200)
						and J.CanBeAttacked(enemyHero)
						and J.CanCastOnNonMagicImmune(enemyHero)
						and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
						and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
						and hp < enemyHero:GetHealth()
						then
							hp = enemyHero:GetHealth()
							target = enemyHero
						end
					end

					if target ~= nil then
						DoTrample(J.GetCorrectLoc( target, 0.2 ))
						return
					end
				else
					if #tAllyHeroes >= #tEnemyHeroes and J.WeAreStronger(bot, 800) then
						for _, ally in pairs(tAllyHeroes) do
							if J.IsValidHero(ally) and not J.IsSuspiciousIllusion(ally) then
								local allyTarget = ally:GetAttackTarget()
								if J.IsValidHero(allyTarget) then
									DoTrample(J.GetCorrectLoc( allyTarget, 0.2 ))
									return
								end
							end
						end
					end
				end
				-- TrampleToBase()
				return
			elseif bot.trample_status[1] == 'retreating' then
				TrampleToBase()
				return
			elseif bot.trample_status[1] == 'farming' or bot.trample_status[1] == 'laning' then
				local tCreeps = bot:GetNearbyCreeps(1200, true)
				if J.IsValid(tCreeps[1]) and J.CanBeAttacked(tCreeps[1])
				then
					local nLocationAoE = bot:FindAoELocation(true, false, tCreeps[1]:GetLocation(), 0, 300, 0, 0)
					if nLocationAoE.count > 0 then
						DoTrample(nLocationAoE.targetloc)
						return
					end
				else
					TrampleToBase()
					return
				end
			elseif bot.trample_status[1] == 'miniboss' then
				if J.IsValid(bot.trample_status[3]) then
					DoTrample(bot.trample_status[2])
					return
				else
					TrampleToBase()
					return
				end
			end
		end
		TrampleToBase()
		return
	end

	-- Primal Beast (Onslaught)
	if bot:HasModifier('modifier_primal_beast_onslaught_windup')
	or bot:HasModifier('modifier_prevent_taunts')
	or bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable')
	then
		if bot.onslaught_status ~= nil then
			if bot.onslaught_status[1] == 'engage' then
				if J.IsValidHero(bot.onslaught_status[2]) then
					bot:Action_MoveToLocation(J.GetCorrectLoc(bot.onslaught_status[2], 0.3))
					return
				else
					local target = nil
					local targetHealth = math.huge
					for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
						if J.IsValidHero(enemy)
						and J.IsInRange(bot, enemy, 1600)
						and J.CanBeAttacked(enemy)
						and not J.IsEnemyBlackHoleInLocation(enemy:GetLocation())
						and not J.IsEnemyChronosphereInLocation(enemy:GetLocation())
						and not enemy:HasModifier('modifier_necrolyte_reapers_scythe')
						then
							local enemyHealth = enemy:GetHealth()
							if enemyHealth < targetHealth then
								targetHealth = enemyHealth
								target = enemy
							end
						end
					end

					if target ~= nil then
						bot:Action_MoveToLocation(J.GetCorrectLoc(target, 0.3))
						return
					end

					for i = 1, #GetTeamPlayers( GetTeam() ) do
						local member = GetTeamMember(i)
						if J.IsValidHero(member)
						and J.IsInRange(bot, member, 1600)
						then
							local memberTarget = member:GetAttackTarget()
							if J.IsValidHero(memberTarget)
							and J.IsInRange(bot, memberTarget, 1600)
							and not J.IsEnemyBlackHoleInLocation(memberTarget:GetLocation())
							and not J.IsEnemyChronosphereInLocation(memberTarget:GetLocation())
							and not memberTarget:HasModifier('modifier_necrolyte_reapers_scythe')
							then
								bot:Action_MoveToLocation(J.GetCorrectLoc(memberTarget, 0.3))
								return
							end
						end
					end
				end
			end
		elseif bot.onslaught_status[1] == 'retreat' then
			bot:Action_MoveToLocation(bot.onslaught_status[2])
			return
		elseif bot.onslaught_status[1] == 'farm' then
			local nCreeps = bot:GetNearbyCreeps(800, true)
			if J.IsValid(nCreeps[1])
			and not J.IsRunning(nCreeps[1])
			and J.CanBeAttacked(nCreeps[1])
			then
				local nLocationAoE = bot:FindAoELocation(true, false, nCreeps[1]:GetLocation(), 0, 200, 0, 0)
				if ((#nCreeps >= 4 and nLocationAoE.count >= 4))
				or (#nCreeps >= 2 and nLocationAoE.count >= 2 and nCreeps[1]:IsAncientCreep())
				then
					bot:Action_MoveToLocation(nLocationAoE.targetloc)
					return
				end
			end
		end
	end

	-- Phoenix
	if bot:HasModifier('modifier_phoenix_sun_ray')
	then
		local nRadius = 130
		local nBeamDistance = 1150
		local vBeamEndLoc = J.GetFaceTowardDistanceLocation(bot, nBeamDistance)

		if J.IsValidHero(bot.sun_ray_target) then
			bot:Action_MoveToLocation(bot.sun_ray_target:GetLocation())
			return
		end

		-- beam other enemy
		local tEnemyHeroes = bot:GetNearbyHeroes(nBeamDistance, true, BOT_MODE_NONE)
		for _, enemy in pairs(tEnemyHeroes) do
			if J.IsValidHero(enemy)
			and J.CanCastOnNonMagicImmune(enemy)
			and not enemy:HasModifier('modifier_abaddon_borrowed_time')
			and not enemy:HasModifier('modifier_dazzle_shallow_grave')
			and not enemy:HasModifier('modifier_necrolyte_reapers_scythe') then
				bot.sun_ray_target = enemy
				bot:Action_MoveToLocation(enemy:GetLocation())
				return
			end
		end

		-- heal ally
		local tInRangeAlly = bot:GetNearbyHeroes(nBeamDistance, false, BOT_MODE_NONE)
		for _, ally in pairs(tInRangeAlly)
		do
			if J.IsValidHero(ally)
			and bot ~= ally
			and J.GetHP(ally) < 0.5
			and ally:WasRecentlyDamagedByAnyHero(3.5)
			and not ally:IsIllusion()
			and bot:IsFacingLocation(ally:GetLocation(), 60)
			then
				if not J.IsRunning(ally)
				or ally:IsStunned()
				or ally:IsRooted()
				or ally:IsHexed()
				or ally:HasModifier('modifier_bane_fiends_grip')
				or ally:HasModifier('modifier_faceless_void_chronosphere_freeze')
				or ally:HasModifier('modifier_enigma_black_hole_pull') then
					bot.sun_ray_target = ally
					bot:Action_MoveToLocation(ally:GetLocation())
					return
				end
			end
		end
	end

	-- Snapfire
	if bot:HasModifier('modifier_snapfire_mortimer_kisses')
	then
		local nKissesTarget = GetMortimerKissesTarget()

		if nKissesTarget ~= nil
		then
			local eta = (GetUnitToUnitDistance(bot, nKissesTarget) / 1300) + 0.3
			bot:Action_MoveToLocation(J.GetCorrectLoc(nKissesTarget, eta))
			return
		end
	end

	-- Leshrac
	if S.ShouldMoveCloseTowerForEdict
	then
		if S.EdictTowerTarget ~= nil
		then
			if GetUnitToUnitDistance(bot, S.EdictTowerTarget) > 350
			then
				bot:Action_MoveToLocation(S.EdictTowerTarget:GetLocation())
				return
			end
		end
	end

	-- Void Spirit
	if bot:HasModifier('modifier_void_spirit_dissimilate_phase')
	then
		local botTarget = J.GetProperTarget(bot)

		if J.IsGoingOnSomeone(bot)
		then
			if J.IsValidTarget(S.botTarget)
			then
				bot:Action_MoveToLocation(S.botTarget:GetLocation())
			end
		end

		if J.IsRetreating(bot)
		then
			bot:Action_MoveToLocation(J.GetEscapeLoc())
		end

		return
	end

	-- Marci
	if bot:HasModifier("modifier_marci_unleash") then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and GetUnitToUnitDistance(bot, S.botTarget) > bot:GetAttackRange() + 200
		then
			bot:Action_MoveToLocation(S.botTarget:GetLocation())
			return
		else
			bot:Action_AttackUnit(S.botTarget, false)
			return
		end
	end

	if bot:HasModifier("modifier_muerta_pierce_the_veil_buff")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and GetUnitToUnitDistance(bot, S.botTarget) > bot:GetAttackRange() + 200
		then
			bot:Action_MoveToLocation(S.botTarget:GetLocation())
			return
		else
			bot:Action_AttackUnit(S.botTarget, false)
			return
		end
	end

	if bot:HasModifier('modifier_razor_static_link_buff') then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) then
			local distanceFromHero = GetUnitToUnitDistance(bot, S.botTarget)
			if distanceFromHero > bot:GetAttackRange()
			then
				bot:Action_MoveToLocation(S.botTarget:GetLocation() + RandomVector(200))
				return
			elseif distanceFromHero <= bot:GetAttackRange() / 2 then
				bot:Action_AttackUnit(S.botTarget, false)
				return
			end
		end
	end

	if bot:HasModifier("modifier_faceless_void_chronosphere")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and GetUnitToUnitDistance(bot, S.botTarget) > bot:GetAttackRange() + 200
		then
			bot:Action_MoveToLocation(S.botTarget:GetLocation())
			return
		else
			bot:Action_AttackUnit(S.botTarget, false)
			return
		end
	end

	-- Leshrac
	if bot:HasModifier("modifier_leshrac_pulse_nova")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and GetUnitToUnitDistance(bot, S.botTarget) > 400
		then
			bot:Action_MoveToLocation(S.botTarget:GetLocation())
			return
		else
			bot:ActionQueue_AttackUnit(S.botTarget, false)
			return
		end
	end

	if bot:HasModifier("modifier_wisp_tether")
	and J.IsValid(bot.stateTetheredHero) then
		if GetUnitToUnitDistance(bot, bot.stateTetheredHero) > TetherBreakDistance - 400 then
			bot:Action_MoveToLocation(bot.stateTetheredHero:GetLocation())
			return
		else
			local botTarget = J.GetProperTarget(bot)
			if J.IsValidTarget(S.botTarget) then
				bot:ActionQueue_AttackUnit(S.botTarget, false)
			end
			return
		end
	end

	if botName == 'npc_dota_hero_lone_druid_bear' then
		if J.IsTryingtoUseAbility(bot) then return BOT_MODE_DESIRE_NONE end

		local hero = J.Utils.GetLoneDruid(bot).hero
		-- local hasUltimateScepter = J.Item.HasItem(bot, 'item_ultimate_scepter') or bot:HasModifier('modifier_item_ultimate_scepter_consumed')
		local distanceFromHero = GetUnitToUnitDistance(J.Utils.GetLoneDruid(bot).hero, bot)
		local target = hero:GetAttackTarget() or J.GetProperTarget(hero) or J.GetProperTarget(bot)

		if distanceFromHero > BearAttackLimitDistance
		then
			bot:Action_MoveToLocation(hero:GetLocation())
			return
		end

		local avoidDangerous = (#bot:GetNearbyLaneCreeps(400, true) < 3 and #bot:GetNearbyTowers(800, true) == 0) or bot:GetLevel() >= 3
		if J.Utils.IsValidUnit(target)
		and distanceFromHero <= BearAttackLimitDistance
		and GetUnitToUnitDistance(hero, target) < BearAttackLimitDistance + 250
		and avoidDangerous then
			if GetUnitToUnitDistance(hero, target) > hero:GetAttackRange() + 200 then
				bot:Action_MoveToLocation(target:GetLocation())
				return
			else
				bot:Action_AttackUnit(target, false)
				return
			end
		end

		target = J.GetAttackableWeakestUnitFromList(hero, hero:GetNearbyHeroes(BearAttackLimitDistance + 250, true, BOT_MODE_NONE))
		if target ~= nil
		and avoidDangerous
		then
			bot:Action_AttackUnit(target, false)
			return
		end
		return
	end

	if botName == 'npc_dota_hero_pudge' then
		local Rot = bot:GetAbilityByName('pudge_rot')
		if Rot:GetToggleState()
		then
			local botTarget = J.GetProperTarget(bot)
			if J.IsValidTarget(S.botTarget) and GetUnitToUnitDistance(bot, S.botTarget) > 400
			then
				bot:Action_MoveToLocation(S.botTarget:GetLocation())
				return
			end
		end
		bot:ActionQueue_AttackUnit(S.botTarget, false)
	end

	if botName == 'npc_dota_hero_nevermore' then
		if J.Utils.IsTruelyInvisible(bot) then
			local botTarget = J.GetProperTarget(bot)
			if J.IsValidTarget(S.botTarget) and GetUnitToUnitDistance(bot, S.botTarget) > 400
			then
				bot:Action_MoveToLocation(S.botTarget:GetLocation())
				return
			end
		end
	end
end

local trample_step = 12
local trample = {}
function DoTrample(vLoc)
	trample = J.Utils.GetCirclarPointsAroundCenterPoint(vLoc, 300, 12)
	if trample_step < 12 then
		bot:Action_MoveToLocation(trample[trample_step])
		trample_step = trample_step + 1
	else
		trample_step = 1
	end
end
function TrampleToBase()
	trample_step = 12
	trample = {}
	bot:Action_MoveToLocation(J.GetTeamFountain())
end

function GetMortimerKissesTarget()
	for _, enemyHero in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES))
	do
		if J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, 3000 + (275 / 2))
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsInRange(bot, enemyHero, 600)
		then
			if J.IsLocationInChrono(enemyHero:GetLocation())
			or J.IsLocationInBlackHole(enemyHero:GetLocation())
			then
				return enemyHero
			end
		end

		if J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, 3000 + (275 / 2))
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsInRange(bot, enemyHero, 600)
		and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return enemyHero
		end
	end

	local nCreeps = bot:GetNearbyCreeps(1600, true)
	if J.IsValid(nCreeps[1])
	then
		return nCreeps[1]
	end

	return nil
end

end
