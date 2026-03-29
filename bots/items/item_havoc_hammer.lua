-- Havoc Hammer
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget

	local nRadius = 400
	local nDamage = 175 + bot:GetAttributeValue(ATTRIBUTE_STRENGTH) * 1.5

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nRadius, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

	if J.IsInTeamFight(bot, 1200)
	then
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1000)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            local realEnemyCount = J.GetEnemiesNearLoc(bot:GetLocation(), nRadius)

            if realEnemyCount ~= nil and #realEnemyCount >= 2
            and not J.IsLocationInChrono(nInRangeEnemy[1]:GetLocation())
            and not J.IsLocationInBlackHole(nInRangeEnemy[1]:GetLocation())
            then
                return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nRadius)
		and J.IsRunning(botTarget)
		and bot:IsFacingLocation(botTarget:GetLocation(), 30)
		and not botTarget:IsFacingLocation(bot:GetLocation(), 90)
		and not J.IsSuspiciousIllusion(botTarget)
		and not J.IsDisabled(botTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

return X
