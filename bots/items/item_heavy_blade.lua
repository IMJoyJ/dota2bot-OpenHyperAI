--行巫之祸
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	local nCastRange = 500
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	--驱散友军
	for i = 1, #GetTeamPlayers( GetTeam() )
	do 
		local npcAlly = GetTeamMember( i )
		if J.IsValidHero( npcAlly )
			and J.IsInRange( bot, npcAlly, nCastRange + 100 )
		then
			if ( J.IsGoingOnSomeone( npcAlly ) or J.IsRetreating( npcAlly ) )
				and npcAlly:WasRecentlyDamagedByAnyHero( 2.0 )
				and J.GetHP( npcAlly ) < 0.85
			then
				local nEnemyList = J.GetNearbyHeroes(npcAlly,  300, true, BOT_MODE_NONE )
				local npcEnemy = nEnemyList[1]
				if J.IsValidHero( npcEnemy )
					and J.CanCastOnMagicImmune( npcEnemy )
				then
					hEffectTarget = npcAlly
					sCastMotive = "行巫之祸驱散友军:"..J.Chat.GetNormName( npcAlly )
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end	
	end
	
		
	--驱散敌军
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
			and J.CanCastOnNonMagicImmune( botTarget )
		then
			-- if botTarget:HasModifier("")
				-- or botTarget:HasModifier("")
			if botTarget:WasRecentlyDamagedByAnyHero( 3.0 )
				and J.GetHP( botTarget ) < 0.7
			then
				hEffectTarget = botTarget
				sCastMotive = "行巫之祸驱散敌军:"..J.Chat.GetNormName( botTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end
	

	return BOT_ACTION_DESIRE_NONE

end

return X
