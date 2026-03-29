-- Iron Talon
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nCastRange = 350

	-- Only use it for creeps
	if J.IsFarming(bot)
	then
		local nCreep = bot:GetNearbyNeutralCreeps(nCastRange)
		if #nCreep <= 0 then return 0 end

		local creepTarget = J.GetMostHpUnit(nCreep)
		if J.CanBeAttacked(creepTarget)
		and J.GetHP(creepTarget) > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, creepTarget, 'unit', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
