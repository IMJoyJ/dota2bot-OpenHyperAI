-- Pyrrhic Cloak
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nCastRange = J.GetProperCastRange(false, bot, hItem:GetCastRange())

    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if J.IsNotAttackProjectileIncoming(bot, 400)
	and J.IsValidHero(nEnemyHeroes[1])
	and J.IsInRange(bot, nEnemyHeroes[1], nCastRange)
	and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
	and J.CanCastOnTargetAdvanced(nEnemyHeroes[1])
	then
		return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1], 'unit', nil
	end

	for _, enemyHero in pairs(nEnemyHeroes)do
		if J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.CanCastOnTargetAdvanced(enemyHero)
		and (enemyHero:GetAttackTarget() == bot)
		and (bot:WasRecentlyDamagedByHero(enemyHero, 3.0) or J.IsAttackProjectileIncoming(bot, 1000))
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero, 'unit', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
