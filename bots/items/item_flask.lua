--大药
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	if bot:DistanceFromFountain() < 3000 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 900
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if bot:OriginalGetMaxHealth() - bot:OriginalGetHealth() > 500
		and #nInRangeEnmyList == 0
		and not bot:WasRecentlyDamagedByAnyHero( 2.2 )
		and not bot:HasModifier( "modifier_filler_heal" )
		and not bot:HasModifier( "modifier_elixer_healing" )
		and not bot:HasModifier( "modifier_flask_healing" )
		and not bot:HasModifier( "modifier_juggernaut_healing_ward_heal" )
	then
		hEffectTarget = bot
		sCastMotive = '自己吃'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 700 )
	local hNeedHealAlly = nil
	local nNeedHealAllyHealth = 99999
	for _, npcAlly in pairs( hAllyList )
	do
		if J.IsValid( npcAlly ) and npcAlly ~= bot
			and not npcAlly:HasModifier( "modifier_filler_heal" )
			and not npcAlly:HasModifier( "modifier_elixer_healing" )
			and not npcAlly:HasModifier( "modifier_flask_healing" )
			and not npcAlly:HasModifier( "modifier_juggernaut_healing_ward_heal" )
			and not npcAlly:WasRecentlyDamagedByAnyHero( 3.0 )
			and not npcAlly:IsIllusion()
			and not npcAlly:IsChanneling()
			and npcAlly:OriginalGetMaxHealth() - npcAlly:OriginalGetHealth() > 550 
		then
			if( npcAlly:OriginalGetHealth() < nNeedHealAllyHealth )
			then
				hNeedHealAlly = npcAlly
				nNeedHealAllyHealth = npcAlly:OriginalGetHealth()
			end
		end
	end
	if hNeedHealAlly ~= nil and #hNearbyEnemyHeroList == 0
	then
		hEffectTarget = hNeedHealAlly
		sCastMotive = '给队友贴:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
