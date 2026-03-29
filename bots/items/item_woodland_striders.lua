--灵犀角
-- X.ConsiderItemDesire["item_minotaur_horn"] = function( hItem )

-- 	return X.ConsiderItemDesire["item_black_king_bar"]( hItem )

-- end

--林地神行靴
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	if bot:DistanceFromFountain() < 600 then return 0 end

	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil

	if J.IsRetreating( bot )
		and bot:WasRecentlyDamagedByAnyHero( 4.0 )
	then
		hEffectTarget = bot
		sCastMotive = "撤退"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
