--推推
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList
	local team = ctx.team


	local nCastRange = 550 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if bot:HasModifier('modifier_nyx_assassin_vendetta')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	-- 解开先知的树框。bug: 因为先知的树不是正常的树。GetNearbyTrees 不会返回先知的树
	if bot:HasModifier('modifier_furion_sprout_damage') then
		hEffectTarget = bot
		sCastMotive = '解开先知的树框'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	local hAllyList = J.GetAlliesNearLoc( bot:GetLocation(), 600 )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.CanCastOnNonMagicImmune( npcAlly )
		then
			local nNearAllysEnemyList = J.GetNearbyHeroes(npcAlly,  1200, true, BOT_MODE_NONE )
			if #nNearAllysEnemyList >= 1
				and not npcAlly:IsInvisible()
				and npcAlly:GetActiveMode() == BOT_MODE_RETREAT
				and npcAlly:IsFacingLocation( GetAncient( team ):GetLocation(), 30 )
				and npcAlly:DistanceFromFountain() > 600
				and npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
			then
				hEffectTarget = npcAlly
				sCastMotive = '帮队友撤退'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsGoingOnSomeone( npcAlly )
			then
				local hAllyTarget = J.GetProperTarget( npcAlly )
				if J.IsValidHero( hAllyTarget )
					and npcAlly:IsFacingLocation( hAllyTarget:GetLocation(), 15 )
					and J.CanCastOnNonMagicImmune( hAllyTarget )
					and GetUnitToUnitDistance( hAllyTarget, npcAlly ) > npcAlly:GetAttackRange() + 50
					and GetUnitToUnitDistance( hAllyTarget, npcAlly ) < npcAlly:GetAttackRange() + 700
					and not hAllyTarget:IsFacingLocation( npcAlly:GetLocation(), 40 )
					and J.GetEnemyCount( npcAlly, 1600 ) <= 3
				then
					hEffectTarget = npcAlly
					sCastMotive = '帮队友进攻'..J.Chat.GetNormName( hEffectTarget )
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end

			if J.IsStuck( npcAlly ) or npcAlly:HasModifier('modifier_furion_sprout_damage')
			then
				hEffectTarget = npcAlly
				sCastMotive = '队友卡地形了'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end

	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and npcAlly:GetUnitName() == "npc_dota_hero_crystal_maiden"
			and J.CanCastOnNonMagicImmune( npcAlly )
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
					sCastMotive = '推冰女'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	if bot:DistanceFromFountain() < 2600
	then
		for _, npcEnemy in pairs( hNearbyEnemyHeroList )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnMagicImmune( npcEnemy )
				and npcEnemy:IsFacingLocation( GetAncient( team ):GetLocation(), 40 )
				and GetUnitToLocationDistance( npcEnemy, GetAncient( team ):GetLocation() ) < 1200
			then
				hEffectTarget = npcEnemy
				sCastMotive = '推人入泉'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end
	
	
	--推敌人靠近自己
	if J.IsGoingOnSomeone(bot) and #hAllyList >= 2
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
			and Common.IsWithoutSpellShield( botTarget )
		then
			local allyCenterLocation = J.GetCenterOfUnits( hAllyList )
			if botTarget:IsFacingLocation( allyCenterLocation, 28 )
				and GetUnitToLocationDistance( bot, allyCenterLocation ) >= 500
			then
				hEffectTarget = botTarget
				sCastMotive = '推敌人靠近自己'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end			
		end
	end	

	return BOT_ACTION_DESIRE_NONE

end

return X
