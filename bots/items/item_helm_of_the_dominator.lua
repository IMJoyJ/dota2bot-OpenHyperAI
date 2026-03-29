--支配
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	local nCastRange = 1000 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil

	for _, unit in pairs(GetUnitList(UNIT_LIST_ALLIED_CREEPS))
	do
		if J.IsValid(unit)
		and unit:HasModifier('modifier_dominated')
		and unit:IsAncientCreep()
		then
			return BOT_ACTION_DESIRE_NONE, hEffectTarget, 'sCastType', sCastMotive
		end
	end

	local maxHP = 0
	local hCreep = nil
	local hNearbyCreepList = bot:GetNearbyCreeps( nCastRange, true )
	if #hNearbyCreepList >= 2
	then
		for _, creep in pairs( hNearbyCreepList )
		do
			if J.IsValid( creep )
			then
				local nCreepHP = creep:GetHealth()
				if nCreepHP > maxHP
					and ( creep:GetHealth() / creep:GetMaxHealth() ) > 0.75
					and ( not creep:IsAncientCreep() or hItem:GetName() == "item_helm_of_the_overlord" )
					and not J.IsKeyWordUnit( "siege", creep )
				then
					hCreep = creep
					maxHP = nCreepHP
				end
			end
		end
	end
	if hCreep ~= nil
	then
		hEffectTarget = hCreep
		sCastMotive = '支配:'..hEffectTarget:GetUnitName()
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
