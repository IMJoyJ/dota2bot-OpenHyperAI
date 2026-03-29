--勋章
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 900 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	-- local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and not botTarget:HasModifier( 'modifier_item_solar_crest_armor_reduction' )
			and not botTarget:HasModifier( 'modifier_item_medallion_of_courage_armor_reduction' )
			and J.CanCastOnNonMagicImmune( botTarget )
			and not botTarget:IsAncientCreep()
			and ( J.IsInRange( bot, botTarget, bot:GetAttackRange() + 150 )
				or ( J.IsInRange( bot, botTarget, 1000 )
					and J.GetAroundTargetOtherAllyHeroCount( bot, botTarget, 600 ) >= 1 ) )
		then
			hEffectTarget = botTarget
			sCastMotive = '进攻:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if #hNearbyEnemyHeroList == 0
	then
		if J.IsValid( botTarget )
			and not botTarget:HasModifier( 'modifier_item_solar_crest_armor_reduction' )
			and not botTarget:HasModifier( 'modifier_item_medallion_of_courage_armor_reduction' )
			and not botTarget:HasModifier( "modifier_fountain_glyph" )
			and not J.CanKillTarget( botTarget, bot:GetAttackDamage() * 2.38, DAMAGE_TYPE_PHYSICAL )
			and J.IsInRange( bot, botTarget, bot:GetAttackRange() + 150 )
		then
			hEffectTarget = botTarget
			sCastMotive = '刷小兵:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--------
	local hAllyList = J.GetNearbyHeroes(bot, 1000, false, BOT_MODE_NONE )
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= bot
			and J.IsValidHero( npcAlly )
			and not npcAlly:IsIllusion()
			and J.CanCastOnNonMagicImmune( npcAlly )
			and not npcAlly:HasModifier( 'modifier_item_solar_crest_armor_addition' )
			and not npcAlly:HasModifier( 'modifier_item_medallion_of_courage_armor_addition' )
			and not npcAlly:HasModifier( "modifier_arc_warden_tempest_double" )
			and ( ( J.IsDisabled( npcAlly ) )
				or ( J.GetHP( npcAlly ) < 0.35 and #hNearbyEnemyHeroList > 0 and npcAlly:WasRecentlyDamagedByAnyHero( 2.0 ) )
				or ( J.IsValidHero( npcAlly:GetAttackTarget() ) and GetUnitToUnitDistance( npcAlly, npcAlly:GetAttackTarget() ) <= npcAlly:GetAttackRange() and #hNearbyEnemyHeroList == 0 ) )
		then
			hEffectTarget = npcAlly
			sCastMotive = '救队友:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
