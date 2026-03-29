-- Gale Guard
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

    local nAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
    local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	if bot:HasModifier('modifier_abaddon_aphotic_shield') or not J.CanBeAttacked(bot) then
		return BOT_ACTION_DESIRE_NONE
	end

	if bot:IsRooted() and #nEnemyHeroes > 0 then
		return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
	end

	if J.IsGoingOnSomeone(bot) then
		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, bot:GetAttackRange() + 300)
		and (J.GetHP(bot) < 0.65 and bot:WasRecentlyDamagedByAnyHero(3.0))
		and not J.IsSuspiciousIllusion(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	if J.IsRetreating(bot) and not J.IsRealInvisible(bot) then
		for _, enemyHero in pairs(nEnemyHeroes) do
            if J.IsValidHero(enemyHero)
            and J.IsInRange(bot, enemyHero, 800)
            and J.IsChasingTarget(enemyHero, bot)
			and not J.IsSuspiciousIllusion(enemyHero)
            then
                if #nEnemyHeroes > #nAllyHeroes or (J.GetHP(bot) < 0.55 and bot:WasRecentlyDamagedByAnyHero(3.0)) then
                    return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
                end
            end
        end
	end

    if J.IsFarming(bot) then
        local nEnemyCreeps = bot:GetNearbyCreeps(1600, true)
		if nEnemyCreeps then
			if  J.IsValid(nEnemyCreeps[1])
			and J.CanBeAttacked(nEnemyCreeps[1])
			and J.GetHP(bot) < 0.25
			and J.IsAttacking(bot)
			then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end
		end
    end

    if J.IsDoingRoshan(bot) then
        if  J.IsRoshan(botTarget)
		and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
		and J.GetHP(bot) < 0.5
        then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

    if J.IsDoingTormentor(bot) then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
		and J.GetHP(bot) < 0.5
        then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

return X
