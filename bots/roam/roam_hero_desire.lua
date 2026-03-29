-- mode_roam sub-module: hero-specific desire functions
-- Populates ConsiderHeroSpecificRoaming table entries
return function(bot, J, S)

local BearAttackLimitDistance = 1100
local TetherBreakDistance = 1000

------------------------------
-- Hero Channel/Kill/CC abilities
------------------------------
-- ConsiderHeroSpecificRoaming['npc_dota_hero_rubick'] = function ()
-- 	if bot:IsChanneling() or bot:IsUsingAbility() or bot:IsCastingAbility()
-- 	then
-- 		return BOT_MODE_DESIRE_ABSOLUTE
-- 	end
-- 	return BOT_MODE_DESIRE_NONE
-- end

function CheckHighPriorityChannelAbility(abilityName)
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName(abilityName) end;
	if S.cAbility:IsTrained() and (S.cAbility:IsInAbilityPhase() or bot:IsChanneling()) then
		return BOT_MODE_DESIRE_ABSOLUTE;
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_pugna'] = function ()
	return CheckHighPriorityChannelAbility("pugna_life_drain")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_drow_ranger'] = function ()
	return CheckHighPriorityChannelAbility("drow_ranger_multishot")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_shadow_shaman'] = function ()
	return CheckHighPriorityChannelAbility("shadow_shaman_shackles")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_clinkz'] = function ()
	return CheckHighPriorityChannelAbility("clinkz_burning_barrage")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_tiny'] = function ()
	return CheckHighPriorityChannelAbility("tiny_tree_channel")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_hoodwink'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("hoodwink_sharpshooter") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_hoodwink_sharpshooter_windup') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_void_spirit'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("void_spirit_dissimilate") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_void_spirit_dissimilate_phase")
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_primal_beast'] = function ()
	S.cAbility = bot:GetAbilityByName("primal_beast_onslaught")
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_primal_beast_onslaught_windup') or bot:HasModifier('modifier_prevent_taunts') or bot:HasModifier('modifier_primal_beast_onslaught_movement_adjustable') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end

	S.cAbility = bot:GetAbilityByName("primal_beast_trample")
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or (bot:HasModifier('modifier_primal_beast_trample') and J.GetHP(bot) > 0.3) then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end

	S.cAbility = bot:GetAbilityByName("primal_beast_pulverize")
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_primal_beast_pulverize_self') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_batrider'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("batrider_flaming_lasso") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_batrider_flaming_lasso_self")
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_enigma'] = function ()
	return CheckHighPriorityChannelAbility("enigma_black_hole")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_keeper_of_the_light'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("keeper_of_the_light_illuminate") end
	if S.cAbility:IsInAbilityPhase() or bot:IsChanneling() or bot:HasModifier('modifier_keeper_of_the_light_illuminate') then
		return BOT_MODE_DESIRE_ABSOLUTE
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_meepo'] = function ()
	return CheckHighPriorityChannelAbility("meepo_poof")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_monkey_king'] = function ()
	return CheckHighPriorityChannelAbility("monkey_king_primal_spring")
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_nyx_assassin'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("nyx_assassin_vendetta") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_nyx_assassin_vendetta')
		then
			if bot.canVendettaKill
			then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_pangolier'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("pangolier_gyroshell") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_pangolier_gyroshell')
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_phoenix'] = function ()
	S.cAbility = bot:GetAbilityByName("phoenix_supernova")
	if S.cAbility:IsTrained()
	then
		if bot:HasModifier('modifier_phoenix_supernova_hiding') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end

	S.cAbility = bot:GetAbilityByName("phoenix_sun_ray")
	if S.cAbility:IsTrained()
	then
		if bot:HasModifier('modifier_phoenix_sun_ray')
		then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_puck'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("puck_phase_shift") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_puck_phase_shift') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_ringmaster'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("ringmaster_tame_the_beasts") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier("modifier_ringmaster_tame_the_beasts") then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_snapfire'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("snapfire_mortimer_kisses") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_snapfire_mortimer_kisses') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_spirit_breaker'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("spirit_breaker_charge_of_darkness") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:HasModifier('modifier_spirit_breaker_charge_of_darkness') then
			return BOT_MODE_DESIRE_ABSOLUTE * 1.2
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_windrunner'] = function ()
	return CheckHighPriorityChannelAbility("windrunner_powershot")
end
S.ConsiderHeroSpecificRoaming['npc_dota_hero_invoker'] = function ()
	if J.IsValid(S.botTarget)
	and GetUnitToUnitDistance(bot, S.botTarget) < bot:GetAttackRange() - 100
	and (S.botTarget:HasModifier("modifier_invoker_tornado") or S.botTarget:HasModifier("modifier_item_wind_waker")
		or S.botTarget:HasModifier("modifier_eul_cyclone") or S.botTarget:HasModifier("modifier_item_cyclone") or S.botTarget:IsInvulnerable())
	and (J.GetHP(S.botTarget) > 0.3 or J.GetHP(S.botTarget) > J.GetHP(bot)) then
		return BOT_MODE_DESIRE_ABSOLUTE * 0.96
	end
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_tinker'] = function ()
	if S.cAbility == nil then S.cAbility = bot:GetAbilityByName("tinker_rearm") end
	if S.cAbility:IsTrained()
	then
		if S.cAbility:IsInAbilityPhase() or bot:IsChanneling() or bot:HasModifier('modifier_tinker_rearm') then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_leshrac'] = function ()
	if bot:HasModifier("modifier_leshrac_diabolic_edict")
	then
		local DiabolicEdict = bot:GetAbilityByName('leshrac_diabolic_edict')
		if DiabolicEdict:IsTrained()
		then
			local nRadius = DiabolicEdict:GetSpecialValueInt('radius')
			if J.IsPushing(bot)
			then
				local nEnemyTowers = bot:GetNearbyTowers(1600, true)
				local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
				if nEnemyTowers ~= nil and #nEnemyTowers >= 1
				and J.IsValidBuilding(nEnemyTowers[1])
				and J.CanBeAttacked(nEnemyTowers[1])
				and not J.IsInRange(bot, nEnemyTowers[1], nRadius - 75)
				and nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps <= 2
				then
					S.EdictTowerTarget = nEnemyTowers[1]
					return BOT_MODE_DESIRE_VERYHIGH
				end
			end
		end
	end

	if bot:HasModifier("modifier_leshrac_pulse_nova")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and J.GetHP(bot) > J.GetHP(S.botTarget) then
			if GetUnitToUnitDistance(bot, S.botTarget) > 400
			then
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_lone_druid_bear'] = function ()
	if J.IsTryingtoUseAbility(bot) then return BOT_MODE_DESIRE_NONE end

	local hero = J.Utils.GetLoneDruid(bot).hero
	local heroTarget = hero:GetAttackTarget()
	local hasUltimateScepter = J.Item.HasItem(bot, 'item_ultimate_scepter') or bot:HasModifier('modifier_item_ultimate_scepter_consumed')
    local distanceFromHero = GetUnitToUnitDistance(J.Utils.GetLoneDruid(bot).hero, bot)

    if J.IsValidHero(hero)
	and J.GetHP(bot) >= J.GetHP(hero) - 0.2 -- hp is higher or within 20% lower than hero.
	and J.GetHP(bot) > 0.25
	and not hasUltimateScepter
	then
        if distanceFromHero > BearAttackLimitDistance then
			return BOT_MODE_DESIRE_ABSOLUTE * 1.2
        end
		local avoidDangerous = (#bot:GetNearbyLaneCreeps(400, true) < 3 and #bot:GetNearbyTowers(800, true) == 0) or bot:GetLevel() >= 3
		if J.Utils.IsValidUnit(heroTarget)
		and distanceFromHero <= BearAttackLimitDistance
		and GetUnitToUnitDistance(hero, heroTarget) < BearAttackLimitDistance + 250
		and avoidDangerous
		then
			return BOT_MODE_DESIRE_ABSOLUTE * 1.2
		end

		local target = J.GetAttackableWeakestUnitFromList(hero, hero:GetNearbyHeroes(BearAttackLimitDistance + 250, true, BOT_MODE_NONE))
		if target ~= nil
		and avoidDangerous
		then
			return BOT_MODE_DESIRE_ABSOLUTE * 1.2
		end
    end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_marci'] = function ()
	if bot:HasModifier("modifier_marci_unleash")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and J.GetHP(bot) > J.GetHP(S.botTarget) then
			if J.IsInTeamFight(bot, 1500) then
				return BOT_MODE_DESIRE_VERYHIGH
			end
			if J.IsGoingOnSomeone(bot) and #S.nInRangeEnemy >= 1 then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_wisp'] = function ()
	if bot:HasModifier("modifier_wisp_tether") and DotaTime() > 60
	then
		if J.IsValid(bot.stateTetheredHero)
		and J.GetHP(bot) > 0.5
		and GetUnitToUnitDistance(bot, bot.stateTetheredHero) > TetherBreakDistance - 200 then
			return BOT_MODE_DESIRE_ABSOLUTE * 0.85
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_pudge'] = function ()
	local Rot = bot:GetAbilityByName('pudge_rot')
	if Rot ~= nil and Rot:GetToggleState() and J.WeAreStronger(bot, 1200)
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and J.GetHP(bot) > J.GetHP(S.botTarget) then
			return BOT_MODE_DESIRE_ABSOLUTE * 0.85
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_muerta'] = function ()
	if bot:HasModifier("modifier_muerta_pierce_the_veil_buff")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and J.GetHP(bot) > 0.2 then
			if J.IsInTeamFight(bot, 1500) then
				return BOT_MODE_DESIRE_VERYHIGH
			end
			if J.IsGoingOnSomeone(bot) and #S.nInRangeEnemy >= 1 then
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_razor'] = function ()
	if bot:HasModifier("modifier_razor_static_link_buff")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidHero(S.botTarget) and J.GetHP(bot) > 0.3 and J.GetHP(bot) >= J.GetHP(S.botTarget) then
			if S.enemyTowers == nil or #S.enemyTowers == 0 or GetUnitToUnitDistance(bot, S.enemyTowers[1]) > 850 then
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_faceless_void'] = function ()
	if bot:HasModifier("modifier_faceless_void_chronosphere")
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidTarget(S.botTarget) and J.GetHP(bot) > 0.25
		and J.IsLocationInChrono(S.botTarget:GetLocation()) then
			return BOT_MODE_DESIRE_VERYHIGH
		end
	end
	return BOT_MODE_DESIRE_NONE
end

S.ConsiderHeroSpecificRoaming['npc_dota_hero_nevermore'] = function ()
	bot.invisUltCombo = false
	if J.Utils.IsTruelyInvisible(bot)
	and bot:GetAbilityByName("nevermore_requiem"):IsFullyCastable()
	then
		local botTarget = J.GetProperTarget(bot)
		if J.IsValidHero(S.botTarget) and J.GetHP(bot) > 0.5 and J.GetHP(S.botTarget) > 0.5 and S.botTarget:GetHealth() > 800 then
			if S.enemyTowers == nil or #S.enemyTowers == 0 or GetUnitToUnitDistance(bot, S.enemyTowers[1]) > 850 then
				bot.invisUltCombo = true
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	return BOT_MODE_DESIRE_NONE
end

end
