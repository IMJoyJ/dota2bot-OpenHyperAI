-- jmz_func sub-module: jmz_cast
return function(J)

local fKeepManaPercent = 0.39
local maxAddedRange = 200
local maxGetRange = 1600
local maxLevel = 30


function J.GetUltimateAbility( bot )

	return bot:GetAbilityInSlot( 5 )

end



function J.CanUseRefresherShard( bot )

	local ult = J.GetUltimateAbility( bot )

	if ult ~= nil
		and ult:IsPassive() == false
	then
		local ultCD = ult:GetCooldown()
		local manaCost = ult:GetManaCost()
		local ultInCooldownAtLeast = 2 -- don't directly use refresh if the ult was just use.

		if bot:GetMana() >= manaCost * 2
			and ult:GetCooldownTimeRemaining() >= ultCD / 2
			and ultCD - ult:GetCooldownTimeRemaining() >= ultInCooldownAtLeast
		then
			return true
		end
	end

	return false

end



function J.CanUseRefresherOrb( bot )

	local ult = J.GetUltimateAbility( bot )

	if ult ~= nil
		and ult:IsPassive() == false
	then
		local ultCD = ult:GetCooldown()
		local manaCost = ult:GetManaCost()
		if bot:GetMana() >= manaCost + 375
			and ult:GetCooldownTimeRemaining() >= ultCD / 2
		then
			return true
		end
	end

	return false
end



function J.CanCastAbilityOnTarget( npcTarget, bIgnoreMagicImmune )

	return npcTarget:CanBeSeen()
			and ( bIgnoreMagicImmune or not npcTarget:IsMagicImmune() )
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			-- and not J.IsAllyCanKill( npcTarget )

end


function J.CanCastAbility(ability)
	if ability == nil
	or ability:IsNull()
	or ability:IsPassive()
	or ability:IsHidden()
	or not ability:IsTrained()
	or not ability:IsFullyCastable()
	or not ability:IsActivated()
	then
		return false
	end

	return true
end


function J.CanBlinkDagger(bot)
    local blink = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil
        and (item:GetName() == "item_blink" or item:GetName() == "item_overwhelming_blink" or item:GetName() == "item_arcane_blink" or item:GetName() == "item_swift_blink")
        then
			blink = item
			break
		end
	end

    if blink ~= nil and blink:IsFullyCastable()
	then
        bot.Blink = blink
        return true
	end

    return false
end


function J.CanBlackKingBar(bot)
    local bkb = nil

    for i = 0, 5
    do
		local item = bot:GetItemInSlot(i)

		if item ~= nil and item:GetName() == "item_black_king_bar"
        then
			bkb = item
			break
		end
	end

    if bkb ~= nil and bkb:IsFullyCastable()
	then
        bot.BlackKingBar = bkb
        return true
	end

    return false
end


function J.CanCastOnMagicImmune( npcTarget )
	return npcTarget:CanBeSeen()
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )
			-- and not J.IsAllyCanKill( npcTarget )

end


function J.IsNotImmune(botTarget)
	return J.IsValidTarget(botTarget)
	and botTarget:CanBeSeen()
	and not botTarget:IsInvulnerable()
	and not botTarget:IsMagicImmune()
end


function J.FilterEnemiesForStun(enemies)
	local filteredenemies = {}
	for v, enemy in pairs(enemies) do
		if not J.IsSuspiciousIllusion(enemy) and not enemy:IsRooted() and not enemy:IsStunned() and not enemy:IsHexed() and not enemy:IsNightmared() and not J.IsTaunted(enemy) then
			table.insert(filteredenemies, enemy)
		end
	end
	return filteredenemies
end



function J.CanCastOnNonMagicImmune( npcTarget )

	return npcTarget:CanBeSeen()
			and not npcTarget:IsMagicImmune()
			and not npcTarget:IsInvulnerable()
			and not J.IsSuspiciousIllusion( npcTarget )
			and not J.HasForbiddenModifier( npcTarget )

end


function J.IsInEtherealForm( npcTarget )
	return npcTarget:HasModifier( "modifier_ghost_state" )
    or npcTarget:HasModifier( "modifier_item_ethereal_blade_ethereal" )
    or npcTarget:HasModifier( "modifier_necrolyte_death_seeker" )
    or npcTarget:HasModifier( "modifier_necrolyte_sadist_active" )
    or npcTarget:HasModifier( "modifier_pugna_decrepify" )
end


function J.CanCastOnTargetAdvanced( npcTarget )
	if J.IsSuspiciousIllusion(npcTarget) then return false end
	if npcTarget:GetUnitName() == 'npc_dota_hero_antimage' --and npcTarget:IsBot()
	then

		if npcTarget:HasModifier( "modifier_antimage_spell_shield" )
			and J.GetModifierTime( npcTarget, "modifier_antimage_spell_shield" ) > 0.27
		then
			return false
		end

		if npcTarget:IsSilenced()
			or npcTarget:IsStunned()
			or npcTarget:IsHexed()
			or npcTarget:IsNightmared()
			or npcTarget:IsChanneling()
			or J.IsTaunted( npcTarget )
			or npcTarget:GetMana() < 45
			or ( npcTarget:HasModifier( "modifier_antimage_spell_shield" )
				and J.GetModifierTime( npcTarget, "modifier_antimage_spell_shield" ) < 0.27 )
		then
			if not npcTarget:HasModifier( "modifier_item_sphere_target" )
				and not npcTarget:HasModifier( "modifier_item_lotus_orb_active" )
				and not npcTarget:HasModifier( "modifier_item_aeon_disk_buff" )
				and ( not npcTarget:HasModifier( "modifier_dazzle_shallow_grave" ) or npcTarget:GetHealth() > 300 )
			then
				return true
			end
		end

		return false
	end

	return not npcTarget:HasModifier( "modifier_item_sphere_target" )
			and not npcTarget:HasModifier( "modifier_antimage_spell_shield" )
			and not npcTarget:HasModifier( "modifier_brewmaster_earth_spell_immunity" )
			and not npcTarget:HasModifier( "modifier_item_lotus_orb_active" )
			and not npcTarget:HasModifier( "modifier_item_aeon_disk_buff" )
			and not npcTarget:HasModifier( "modifier_roshan_spell_block" )
			and ( not npcTarget:HasModifier( "modifier_dazzle_shallow_grave" ) or npcTarget:GetHealth() > 300 )

end


--加入时间后的进阶函数
function J.CanCastUnitSpellOnTarget( npcTarget, nDelay )

	for _, modifier in pairs( J.Buff["hero_has_spell_shield"] )
	do
		if npcTarget:HasModifier( modifier )
			and J.GetModifierTime( npcTarget, modifier ) >= nDelay
		then
			return false
		end
	end

	return true

end



function J.IsAllowedToSpam( bot, nManaCost )

	if bot:HasModifier( "modifier_silencer_curse_of_the_silent" ) then return false end

	if bot:HasModifier( "modifier_rune_regen" ) then return true end

	return ( bot:GetMana() - nManaCost ) / bot:GetMaxMana() >= fKeepManaPercent

end



function J.IsAllyUnitSpell( sAbilityName )

	return J.Skill['sAllyUnitAbilityIndex'][sAbilityName] == true

end



function J.IsProjectileUnitSpell( sAbilityName )

	return J.Skill['sProjectileAbilityIndex'][sAbilityName] == true


end



function J.IsOnlyProjectileSpell( sAbilityName )

	return J.Skill['sOnlyProjectileAbilityIndex'][sAbilityName] == true

end



function J.IsStunProjectileSpell( sAbilityName )

	return J.Skill['sStunProjectileAbilityIndex'][sAbilityName] == true

end



function J.IsWillBeCastUnitTargetSpell( bot, nRadius )

	if nRadius > 1600 then nRadius = 1600 end

	local enemyList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )
	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 20 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
				and nAbility:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
			then
				local sAbilityName = nAbility:GetName()
				if not J.IsAllyUnitSpell( sAbilityName )
				then
					if J.IsInRange( npcEnemy, bot, 330 )
						or not J.IsProjectileUnitSpell( sAbilityName )
					then
						if not J.IsHumanPlayer( npcEnemy )
						then
							return true
						else
							local nCycle = npcEnemy:GetAnimCycle()
							local nPoint = nAbility:GetCastPoint()
							if nCycle > 0.1 and nPoint * ( 1 - nCycle ) < 0.27 --极限时机0.26
							then
								return true
							end
						end
					end
				end
			end
		end
	end

	return false

end



function J.IsWillBeCastPointSpell( bot, nRadius )

	local enemyList = J.GetNearbyHeroes(bot, nRadius, true, BOT_MODE_NONE )

	for _, npcEnemy in pairs( enemyList )
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
			and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
			and npcEnemy:IsFacingLocation( bot:GetLocation(), 50 )
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				if nAbility:GetBehavior() == ABILITY_BEHAVIOR_POINT
					or nAbility:GetBehavior() == ABILITY_BEHAVIOR_NO_TARGET
					or nAbility:GetBehavior() == 48
				then
					return true
				end
			end
		end
	end

	return false

end



function J.GetCastDelay( bot, unit, nPointTime, nProjectSpeed )

	local nDist = GetUnitToUnitDistance( bot, unit )

	local nDistTime = 0
	if nProjectSpeed ~= 0 then nDistTime = nDist / nProjectSpeed end

	return nPointTime + nDistTime

end



function J.CanBreakTeleport( bot, unit, nPointTime, nProjectSpeed )

	if unit:HasModifier( "modifier_teleporting" )
	then
		return J.GetCastPoint( bot, unit, nPointTime, nProjectSpeed ) < J.GetModifierTime( unit, "modifier_teleporting" )
	end

	return true

end


-- NEWLY ADDED FUNCTIONS FOR NEW HEROES AND BEHAVIOUR

function J.CanBeCast(ability)
	return ability:IsTrained() and ability:IsFullyCastable() and ability:IsHidden() == false;
end


function J.CanSpamSpell(bot, manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(3*30) );
end


function J.GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + maxAddedRange;
	elseif abilityCR + maxAddedRange <= maxGetRange then
		return abilityCR + maxAddedRange;
	elseif abilityCR > maxGetRange then
		return maxGetRange;
	else
		return abilityCR;
	end
end


function J.AllowedToSpam(bot, manaCost)
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( 1.0 - bot:GetLevel()/(2*maxLevel) );
end


function J.CanCastAbilitySoon(ability, fTime)
	if ability == nil
	or ability:IsNull()
	or ability:GetName() == ''
	or ability:IsPassive()
	or ability:IsHidden()
	or not ability:IsTrained()
	or not ability:IsActivated()
	then
		return false
	end

	if ability:GetCooldownTimeRemaining() > fTime then
		return false
	end

	return true
end


-- hAbilityList: handle / integer (mana)
function J.GetManaThreshold(bot, nManaCost, hAbilityList)
	local fManaThreshold = 0
	local botManaRegen = bot:GetManaRegen()
	local botMaxMana = bot:GetMaxMana()

	-- tp, bkb
	local itemSlots = {0, 1, 2, 3, 4, 5, 15}
	for i = 1, #itemSlots do
		local hItem = bot:GetItemInSlot(itemSlots[i])
		if hItem then
			local sItemName = hItem:GetName()
			if sItemName == 'item_tpscroll'
			or sItemName == 'item_black_king_bar'
			then
				local nManaCostItem = hItem:GetManaCost()
				if J.CanCastAbilitySoon(hItem, nManaCost / botManaRegen) then
					fManaThreshold = fManaThreshold + (nManaCostItem / botMaxMana)
				end
			end
		end
	end

	for _, hAbility in pairs(hAbilityList) do
		if type(hAbility) == 'number' then
			fManaThreshold = fManaThreshold + hAbility / botMaxMana
		else
			if J.CanCastAbilitySoon(hAbility, nManaCost / botManaRegen) then
				fManaThreshold = fManaThreshold + (hAbility:GetManaCost()) / botMaxMana
			end
		end
	end

	return fManaThreshold
end


function J.CheckLoneDruid()
	local ld = {hero=nil,bear=nil}
	for _, unit in pairs(GetUnitList(UNIT_LIST_ALL)) do
		if J.IsValid(unit) and not J.IsSuspiciousIllusion(unit) then
			local unitName = unit:GetUnitName()
			if unitName == 'npc_dota_hero_lone_druid' then
				ld.hero = unit
			elseif unitName == 'npc_dota_hero_lone_druid_bear' then
				ld.bear = unit
			end
		end
	end
	return ld
end


function J.GetManaAfter(manaCost)
	local bot = GetBot()
	return (bot:GetMana() - manaCost) / bot:GetMaxMana()
end

function J.GetHealthAfter(hpCost)
	local bot = GetBot()
	return (bot:GetHealth() - hpCost) / bot:GetMaxHealth()
end

end
