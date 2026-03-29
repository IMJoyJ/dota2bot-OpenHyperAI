--魔瓶
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	if hItem:GetCurrentCharges() == 0
		or bot:HasModifier( "modifier_bottle_regeneration" )
	then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = 400 + aetherRange
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nLostMana = bot:GetMaxMana() - bot:GetMana()
	local nLostHealth = bot:OriginalGetMaxHealth() - bot:OriginalGetHealth()


	--泉水喝
	if bot:HasModifier( "modifier_fountain_aura" )
	then
		hEffectTarget = bot
		sCastMotive = "在泉水里喝"
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	--自己喝
	if not bot:WasRecentlyDamagedByAnyHero( 3.0 )
	then
		if nLostHealth > 150 and nLostMana > 90
		then
			hEffectTarget = bot
			sCastMotive = "补血补篮"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if nLostHealth > 500 and J.GetHP( bot ) < 0.5
		then
			hEffectTarget = bot
			sCastMotive = "只补血"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if nLostMana > 280 and J.GetMP( bot ) < 0.4
		then
			hEffectTarget = bot
			sCastMotive = "只补篮"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
