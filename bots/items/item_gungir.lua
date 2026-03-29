--缚灵索
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local aetherRange = ctx.aetherRange

	local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1000)
	for _, enemyHero in pairs(nInRangeEnemy)
	do
		if J.IsValidTarget(enemyHero)
		and J.IsUnitWillGoInvisible(enemyHero)
		and J.IsClosestToDustLocation(bot, enemyHero:GetLocation())
		and not J.HasInvisCounterBuff(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if hItem:GetName() == "item_gungir" then hEffectTarget = enemyHero:GetLocation() end
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, 'unit', 'Stop invis'
		end	
	end	

	--return X.ConsiderItemDesire["item_rod_of_atos"]( hItem )
	-- [inlined from item_rod_of_atos]

	local nCastRange = 1100 + aetherRange
	local sCastType = 'unit'
	if hItem:GetName() == "item_gungir" then sCastType = 'ground' end
	local hEffectTarget = nil
	local sCastMotive = nil
	local nEnemysHerosInCastRange = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	for _, npcEnemy in pairs( nEnemysHerosInCastRange )
	do
		if J.IsValid( npcEnemy )
			and npcEnemy:IsChanneling()
			and npcEnemy:HasModifier( "modifier_teleporting" )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and J.CanCastOnTargetAdvanced( npcEnemy )
		then
			hEffectTarget = npcEnemy
			sCastMotive = '打断:'..J.Chat.GetNormName( hEffectTarget )
			
			if hItem:GetName() == "item_gungir" then hEffectTarget = hEffectTarget:GetLocation() end
			
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if nMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
		and	J.IsValid( nEnemysHerosInCastRange[1] )
		and J.CanCastOnNonMagicImmune( nEnemysHerosInCastRange[1] )
		and J.CanCastOnTargetAdvanced( nEnemysHerosInCastRange[1] )
		and not J.IsDisabled( nEnemysHerosInCastRange[1] )
	then
		hEffectTarget = nEnemysHerosInCastRange[1]
		sCastMotive = '撤退了'
		
		if hItem:GetName() == "item_gungir" then hEffectTarget = hEffectTarget:GetLocation() end
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not J.IsDisabled( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
			and GetUnitToUnitDistance( botTarget, bot ) <= nCastRange
			and J.IsMoving( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = '进攻:'..J.Chat.GetNormName( hEffectTarget )
			if hItem:GetName() == "item_gungir" then hEffectTarget = hEffectTarget:GetLocation() end
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

return X
