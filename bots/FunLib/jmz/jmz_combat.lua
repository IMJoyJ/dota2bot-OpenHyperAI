-- jmz_func sub-module: jmz_combat
return function(J)



function J.IsAllyCanKill( target )
	-- local cacheKey = 'IsAllyCanKill'..tostring(target:GetPlayerID())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	if target:GetHealth() / target:GetMaxHealth() > 0.38
	then
		-- J.Utils.SetCachedVars(cacheKey, false)
		return false
	end

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nTeamMember = GetTeamPlayers( GetTeam() )
	for i = 1, #nTeamMember
	do
		local ally = GetTeamMember( i )
		if ally ~= nil and ally:IsAlive() and ally:CanBeSeen()
			and ( ally:GetAttackTarget() == target )
			and GetUnitToUnitDistance( ally, target ) <= ally:GetAttackRange() + 50
		then
			nTotalDamage = nTotalDamage + ally:GetAttackDamage()
		end
	end

	nTotalDamage = nTotalDamage * 2.44 + J.GetAttackProjectileDamageByRange( target, 1200 )

	if J.CanKillTarget( target, nTotalDamage, nDamageType )
	then
		-- J.Utils.SetCachedVars(cacheKey, true)
		return true
	end

	-- J.Utils.SetCachedVars(cacheKey, false)
	return false

end



function J.IsOtherAllyCanKillTarget( bot, target )
	-- local cacheKey = 'IsOtherAllyCanKillTarget'..tostring(target:GetPlayerID())
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	if not J.IsValid(target) then
		-- J.Utils.SetCachedVars(cacheKey, false)
		return false
	end

	if target:GetHealth() / target:GetMaxHealth() > 0.38
	then
		-- J.Utils.SetCachedVars(cacheKey, false)
		return false
	end

	local nTotalDamage = 0
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nTeamMember = GetTeamPlayers( GetTeam() )

	for i = 1, #nTeamMember
	do
		local ally = GetTeamMember( i )
		if J.IsValidTarget(ally)
			and ally ~= bot
			and not J.IsDisabled( ally )
			and ally:GetHealth() / ally:GetMaxHealth() > 0.15
			and ally:IsFacingLocation( target:GetLocation(), 20 )
			and GetUnitToUnitDistance( ally, target ) <= ally:GetAttackRange() + 50
		then
			local allyTarget = J.GetProperTarget( ally )
			if allyTarget == nil or allyTarget == target or J.IsHumanPlayer( ally )
			then
				local allyDamageTime = J.IsHumanPlayer( ally ) and 6.0 or 2.0
				nTotalDamage = nTotalDamage + ally:GetEstimatedDamageToTarget( true, target, allyDamageTime, DAMAGE_TYPE_PHYSICAL )
			end
		end
	end

	if nTotalDamage > target:GetHealth()
	then
		-- J.Utils.SetCachedVars(cacheKey, true)
		return true
	end

	-- J.Utils.SetCachedVars(cacheKey, false)
	return false
end



function J.IsAllyHeroBetweenAllyAndEnemy( hAlly, hEnemy, vLoc, nRadius )

	local vStart = hAlly:GetLocation()
	local vEnd = vLoc
	local heroList = J.GetNearbyHeroes( hAlly, 1600, false, BOT_MODE_NONE )
	for i, hero in pairs( heroList )
	do
		if hero ~= hAlly
		then
			local tResult = PointToLineDistance( vStart, vEnd, hero:GetLocation() )
			if tResult ~= nil
				and tResult.within
				and tResult.distance <= nRadius + 50
			then
				return true
			end
		end
	end

	heroList = J.GetNearbyHeroes( hEnemy, 1600, true, BOT_MODE_NONE )
	for i, hero in pairs( heroList )
	do
		if hero ~= hAlly
		then
			local tResult = PointToLineDistance( vStart, vEnd, hero:GetLocation() )
			if tResult ~= nil
				and tResult.within
				and tResult.distance <= nRadius + 50
			then
				return true
			end
		end
	end

	return false

end



function J.CanKillTarget( npcTarget, dmg, dmgType )
	if dmgType == DAMAGE_TYPE_PURE then
		return dmg >= npcTarget:GetHealth()
	end

	return npcTarget:GetActualIncomingDamage( dmg, dmgType ) >= npcTarget:GetHealth()

end



--未计算技能增强
function J.WillKillTarget( npcTarget, dmg, dmgType, nDelay )

	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * nDelay + 0.8

	local nRealBonus = J.GetTotalAttackWillRealDamage( npcTarget, nDelay )

	local nTotalDamage = npcTarget:GetActualIncomingDamage( dmg, dmgType ) + nRealBonus

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1

end



--未计算技能增强
function J.WillMixedDamageKillTarget( npcTarget, nPhysicalDamge, nMagicalDamage, nPureDamage, nDelay )

	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * nDelay + 0.8

	local nRealBonus = J.GetTotalAttackWillRealDamage( npcTarget, nDelay )

	local nRealPhysicalDamge = npcTarget:GetActualIncomingDamage( nPhysicalDamge, DAMAGE_TYPE_PHYSICAL )

	local nRealMagicalDamge = npcTarget:GetActualIncomingDamage( nMagicalDamage, DAMAGE_TYPE_MAGICAL )

	local nRealPureDamge = npcTarget:GetActualIncomingDamage( nPureDamage, DAMAGE_TYPE_PURE )

	local nTotalDamage = nRealPhysicalDamge + nRealMagicalDamge + nRealPureDamge + nRealBonus

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1

end


--计算了技能增强
function J.WillMagicKillTarget( bot, npcTarget, dmg, nDelay )

	local nDamageType = DAMAGE_TYPE_MAGICAL

	local MagicResistReduce = 1 - npcTarget:GetMagicResist()

	if MagicResistReduce < 0.05 then MagicResistReduce = 0.05 end

	local HealthBack = npcTarget:GetHealthRegen() * nDelay

	local EstDamage = dmg * ( 1 + bot:GetSpellAmp() ) - HealthBack / MagicResistReduce

	if npcTarget:HasModifier( "modifier_medusa_mana_shield" )
	then
		local EstDamageMaxReduce = EstDamage * 0.98
		if npcTarget:GetMana() * 2.8 >= EstDamageMaxReduce
		then
			EstDamage = EstDamage * 0.04
		else
			EstDamage = EstDamage * 0.02 + EstDamageMaxReduce - npcTarget:GetMana() * 2.8
		end
	end

	if npcTarget:GetUnitName() == "npc_dota_hero_bristleback"
		and not npcTarget:IsFacingLocation( bot:GetLocation(), 120 )
	then
		EstDamage = EstDamage * 0.7
	end

	if npcTarget:HasModifier( "modifier_kunkka_ghost_ship_damage_delay" )
	then
		local buffTime = J.GetModifierTime( npcTarget, "modifier_kunkka_ghost_ship_damage_delay" )
		if buffTime >= nDelay then EstDamage = EstDamage * 0.55 end
	end

	if npcTarget:HasModifier( "modifier_templar_assassin_refraction_absorb" )
	then
		local buffTime = J.GetModifierTime( npcTarget, "modifier_templar_assassin_refraction_absorb" )
		if buffTime >= nDelay then EstDamage = 0 end
	end

	local nRealDamage = npcTarget:GetActualIncomingDamage( EstDamage, nDamageType )

	return nRealDamage >= npcTarget:GetHealth() --, nRealDamage

end

function J.IsTargetedByEnemyWithModifier(tUnits, sModifierName)
    for _, enemyHero in pairs(tUnits) do
        if J.IsValidHero(enemyHero)
        and enemyHero:HasModifier(sModifierName)
        and (enemyHero:GetAttackTarget() == bot or J.IsChasingTarget(enemyHero, bot))
        then
            return true
        end
    end

    return false
end


function J.ShouldEscape( bot )

	local tableNearbyAttackAllies = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_ATTACK )

	if #tableNearbyAttackAllies > 0 and J.GetHP( bot ) > 0.16 then return false end

	local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
	if bot:WasRecentlyDamagedByAnyHero( 2.0 )
		or bot:WasRecentlyDamagedByTower( 2.0 )
		or #tableNearbyEnemyHeroes >= 2
	then
		return true
	end
end

local function IsEnemyTerrorbladeNear(unit, nRadius)
	for _, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
		if J.IsValidHero(enemy)
		and J.IsInRange(unit, enemy, nRadius)
		and enemy:GetUnitName() == 'npc_dota_hero_terrorblade'
		and not J.IsSuspiciousIllusion(enemy)
		then
			return true
		end
	end

	return false
end

local function GetUnitAttackDamage(unit, fInterval, bIllusion)
	if J.IsValid(unit) then
		local nAttackDamage = unit:GetAttackDamage()
		local sUnitName = unit:GetUnitName()

		if bIllusion and J.IsSuspiciousIllusion(unit) then
			if string.find(sUnitName, 'phantom_lancer') then
				nAttackDamage = nAttackDamage * 0.19
			elseif string.find(sUnitName, 'naga_siren') then
				nAttackDamage = nAttackDamage * 0.4
			elseif string.find(sUnitName, 'chaos_knight') then
				-- full
			elseif string.find(sUnitName, 'terrorblade') then
				if IsEnemyTerrorbladeNear(unit, 1200) then
					nAttackDamage = nAttackDamage * 0.6 * (1.25)
				else
					nAttackDamage = nAttackDamage * 0.6 * (0.60)
				end
			elseif unit:HasModifier('modifier_darkseer_wallofreplica_illusion') then
				nAttackDamage = nAttackDamage * 0.9
			elseif unit:HasModifier('modifier_grimstroke_scepter_buff') then
				nAttackDamage = nAttackDamage * 1.5
			else
				nAttackDamage = nAttackDamage * 0.33
			end

			return nAttackDamage * unit:GetAttackSpeed() * fInterval
		else
			if not bIllusion then
				return nAttackDamage * unit:GetAttackSpeed() * fInterval
			end
		end
	end


	return nil
end


function J.CannotBeKilled(bot, botTarget)
	return J.IsValidHero( botTarget )
	and (
		(J.GetModifierTime(botTarget, 'modifier_dazzle_shallow_grave') > 0.6 and J.GetHP(botTarget) < 0.15 and (bot == nil or bot:GetUnitName() ~= "npc_dota_hero_axe"))
		or J.GetModifierTime(botTarget, 'modifier_oracle_false_promise_timer') > 0.6
		or botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		or botTarget:HasModifier('modifier_item_helm_of_the_undying_active')
		or botTarget:HasModifier('modifier_item_aeon_disk_buff')
		or botTarget:HasModifier('modifier_abaddon_borrowed_time')
	)
end


function J.CanIgnoreLowHp(bot)
	return J.GetModifierTime(bot, 'modifier_dazzle_shallow_grave') > 0.6
	or J.GetModifierTime(bot, 'modifier_oracle_false_promise_timer') > 0.6
end


function J.CanBeAttacked( unit )
	return  unit ~= nil
			and not J.HasForbiddenModifier( unit )
			and unit:IsAlive()
			and unit:CanBeSeen()
			and not unit:IsNull()
			and not unit:IsAttackImmune()
			and not unit:IsInvulnerable()
			and not unit:HasModifier("modifier_fountain_glyph")
			and not unit:HasModifier("modifier_omninight_guardian_angel")
			and not unit:HasModifier("modifier_winter_wyvern_cold_embrace")
			and not unit:HasModifier("modifier_dark_willow_shadow_realm_buff")
			and not unit:HasModifier("modifier_ringmaster_the_box_buff")
			and not unit:HasModifier("modifier_dazzle_nothl_projection_soul_debuff")
			and (unit:GetTeam() == GetTeam() 
					or not unit:HasModifier("modifier_crystal_maiden_frostbite") )
			and (unit:GetTeam() ~= GetTeam() 
			     or ( unit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior" 
					  and unit:GetHealth()/unit:GetMaxHealth() < 0.5 ) )
end

local function GetEffectiveHealthFromArmor(nHealth, fArmor)
    local damageMultiplier = 1 - ((0.06 * fArmor) / (1 + 0.06 * math.abs(fArmor)))
    return nHealth / damageMultiplier
end

local function GetHealthMultiplier(hUnit)
	local mul = 1
	local sUnitName = hUnit:GetUnitName()
	local botHP = J.GetHP(hUnit) + (hUnit:GetHealthRegen() * 5.0 / hUnit:GetMaxHealth())
	local botMP = J.GetMP(hUnit) + (hUnit:GetManaRegen() * 5.0 / hUnit:GetMaxMana())
	if sUnitName == 'npc_dota_hero_huskar' then
		botHP = ((GetEffectiveHealthFromArmor(hUnit:GetHealth(), hUnit:GetArmor())) / hUnit:GetMaxHealth()) + (hUnit:GetHealthRegen() * 5.0 / hUnit:GetMaxHealth())
		mul = RemapValClamped(botHP, 0, 0.5, 0.5, 1)
	elseif sUnitName == 'npc_dota_hero_medusa' then
		local unitHealth = GetEffectiveHealthFromArmor(hUnit:GetHealth() - hUnit:GetMana(), hUnit:GetArmor())
		local unitMaxHealth = hUnit:GetMaxHealth() - hUnit:GetMaxMana()
		local nHealth = RemapValClamped(unitHealth / unitMaxHealth, 0, 1, 0, 1) * 0.2 + RemapValClamped(botMP, 0, 0.75, 0, 1) * 0.8
		mul = RemapValClamped(nHealth, 0.5, 1, 0.5, 1)
	else
		botHP = ((GetEffectiveHealthFromArmor(hUnit:GetHealth(), hUnit:GetArmor())) / hUnit:GetMaxHealth()) + (hUnit:GetHealthRegen() * 5.0 / hUnit:GetMaxHealth())
		local nHealth = RemapValClamped(botHP, 0, 0.75, 0, 1) * 0.8 + RemapValClamped(botMP, 0, 1, 0, 1) * 0.2
		mul = RemapValClamped(nHealth, 0.5, 1, 0.5, 1)
	end

	return mul
end


function J.WeAreStronger(bot, nRadius)
	local cacheKey = 'WeAreStronger'..tostring(bot:GetPlayerID())..'-'..tostring(nRadius)
	local cachedVar = J.Utils.GetCachedVars(cacheKey, 0.5)
	if cachedVar ~= nil then return cachedVar end

	local tAllyHeroes = {}
	local tEnemyHeroes = {}
	local ourPower = 0
	local ourPowerRaw = 0
	local enemyPower = 0
	local botHealthRegen =  bot:GetHealthRegen() * 2.0

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALL)) do
		if J.IsValidHero(unit)
		and GetUnitToUnitDistance(bot, unit) <= nRadius
		and J.GetHP(unit) > 0.1
		and not unit:HasModifier('modifier_necrolyte_reapers_scythe')
		and not unit:HasModifier('modifier_dazzle_nothl_projection_physical_body_debuff')
		and not unit:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
		and not unit:HasModifier('modifier_item_helm_of_the_undying_active')
		and not unit:HasModifier('modifier_teleporting')
		and unit:GetTeam() ~= TEAM_NEUTRAL
		and unit:GetTeam() ~= TEAM_NONE
		then
			local sUnitName = unit:GetUnitName()
			local fMul = GetHealthMultiplier(unit)
			local fMul_Illusion = RemapValClamped(J.GetHP(unit), 0.25, 1, 0, 1)

			if GetTeam() == unit:GetTeam() then
				if not unit:HasModifier('modifier_arc_warden_tempest_double')
				and J.IsSuspiciousIllusion(unit)
				then
					local nDamage = GetUnitAttackDamage(unit, 5.0, true)
					if nDamage then
						ourPower = ourPower + (math.log(1 + unit:GetOffensivePower())) * ((math.sqrt(Max(0, nDamage)))) * fMul_Illusion
						ourPowerRaw = ourPowerRaw + (math.log(1 + unit:GetRawOffensivePower())) * (math.sqrt(Max(0, nDamage))) * fMul_Illusion
					end
				else
					if not J.IsMeepoClone(unit)
					and not string.find(sUnitName, 'lone_druid_bear')
					and not unit:HasModifier('modifier_item_helm_of_the_undying_active')
					then
						table.insert(tAllyHeroes, unit)
					end
					ourPower = ourPower + (math.log(1 + unit:GetOffensivePower())) * (math.sqrt(unit:GetAttackDamage() * unit:GetAttackSpeed() * 5)) * fMul
					ourPowerRaw = ourPowerRaw + (math.log(1 + unit:GetRawOffensivePower())) * (math.sqrt(Max(0, unit:GetAttackDamage() * unit:GetAttackSpeed() * 5))) * fMul
				end
			else
				if not unit:HasModifier('modifier_arc_warden_tempest_double')
				and J.IsSuspiciousIllusion(unit)
				then
					local nDamage = GetUnitAttackDamage(unit, 5.0, true)
					if nDamage then
						enemyPower = enemyPower + (math.log(1 + unit:GetRawOffensivePower())) * (math.sqrt(Max(0, nDamage))) * fMul_Illusion
					end
				else
					if not J.IsMeepoClone(unit)
					and not string.find(sUnitName, 'lone_druid_bear')
					and not unit:HasModifier('modifier_item_helm_of_the_undying_active')
					then
						table.insert(tEnemyHeroes, unit)
					end
					enemyPower = enemyPower + (math.log(1 + unit:GetRawOffensivePower())) * (math.sqrt(Max(0, unit:GetAttackDamage() * unit:GetAttackSpeed() * 5))) * fMul
				end
			end
		end
	end

	local nAllyTowers = bot:GetNearbyTowers(600, false)
	if J.IsValidBuilding(nAllyTowers[1]) then
		if nAllyTowers[1]:HasModifier('modifier_fountain_glyph') then
			local power = #nAllyTowers * (math.sqrt(Max(0, nAllyTowers[1]:GetAttackDamage() * nAllyTowers[1]:GetAttackSpeed() * 5.0 * 2)))
			ourPower = ourPower + power
			ourPowerRaw = ourPowerRaw + power
		else
			local power = #nAllyTowers * (math.sqrt(Max(0, nAllyTowers[1]:GetAttackDamage() * nAllyTowers[1]:GetAttackSpeed() * 5.0)))
			ourPower = ourPower + power
			ourPowerRaw = ourPowerRaw + power
		end
	end

	if not J.IsEarlyGame() and J.IsInTeamFight(bot, 1600) and #tAllyHeroes >= #tEnemyHeroes then
		local vTeamFightLocation = J.GetTeamFightLocation(bot)
		if vTeamFightLocation ~= nil and (J.IsHumanInLoc(vTeamFightLocation, 1200) or #tAllyHeroes > #tEnemyHeroes) then
			ourPower = ourPower * 1.20
			ourPowerRaw = ourPowerRaw * 1.20
		end
	end

	local res = ourPowerRaw > enemyPower
	J.Utils.SetCachedVars(cacheKey, res)
	return res
end


function J.GetArmorReducers(hero)
	local reducedArmor = 0

	-- Items (Passives for now)
	if J.HasItem(hero, "item_desolator")
	and (hero:GetItemInSlot (6) ~= "item_desolator" or hero:GetItemInSlot(7) ~= "item_desolator" or hero:GetItemInSlot(8) ~= "item_desolator")
	then
		reducedArmor = reducedArmor + 6
	end

	if J.HasItem(hero, "item_assault")
	and (hero:GetItemInSlot (6) ~= "item_assault" or hero:GetItemInSlot(7) ~= "item_assault" or hero:GetItemInSlot(8) ~= "item_assault")
	then
		reducedArmor = reducedArmor + 5
	end

	if J.HasItem(hero, "item_blight_stone")
	and (hero:GetItemInSlot (6) ~= "item_blight_stone" or hero:GetItemInSlot(7) ~= "item_blight_stone" or hero:GetItemInSlot(8) ~= "item_blight_stone")
	then
		reducedArmor = reducedArmor + 2
	end

	-- Abilities (Passives for now)
	local NevermoreDarkLord = hero:GetAbilityByName("nevermore_dark_lord")
	if hero:GetUnitName() == "npc_dota_hero_nevermore"
	and NevermoreDarkLord ~= nil
	and NevermoreDarkLord:GetLevel() > 0
	then
		reducedArmor = reducedArmor + NevermoreDarkLord:GetSpecialValueInt("presence_armor_reduction")
	end

	local NagaSirenRiptide = hero:GetAbilityByName("naga_siren_rip_tide")
	if hero:GetUnitName() == "npc_dota_hero_naga_siren"
	and NagaSirenRiptide ~= nil
	and NagaSirenRiptide:GetLevel() > 0 then
		reducedArmor = reducedArmor + NagaSirenRiptide:GetSpecialValueInt("armor_reduction")
	end

	return reducedArmor
end


function J.HasEnoughDPSForRoshan(heroes)
    local DPS = 0
    local DPSThreshold = 0
    local plannedTimeToKill = 60

    -- Roshan Stats
    local baseHealth = 6000
    local baseArmor = 30
    local armorPerInterval = 0.375
    local maxHealthBonusPerInterval = 130 * 2

    local roshanHealth = baseHealth + maxHealthBonusPerInterval * math.floor(DotaTime() / 60)

    for _, h in pairs(heroes) do
        local roshanArmor = baseArmor + armorPerInterval * math.floor(DotaTime() / 60) - J.GetArmorReducers(h)

        -- Only right click damage for now
        local attackDamage = h:GetAttackDamage()
        local attackSpeed = h:GetAttackSpeed()

        local dps = attackDamage * attackSpeed * (1 - roshanArmor / (roshanArmor + 20))
        DPS = DPS + dps
    end

    DPS =  DPS / #heroes

    DPSThreshold = roshanHealth / plannedTimeToKill
    return DPS >= DPSThreshold
end


function J.GetTotalEstimatedDamageToTarget(nUnits, target)
	local dmg = 0

	for _, unit in pairs(nUnits)
	do
		if J.IsValid(unit)
		and J.IsValid(target)
		and not J.IsSuspiciousIllusion(unit)
		then
			dmg = dmg + unit:GetEstimatedDamageToTarget(true, target, 5, DAMAGE_TYPE_ALL)
		end
	end

	return dmg
end

end
