local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	local nRadius = hItem:GetSpecialValueInt('debuff_radius')

	local nInRangeEnemy = J.GetEnemiesNearLoc(botLocation, nRadius)

	if J.IsInTeamFight(bot, 1200) then
        if #nInRangeEnemy >= 2 then
            local count = 0
            for _, enemyHero in pairs(nInRangeEnemy) do
                if J.IsValidHero(enemyHero)
                and J.CanBeAttacked(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
				and not enemyHero:HasModifier('modifier_doom_bringer_doom_aura_enemy')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and not enemyHero:HasModifier('modifier_ice_blast')
				and not enemyHero:HasModifier('modifier_item_spirit_vessel_damage')
                then
                    count = count + 1
                end
            end

            if count >= 2 then
                return BOT_ACTION_DESIRE_HIGH, nil, ITEM_TARGET_TYPE_NONE
            end
        end
    end

    if J.IsGoingOnSomeone(bot) then
        if  J.IsValidHero(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.CanCastOnNonMagicImmune(botTarget)
        and not botTarget:HasModifier('modifier_doom_bringer_doom_aura_enemy')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and not botTarget:HasModifier('modifier_ice_blast')
		and not botTarget:HasModifier('modifier_item_spirit_vessel_damage')
        then
			return BOT_ACTION_DESIRE_HIGH, nil, ITEM_TARGET_TYPE_NONE
        end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
