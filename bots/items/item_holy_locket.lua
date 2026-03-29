--圣洁吊坠
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	--给队友

	--return X.ConsiderItemDesire["item_magic_wand"]( hItem )
	-- [inlined from item_magic_wand]

	if hItem:GetCurrentCharges() <= 0 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1000
	local sCastType = 'none'
	if hItem:GetName() == 'item_holy_locket' then sCastType = 'unit' end
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	local nEnemyCount = #nInRangeEnmyList
	local nHPrate = bot:GetHealth() / bot:GetMaxHealth()
	local nMPrate = bot:GetMana() / bot:GetMaxMana()
	local nLostHP = bot:GetMaxHealth() - bot:GetHealth()
	local nLostMP = bot:GetMaxMana() - bot:GetMana()
	local nCharges = hItem:GetCurrentCharges()

	if ( ( nHPrate < 0.4 or nMPrate < 0.3 ) and nEnemyCount >= 1 and nCharges >= 1 )
	then
		hEffectTarget = bot
		sCastMotive = '用途1'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nHPrate < 0.7 and nMPrate < 0.7 and nCharges >= 12 and nEnemyCount >= 1 ) 
	then
		hEffectTarget = bot
		sCastMotive = '用途2'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nCharges >= 19 and bot:GetItemInSlot( 6 ) ~= nil and ( nHPrate <= 0.6 or nMPrate <= 0.5 ) ) 
	then
		hEffectTarget = bot
		sCastMotive = '用途3'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( nCharges == 20 and nEnemyCount >= 1 and nLostHP > 350 and nLostMP > 350 ) 
	then
		hEffectTarget = bot
		sCastMotive = '用途4'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE


end

return X
