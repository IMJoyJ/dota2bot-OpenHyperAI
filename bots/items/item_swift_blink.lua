--迅疾闪光
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local botName = ctx.botName


	--return X.ConsiderItemDesire["item_blink"]( hItem )
	-- [inlined from item_blink]
	local nCastRange = 1200
	if hItem:GetName() == 'item_arcane_blink' then
		nCastRange = 1400
	end

	nCastRange = nCastRange + aetherRange

	if J.HasItemInInventory('item_magnifying_monocle') then
		nCastRange = nCastRange + 100
	end

	if J.HasItemInInventory('item_enhancement_keen_eyed') then
		if DotaTime() >= (J.IsModeTurbo() and 7.5*60 or 15*60) then
			nCastRange = nCastRange + 125
		elseif DotaTime() >= (J.IsModeTurbo() and 12.5*60 or 25*60) then
			nCastRange = nCastRange + 135
		end
	end

	if J.HasItemInInventory('item_enhancement_mystical') then
		if DotaTime() >= (J.IsModeTurbo() and 17.5*60 or 35*60) then
			nCastRange = nCastRange + 100
		end
	end

	if J.HasItemInInventory('item_enhancement_boundless') then
		if DotaTime() >= (J.IsModeTurbo() and 30*60 or 60*60) then
			nCastRange = nCastRange + 350
		end
	end

	local botName = bot:GetUnitName()

	if bot:IsRooted()
	or bot:HasModifier('modifier_nyx_assassin_vendetta')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.IsStuck(bot)
	then
		local loc = J.GetLocationTowardDistanceLocation(bot, GetAncient(GetTeam()):GetLocation(), nCastRange)
		return BOT_ACTION_DESIRE_HIGH, loc, 'ground', nil
	end

	local nInRangeAlly = bot:GetNearbyHeroes(800, false, BOT_MODE_ATTACK)

	if  J.IsRetreating(bot)
	and not J.IsRealInvisible(bot)
	and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	then
		local vLocation = J.GetLocationTowardDistanceLocation(bot, GetAncient(GetTeam()):GetLocation(), nCastRange)
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)

		if  bot:DistanceFromFountain() > 900
		and IsLocationPassable(vLocation)
		and (#nInRangeAlly <= 1
			or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH * 0.9)
		and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, vLocation, 'ground', nil
		end
	end

	nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_ATTACK)

	if #nInRangeAlly <= 1 and (botTarget == nil or not botTarget:IsHero())
	and J.IsFarming(bot)
	and not bot:WasRecentlyDamagedByAnyHero(3.1)
	and not J.IsPushing(bot)
	and not J.IsDefending(bot)
	then
		local nAOELocation = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, 500, 0, 0)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		local nInRangeEnemy = J.GetEnemiesNearLoc(nAOELocation.targetloc, 1600)

		if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		and nAOELocation.count >= 4
		then
			local bCenter = J.GetCenterOfUnits(nEnemyLaneCreeps)
			local bDist = GetUnitToLocationDistance(bot, bCenter)
			local vLocation = J.GetLocationTowardDistanceLocation(bot, bCenter, bDist + 550)
			local bLocation = J.GetLocationTowardDistanceLocation(bot, bCenter, bDist - 300)

			if bDist > nCastRange then bLocation = J.GetLocationTowardDistanceLocation(bot, bCenter, nCastRange) end

			if  IsLocationPassable(bLocation)
			and GetUnitToLocationDistance(bot, bLocation) > 600
			and IsLocationVisible(vLocation)
			and not J.IsLocHaveTower(700, true, bLocation)
			then
				return BOT_ACTION_DESIRE_HIGH, bLocation, 'ground', nil
			end
		end
	end

	if  J.IsProjectileIncoming(bot, 1200)
	and (botTarget == nil
		or not botTarget:IsHero()
		or not J.IsInRange(bot, botTarget, bot:GetAttackRange() + 100))
	then
		local loc = J.GetLocationTowardDistanceLocation(bot, GetAncient(GetTeam()):GetLocation(), 1199)
		return BOT_ACTION_DESIRE_HIGH, loc, 'ground', nil
	end

	if J.IsGoingOnSomeone(bot) then
		-- for their queued spell combos
		if  bot.shouldBlink ~= nil
		and bot.shouldBlink
		and (botName == 'npc_dota_hero_batrider'
			or botName == 'npc_dota_hero_beastmaster'
			or botName == 'npc_dota_hero_dark_seer'
			or botName == 'npc_dota_hero_earthshaker'
			or botName == 'npc_dota_hero_magnataur'
			or botName == 'npc_dota_hero_rubick'
			-- or botName == 'npc_dota_hero_tinker'
			or botName == 'npc_dota_hero_tiny'
			or botName == 'npc_dota_hero_treant')
		then
			return BOT_ACTION_DESIRE_NONE
		end

		if botName == 'npc_dota_hero_nevermore' then
			local RequiemOfSouls = bot:GetAbilityByName('nevermore_requiem')
			if J.CanCastAbility(RequiemOfSouls) then
				return BOT_ACTION_DESIRE_NONE
			end
		end

		if  J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanBeAttacked(botTarget)
		and not J.IsInRange(bot, botTarget, 500)
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		then
			local nInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
			local nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)
			local bWeAreStronger = J.WeAreStronger(bot, 1200)
			local nNearbyEnemyHeroCount = 0
			for _, id in pairs(GetTeamPlayers(GetOpposingTeam())) do
				if IsHeroAlive(id) then
					local info = GetHeroLastSeenInfo(id)
					if info ~= nil then
						local dInfo = info[1]
						if dInfo ~= nil and dInfo.time_since_seen < 3.0 and GetUnitToLocationDistance(botTarget, dInfo.location) <= 1200 then
							nNearbyEnemyHeroCount = nNearbyEnemyHeroCount + 1
						end
					end
				end
			end

			if (#nInRangeAlly >= nNearbyEnemyHeroCount and bWeAreStronger) then
				local nDistance = Min(nCastRange, GetUnitToUnitDistance(bot, botTarget))
				local vLocation = J.GetUnitTowardDistanceLocation(bot, botTarget, nDistance) + RandomVector(150)
				if IsLocationPassable(vLocation) then
					return BOT_ACTION_DESIRE_HIGH, vLocation, 'ground', nil
				end
			end
		end
	end

	if J.IsDoingTormentor(bot) and not J.IsRealInvisible(bot) then
		local vTormentorLocation = J.GetTormentorLocation(GetTeam())
		if GetUnitToLocationDistance(bot, vTormentorLocation) > 2000 then
			local vLocation = J.VectorTowards(bot:GetLocation(), vTormentorLocation, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(vLocation, 1200)
			if IsLocationPassable(vLocation) and #nInRangeEnemy == 0 then
				return BOT_ACTION_DESIRE_HIGH, vLocation, 'ground', nil
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
