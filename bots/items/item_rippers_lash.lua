-- Ripper's Lash
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nCastRange = 700
	local nRadius = 200

	local nAllyHeroes = J.GetAlliesNearLoc(bot:GetLocation(), nCastRange)
	for _, allyHero in pairs(nAllyHeroes) do
		if J.IsValidHero(allyHero) and not allyHero:IsIllusion() then
			local hAllyTarget = allyHero:GetAttackTarget()
			if J.IsGoingOnSomeone(allyHero) and J.IsAttacking(allyHero) then
				if J.IsValidHero(hAllyTarget)
				and J.CanBeAttacked(hAllyTarget)
				and J.IsInRange(allyHero, hAllyTarget, allyHero:GetAttackRange() + 50)
				and J.IsInRange(bot, hAllyTarget, nCastRange)
				and not J.IsSuspiciousIllusion(hAllyTarget)
				and not hAllyTarget:HasModifier('modifier_abaddon_borrowed_time')
				and not hAllyTarget:HasModifier('modifier_necrolyte_reapers_scythe')
				and not hAllyTarget:HasModifier('modifier_dazzle_shallow_grave')
				then
					local nLocationAoE = bot:FindAoELocation(true, true, hAllyTarget:GetLocation(), 0, nRadius, 0, 0)
					if nLocationAoE.count >= 2 then
						return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc, 'point', nil
					else
						return BOT_ACTION_DESIRE_HIGH, hAllyTarget:GetLocation(), 'point', nil
					end
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
