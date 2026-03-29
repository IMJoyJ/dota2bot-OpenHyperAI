--大推推
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList
	local team = ctx.team


	local nCastRange = 800 + aetherRange
	local nNearRange = 450 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nNearRange, true, BOT_MODE_NONE )


	if ( nMode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH )
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if ( J.IsInRange( bot, npcEnemy, nNearRange ) 
				and J.CanCastOnNonMagicImmune( npcEnemy ) )
			then
				hEffectTarget = npcEnemy
				sCastMotive = '撤退了推敌人'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		if bot:IsFacingLocation( GetAncient( team ):GetLocation(), 20 )
			and bot:DistanceFromFountain() > 600
			and #hNearbyEnemyHeroList >= 1
		then
			hEffectTarget = bot
			sCastMotive = '撤退了推自己'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and GetUnitToUnitDistance( botTarget, bot ) > bot:GetAttackRange() + 100
			and GetUnitToUnitDistance( botTarget, bot ) < bot:GetAttackRange() + 700
			and GetUnitToUnitDistance( botTarget, bot ) < GetUnitToLocationDistance( bot, J.GetCorrectLoc( botTarget, 1.0 ) ) - 100
			and bot:IsFacingLocation( botTarget:GetLocation(), 20 )
			and not botTarget:IsFacingLocation( bot:GetLocation(), 120 )
			and J.GetEnemyCount( bot, 1600 ) <= 2
		then
			hEffectTarget = bot
			sCastMotive = "进攻"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.HasItem(bot, "item_hurricane_pike")
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if npcEnemy ~= nil
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and GetUnitToUnitDistance( npcEnemy, bot ) <= nNearRange
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				bot:SetTarget( npcEnemy )
				hEffectTarget = npcEnemy
				sCastMotive = '推开'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	local hAllyList = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and npcAlly:GetUnitName() == "npc_dota_hero_crystal_maiden"
			and J.CanCastOnNonMagicImmune( npcAlly )
			and Common.IsWithoutSpellShield( npcAlly )
			and ( npcAlly:IsInvisible() or npcAlly:GetHealth() / npcAlly:GetMaxHealth() > 0.8 )
			and ( npcAlly:IsChanneling() and not npcAlly:HasModifier( "modifier_teleporting" ) )
		then
			local enemyHeroesNearbyCM = J.GetNearbyHeroes(npcAlly,  1200, true, BOT_MODE_NONE )
			for _, npcEnemy in pairs( enemyHeroesNearbyCM )
			do
				if npcEnemy ~= nil and npcEnemy:IsAlive()
					and J.CanCastOnNonMagicImmune( npcEnemy )
					and GetUnitToUnitDistance( npcEnemy, npcAlly ) > 835
					and npcAlly:IsFacingLocation( npcEnemy:GetLocation(), 30 )
				then
					hEffectTarget = npcAlly
					sCastMotive = '推CM'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
