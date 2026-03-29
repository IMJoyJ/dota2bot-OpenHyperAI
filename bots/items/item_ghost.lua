--绿杖
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if bot:GetAttackTarget() == nil
		or bot:GetHealth() < 500
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and J.IsInRange( bot, npcEnemy, npcEnemy:GetAttackRange() + 100 )
				and npcEnemy:GetAttackTarget() == bot
				and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
				and npcEnemy:GetAttackDamage() > bot:GetAttackDamage()
			then
				hEffectTarget = npcEnemy
				sCastMotive = "撤退"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
