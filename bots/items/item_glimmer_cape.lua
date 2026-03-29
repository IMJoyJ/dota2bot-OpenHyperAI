--微光
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList
	local hNearbyEnemyTowerList = ctx.hNearbyEnemyTowerList


	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	if	bot:DistanceFromFountain() > 600
		and #hNearbyEnemyTowerList == 0
		and not bot:HasModifier( 'modifier_item_dustofappearance' )
		and not bot:HasModifier( 'modifier_slardar_amplify_damage' )
		and not bot:HasModifier( 'modifier_item_glimmer_cape' )
		and not bot:IsInvulnerable()
		and not bot:IsMagicImmune()
	then

		if bot:IsSilenced() or bot:IsRooted() or J.IsStunProjectileIncoming( bot, 1000 )
		then
			hEffectTarget = bot
			sCastMotive = '自己被缠绕或沉默了'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if ( J.IsRetreating( bot ) 
				and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYHIGH 
				and not bot:HasModifier("modifier_fountain_aura") )
			 or ( botTarget == nil 
					and #hNearbyEnemyHeroList > 0 
					and J.GetHP( bot ) < 0.36 + ( 0.09 * #hNearbyEnemyHeroList ) )
		then
			hEffectTarget = bot
			sCastMotive = '自己撤退'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		--------------------
		--use at npcAlly target
		--------------------
		local hAllyList = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE )
		for _, npcAlly in pairs( hAllyList )
		do
			if J.IsValid( npcAlly )
				and not npcAlly:IsIllusion()
				and not npcAlly:IsMagicImmune()
				and not npcAlly:IsInvulnerable()
				and not npcAlly:IsInvisible()
				and npcAlly:DistanceFromFountain() > 600
				and not npcAlly:HasModifier( 'modifier_item_glimmer_cape' )
				and not npcAlly:HasModifier( 'modifier_item_dustofappearance' )
				and not npcAlly:HasModifier( 'modifier_slardar_amplify_damage' )
				and not npcAlly:HasModifier( 'modifier_arc_warden_tempest_double' )
			then
				local nNearbyAllyEnemyTowers = npcAlly:GetNearbyTowers( 888, true )
				if #nNearbyAllyEnemyTowers == 0
				then
					--retreat
					if J.GetHP( npcAlly ) < 0.35 + ( 0.05 * #hNearbyEnemyHeroList )
						and J.IsRetreating( npcAlly )
						and npcAlly:WasRecentlyDamagedByAnyHero( 4.0 )
					then
						hEffectTarget = npcAlly
						sCastMotive = '保护队友撤退:'..J.Chat.GetNormName( hEffectTarget )
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end

					--Disable
					if J.IsDisabled( npcAlly ) --debug
						or J.IsStunProjectileIncoming( npcAlly, 1000 )
					then
						hEffectTarget = npcAlly
						sCastMotive = '保护被控队友:'..J.Chat.GetNormName( hEffectTarget )
						return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
					end
				end
			end
		end

	end

	return BOT_ACTION_DESIRE_NONE

end

return X
