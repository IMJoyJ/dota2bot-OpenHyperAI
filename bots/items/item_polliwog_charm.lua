-- Pollywog Charm
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nCastRange = 1000

	if bot:GetMana() < 75 + 40 then
		return BOT_ACTION_DESIRE_NONE
	end

	local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
	local hNeedHealAlly = nil
	local nNeedHealAllyHealth = 99999
	for _, allyHero in pairs(nAllyHeroes) do
		if J.IsValidHero(allyHero)
		and not allyHero:IsIllusion()
		and not allyHero:HasModifier("modifier_abaddon_borrowed_time")
		and not allyHero:HasModifier("modifier_necrolyte_reapers_scythe")
		and not allyHero:HasModifier("modifier_filler_heal")
		and not allyHero:HasModifier("modifier_elixer_healing")
		and not allyHero:HasModifier("modifier_flask_healing")
		and not allyHero:HasModifier("modifier_juggernaut_healing_ward_heal")
		and not allyHero:HasModifier("modifier_juggernaut_healing_ward_heal")
		and not allyHero:IsChanneling()
		and (allyHero:GetMaxHealth() - allyHero:GetHealth() > 100)
		then
			if allyHero:GetHealth() < nNeedHealAllyHealth then
				hNeedHealAlly = allyHero
				nNeedHealAllyHealth = allyHero:GetHealth()
			end
		end
	end

	if hNeedHealAlly ~= nil then
		return BOT_ACTION_DESIRE_HIGH, hNeedHealAlly, 'unit', nil
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
