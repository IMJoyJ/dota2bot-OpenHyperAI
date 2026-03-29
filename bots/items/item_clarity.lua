--小净化
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	if bot:DistanceFromFountain() < 2000 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.GetMP( bot ) < 0.4
		and not bot:HasModifier( "modifier_clarity_potion" )
		and #nInRangeEnmyList == 0
		and not bot:WasRecentlyDamagedByAnyHero( 4.0 )
	then
		hEffectTarget = bot
		sCastMotive = '净化自己'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if #nInRangeEnmyList == 0 
	then
		local hAllyList = J.GetNearbyHeroes(bot, 600, false, BOT_MODE_NONE )
		local hNeedManaAlly = nil
		local nNeedManaAllyMana = 99999
		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsValid( npcAlly )
				and npcAlly ~= bot
				and not npcAlly:IsIllusion()
				and not npcAlly:IsChanneling()
				and not npcAlly:HasModifier( "modifier_clarity_potion" )
				and not npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
				and npcAlly:GetMaxMana() - npcAlly:GetMana() > 350 
			then
				if( npcAlly:GetMana() < nNeedManaAllyMana )
				then
					hNeedManaAlly = npcAlly
					nNeedManaAllyMana = npcAlly:GetMana()
				end
			end
		end
		if( hNeedManaAlly ~= nil )
		then
			hEffectTarget = hNeedManaAlly
			sCastMotive = '净化队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
