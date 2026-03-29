--魔棒
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	local nEnemyCount = #nInRangeEnmyList
	local nHPrate = bot:GetHealth() / bot:GetMaxHealth()
	local nMPrate = bot:GetMana() / bot:GetMaxMana()
	local nCharges = hItem:GetCurrentCharges()

	if ( nHPrate < 0.5 or nMPrate < 0.3 ) and nEnemyCount >= 1 and nCharges >= 1
	then
		hEffectTarget = bot
		sCastMotive = '用途1'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nHPrate + nMPrate < 1.1 and nCharges >= 7 and nEnemyCount >= 1 )
	then
		hEffectTarget = bot
		sCastMotive = '用途2'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nCharges >= 9 and bot:GetItemInSlot( 6 ) ~= nil and ( nHPrate <= 0.7 or nMPrate <= 0.6 ) )
	then
		hEffectTarget = bot
		sCastMotive = '用途3'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
