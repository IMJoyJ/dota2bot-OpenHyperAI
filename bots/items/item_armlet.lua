local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local bDeafaultItemHero = ctx.bDeafaultItemHero


	if bDeafaultItemHero then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local bActive = hItem:GetToggleState()

	if ( J.IsValid( botTarget ) or J.IsValidBuilding( botTarget ) )
		and not botTarget:IsAttackImmune()
		and not botTarget:IsInvulnerable()
		and ( not botTarget:IsBuilding() or not J.IsKeyWordUnit( "OutpostName", botTarget ) )
		and not J.HasForbiddenModifier( botTarget )
		and J.IsInRange( bot, botTarget, bot:GetAttackRange() + 180 )
		and not bot:IsDisarmed()
	then
		nLastActiveArmletTime = DotaTime()
		if not bActive
		then
			hEffectTarget = botTarget
			sCastMotive = '激活臂章攻击'..( hEffectTarget:IsHero() and J.Chat.GetNormName( hEffectTarget ) or "非英雄" )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if bot:OriginalGetHealth() <= 600
		and ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) or J.IsAttackProjectileIncoming( bot, 1600 ) )
	then
		nLastActiveArmletTime = DotaTime()
		if not bActive
		then
			hEffectTarget = bot
			sCastMotive = '激活临时血量'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	if bActive
		and DotaTime() > nLastActiveArmletTime + 0.9
		and ( #nInRangeEnmyList == 0 or bot:OriginalGetHealth() > 990 )
	then
		hEffectTarget = bot
		sCastMotive = '关闭臂章'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType --, '关闭臂章'
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
