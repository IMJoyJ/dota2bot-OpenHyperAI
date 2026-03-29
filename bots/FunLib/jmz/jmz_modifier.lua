-- jmz_func sub-module: jmz_modifier
return function(J)

local TempMovableModifierNames = {
    'modifier_abaddon_borrowed_time',
    'modifier_dazzle_shallow_grave',
    'modifier_wind_waker', -- movability depends on whether who uses the item.
    'modifier_item_wind_waker',
    'modifier_oracle_false_promise_timer',
    'modifier_item_aeon_disk_buff'
}
local MovableUndyingModifierRemain = 0


-- check if the target will still have at least one movable undying modifier after nDelay seconds.
function J.HasMovableUndyingModifier(botTarget, nDelay)
    for _, mName in pairs(TempMovableModifierNames)
    do
        if botTarget:HasModifier(mName) then
            MovableUndyingModifierRemain = J.GetModifierTime(botTarget, mName)
            -- print(DotaTime().." - Target has undying modifier "..mName..", the remaining time: " .. tostring(MovableUndyingModifierRemain) .. " seconds, check delay: "..tostring(nDelay))
            if MovableUndyingModifierRemain > 0 then
				if MovableUndyingModifierRemain > nDelay then
					return true
				end
				return false
            end
        end
    end
    return false
end


function J.IsUnderLongDurationStun(enemyHero)
    return enemyHero:HasModifier('modifier_bane_fiends_grip')
    or enemyHero:HasModifier('modifier_legion_commander_duel')
    or enemyHero:HasModifier('modifier_enigma_black_hole_pull')
    or enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
    or enemyHero:HasModifier('modifier_magnataur_reverse_polarity')
    or enemyHero:HasModifier('modifier_tidehunter_ravage')
	or enemyHero:HasModifier('modifier_winter_wyvern_winters_curse_aura')
end



function J.HasForbiddenModifier( npcTarget )

	for _, mod in pairs( J.Buff['enemy_is_immune'] )
	do
		if npcTarget:HasModifier( mod )
		then
			return true
		end
	end

	if npcTarget:IsHero()
	then
		local enemies = J.GetNearbyHeroes(npcTarget, 800, false, BOT_MODE_NONE )
		if enemies ~= nil and #enemies >= 2
		then
			for _, mod in pairs( J.Buff['enemy_is_undead'] )
			do
				if npcTarget:HasModifier( mod )
				then
					return true
				end
			end
		end
		
		-- 有的玩家太菜了，特地加一个判断让这个玩家舒服一点
		if not npcTarget:IsBot()
		then
			local nID = npcTarget:GetPlayerID()
			local nKillCount = GetHeroKills( nID )
			local nDeathCount = GetHeroDeaths( nID )
			if nDeathCount >= 6
				and nKillCount <= 6
				and nKillCount / nDeathCount <= 0.3
			then
				return true
			end
		end
		
	else
		if npcTarget:HasModifier( "modifier_crystal_maiden_frostbite" )
			or npcTarget:HasModifier( "modifier_fountain_glyph" )
		then
			return true
		end
	end
	
	return false
end



function J.GetModifierTime( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			return bot:GetModifierRemainingDuration( i )
		end
	end

	return 0

end



function J.GetModifierCount( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			return bot:GetModifierStackCount( i )
		end
	end

	return 0

end



function J.GetUniqueModifierCount( bot, sModifierName )

	if not bot:HasModifier( sModifierName ) then return 0 end

	local count = 0
	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == sModifierName
		then
			count = count + 1
		end
	end

	return count

end




function J.GetRemainStunTime( bot )

	if not bot:HasModifier( "modifier_stunned" ) then return 0 end

	local npcModifier = bot:NumModifiers()
	for i = 0, npcModifier
	do
		if bot:GetModifierName( i ) == "modifier_stunned"
		then
			return bot:GetModifierRemainingDuration( i )
		end
	end

	return 0

end


function J.DoesSomeoneHaveModifier(nUnitList, modifierName)
	for _, unit in pairs(nUnitList)
	do
		if J.IsValid(unit)
		and unit:HasModifier(modifierName)
		then
			return true
		end
	end

	return false
end

function J.DoesUnitHaveTemporaryBuff(hUnit)
	local sUnitName = hUnit:GetUnitName()
	if sUnitName == 'npc_dota_hero_huskar' and J.GetHP(hUnit) < 0.6 then
		return true
	end

	for i = 0, hUnit:NumModifiers() do
		local sDuration = hUnit:GetModifierRemainingDuration(i)
		if (sDuration > 0.5)
		or (sDuration > -1 and sDuration < 0.5)
		then
			return true
		end
	end

	return false
end

end
