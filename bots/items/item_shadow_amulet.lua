--护符
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	local nCastRange = 600 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if not bot:HasModifier( 'modifier_invisible' )
		and not bot:HasModifier( 'modifier_item_glimmer_cape' )
		and not bot:HasModifier( 'modifier_item_shadow_amulet_fade' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
	then
		local nEnemyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		for _, enemy in pairs( nEnemyList )
		do
			if enemy:IsAlive()
				and ( enemy:GetAttackTarget() == bot or enemy:IsFacingLocation( bot:GetLocation(), 16 ) )
			then
				local nNearbyEnemyTowers = bot:GetNearbyTowers( 888, true )
				if #nNearbyEnemyTowers == 0
					and lastAmuletTime < DotaTime() - 1.28
					and not J.IsGoingOnSomeone(bot)
				then
					lastAmuletTime = DotaTime()
					hEffectTarget = bot
					sCastMotive = '自己用'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end

		if bot:IsRooted()
			or J.IsStunProjectileIncoming( bot, 1000 )
		then
			local nNearbyEnemyTowers = bot:GetNearbyTowers( 888, true )
			if #nNearbyEnemyTowers == 0
				and lastAmuletTime < DotaTime() - 1.28
			then
				lastAmuletTime = DotaTime()
				hEffectTarget = bot
				sCastMotive = '撤退了'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	local nNearAllyList = J.GetNearbyHeroes(bot, 849, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( nNearAllyList )
	do
		if J.IsValid( npcAlly )
			and npcAlly ~= bot
			and not npcAlly:IsIllusion()
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvisible()
			and not npcAlly:HasModifier( 'modifier_invisible' )
			and not npcAlly:HasModifier( 'modifier_item_glimmer_cape' )
			and not npcAlly:HasModifier( 'modifier_item_shadow_amulet_fade' )
			and not npcAlly:HasModifier( 'modifier_slardar_amplify_damage' )
			and not npcAlly:HasModifier( 'modifier_item_dustofappearance' )
			and ( npcAlly:IsStunned()
					or npcAlly:IsRooted()
					or J.IsStunProjectileIncoming( npcAlly, 1000 ) )
		then
			local nNearbyAllyEnemyTowers = npcAlly:GetNearbyTowers( 888, true )
			if #nNearbyAllyEnemyTowers == 0
			then
				hEffectTarget = npcAlly
				sCastMotive = '帮助队友隐身'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
