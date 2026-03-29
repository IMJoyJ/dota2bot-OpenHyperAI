--风暴宝器
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	local nCastRange = 300 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


	if J.CanCastOnNonMagicImmune( bot )
		and #nInRangeEnmyList > 0
	then
		if bot:IsRooted()
			or ( bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and bot:IsSilenced() )
		then
			hEffectTarget = bot
			sCastMotive = '解缠绕:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsUnitTargetProjectileIncoming( bot, 400 )
		then
			hEffectTarget = bot
			sCastMotive = '防御弹道:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
