local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	local nDuration = hItem:GetSpecialValueInt('duration')

	if J.IsGoingOnSomeone(bot) then
		if bot:WasRecentlyDamagedByAnyHero(2.0) then
			local enemyDamage = 0
			for _, enemyHero in pairs(nEnemyHeroes) do
				if  J.IsValidHero(enemyHero)
				and not J.IsSuspiciousIllusion(enemyHero)
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and not enemyHero:IsChanneling()
				then
					if enemyHero:GetAttackTarget() == bot
					or J.IsChasingTarget(enemyHero, bot)
					or enemyHero:IsFacingLocation(bot:GetLocation(), 15)
					or bot:WasRecentlyDamagedByHero(enemyHero, 3.0)
					then
						enemyDamage = enemyDamage + (enemyHero:GetAttackDamage() * enemyHero:GetAttackSpeed() * nDuration)
					end
				end
			end

			if bot:GetActualIncomingDamage(enemyDamage * 1.5, DAMAGE_TYPE_PHYSICAL) < bot:GetHealth() then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
