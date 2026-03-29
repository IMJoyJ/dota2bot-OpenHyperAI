--刷新碎片
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	--return X.ConsiderItemDesire["item_refresher"]( hItem )
	-- [inlined from item_refresher]

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = '刷新技能'
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	-- if bot has an overrided version of CanUseRefresherShard logic:
	if BotBuild.CanUseRefresherShard ~= nil and BotBuild.CanUseRefresherShard() then
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if #nInRangeEnmyList > 0
		and ( J.IsGoingOnSomeone( bot ) or J.IsInTeamFight( bot ) )
		and J.CanUseRefresherShard( bot )
	then
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE


end

return X
