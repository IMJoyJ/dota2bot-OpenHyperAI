--散失
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 630 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if( nMode == BOT_MODE_RETREAT )
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValid( npcEnemy )
				and J.IsMoving( npcEnemy )
				and J.IsInRange( npcEnemy, bot, nCastRange )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 )
				and npcEnemy:GetCurrentMovementSpeed() > 200
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and Common.IsWithoutSpellShield( npcEnemy )
				and not J.IsDisabled( npcEnemy ) 
			then
				hEffectTarget = npcEnemy
				sCastMotive = "撤退:"..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsMoving( botTarget )
			and botTarget:GetCurrentMovementSpeed() > 200
			and J.IsInRange( botTarget, bot, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and Common.IsWithoutSpellShield( botTarget )
			and not J.IsDisabled( botTarget ) 
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local npcEnemy = hNearbyEnemyHeroList[1]
	if J.IsValidHero( npcEnemy )
		and J.IsInRange( bot, npcEnemy, nCastRange - 100 )
		and J.CanCastOnNonMagicImmune( npcEnemy )
		and Common.IsWithoutSpellShield( npcEnemy )
		and not J.IsDisabled( npcEnemy )
		and J.IsMoving( npcEnemy )
		and J.IsRunning( npcEnemy )
		and npcEnemy:GetCurrentMovementSpeed() > bot:GetCurrentMovementSpeed() * 0.8
	then
		hEffectTarget = npcEnemy
		sCastMotive = '减速:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
