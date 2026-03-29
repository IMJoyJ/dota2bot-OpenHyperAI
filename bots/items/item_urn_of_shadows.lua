--骨灰
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	if hItem:GetCurrentCharges() == 0 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 950 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget ) and 
			((J.CanCastOnNonMagicImmune( botTarget )
				and J.IsInRange( bot, botTarget, nCastRange )
				and not botTarget:HasModifier( "modifier_item_urn_damage" )
				and not botTarget:HasModifier( "modifier_item_spirit_vessel_damage" )
				and not botTarget:HasModifier( "modifier_arc_warden_tempest_double" )
				and ( J.GetHP( botTarget ) < 0.95 or J.IsInRange( bot, botTarget, 700 ) ))
			or botTarget:HasModifier( "modifier_invoker_cold_snap_freeze" ) -- 配合急速冷却
		) then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if bot:GetActiveMode() ~= BOT_MODE_ROSHAN
	then
		local hAllyList = J.GetNearbyHeroes(bot, nCastRange + 80, false, BOT_MODE_NONE )
		local hNeedHealAlly = nil
		local nNeedHealAllyHealth = 99999
		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsValid( npcAlly )
				and not npcAlly:IsIllusion()
				and npcAlly:DistanceFromFountain() > 800
				and J.CanCastOnNonMagicImmune( npcAlly )
				and not npcAlly:WasRecentlyDamagedByAnyHero( 3.1 )
				and not npcAlly:HasModifier( "modifier_item_spirit_vessel_heal" )
				and not npcAlly:HasModifier( "modifier_item_urn_heal" )
				and not npcAlly:HasModifier( "modifier_fountain_aura" )
				and not npcAlly:HasModifier( "modifier_arc_warden_tempest_double" )
				and npcAlly:OriginalGetMaxHealth() - npcAlly:OriginalGetHealth() > 450
				and #hNearbyEnemyHeroList == 0 
			then
				if( npcAlly:OriginalGetHealth() < nNeedHealAllyHealth )
				then
					hNeedHealAlly = npcAlly
					nNeedHealAllyHealth = npcAlly:OriginalGetHealth()
				end
			end
		end

		if( hNeedHealAlly ~= nil )
		then
			hEffectTarget = hNeedHealAlly
			sCastMotive = '治疗:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
