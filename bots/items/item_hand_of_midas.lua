--点金
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 990 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	if #hNearbyEnemyHeroList >= 1 then nCastRange = 628 end
	local hNearbyCreepList = bot:GetNearbyCreeps( nCastRange, true )
	local targetCreep = nil
	local targetCreepLV = 0

	for _, creep in pairs( hNearbyCreepList )
	do
		if J.IsValid( creep )
		 and not creep:IsMagicImmune()
		 and not creep:IsAncientCreep()
		then
			if creep:GetLevel() > targetCreepLV
			then
				targetCreepLV = creep:GetLevel()
				targetCreep = creep
			end
		end

	end

	if targetCreep ~= nil
	then
		hEffectTarget = targetCreep
		sCastMotive = '点金小兵:'..hEffectTarget:GetUnitName()
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
