local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	local nCastRange = 500 + aetherRange
	local sCastType = 'ground'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, 1200, true, BOT_MODE_NONE )
	local nAllyTowerList = bot:GetNearbyTowers( 1200, false )


	--进攻时对拥有隐身能力的敌人使用
	if J.IsGoingOnSomeone( bot )
		and #nInRangeEnmyList >= 1
	then
		local targetHero = nil
		for _, npcEnemy in pairs( nInRangeEnmyList )
		do
			if J.IsValidHero( npcEnemy )
				and J.IsInRange( bot, npcEnemy, 900 )
				and J.CanCastOnMagicImmune( npcEnemy )
				and J.HasInvisibilityOrItem( npcEnemy )
				and not npcEnemy:HasModifier( "modifier_slardar_amplify_damage" )
				and not npcEnemy:HasModifier( "modifier_item_dustofappearance" )
				and not J.Site.IsLocationHaveTrueSight( npcEnemy:GetLocation() )
			then
				hEffectTarget = J.GetUnitTowardDistanceLocation( bot, npcEnemy, nCastRange )
				sCastMotive = '插真眼针对:'..J.Chat.GetNormName( npcEnemy )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

	end


	return BOT_ACTION_DESIRE_NONE

end

return X
