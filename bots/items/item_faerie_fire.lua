--心火
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local nMode = ctx.nMode
	local aetherRange = ctx.aetherRange


	if bot:DistanceFromFountain() < 1800 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 300 + aetherRange
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if nMode == BOT_MODE_RETREAT
		 and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
		 and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		 and bot:OriginalGetHealth() < 90
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--攻击
	if J.IsGoingOnSomeone( bot )
		and J.GetHP( bot ) < 0.3
		and J.IsValidHero( botTarget )
		and bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		hEffectTarget = bot
		sCastMotive = "进攻"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--自己吃
	if DotaTime() > 10 * 60
		and hItem:GetName() == "item_faerie_fire"
		and bot:GetItemInSlot( 6 ) ~= nil
		and bot:GetMaxHealth() - bot:OriginalGetHealth() > 200
	then
		hEffectTarget = bot
		sCastMotive = '自己吃'
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
