--肉山A杖
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	local nCastRange = 300
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if hItem:IsFullyCastable()
	then
		hEffectTarget = bot
		sCastMotive = '吃A杖'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
