-- jmz_func sub-module: jmz_item
return function(J)


function J.HasItemInInventory( hItem )
	return GetBot():FindItemSlot(hItem) >= 0
end


function J.GetItem(itemName)
	for i = 0, 5
    do
		local item = GetBot():GetItemInSlot(i)

		if  item ~= nil
        and item:GetName() == itemName
        then
			return item
		end
	end

	return nil
end


function J.GetItem2(bot, sItemName)
	for i = 0, 16
	do
		local item = bot:GetItemInSlot(i)
		if item ~= nil
		then
			if string.find(item:GetName(), sItemName)
			then
				return item
			end
		end
	end

	return nil
end


function J.GetAbility(bot, abilityName)
	for i = 0, 23 do
		local ability = bot:GetAbilityInSlot(i)
		if  ability ~= nil
		and ability:GetName() == abilityName
		then
			return ability
		end
	end

	return nil
end



function J.GetComboItem( bot, sItemName )

	local Slot = bot:FindItemSlot( sItemName )

	if Slot >= 0 and Slot <= 5
	then
		return bot:GetItemInSlot( Slot )
	end

end



function J.HasItem( bot, sItemName )

	local Slot = bot:FindItemSlot( sItemName )

	if Slot >= 0 and Slot <= 5 then	return true end

	return false

end


function J.FindItemSlotNotInNonbackpack( bot, sItemName )
	local Slot = bot:FindItemSlot( sItemName )
	if Slot >= 0 and Slot <= 5 then	return Slot end
	return -1
end


function J.IsItemAvailable( sItemName )

	local bot = GetBot()

	local slot = bot:FindItemSlot( sItemName )

	if slot >= 0 and slot <= 5
	then
		return bot:GetItemInSlot( slot )
	end

end


function J.HasHealingItem(bot)
	return (J.HasItem(bot, "item_tango") or bot:HasModifier("modifier_tango_heal"))
		or (J.HasItem(bot, "item_flask") or bot:HasModifier("modifier_flask_healing"))
		or (J.HasItem(bot, "item_bottle") or bot:HasModifier("modifier_bottle_regeneration"))
end



function J.SetQueueToInvisible( bot )

	if bot:IsAlive()
		and not bot:IsInvisible()
		and not bot:HasModifier( "modifier_item_dustofappearance" )
	then
		local enemyTowerList = bot:GetNearbyTowers( 888, true )

		if enemyTowerList[1] ~= nil then return end

		local itemAmulet = J.IsItemAvailable( 'item_shadow_amulet' )
		if itemAmulet ~= nil
			and itemAmulet:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( itemAmulet, bot )
			return
		end
	
		local itemGlimer = J.IsItemAvailable( 'item_glimmer_cape' )
		if itemGlimer ~= nil and itemGlimer:IsFullyCastable()
		then
			bot:ActionQueue_UseAbilityOnEntity( itemGlimer, bot )
			return
		end

		local itemInvisSword = J.IsItemAvailable( 'item_invis_sword' )
		if itemInvisSword ~= nil and itemInvisSword:IsFullyCastable()
		then
			bot:ActionQueue_UseAbility( itemInvisSword )
			return
		end

		local itemSilverEdge = J.IsItemAvailable( 'item_silver_edge' )
		if itemSilverEdge ~= nil and itemSilverEdge:IsFullyCastable()
		then
			bot:ActionQueue_UseAbility( itemSilverEdge )
			return
		end

	end


end



function J.SetQueueSwitchPtToINT( bot )

	local pt = J.IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() == ATTRIBUTE_INTELLECT
		then
			bot:ActionQueue_UseAbility( pt )
			bot:ActionQueue_UseAbility( pt )
			return
		elseif pt:GetPowerTreadsStat() == ATTRIBUTE_STRENGTH
			then
				bot:ActionQueue_UseAbility( pt )
				return
		end
	end

end



function J.SetQueueUseSoulRing( bot )

	local sr = J.IsItemAvailable( "item_soul_ring" )

	if sr ~= nil and sr:IsFullyCastable()
	then
		local nEnemyCount = J.GetEnemyCount( bot, 1600 )
		local botHP = J.GetHP( bot )
		local botMP = J.GetMP( bot )
		if botHP > 0.35 + 0.1 * nEnemyCount
			and botMP < 0.99 - 0.1 * nEnemyCount
			and ( nEnemyCount <= 2 or botHP > botMP * 2.5 )
		then
			bot:ActionQueue_UseAbility( sr )
			return
		end
	end

end



function J.SetQueuePtToINT( bot, bSoulRingUsed )

	bot:Action_ClearActions(false)

	if bSoulRingUsed then J.SetQueueUseSoulRing( bot ) end

	if not J.IsPTReady( bot, ATTRIBUTE_INTELLECT )
	then
		J.SetQueueSwitchPtToINT( bot )
	end

end


-- 动力鞋/假腿状态
function J.IsPTReady( bot, status )

	if not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsChanneling()
		or bot:IsInvisible()
		or bot:GetHealth() / bot:GetMaxHealth() < 0.2
	then
		return true
	end

	if status == ATTRIBUTE_INTELLECT
	then
		status = ATTRIBUTE_AGILITY
	elseif status == ATTRIBUTE_AGILITY
		then
			status = ATTRIBUTE_INTELLECT
	end

	local pt = J.IsItemAvailable( "item_power_treads" )
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() ~= status
		then
			return false
		end
	end

	return true

end



function J.ShouldSwitchPTStat( bot, pt )

	local ptStatus = pt:GetPowerTreadsStat()
	local botAttribute = bot:GetPrimaryAttribute()
	
	
	if ptStatus == ATTRIBUTE_INTELLECT
	then
		ptStatus = ATTRIBUTE_AGILITY
	elseif ptStatus == ATTRIBUTE_AGILITY
		then
			ptStatus = ATTRIBUTE_INTELLECT
	end
	
	if botAttribute ~= ATTRIBUTE_INTELLECT
		and botAttribute ~= ATTRIBUTE_STRENGTH
		and botAttribute ~= ATTRIBUTE_AGILITY
	then
		return ptStatus ~= ATTRIBUTE_STRENGTH
	end

	return botAttribute ~= ptStatus

end


function J.HasAghanimsShard(bot)
	return bot:HasModifier("modifier_item_aghanims_shard")
end


function J.HasInvisibilityOrItem( npcEnemy )

	if npcEnemy:HasInvisibility( false )
		or J.HasItem( npcEnemy, "item_shadow_amulet" )
		or J.HasItem( npcEnemy, "item_glimmer_cape" )
		or J.HasItem( npcEnemy, "item_invis_sword" )
		or J.HasItem( npcEnemy, "item_silver_edge" )
	then
		return true
	end

	return false

end


function J.HasAbility(bot, abilityName)
	for i = 0, 23
	do
		local ability = bot:GetAbilityInSlot(i)
		if  ability ~= nil
		and ability:GetName() == abilityName
		then
			return true, ability
		end
	end

	return false, nil
end


function J.IsUnitWillGoInvisible(unit)
	return unit:HasModifier('modifier_sandking_sand_storm')
		or unit:HasModifier('modifier_bounty_hunter_wind_walk')
		or unit:HasModifier('modifier_clinkz_wind_walk')
		or unit:HasModifier('modifier_weaver_shukuchi')
		or (unit:HasModifier('modifier_oracle_false_promise') and unit:HasModifier('modifier_oracle_false_promise_invis'))
		or (unit:HasModifier('modifier_windrunner_windrun') and unit:HasModifier('modifier_windrunner_windrun_invis'))
		or unit:HasModifier('modifier_item_invisibility_edge')
		or unit:HasModifier('modifier_item_invisibility_edge_windwalk')
		or unit:HasModifier('modifier_item_silver_edge')
		or unit:HasModifier('modifier_item_silver_edge_windwalk')
		or unit:HasModifier('modifier_item_glimmer_cape_fade')
		or unit:HasModifier('modifier_item_glimmer_cape')
		or unit:HasModifier('modifier_item_shadow_amulet')
		or unit:HasModifier('modifier_item_shadow_amulet_fade')
		or unit:HasModifier('modifier_item_trickster_cloak_invis')
end


function J.HasInvisCounterBuff(unit)
	if unit:HasModifier('modifier_item_dustofappearance')
	or unit:HasModifier('modifier_bounty_hunter_track')
	or unit:HasModifier('modifier_bloodseeker_thirst_vision')
	or unit:HasModifier('modifier_slardar_amplify_damage')
	or unit:HasModifier('modifier_sniper_assassinate')
	or unit:HasModifier( 'modifier_faceless_void_chronosphere_freeze' )
	then
		return true
	end

	return false
end


function J.HasPowerTreads(bot)
	if J.HasItem(bot, 'item_power_treads')
	or J.HasItem(bot, 'item_power_treads_agi')
	or J.HasItem(bot, 'item_power_treads_int')
	or J.HasItem(bot, 'item_power_treads_str')
	then
		return true
	end

	return false
end

end
