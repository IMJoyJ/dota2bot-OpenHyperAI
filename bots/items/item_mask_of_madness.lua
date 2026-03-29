--疯脸
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botName = ctx.botName


	if botName == 'npc_dota_hero_drow_ranger' then return BOT_ACTION_DESIRE_NONE end

	local nAttackTarget = bot:GetAttackTarget()
	local nCastRange = bot:GetAttackRange() + 100
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	-- local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if ( J.IsValid( nAttackTarget ) or J.IsValidBuilding( nAttackTarget ) )
		and J.CanBeAttacked( nAttackTarget )
		and J.IsInRange( bot, nAttackTarget, nCastRange )
		and ( not J.CanKillTarget( nAttackTarget, bot:GetAttackDamage() * 2, DAMAGE_TYPE_PHYSICAL )
			 or J.GetAroundTargetEnemyUnitCount( bot, nCastRange ) >= 2 )
	then
		local nEnemyHeroInView = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
		if nAttackTarget:IsHero()
			or ( #nEnemyHeroInView == 0 and not bot:WasRecentlyDamagedByAnyHero( 2.0 ) )
		then
			if ( #nEnemyHeroInView == 0 )
			or ( botName ~= "npc_dota_hero_sniper"
				or botName ~= "npc_dota_hero_medusa"
				or botName ~= "npc_dota_hero_faceless_void" and J.GetUltimateAbility(bot):GetCooldown() > 0)
			then
				bot:SetTarget( nAttackTarget )
				hEffectTarget = nAttackTarget
				sCastMotive = '启动'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
