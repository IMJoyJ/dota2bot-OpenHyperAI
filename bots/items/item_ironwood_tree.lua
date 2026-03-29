local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	local nCastRange = 600
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil

	if lastKACount == -1 then lastKACount = GetHeroKills( bot:GetPlayerID() ) + GetHeroAssists( bot:GetPlayerID() ) end

	if lastKACount < GetHeroKills( bot:GetPlayerID() ) + GetHeroAssists( bot:GetPlayerID() )
	then
		lastKACount = -1
		hEffectTarget = J.GetFaceTowardDistanceLocation( bot, nCastRange )
		sCastMotive = 'GG'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
