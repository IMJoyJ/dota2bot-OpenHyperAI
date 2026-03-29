--机械之心
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget


	local nCastRange = 800
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
		then
			local nSoltList = { 0, 1, 2, 3, 4, 5 }
			local nRemainTime = 0
			for _, nSlot in pairs( nSoltList )
			do
				local hItem = bot:GetItemInSlot( nSlot )
				if hItem ~= nil and hItem:GetName() ~= 'item_refresher'
				then
					local nCooldownTime = hItem:GetCooldownTimeRemaining()
					nRemainTime = nRemainTime + nCooldownTime
				end
			end

			if nRemainTime >= 30
			then
				hEffectTarget = botTarget
				sCastMotive = "刷新CD"
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
