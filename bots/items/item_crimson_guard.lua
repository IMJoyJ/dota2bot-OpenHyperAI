--赤红甲
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	if bot:DistanceFromFountain() < 400 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1200
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	local hNearbyAllyList = J.GetAllyList( bot, nCastRange )

	for _, npcAlly in pairs( hNearbyAllyList )
	do
		if J.IsValid( npcAlly )
			and npcAlly:OriginalGetHealth() / npcAlly:OriginalGetMaxHealth() < 0.8
			and npcAlly:WasRecentlyDamagedByAnyHero( 2.0 )
			and not npcAlly:HasModifier( "modifier_item_crimson_guard_nostack" )
			and #hNearbyEnemyHeroList > 0
		then
			hEffectTarget = npcAlly
			sCastMotive = '救救队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	local nNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
	local nNearbyEnemyTowers = bot:GetNearbyTowers( 800, true )
	if #hNearbyAllyList >= 2
		and ( #nNearbyEnemyHeroes + #nNearbyEnemyTowers >= 2 or #nNearbyEnemyHeroes >= 2 )
	then
		for _, npcAlly in pairs( hNearbyAllyList )
		do
			if npcAlly:WasRecentlyDamagedByAnyHero( 2.0 )
				and not npcAlly:HasModifier( "modifier_item_crimson_guard_nostack" )
			then
				hEffectTarget = npcAlly
				sCastMotive = '保护队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
