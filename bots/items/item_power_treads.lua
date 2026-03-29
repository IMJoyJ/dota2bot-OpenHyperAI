--假腿
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nMode = ctx.nMode
	local bDeafaultItemHero = ctx.bDeafaultItemHero


	if bDeafaultItemHero then return 0 end

	local nCastRange = 1000
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	local nPtStat = hItem:GetPowerTreadsStat()
	if nPtStat == ATTRIBUTE_INTELLECT
	then
		nPtStat = ATTRIBUTE_AGILITY
	elseif nPtStat == ATTRIBUTE_AGILITY
	then
		nPtStat = ATTRIBUTE_INTELLECT
	end

	if ( bot:HasModifier( "modifier_flask_healing" )
		 or bot:HasModifier( "modifier_clarity_potion" )
		 or bot:HasModifier( "modifier_item_urn_heal" )
		 or bot:HasModifier( "modifier_item_spirit_vessel_heal" )
		 or bot:HasModifier( "modifier_bottle_regeneration" ) )
		and nMode ~= BOT_MODE_ATTACK
		and nMode ~= BOT_MODE_RETREAT
	then
		if nPtStat ~= ATTRIBUTE_AGILITY
		then
			--切换敏捷腿回复
			lastSwitchPtTime = DotaTime()
			if nPtStat == ATTRIBUTE_STRENGTH
			then
				sCastMotive = '力量腿切敏捷回复'
				return BOT_ACTION_DESIRE_HIGH, bot, 'twice', sCastMotive
			else
				sCastMotive = '智力腿切敏捷回复'
				return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
			end

		end
	elseif ( nMode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE )
			or nMode == BOT_MODE_EVASIVE_MANEUVERS
			or ( J.IsNotAttackProjectileIncoming( bot, 1200 ) )
			or ( bot:HasModifier( "modifier_sniper_assassinate" ) )
			or ( bot:GetHealth() / bot:GetMaxHealth() < 0.2 )
			or ( nPtStat == ATTRIBUTE_STRENGTH and bot:GetHealth() / bot:GetMaxHealth() < 0.3 )
			or ( nMode ~= BOT_MODE_LANING and bot:GetLevel() <= 10 and J.IsEnemyFacingUnit( bot, 800, 20 ) )
		then
			if nPtStat ~= ATTRIBUTE_STRENGTH
			then
				--切换力量腿吃伤害
				lastSwitchPtTime = DotaTime()
				if nPtStat == ATTRIBUTE_AGILITY
				then
					sCastMotive = '敏捷腿切换力量吃伤害'
					return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
				else
					sCastMotive = '智力腿切换力量吃伤害'
					return BOT_ACTION_DESIRE_HIGH, bot, 'twice', sCastMotive
				end

			end
	elseif nMode == BOT_MODE_ATTACK
			or nMode == BOT_MODE_TEAM_ROAM
		then
			if J.ShouldSwitchPTStat( bot, hItem )
				and lastSwitchPtTime < DotaTime() - 0.2
			then
				--切换主属性腿攻击
				sCastMotive = '切换主属性腿攻击'
				return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
			end
	elseif J.ShouldSwitchPTStat( bot, hItem )
			and lastSwitchPtTime < DotaTime() - 0.2
		then
			--默认为主属性腿
			sCastMotive = '默认为主属性腿'
			return BOT_ACTION_DESIRE_HIGH, bot, sCastType, sCastMotive
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
