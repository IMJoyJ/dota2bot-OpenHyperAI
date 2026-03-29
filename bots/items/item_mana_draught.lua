-- Mana Draught
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if #nEnemyHeroes == 0
	or (J.IsValidHero(nEnemyHeroes[1]) and not J.IsInRange(bot, nEnemyHeroes[1], 800) and not bot:WasRecentlyDamagedByAnyHero(5.0))
	then
		if J.GetMP(bot) < 0.5 then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
