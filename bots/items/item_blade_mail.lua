--刃甲
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.IsNotAttackProjectileIncoming( bot, 366 )
		and #nInRangeEnmyList >= 1
	then
		hEffectTarget = bot
		sCastMotive = '反弹弹道'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	for _, npcEnemy in pairs( hNearbyEnemyHeroList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and npcEnemy:GetAttackTarget() == bot
			and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 )
				 or J.IsAttackProjectileIncoming( bot, 1000 ) )
		then
			hEffectTarget = npcEnemy
			sCastMotive = '反弹敌人伤害:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
