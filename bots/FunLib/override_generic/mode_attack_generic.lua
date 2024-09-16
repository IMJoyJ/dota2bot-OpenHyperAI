local J = require( GetScriptDirectory()..'/FunLib/jmz_func')

BotsInit = require( "game/botsinit" )
local X = BotsInit.CreateGeneric()

local bot = GetBot()
local botName = bot:GetUnitName()
local botTarget, nEnemyHeroes, nAllyHeroes, nEnemyTowers, nEnemyCreeps, nAllyCreeps, nAttackRange
local MaxTrackingDistance = 3000
local attackDeltaDistance = 600

function X.OnStart() end
function X.OnEnd() end

function X.GetDesire()
    if not bot:IsAlive() or J.CanNotUseAction(bot) or bot:IsUsingAbility() or bot:IsChanneling() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end

	botTarget = bot:GetTarget()
	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		if not J.IsValid(botTarget)
		or not J.CanBeAttacked(botTarget)
		or not J.IsInRange(bot, botTarget, MaxTrackingDistance) then
			bot:SetTarget(nil)
			return BOT_ACTION_DESIRE_NONE
		end
	end

	if J.IsValid(botTarget) and botTarget:IsCreep() and bot:GetActiveMode() == BOT_MODE_ATTACK then
		return bot:GetActiveModeDesire()
	end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)
	nEnemyTowers = bot:GetNearbyTowers(1000, true )
	nEnemyCreeps = bot:GetNearbyCreeps(800, true)
	nAttackRange = bot:GetAttackRange()

	if J.GetModifierTime(bot, "modifier_muerta_pierce_the_veil") > 0.5
	then
		return BOT_MODE_DESIRE_VERYHIGH
	end

	-- going on killing a target
	if J.IsGoingOnSomeone(bot)
	then
		botTarget = J.GetProperTarget(bot)
		if J.IsValidHero(botTarget)
		and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
			return GetDesireBasedOnHp(botTarget)
		end
	end

	if J.WeAreStronger(bot, 1200) and (#nEnemyCreeps > 0 or #nEnemyHeroes > 0) then
		bot:SetTarget(nEnemyHeroes[1])
		return GetDesireBasedOnHp(nEnemyHeroes[1])
	end

	-- has an enemy hero nearby in attack range + some delta distance
	if #nEnemyHeroes >= 1
	and J.IsValidHero(nEnemyHeroes[1])
	and J.IsInRange(nEnemyHeroes[1], bot, nAttackRange + attackDeltaDistance)
	and J.CanBeAttacked(nEnemyHeroes[1]) then
		bot:SetTarget(nEnemyHeroes[1])
		return GetDesireBasedOnHp(nEnemyHeroes[1])
	end

	-- check if any near allies are in or about to be in a fight.
	for _, allyHero in pairs(GetUnitList(UNIT_LIST_ALLIED_HEROES))
	do
		if J.IsValidHero(allyHero)
		and J.IsInRange(allyHero, bot, MaxTrackingDistance)
		-- and not J.IsInRange(allyHero, bot, 800)
		and not allyHero:IsIllusion()
		then
			local nEnemyHeroesNearAlly = J.GetNearbyHeroes(allyHero, 800, true)
			if #nEnemyHeroesNearAlly > 0
			and J.IsValidHero(nEnemyHeroesNearAlly[1])
			and not J.IsSuspiciousIllusion(nEnemyHeroesNearAlly[1]) then
				bot:SetTarget(nEnemyHeroesNearAlly[1])
				return GetDesireBasedOnHp(nEnemyHeroesNearAlly[1])
			end
		end
	end

	-- time to direct attack any creeps
	if #nEnemyCreeps > 0 then
		if J.IsInLaningPhase() then
			if not J.IsCore(bot) and #nAllyHeroes > 1 then
				return BOT_ACTION_DESIRE_NONE
			end
		end
		return GetDesireBasedOnHp(nil)
	end

	return BOT_ACTION_DESIRE_NONE
end

function GetDesireBasedOnHp(target)
	-- check if can/already hit by creeps
	if target ~= nil
	and J.IsInLaningPhase()
	and bot:WasRecentlyDamagedByCreep(2)
	and #nEnemyCreeps >= 3
	and J.GetHP(bot) < J.GetHP(target) then
		return BOT_ACTION_DESIRE_NONE
	end

	-- check if can be hit by tower
	if #nEnemyTowers >= 1 then
		if bot:GetLevel() < 5 then
			return BOT_ACTION_DESIRE_NONE
		end
	end
	return RemapValClamped(J.GetHP(bot), 0, 1, BOT_ACTION_DESIRE_NONE, BOT_ACTION_DESIRE_ABSOLUTE )
end

function X.Think()
	-- try last hitting creeps
	if J.IsInLaningPhase() and LastHitCreeps() > 0 then
		return
	end

	-- has a target already
	botTarget = J.GetProperTarget(bot)
	if J.IsValidHero(botTarget) and J.IsInRange(botTarget, bot, MaxTrackingDistance) then
		local distance = GetUnitToUnitDistance(bot, botTarget)
		if distance <= nAttackRange + attackDeltaDistance then
			bot:Action_AttackUnit(botTarget, true)
			return
		else
			bot:Action_MoveToUnit(botTarget)
			return
		end
	end

    nEnemyHeroes = J.GetNearbyHeroes(bot, 1600, true)
    nAllyHeroes = J.GetNearbyHeroes(bot, 1600, false)

	botTarget = ChooseAndAttackEnemyHero(nEnemyHeroes)

	-- if again no direct target, try hitting any unit
	if bot:GetTarget() == nil then
		-- don't hit high hp creeps during laning time in the lane.
		if J.IsInLaningPhase() then
			local vLaneFront = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
			if GetUnitToLocationDistance(bot, vLaneFront) < 700 then
				return
			end
		end

		local units = GetUnitList(UNIT_LIST_ENEMIES)
		for _, unit in pairs(units) do
			if J.Utils.IsValidUnit(unit)
			and GetUnitToUnitDistance(bot, unit) <= nAttackRange + attackDeltaDistance then
				bot:Action_AttackUnit(unit, true)
				return
			end
		end
	end
end

function ChooseAndAttackEnemyHero(hEnemyList)
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange + attackDeltaDistance, true, true )
	if nInAttackRangeWeakestEnemyHero ~= nil then
		bot:SetTarget(nInAttackRangeWeakestEnemyHero)
		bot:Action_AttackUnit(nInAttackRangeWeakestEnemyHero, true)
		return nInAttackRangeWeakestEnemyHero
	end

    for _, enemyHero in pairs(hEnemyList)
    do
        if J.IsValidHero(enemyHero)
		and J.CanBeAttacked(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
        then
			if J.IsInRange(bot, enemyHero, nAttackRange + attackDeltaDistance)
			then
				bot:SetTarget(enemyHero)
				bot:Action_AttackUnit(enemyHero, true)
				return enemyHero
			end
        end
    end
	return nil
end

function LastHitCreeps()
	nAllyCreeps = bot:GetNearbyCreeps(nAttackRange + attackDeltaDistance, false)
	nEnemyCreeps = bot:GetNearbyCreeps(nAttackRange + attackDeltaDistance, true)

	local hitCreep = GetBestLastHitCreep(nEnemyCreeps)
	if J.IsValid(hitCreep)
	then
		local nLanePartner = J.GetLanePartner(bot)
		if nLanePartner == nil
		or J.IsCore(bot)
		or (not J.IsCore(bot)
			and J.IsCore(nLanePartner)
			and (not nLanePartner:IsAlive()
				or not J.IsInRange(bot, nLanePartner, 800)))
		then
			bot:SetTarget(hitCreep)
			bot:Action_AttackUnit(hitCreep, false)
			return 1
		end
	end

	local denyCreep = GetBestDenyCreep(nAllyCreeps)
	if J.IsValid(denyCreep)
	then
		bot:SetTarget(denyCreep)
		bot:Action_AttackUnit(denyCreep, false)
		return 1
	end
	return 0
end

function GetBestLastHitCreep(hCreepList)
	for _, creep in pairs(hCreepList)
	do
		if J.IsValid(creep) and J.CanBeAttacked(creep)
		then
			local nAttackDelayTime = J.GetAttackProDelayTime(bot, creep)
			if J.WillKillTarget(creep, bot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL, nAttackDelayTime)
			or not (J.IsLaning( bot ) or J.IsInLaningPhase())
			then
				return creep
			end
		end
	end

	return nil
end

function GetBestDenyCreep(hCreepList)
	for _, creep in pairs(hCreepList)
	do
		if J.IsValid(creep)
		and J.GetHP(creep) < 0.49
		and J.CanBeAttacked(creep)
		and creep:GetHealth() <= bot:GetAttackDamage()
		then
			return creep
		end
	end

	return nil
end

return X