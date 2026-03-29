-- jmz_func sub-module: jmz_illusion
return function(J)



function J.IsNoItemIllution(bot)
	-- local cacheKey = 'IsNoItemIllution'
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	if (bot:IsIllusion() or J.IsMeepoClone(bot))
	and not bot:HasModifier("modifier_arc_warden_tempest_double")
	and bot:GetUnitName() ~= 'npc_dota_hero_vengefulspirit'
	then
		-- J.Utils.SetCachedVars(cacheKey, true)
		return true
	end
	-- J.Utils.SetCachedVars(cacheKey, false)
	return false
end


function J.IsNoAbilityIllution(bot)
	-- local cacheKey = 'IsNoAbilityIllution'
	-- local cache = J.Utils.GetCachedVars(cacheKey, 0.5)
	-- if cache ~= nil then return cache end

	if bot:IsIllusion()
	and not bot:HasModifier("modifier_arc_warden_tempest_double")
	and bot:GetUnitName() ~= 'npc_dota_hero_vengefulspirit'
	and not J.IsMeepoClone(bot)
	then
		-- J.Utils.SetCachedVars(cacheKey, true)
		return true
	end
	-- J.Utils.SetCachedVars(cacheKey, false)
	return false
end



function J.IsSuspiciousIllusion( npcTarget )
	if npcTarget == nil or npcTarget:IsNull() then return false end
	if npcTarget.is_suspicious_illusion ~= nil then
		return npcTarget.is_suspicious_illusion
	end
	if not npcTarget:CanBeSeen() then
		npcTarget.is_suspicious_illusion = false
		return false
	end

	if npcTarget:CanBeSeen() and (
		not npcTarget:IsHero()
		or npcTarget:IsCastingAbility()
		or npcTarget:IsUsingAbility()
		or npcTarget:IsChanneling()
	)
		-- or npcTarget:HasModifier( "modifier_item_satanic_unholy" )
		-- or npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
		-- or npcTarget:HasModifier( "modifier_black_king_bar_immune" )
		-- or npcTarget:HasModifier( "modifier_rune_doubledamage" )
		-- or npcTarget:HasModifier( "modifier_rune_regen" )
		-- or npcTarget:HasModifier( "modifier_rune_haste" )
		-- or npcTarget:HasModifier( "modifier_rune_arcane" )
		-- or npcTarget:HasModifier( "modifier_item_phase_boots_active" )
	then
		npcTarget.is_suspicious_illusion = false
		return false
	end

	local bot = GetBot()

	if npcTarget:GetTeam() == bot:GetTeam()
	then
		npcTarget.is_suspicious_illusion = npcTarget:IsIllusion() or npcTarget:HasModifier( "modifier_arc_warden_tempest_double" )
		return npcTarget.is_suspicious_illusion
	elseif npcTarget:GetTeam() == GetOpposingTeam()
	then

		if npcTarget:HasModifier( 'modifier_illusion' )
		or npcTarget:HasModifier( 'modifier_darkseer_wallofreplica_illusion' )
		or npcTarget:HasModifier( 'modifier_phantom_lancer_doppelwalk_illusion' )
		or npcTarget:HasModifier( 'modifier_phantom_lancer_juxtapose_illusion' )
		or npcTarget:HasModifier( 'modifier_skeleton_king_reincarnation_scepter_active' )
		or npcTarget:HasModifier( 'modifier_item_helm_of_the_undying_active' )
		or npcTarget:HasModifier( 'modifier_terrorblade_conjureimage' )
		then
			npcTarget.is_suspicious_illusion = true
			return true
		end

		local tID = npcTarget:GetPlayerID()

		if not IsHeroAlive( tID )
		then
			npcTarget.is_suspicious_illusion = true
			return true
		end

		if GetHeroLevel( tID ) > npcTarget:GetLevel()
		then
			npcTarget.is_suspicious_illusion = true
			return true
		end
		--[[
		if GetSelectedHeroName( tID ) ~= "npc_dota_hero_morphling"
			and GetSelectedHeroName( tID ) ~= npcTarget:GetUnitName()
		then
			npcTarget.is_suspicious_illusion = true
			return true
		end
		--]]
	end

	npcTarget.is_suspicious_illusion = false
	return false

end


function J.GetMeepos()
	local Meepos = {}

	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and allyHero:GetUnitName() == 'npc_dota_hero_meepo'
		and not J.IsSuspiciousIllusion(allyHero)
		then
			table.insert(Meepos, allyHero)
		end
	end

	return Meepos
end


function J.IsMeepoClone(hero)
	if J.IsValidHero(hero)
	and hero:GetUnitName() == 'npc_dota_hero_meepo'
	then
		for i = 0, 5
		do
			local hItem = hero:GetItemInSlot(i)

			if hItem ~= nil
			and not (hItem:GetName() == 'item_boots'
					or hItem:GetName() == 'item_tranquil_boots'
					or hItem:GetName() == 'item_arcane_boots'
					or hItem:GetName() == 'item_power_treads'
					or hItem:GetName() == 'item_phase_boots'
					or hItem:GetName() == 'item_travel_boots'
					or hItem:GetName() == 'item_boots_of_bearing'
					or hItem:GetName() == 'item_guardian_greaves'
					or hItem:GetName() == 'item_travel_boots_2'
				)  
			then
				return false
			end
		end

		return true
    end
end

end
