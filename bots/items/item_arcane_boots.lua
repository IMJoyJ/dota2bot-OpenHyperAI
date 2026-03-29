--秘法
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	if bot:DistanceFromFountain() < 800 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1200
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	local hNearbyAllyList = J.GetAllyList( bot, nCastRange )

	if #hNearbyAllyList >= 2
		and bot:GetHealth() <= 120
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		sCastMotive = '死前为队友用'
		return BOT_ACTION_DESIRE_HIGH, hNearbyAllyList[2], sCastType, sCastMotive
	end

	local nNeedMPCount = 0
	for _, npcAlly in pairs( hNearbyAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and npcAlly:GetMaxMana()- npcAlly:GetMana() > 180
		then
			nNeedMPCount = nNeedMPCount + 1
		end

		if nNeedMPCount >= 2
		then
			sCastMotive = '团队回蓝'
			return BOT_ACTION_DESIRE_HIGH, hNearbyAllyList[2], sCastType, sCastMotive
		end
	end

	if bot:GetMana() / bot:GetMaxMana() < 0.58
	then
		sCastMotive = '自己补蓝'
		return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
