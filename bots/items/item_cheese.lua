--奶酪
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	if bot:DistanceFromFountain() < 1200 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local nLostHealth = bot:GetMaxHealth() - bot:GetHealth()
	local botHP = bot:GetHealth() / bot:GetMaxHealth()
	local nLostMana = bot:GetMaxMana() - bot:GetMana()
	local botMP = bot:GetMana() / bot:GetMaxMana()


	if ( nLostHealth > 2500 and nLostMana > 1500 )
		or ( nLostHealth > 2000 and nLostHealth + nLostMana > 3000 )
		or ( botHP < 0.4 and botMP < 0.4 )
		or ( botHP < 0.2 )
		or ( botMP < 0.06 )
	then
		if J.IsGoingOnSomeone( bot )
		then
			if J.IsValidHero( botTarget )
				and J.IsInRange( bot, botTarget, 2000 )
				and J.CanCastOnMagicImmune( botTarget )
			then
				hEffectTarget = bot
				sCastMotive = "进攻"
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		if J.IsRetreating( bot )
			and bot:WasRecentlyDamagedByAnyHero( 4.0 )
		then
			hEffectTarget = bot
			sCastMotive = "撤退"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
