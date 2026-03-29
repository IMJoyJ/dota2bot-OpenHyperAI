--大勋章
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)

	local nCastRange = 1000
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1000)

	for _, npcAlly in pairs(hAllyList)
	do
		if J.IsValidHero( npcAlly )
		and J.IsInRange( bot, npcAlly, nCastRange )
		and not npcAlly:HasModifier( 'modifier_legion_commander_press_the_attack' )
		and not npcAlly:IsMagicImmune()
		and not npcAlly:IsInvulnerable()
		and npcAlly:CanBeSeen()
		then
			if not npcAlly:IsBot()
			and npcAlly:GetAttackTarget() ~= nil
			and npcAlly:GetMaxHealth() - npcAlly:GetHealth() >= 120
			then
				hEffectTarget = npcAlly
				sCastMotive = 'Solar Crest'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsGoingOnSomeone(npcAlly)
			then
				local allyTarget = J.GetProperTarget(npcAlly)

				if J.IsValidHero(allyTarget)
				and npcAlly:IsFacingLocation( allyTarget:GetLocation(), 20)
				and J.IsInRange(npcAlly, allyTarget, npcAlly:GetAttackRange() + 100)
				then
					hEffectTarget = npcAlly
					sCastMotive = 'Solar Crest'
					return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
