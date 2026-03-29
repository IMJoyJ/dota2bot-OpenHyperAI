local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	if royalJellyTime == nil
	then
		royalJellyTime = DotaTime()
	else
		if royalJellyTime < DotaTime() - 2.0
		then
			local targetAlly = nil

			for i = 1, #GetTeamPlayers( GetTeam() )
			do
				local allyHero = GetTeamMember(i)

				if J.IsValidHero(allyHero)
				and J.IsCore(allyHero)
				and not allyHero:IsIllusion()
				and not allyHero:HasModifier('modifier_royal_jelly')
				then
					targetAlly = allyHero
				end
			end

			if targetAlly ~= nil
			then
				royalJellyTime = nil
				return BOT_ACTION_DESIRE_HIGH, targetAlly, 'unit', nil
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
