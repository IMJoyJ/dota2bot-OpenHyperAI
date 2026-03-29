local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local nRadius = hItem:GetSpecialValueInt('block_radius')
	local unitList = GetUnitList(UNIT_LIST_ALLIES)

	local countControlledCreep = 0
	local countControlledHero = 0

	for _, unit in pairs(unitList) do
		if J.IsValid(unit) and J.IsInRange(bot, unit, nRadius) then
			local sUnitName = unit:GetUnitName()

			if unit:IsHero() and (unit:IsIllusion() or string.find(sUnitName, 'bear')) then
				countControlledHero = countControlledHero + 1
			end

			if string.find(sUnitName, 'golem') then
				return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
			end

			if string.find(sUnitName, 'spiderlings')
			or string.find(sUnitName, 'forge_spirit')
			or string.find(sUnitName, 'golem')
			or string.find(sUnitName, 'boar')
			or string.find(sUnitName, 'furion_treant')
			or string.find(sUnitName, 'familiars')
			or unit:IsDominated()
			or unit:HasModifier('modifier_chen_holy_persuasion')
			then
				countControlledCreep = countControlledCreep + 1
			end
		end
	end

	if J.IsGoingOnSomeone(bot) then
		if bot:WasRecentlyDamagedByAnyHero(2.0) and (countControlledCreep >= 2 or countControlledHero >= 2) then
			return BOT_ACTION_DESIRE_HIGH, bot, 'none', nil
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
