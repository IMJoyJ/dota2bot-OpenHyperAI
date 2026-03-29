--血精石
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	if bot:DistanceFromFountain() < 1200 then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if bot:WasRecentlyDamagedByAnyHero(2.0)
	and J.GetHP(bot) < 0.3
	then
		hEffectTarget = bot
		sCastMotive = "开启血精石" --"亡魂胸针进攻:"..J.Chat.GetNormName( botTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end


	if J.IsGoingOnSomeone( bot )
	and (#nInRangeEnmyList >= 2 or J.GetHP(bot) < 0.3)
	then
		if bot:WasRecentlyDamagedByAnyHero( 2.0 )
		then
			hEffectTarget = bot
			sCastMotive = "开启血精石" --"亡魂胸针进攻:"..J.Chat.GetNormName( botTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end
	

	return BOT_ACTION_DESIRE_NONE

end

return X
