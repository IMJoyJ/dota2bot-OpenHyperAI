local X = {}
local bot = GetBot()
local botName = bot:GetUnitName()
if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not string.find(botName, "hero") or bot:IsIllusion() then return end
if not bot.frameProcessTime then bot.frameProcessTime = 0.1 end

local team = GetTeam()
local bDebugMode = ( 10 == 10 )

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Utils = require( GetScriptDirectory()..'/FunLib/utils' )
local BotBuild = dofile( GetScriptDirectory().."/BotLib/"..string.gsub( botName, "npc_dota_", "" ) )
local Localization = require( GetScriptDirectory()..'/FunLib/localization' )
local Customize = require(GetScriptDirectory()..'/Customize/general')
Customize.ThinkLess = Customize.Enable and Customize.ThinkLess or 1
if GAMEMODE_TURBO == nil then GAMEMODE_TURBO = 23 end

if BotBuild == nil then return end

local bDeafaultAbilityHero = BotBuild['bDeafaultAbility']
local bDeafaultItemHero = BotBuild['bDeafaultItem']
local sAbilityLevelUpList = BotBuild['sSkillList']

local RadiantFountain = Vector(-6619, -6336, 384)
local DireFountain = Vector(6928, 6372, 392)

local function AbilityLevelUpComplement()
	if GetGameState() ~= GAME_STATE_PRE_GAME
		and GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS
	then
		return
	end

	if bot:GetLevel() >= 30
		and botName == "npc_dota_hero_bloodseeker"
	then
		return
	end

	if DotaTime() < 15
	then
		bot.theRole = J.Role.GetCurrentSuitableRole( bot, botName )
	end

	local botLoc = bot:GetLocation()
	if bot:IsAlive()
		and DotaTime() > 90
		and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO
		and not IsLocationPassable( botLoc )
	then
		if bot.stuckLoc == nil
		then
			bot.stuckLoc = botLoc
			bot.stuckTime = DotaTime()
		elseif bot.stuckLoc ~= botLoc
		then
			bot.stuckLoc = botLoc
			bot.stuckTime = DotaTime()
		end
	else
		bot.stuckTime = nil
		bot.stuckLoc = nil
	end

	if bot.needRefreshAbilitiesFor737 ~= nil then
		sAbilityLevelUpList = BotBuild['sSkillList']
		if not bot.needRefreshAbilitiesFor737 then bot.needRefreshAbilitiesFor737 = nil end
	end

	local botLevel = bot:GetLevel()

	if #sAbilityLevelUpList >= 1
	and bot:GetAbilityPoints() > 0
	then
		if J.IsTryingtoUseAbility(bot) then return end
		local abilityName = sAbilityLevelUpList[1]
		local abilityToLevelup = bot:GetAbilityByName( abilityName )

		if abilityName == 'npc_dota_hero_kez'
		and (abilityToLevelup == nil or abilityToLevelup:IsHidden()) then
			return
		end

		-- Kez abilities
		if botName == 'npc_dota_hero_kez' then
			if bot.kez_mode == 'sai' then
				for i = 0, 6 do
					local hAbility = bot:GetAbilityInSlot(i)
					local sAbilityName = hAbility:GetName()
					if hAbility ~= nil then
						if sAbilityLevelUpList[1] == 'kez_echo_slash' and sAbilityName == 'kez_falcon_rush'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_falcon_rush'
						elseif sAbilityLevelUpList[1] == 'kez_grappling_claw' and sAbilityName == 'kez_talon_toss'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_talon_toss'
						elseif sAbilityLevelUpList[1] == 'kez_kazurai_katana' and sAbilityName == 'kez_shodo_sai'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_shodo_sai'
						elseif sAbilityLevelUpList[1] == 'kez_raptor_dance' and sAbilityName == 'kez_ravens_veil'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_ravens_veil'
						end
					end
				end
			else
				for i = 0, 6 do
					local hAbility = bot:GetAbilityInSlot(i)
					local sAbilityName = hAbility:GetName()
					if hAbility ~= nil then
						if sAbilityLevelUpList[1] == 'kez_falcon_rush' and sAbilityName == 'kez_echo_slash'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_echo_slash'
						elseif sAbilityLevelUpList[1] == 'kez_talon_toss' and sAbilityName == 'kez_grappling_claw'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_grappling_claw'
						elseif sAbilityLevelUpList[1] == 'kez_shodo_sai' and sAbilityName == 'kez_kazurai_katana'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_kazurai_katana'
						elseif sAbilityLevelUpList[1] == 'kez_ravens_veil' and sAbilityName == 'kez_raptor_dance'
						then
							abilityToLevelup = hAbility
							sAbilityLevelUpList[1] = 'kez_raptor_dance'
						end
					end
				end
			end
		end

		-- fix phoenix_fire_spirits can't upgrade bug.
		if abilityName == 'phoenix_fire_spirits'
		and not bot:GetAbilityByName('phoenix_launch_fire_spirit'):IsHidden() then
			return
		end

		-- fix 'alchemist_unstable_concoction can't upgrade bug.
		if abilityName == 'alchemist_unstable_concoction'
		and not bot:GetAbilityByName('alchemist_unstable_concoction_throw'):IsHidden() then
			return
		end

		if abilityToLevelup ~= nil
			and not abilityToLevelup:IsHidden()
		    and botLevel >= abilityToLevelup:GetHeroLevelRequiredToUpgrade()
			and abilityToLevelup:CanAbilityBeUpgraded()
			and abilityToLevelup:GetLevel() < abilityToLevelup:GetMaxLevel()
		then
			-- print('Trying to upgrade '..abilityToLevelup:GetName())
			bot:ActionImmediate_LevelAbility(abilityToLevelup:GetName())
			table.remove( sAbilityLevelUpList, 1 )
		elseif abilityName == 'generic_hidden' then
			local nextAbility = sAbilityLevelUpList[2]
			print("[WARN] Level up ability "..abilityName.." for "..botName.." does not make sense. try to upgrade the next ability: "..tostring(nextAbility))
			table.remove( sAbilityLevelUpList, 1 )
			if nextAbility then
				bot:ActionImmediate_LevelAbility(nextAbility)
			end
		elseif not abilityToLevelup:IsHidden() and botLevel >= abilityToLevelup:GetHeroLevelRequiredToUpgrade() then
			-- still try it
			print("[WARN] Level up ability "..abilityName.." for "..botName.." may fail because it was called on ability that's not available or can't get upgraded anymore.")
			bot:ActionImmediate_LevelAbility(abilityName)
			table.remove( sAbilityLevelUpList, 1 )
			-- bot:ActionImmediate_LevelAbility('special_bonus_attributes')
		else
			print("[WARN] Skipped to level up ability "..abilityName.." for "..botName.." for this time because it may fail.")
			if botLevel > 25 then
				print("[WARN] Ignore ability "..abilityName.." for "..botName.." because it may always fail.")
				table.remove( sAbilityLevelUpList, 1 )
			end
		end
	end

	if botLevel > 25 and botLevel < 30 and bot:GetAbilityPoints() >= 1 and #sAbilityLevelUpList <= 3 then
		sAbilityLevelUpList = J.Utils.CombineTablesUnique(J.Skill.GetTalentList( bot ), J.Skill.GetAbilityList( bot ))
	end
end

function X.GetNumEnemyNearby( building )

	local nearbynum = 0
	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil
			then
				local dInfo = info[1]
				if dInfo ~= nil
					and GetUnitToLocationDistance( building, dInfo.location ) <= 3000
					and dInfo.time_since_seen < 1.0
				then
					nearbynum = nearbynum + 1
				end
			end
		end
	end

	return nearbynum

end

local fDeathTime = 0
function X.GetRemainingRespawnTime()

	if fDeathTime == 0
	then
		return 0
	else
		return bot:GetRespawnTime() - ( DotaTime() - fDeathTime )
	end

end

local nJiDiCount = RandomInt( 14, 20 )
local nTalkDelay = RandomInt( 19, 56 )/10
local nDeathReplyTime = -999
local nLastGold = 9999
local nLastKillCount = 999
local nLastDeathCount = 0
local nContinueKillCount = 0
local nReplyHumanCount = 0
local nMaxReplyCount = RandomInt( 5, 9 )
local bInstallChatCallbackDone = false
local nReplyHumanTime = nil
local sHumanString = nil
local bAllChat = false
function X.SetTalkMessage()

	local nBotID = bot:GetPlayerID()
	local nCurrentGold = bot:GetGold()
	local nCurrentKills = GetHeroKills( nBotID )
	local nCurrentDeaths = GetHeroDeaths( nBotID )
	local nRate = GetGameMode() == GAMEMODE_TURBO and 2.0 or 1.0

	--回复玩家的对话
	if nBotID == J.Role.GetReplyMemberID()
		and nReplyHumanCount <= nMaxReplyCount
	then
		if not bInstallChatCallbackDone and GetGameState() == GAME_STATE_GAME_IN_PROGRESS
		then
			bInstallChatCallbackDone = true
			--print(botName)
			InstallChatCallback( function( tChat ) X.SetReplyHumanTime( tChat ) end )
		end

		if sHumanString ~= nil
			and nReplyHumanTime ~= nil
			and DotaTime() > nReplyHumanTime + nTalkDelay
		then
			local chatString = J.Chat.GetReplyString( sHumanString, bAllChat )
			if chatString ~= nil
			then
				if nReplyHumanCount == nMaxReplyCount
				then chatString = J.Chat.GetStopReplyString() end

				bot:ActionImmediate_Chat( chatString, bAllChat )

				nReplyHumanCount = nReplyHumanCount + 1
				nTalkDelay = RandomInt( 6, 30 )/10
				if nTalkDelay > 2.0 then nTalkDelay = RandomInt( 6, 30 )/10 end
			end
			sHumanString = nil
			nReplyHumanTime = nil
		end
	end

	if J.Customize.Allow_Trash_Talk then
		--一血
		if DotaTime() < 600
			and bot:IsAlive()
			and nCurrentKills > nLastKillCount
			and J.GetNumOfTeamTotalKills( false ) == 1
			and J.GetNumOfTeamTotalKills( true ) == 0
			and RandomInt( 1, 9 ) > 4
		then
			local sTauntMark = Localization.Get('got_first_blood')[RandomInt( 1, #Localization.Get('got_first_blood') )]
			bot:ActionImmediate_Chat( sTauntMark, true )
		end

		--发问号
		if bot:IsAlive()
			and nCurrentGold > nLastGold + 300 * nRate
			and nCurrentKills > nLastKillCount
		then
			local sTauntMark = "?"
			if J.Customize.Trash_Talk_Level and J.Customize.Trash_Talk_Level >= 2 then
				if RandomInt( 1, 9 ) > 7 then sTauntMark = Localization.Get('got_a_kill')[RandomInt( 1, #Localization.Get('got_a_kill') )] end
				if nCurrentGold > nLastGold + 800 * nRate and RandomInt( 1, 9 ) > 4 then sTauntMark = Localization.Get('got_big_kill')[RandomInt( 1, #Localization.Get('got_big_kill') )] end
				if nCurrentGold > nLastGold + 1000 * nRate and RandomInt( 1, 9 ) > 3 then sTauntMark = Localization.Get('got_big_kill_2')[RandomInt( 1, #Localization.Get('got_big_kill_2') )] end
				if nCurrentGold > nLastGold + 1500 * nRate then sTauntMark = Localization.Get('got_big_kill_3')[RandomInt( 1, #Localization.Get('got_big_kill_3') )] end
			end
			if RandomInt( 1, 9 ) > 4 then bot:ActionImmediate_Chat( sTauntMark, true ) end
		end

		--发省略号
		if not bot:IsAlive()
		then
			if nContinueKillCount >= 8
				and nDeathReplyTime == -999
			then
				nDeathReplyTime = DotaTime()
				nContinueKillCount = 0
			end

			if nDeathReplyTime ~= -999
				and nDeathReplyTime < DotaTime() - nTalkDelay
			then
				bot:ActionImmediate_Chat( Localization.Get('kill_streak_ended')[RandomInt( 1, #Localization.Get('kill_streak_ended'))], true )
				nDeathReplyTime = -999
				nTalkDelay = RandomInt( 36, 49 )/10
			end
		end

		--发"jidi, xiayiba"
		if nCurrentKills == 0
			and nCurrentDeaths >= nJiDiCount
			and J.Role.NotSayJiDi()
		then
			bot:ActionImmediate_Chat( Localization.Get('say_end')[RandomInt( 1, #Localization.Get('say_end'))], true )
			J.Role['sayJiDi'] = true
		end
	end

	--计算连杀数量
	if nLastDeathCount == nCurrentDeaths
	then
		if nCurrentKills >= nLastKillCount + 1
		then
			nContinueKillCount = nContinueKillCount + 1
		end
	else
		nContinueKillCount = 0
	end

	nLastKillCount = GetHeroKills( nBotID )
	nLastDeathCount = GetHeroDeaths( nBotID )
	nLastGold = bot:GetGold()

end


function X.SetReplyHumanTime( tChat )

	local sChatString = tChat.string
	local nChatID = tChat.player_id

	if string.find(sChatString, "!sp") or string.find(sChatString, "!speak") then
		local action, target = J.Utils.TrimString(sChatString):match("^(%S+)%s+(.*)$")
		print("Set to speak: ".. target)
		J.Customize.Localization = target
		return
	end

	if sChatString ~= "-都来守家" or J.Role.IsAllyMemberID( nChatID )
	then
		J.Role.SetLastChatString( sChatString )
	end
		
	if not IsPlayerBot( nChatID )
		and ( tChat.team_only or J.Role.IsEnemyMemberID( nChatID ) )
	then
		sHumanString = sChatString
		nReplyHumanTime = DotaTime()
		bAllChat = not tChat.team_only
	end


end


local function BuybackUsageComplement()
	if J.IsMeepoClone(bot) then return end

	X.SetTalkMessage()

	if bot:GetLevel() <= 15
		or bot:HasModifier( 'modifier_arc_warden_tempest_double' )
		or not J.Role.ShouldBuyBack()
	then
		return
	end

	if bot:IsAlive() and fDeathTime ~= 0
	then
		fDeathTime = 0
	end

	if not bot:IsAlive()
	then
		if fDeathTime == 0 then fDeathTime = DotaTime() end
	end

	if not bot:HasBuyback() then return end


	local ancient = GetAncient( GetTeam() )

	local nFullRespawnTime = bot:GetRespawnTime()
	local nRemainingRespawnTime = X.GetRemainingRespawnTime()

	if ancient ~= nil and ancient:GetHealth() < 0.8 then
		local nEnemyUnitsAroundAncient = J.GetEnemiesAroundLoc(ancient:GetLocation(), 1500)
		local nAllyUnitsAroundAncient = J.GetAlliesNearLoc(ancient:GetLocation(), 1500)
		if nEnemyUnitsAroundAncient > 1 and nAllyUnitsAroundAncient == 0 and nRemainingRespawnTime > 20 then
			J.Role['lastbbtime'] = DotaTime()
			bot:ActionImmediate_Buyback()
			return
		end
	end

	if nFullRespawnTime < 60 then
		return
	end

	if bot:GetLevel() > 24
		and nRemainingRespawnTime > 80
	then
		local nTeamFightLocation = J.GetTeamFightLocation( bot )
		if nTeamFightLocation ~= nil
		then
			J.Role['lastbbtime'] = DotaTime()
			bot:ActionImmediate_Buyback()
			return
		end
	end

	if nRemainingRespawnTime < 40
	then
		return
	end

	if ancient ~= nil
	then
		local nEnemyCount = X.GetNumEnemyNearby( ancient )
		local nAllyCount = J.GetNumOfAliveHeroes( false )
		if nEnemyCount > 0 and nEnemyCount >= nAllyCount
		then
			J.Role['lastbbtime'] = DotaTime()
			bot:ActionImmediate_Buyback()
			return
		end
	end

end


local nCourierLastActionTime = -90
local nCourierState = -1
bot.SShopUser = false
local nCourierReturnTime = -90
local nCourierDeliverTime = -90
local function CourierUsageComplement()

	if DotaTime() < -56
		or bot:HasModifier( "modifier_arc_warden_tempest_double" )
		or nCourierReturnTime + 5.0 > DotaTime()
	then
		return
	end

	if bot.theCourier == nil
	then
		bot.theCourier = X.GetBotCourier( bot )
		return
	end

	--------* * * * * * * ----------------* * * * * * * ----------------* * * * * * * --------
	local bDebugCourier = ( 10 == 10 )
	local npcCourier = bot.theCourier
	nCourierState = GetCourierState( npcCourier )
	local courierHP = npcCourier:GetHealth() / npcCourier:GetMaxHealth()
	local currentTime = DotaTime()
	local bAliveBot = bot:IsAlive()
	local botLV = bot:GetLevel()
	local useCourierCD = 2.3
	local protectCourierCD = 5.0
	--------* * * * * * * ----------------* * * * * * * ----------------* * * * * * * --------

	if nCourierState == COURIER_STATE_DEAD then return	end

	if X.IsCourierTargetedByUnit( npcCourier )
	then
		if currentTime > nCourierReturnTime + protectCourierCD
		then
			nCourierReturnTime = currentTime

			J.SetReportMotive( bDebugCourier, "信使可能会被攻击" )

			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS )

			local abilityBurst = npcCourier:GetAbilityByName( 'courier_burst' )
			if abilityBurst and abilityBurst:IsFullyCastable()
			then
				bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_BURST )
			end

			return
		end
	end

	if bot.SShopUser
		and ( not bAliveBot or bot:GetActiveMode() == BOT_MODE_SECRET_SHOP or not bot.SecretShop )
	then
		bot.SShopUser = false
		J.SetReportMotive( bDebugCourier, "让信使返回基地避免被卡住" )
		bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS )
		return
	end


	if ( nCourierState == COURIER_STATE_RETURNING_TO_BASE
		or nCourierState == COURIER_STATE_AT_BASE
		or nCourierState == COURIER_STATE_IDLE )
		and currentTime > nCourierReturnTime + protectCourierCD
	then

		if nCourierState == COURIER_STATE_AT_BASE and courierHP < 0.8 
		then return	end

		if nCourierState == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() > 800
		then
			J.SetReportMotive( bDebugCourier, "让空闲的信使返回" )
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_RETURN_STASH_ITEMS )
			return
		end

		if bAliveBot
			and ( not X.IsInvFull( bot )
					or currentTime <= 5 * 60
					or ( bot.currBuyingBasicItemList ~= nil and #bot.currBuyingBasicItemList == 0 and bot.currBuyingItemInPurchaseList ~= 'item_travel_boots' ) )
			and ( nCourierState == COURIER_STATE_AT_BASE
					or ( nCourierState == COURIER_STATE_IDLE and npcCourier:DistanceFromFountain() < 800 ) )
		then
			local nMSlot = X.GetNumStashItem( bot )
			if nMSlot > 0
			-- and Utils.CountBackpackEmptySpace(bot) >= 1
			then
				if ( bot.currBuyingBasicItemList ~= nil and #bot.currBuyingBasicItemList == 0 )
					or ( bot.currBuyingBasicItem ~= nil
							and ( IsItemPurchasedFromSecretShop( bot.currBuyingBasicItem )
									or X.GetNumStashItem( bot ) == 6
									or bot:GetGold() + 80 < GetItemCost( bot.currBuyingBasicItem ) ) )
				then
					J.SetReportMotive( bDebugCourier, "信使取出物品并开始运输" )
					bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TAKE_STASH_ITEMS )
					nCourierLastActionTime = currentTime

					if currentTime > nCourierDeliverTime + protectCourierCD
					then
						nCourierDeliverTime = currentTime
						local abilityBurst = npcCourier:GetAbilityByName( 'courier_burst' )
						if abilityBurst and abilityBurst:IsFullyCastable()
						then
							J.SetReportMotive( bDebugCourier, "信使加速配送" )
							bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_BURST )
						end
					end
				end
			end
		end

		if bAliveBot and bot.SecretShop
			and npcCourier:DistanceFromFountain() < 7000
			and J.Item.GetEmptyInventoryAmount( npcCourier ) >= 2
			and not X.IsEnemyHeroAroundSecretShop() -- 商店附近没有敌人
			and currentTime > nCourierLastActionTime + useCourierCD
		then
			J.SetReportMotive( bDebugCourier, "信使前往神秘商店购物" )
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_SECRET_SHOP )
			bot.SShopUser = true
			nCourierLastActionTime = currentTime
			return
		end

		if bAliveBot
			and bot:GetCourierValue() > 0
			and bot:GetStashValue() < 100
			and ( not X.IsInvFull( bot ) or ( X.GetNumStashItem( bot ) == 0 and bot.currBuyingBasicItemList ~= nil and #bot.currBuyingBasicItemList == 0 ) )
			and ( npcCourier:DistanceFromFountain() < 4000 + botLV * 200 or GetUnitToUnitDistance( bot, npcCourier ) < 1800 )
			and currentTime > nCourierLastActionTime + useCourierCD
			-- and Utils.CountBackpackEmptySpace(bot) >= 1
		then
			J.SetReportMotive( bDebugCourier, "信使运输背包中的东西" )
			bot:ActionImmediate_Courier( npcCourier, COURIER_ACTION_TRANSFER_ITEMS )
			nCourierLastActionTime = currentTime
			return
		end


	end

end


function X.GetBotCourier( bot )

	local nPlayerID = bot:GetPlayerID()

	for nCourierID = 0, 4
	do
		local courier = GetCourier( nCourierID )
		if courier:GetPlayerID() == nPlayerID
		then
			return courier
		end
	end

end


function X.GetNumStashItem( unit )

	local amount = 0
	for i = 9, 14
	do
		if unit:GetItemInSlot( i ) ~= nil
		then
			amount = amount + 1
		end
	end

	return amount

end

function X.IsThereRecipeInStash( unit )
	local amount = 0

	for i = 9, 14
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil
		then
			if string.find(item:GetName(), "item_recipe_")
			then
				amount = amount + 1
			end
		end
	end

	return amount > 0
end


function X.IsCourierTargetedByUnit( courier )
	if GetGameMode() == GAMEMODE_TURBO then return false end
	
	local botLV = bot:GetLevel()

	if J.GetHP( courier ) < 0.9
	then
		return true
	end

	if courier:DistanceFromFountain() < 900 then return false end

	for i = 0, 10
	do
		local tower = GetTower( GetOpposingTeam(), i )
		if tower ~= nil and tower:CanBeSeen()
		then
			local towerTarget = tower:GetAttackTarget()

			if towerTarget == courier
			then
				return true
			end

			if towerTarget == nil
				and GetUnitToUnitDistance( courier, tower ) < 999
			then
				return true
			end
		end
	end

	for i, id in pairs( GetTeamPlayers( GetOpposingTeam() ) )
	do
		if IsHeroAlive( id )
		then
			local info = GetHeroLastSeenInfo( id )
			if info ~= nil
			then
				local dInfo = info[1]
				if dInfo ~= nil
					and GetUnitToLocationDistance( courier, dInfo.location ) <= 800
					and dInfo.time_since_seen < 1.8
				then
					return true
				end
			end
		end
	end

	local nEnemysHeroesCanSeen = GetUnitList( UNIT_LIST_ENEMY_HEROES )
	for _, enemy in pairs( nEnemysHeroesCanSeen )
	do
		if GetUnitToUnitDistance( enemy, courier ) <= 700 + botLV * 15
		then
			local nNearCourierAllyList = J.GetAlliesNearLoc( enemy:GetLocation(), 600 )
			if #nNearCourierAllyList == 0
				or enemy:GetAttackTarget() == courier
			then
				return true
			end
		end

		if enemy:GetUnitName() == 'npc_dota_hero_sniper'
			and GetUnitToUnitDistance( enemy, courier ) <= 1100 + botLV * 30
		then
			return true
		end

		if GetUnitToUnitDistance( enemy, courier ) <= enemy:GetAttackRange() + 88
		then
			return true
		end
	end

	local nEnemysHeroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	for _, enemy in pairs( nEnemysHeroes )
	do
		if enemy ~= nil and J.IsValidHero( enemy ) and GetUnitToUnitDistance( enemy, courier ) <= 700 + botLV * 15
		then
			local nNearCourierAllyList = J.GetAlliesNearLoc( enemy:GetLocation(), 800 )
			if #nNearCourierAllyList == 0
				or enemy:GetAttackTarget() == courier
			then
				return true
			end
		end

		if enemy ~= nil and J.IsValidHero( enemy ) and GetUnitToUnitDistance( enemy, courier ) <= enemy:GetAttackRange() + 100
		then
			return true
		end
	end

	local nAllEnemyCreeps = GetUnitList( UNIT_LIST_ENEMY_CREEPS )
	local nNearCourierAllyList = J.GetAlliesNearLoc( courier:GetLocation(), 1500 )
	local nNearCourierAllyCount = #nNearCourierAllyList
	for _, creep in pairs( nAllEnemyCreeps )
	do
		if GetUnitToUnitDistance( courier, creep ) <= 800
			and ( creep:GetAttackTarget() == courier or botLV > 10 )
			and ( nNearCourierAllyCount == 0 or creep:GetAttackTarget() == courier )
		then
			return true
		end
	end

	return false

end


function X.IsInvFull( bot )

	for i = 0, 8
	do
		if bot:GetItemInSlot( i ) == nil
		then
			return false
		end
	end

	return true

end


function X.IsEnemyHeroAroundSecretShop()

	local vRadiantShop = GetShopLocation( team, SHOP_SECRET )
	local vDireShop = GetShopLocation( team, SHOP_SECRET2 )
	local vTeamSecretShop = team == TEAM_DIRE and vDireShop or vRadiantShop

	local vCenterLocation = ( vTeamSecretShop + GetAncient( team ):GetLocation() ) * 0.5

	if J.IsEnemyHeroAroundLocation( vCenterLocation, 2000 )
	then
		return true
	end

	return false

end




local fLastStashItemTimeList = {}
local aetherRange = 0
local lastAmuletTime = 0
local thereBeMonkey = false
local lastSwitchPtTime = -90
local hNearbyEnemyHeroList = {}
local hNearbyEnemyTowerList = {}
local botTarget = nil
local nMode = -1

-- Load item registry
local ItemLogicRegistry = {}
local RegisterAll = require(GetScriptDirectory()..'/items/_registry')
RegisterAll(ItemLogicRegistry)

local function ItemUsageComplement()

	X.SetStashItemTimeUpdate()

	if not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsHexed()
		or bot:IsStunned()
		or bot:IsChanneling()
		or bot:IsInvulnerable()
		or bot:IsUsingAbility()
		or bot:IsCastingAbility()
		or bot:NumQueuedActions() > 0
		or bot:HasModifier( 'modifier_teleporting' )
		or bot:HasModifier( 'modifier_doom_bringer_doom' )
		or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )
		or X.WillBreakInvisible( bot )
	then return	BOT_ACTION_DESIRE_NONE end

	local aether = J.IsItemAvailable( "item_aether_lens" )
	local aetherRange = (aether ~= nil) and 250 or 0

	-- Build per-frame context for item modules
	local ctx = {
		botTarget = J.GetProperTarget( bot ),
		nMode = bot:GetActiveMode(),
		aetherRange = aetherRange,
		hNearbyEnemyHeroList = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE ),
		hNearbyEnemyTowerList = bot:GetNearbyTowers( 888, true ),
		team = team,
		botName = botName,
		bDebugMode = bDebugMode,
		RadiantFountain = RadiantFountain,
		DireFountain = DireFountain,
		bDeafaultAbilityHero = bDeafaultAbilityHero,
		bDeafaultItemHero = bDeafaultItemHero,
	}

	local nItemSlot = { 5, 4, 3, 2, 1, 0, 15, 16 }

	for _, nSlot in pairs( nItemSlot )
	do
		local hItem = bot:GetItemInSlot( nSlot )
		if J.CanCastAbility(hItem)
		then
			local sItemName = hItem:GetName()
			local itemModule = ItemLogicRegistry[sItemName]
			if itemModule ~= nil
				and not X.IsItemInStash( sItemName )
			then
				local nItemDesire, hItemTarget, sCastType, sMotive = itemModule.ConsiderItemDesire(bot, hItem, ctx)

				if nItemDesire > 0
				then
					if bDebugMode
						and sMotive ~= nil
						and J.Item.IsSpecifiedItem( sItemName )
					then
						J.SetReportMotive( bDebugMode, sItemName..'→'..sMotive )
					end

					X.SetUseItem( hItem, hItemTarget, sCastType )

					return nSlot + 1
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

function X.SetUseItem( hItem, hItemTarget, sCastType )

	if sCastType == 'none'
	then
		bot:Action_UseAbility( hItem )
		return
	elseif sCastType == 'unit' and type(hItemTarget) == 'table'
	then
		bot:Action_UseAbilityOnEntity( hItem, hItemTarget )
		return
	elseif sCastType == 'ground' or (hItemTarget and type(hItemTarget) ~= 'number' and type(hItemTarget) ~= 'table' and hItemTarget.x ~= nil) -- in case target is a location
	then
		bot:Action_UseAbilityOnLocation( hItem, hItemTarget )
		return
	elseif sCastType == 'tree'
	then
		bot:Action_UseAbilityOnTree( hItem, hItemTarget )
		return
	elseif sCastType == 'twice'
	then
		bot:Action_UseAbility( hItem )
		bot:ActionQueue_UseAbility( hItem )
		return
	end

end

function X.IsWithoutSpellShield( npcEnemy )

	return not npcEnemy:HasModifier( "modifier_item_sphere_target" )
			and not npcEnemy:HasModifier( "modifier_antimage_spell_shield" )
			and not npcEnemy:HasModifier( "modifier_item_lotus_orb_active" )

end


local lastDeleteTime = -90
function X.SetStashItemTimeUpdate()

	local currentTime = DotaTime()

	for i = 6, 8
	do
		local hItem = bot:GetItemInSlot( i )
		if hItem ~= nil
		then
			fLastStashItemTimeList[hItem:GetName()] = currentTime
		end
	end

	if currentTime > lastDeleteTime + 7.0
	then
		lastDeleteTime = currentTime
		for k, v in pairs( fLastStashItemTimeList )
		do
			if v ~= nil
				and v < currentTime - 7.0
			then
				fLastStashItemTimeList[k] = nil
			end
		end
	end

end


function X.IsItemInStash( sItemName )

	if fLastStashItemTimeList[sItemName] ~= nil
		and DotaTime() < fLastStashItemTimeList[sItemName] + 6.05
	then
		return true
	end

	return false

end


function X.WillBreakInvisible( bot )

	local botName = botName

	if bot:IsInvisible()
	then
		if not bot:HasModifier( "modifier_phantom_assassin_blur_active" )
			and botName ~= "npc_dota_hero_riki"
		then
			return true
		end
	end

	return false

end


function X.IsTargetedByEnemy( building )

	local heroList = GetUnitList( UNIT_LIST_ENEMY_HEROES )
	for _, hero in pairs( heroList )
	do
		if J.IsValidHero(hero) then
			if ( GetUnitToUnitDistance( building, hero ) <= hero:GetAttackRange() + 200
				and hero:GetAttackTarget() == building )
			then
				return true
			end
		end
	end

	return false

end

local function UseGlyph()

	if GetGlyphCooldown( ) > 0
		or DotaTime() < 60
		or bot ~= GetTeamMember( 1 )
		or not GetTeamMember( 2 ):IsBot()
		or not GetTeamMember( 3 ):IsBot()
		or not GetTeamMember( 4 ):IsBot()
		or not GetTeamMember( 5 ):IsBot()
	then
		return
	end

	local T1 = {
		TOWER_TOP_1,
		TOWER_MID_1,
		TOWER_BOT_1,
		TOWER_TOP_2,
		TOWER_MID_2,
		TOWER_BOT_2,
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2
	}

	for _, t in pairs( T1 )
	do
		local tower = GetTower( team, t )
		if tower ~= nil and tower:GetHealth() > 0
			and tower:GetHealth() / tower:GetMaxHealth() < 0.36
			and tower:CanBeSeen()
			and X.IsTargetedByEnemy(tower)
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end


	local MeleeBarrack = {
		BARRACKS_TOP_MELEE,
		BARRACKS_MID_MELEE,
		BARRACKS_BOT_MELEE
	}

	for _, b in pairs( MeleeBarrack )
	do
		local barrack = GetBarracks( team, b )
		if barrack ~= nil and barrack:GetHealth() > 0
			and barrack:GetHealth() / barrack:GetMaxHealth() < 0.5
			and X.IsTargetedByEnemy( barrack )
		then
			bot:ActionImmediate_Glyph( )
			return
		end
	end

	local Ancient = GetAncient( team )
	if Ancient ~= nil and Ancient:GetHealth() > 0
		and Ancient:GetHealth() / Ancient:GetMaxHealth() < 0.5
		and X.IsTargetedByEnemy( Ancient )
	then
		bot:ActionImmediate_Glyph( )
		return
	end

end

function ItemUsageThink()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
	if bot.lastItemFrameProcessTime == nil then bot.lastItemFrameProcessTime = DotaTime() end
	if DotaTime() > 30 and (DotaTime() - bot.lastItemFrameProcessTime < (bot.frameProcessTime * (1 + Customize.ThinkLess))) then return end
	bot.lastItemFrameProcessTime = DotaTime()
	if not J.IsNoItemIllution(bot) then ItemUsageComplement() end
end

function AbilityUsageThink()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end
	if bot.lastAbilityFrameProcessTime == nil then bot.lastAbilityFrameProcessTime = DotaTime() end
	if DotaTime() > 30 and (DotaTime() - bot.lastAbilityFrameProcessTime < (bot.frameProcessTime * (1 + Customize.ThinkLess))) and bot.isBear == nil then return end
	bot.lastAbilityFrameProcessTime = DotaTime()
	if not J.IsNoAbilityIllution(bot) then BotBuild.SkillsComplement() end
end

function BuybackUsageThink()
	if bot.lastBuybackFrameProcessTime == nil then bot.lastBuybackFrameProcessTime = DotaTime() end
	if DotaTime() > 30 and (DotaTime() - bot.lastBuybackFrameProcessTime < 2) then return end
	bot.lastBuybackFrameProcessTime = DotaTime()
	if not bot:IsIllusion() then BuybackUsageComplement() end
	if not bot:IsIllusion() then UseGlyph() end
end

function CourierUsageThink()
	if bot.lastCourierFrameProcessTime == nil then bot.lastCourierFrameProcessTime = DotaTime() end
	if DotaTime() > 30 and (DotaTime() - bot.lastCourierFrameProcessTime < 0.5) then return end
	bot.lastCourierFrameProcessTime = DotaTime()
	if not bot:IsIllusion() then CourierUsageComplement() end
end

function AbilityLevelUpThink()
	if bot.lastLevelUpFrameProcessTime == nil then bot.lastLevelUpFrameProcessTime = DotaTime() end
	if DotaTime() > 30 and (DotaTime() - bot.lastLevelUpFrameProcessTime < 1) then return end
	bot.lastLevelUpFrameProcessTime = DotaTime()
	if not bot:IsIllusion() then AbilityLevelUpComplement() end
end

function X.SetAbilityItemList(heroAbility, items, abilityLvlup)
	bDeafaultAbilityHero = heroAbility
	bDeafaultItemHero = items
	sAbilityLevelUpList = abilityLvlup
end

X.AbilityLevelUpThink = AbilityLevelUpThink
X.BuybackUsageThink = BuybackUsageThink
X.AbilityUsageThink = AbilityUsageThink
X.ItemUsageThink = ItemUsageThink

return X