local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	--return X.ConsiderItemDesire["item_necronomicon"]( hItem )
	-- [inlined from item_necronomicon]

	local nCastRange = 750
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if botTarget ~= nil and botTarget:IsAlive()
		and J.IsInRange( bot, botTarget, 1000 )
	then
		hEffectTarget = botTarget
		sCastMotive = "进攻"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE


end

return X
