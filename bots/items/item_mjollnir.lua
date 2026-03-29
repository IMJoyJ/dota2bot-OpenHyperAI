--大电锤
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList


	local nCastRange = 800 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local nNearbyAllyList = J.GetNearbyHeroes(bot, nCastRange + 100, false, BOT_MODE_NONE);

	--团战中对被攻击频率最高的用
	if J.IsInTeamFight( bot, 900 )
	then
		local targetAlly = nil
		local maxTargetCount = 1
		for _, npcAlly in pairs(nNearbyAllyList)
		do
			if J.IsValid( npcAlly )
				and not npcAlly:IsIllusion()
				and not npcAlly:HasModifier( "modifier_item_mjollnir_static" )
			then
				local nAllyCount = 0 ;
				local nEnemyHeroes = J.GetNearbyHeroes(npcAlly, 1400, true, BOT_MODE_NONE);
				local nEnemyCreeps = npcAlly:GetNearbyCreeps(1000, true);
				for _, unit in pairs(nEnemyHeroes)
				do
					if unit ~= nil and unit:IsAlive()
						and unit:GetAttackTarget() == npcAlly
					then
						nAllyCount = nAllyCount + 1
					end
				end
				for _, unit in pairs(nEnemyCreeps)
				do
					if unit ~= nil and unit:IsAlive()
						and unit:GetAttackTarget() == npcAlly
					then
						nAllyCount = nAllyCount + 1
					end
				end
				if nAllyCount > maxTargetCount
				then
					maxTargetCount = nAllyCount
					targetAlly = npcAlly
				end
			end
		end

		if targetAlly ~= nil
		then
			hEffectTarget = targetAlly
			sCastMotive = '团战中套电锤给队友:'..J.Chat.GetNormName(hEffectTarget)
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.IsValidHero(botTarget)
	then
		local nAllies = J.GetAlliesNearLoc(botTarget:GetLocation(),1400)
		if J.IsValid(nAllies[1])
		then
			local targetAlly = nil
			local targetDis = 9999
			for _, npcAlly in pairs(nAllies)
			do
				if J.IsValid( npcAlly )
					and GetUnitToUnitDistance( bot, npcAlly ) < nCastRange + 200
					and GetUnitToUnitDistance( botTarget, npcAlly ) < targetDis
					and not npcAlly:HasModifier( "modifier_item_mjollnir_static" )
				then
					targetAlly = npcAlly
					targetDis = GetUnitToUnitDistance( botTarget, npcAlly )
				end
			end
			if targetAlly ~= nil
			then
				hEffectTarget = targetAlly
				sCastMotive = '攻击前套电锤给队友:'..J.Chat.GetNormName(hEffectTarget)
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if hNearbyEnemyHeroList[1] == nil
	then
		local nAllyCreeps = bot:GetNearbyLaneCreeps(1000,false);
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(1000,true);
		if #nAllyCreeps >= 1 and #nEnemyCreeps == 0
		then
			local targetCreep = nil
			local targetDis = 0
			for _, creep in pairs(nAllyCreeps)
			do
				if J.IsValid(creep)
					and J.GetHP(creep) > 0.6
					and creep:DistanceFromFountain() > targetDis
				then
					targetCreep = creep;
					targetDis = creep:DistanceFromFountain();
				end
			end
			if targetCreep ~= nil
			then
				hEffectTarget = targetCreep
				sCastMotive = '给前排小兵套上'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end


	if J.IsValidHero(hNearbyEnemyHeroList[1])
	   and hNearbyEnemyHeroList[1]:GetAttackTarget() == bot
	then
		if not bot:HasModifier("modifier_item_mjollnir_static")
		then
			hEffectTarget = bot
			sCastMotive = '给自己套上'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
