----------------
-- Neutral Items
----------------

-- TIER 1

-- Trusty Shovel
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	if GetTeamMember(1):IsBot() then return BOT_ACTION_DESIRE_NONE end

	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1000)

	if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
	then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation(), 'ground', nil
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
