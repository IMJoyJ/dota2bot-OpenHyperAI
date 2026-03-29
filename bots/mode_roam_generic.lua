local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Customize = require( GetScriptDirectory()..'/Customize/general' )

local bot = GetBot()
local botName = bot:GetUnitName()

if bot == nil or bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return end

-- Shared mutable state (accessible by sub-modules via S.xxx)
local S = {
	cAbility = nil,
	TinkerShouldWaitInBaseToHeal = false,
	ShouldWaitInBaseToHeal = false,
	TPScroll = nil,
	ShouldMoveCloseTowerForEdict = false,
	EdictTowerTarget = nil,
	ShouldMoveOutsideFountain = false,
	ShouldMoveOutsideFountainCheckTime = 0,
	laneToGank = nil,
	lastGankDecisionTime = 0,
	targetGate = nil,
	arriveGankLocTime = 0,
	lastStaticLinkDebuffStack = 0,
	AnyUnitAffectedByChainFrost = false,
	HasPossibleWallOfReplicaAround = false,
	ShouldBotsSpreadOut = false,
	nChainFrostBounceDistance = 600 + 150,
	cachedTombstoneZombieSlowState = 0,
	nInRangeEnemy = {}, nInRangeAlly = {}, nInCloseRangeEnemy = {}, nInCloseRangeAlly = {},
	allyTowers = {}, enemyTowers = {},
	trySeduce = false, shouldTempRetreat = false,
	botTarget = nil,
	shouldGoBackToFountain = false,
	tangoDesire = 0, tangoTarget = nil, tangoSlot = nil,
	ConsiderHeroSpecificRoaming = {},
}

local lastThinkTime = 0
local THINK_INTERVAL = 1/30 -- Limit to 30 FPS max
local lastAction = nil -- {type, target, time}

-- Helper function to record actions
local function recordAction(actionType, target)
    lastAction = {type = actionType, target = target, time = DotaTime()}
end

-- Load sub-modules
local RoamHeroDesire = require(GetScriptDirectory()..'/roam/roam_hero_desire')
local RoamHeroThink = require(GetScriptDirectory()..'/roam/roam_hero_think')
local RoamGeneral = require(GetScriptDirectory()..'/roam/roam_general')
RoamHeroDesire(bot, J, S)
RoamHeroThink(bot, J, S, recordAction)
RoamGeneral(bot, J, S, recordAction)

function GetDesire()
	-- local cacheKey = 'GetRoamDesire'..tostring(bot:GetPlayerID())
	-- local cachedVar = J.Utils.GetCachedVars(cacheKey, 0.5 * (1 + Customize.ThinkLess))
	-- if DotaTime() > 30 and cachedVar ~= nil then return cachedVar end
	local res = GetDesireHelper()
	-- J.Utils.SetCachedVars(cacheKey, res)
	return res
end
function GetDesireHelper()
	botName = bot:GetUnitName()
	if bot:IsInvulnerable() or not bot:IsHero() or not bot:IsAlive() or not string.find(botName, "hero") or bot:IsIllusion() then return BOT_MODE_DESIRE_NONE end

	S.trySeduce = false
	S.shouldTempRetreat = false
	S.TPScroll = J.Utils.GetItemFromFullInventory(bot, 'item_tpscroll')
	S.botTarget = J.GetProperTarget(bot)
	S.nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	S.nInRangeAlly = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	S.nInCloseRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	S.nInCloseRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
	S.allyTowers = bot:GetNearbyTowers(1600, false)
	S.enemyTowers = bot:GetNearbyTowers(1600, true)

	-- if ConsiderWaitInBaseToHeal()
	-- and GetUnitToLocationDistance(bot, J.GetTeamFountain()) > 5500
	-- then
	-- 	return BOT_ACTION_DESIRE_ABSOLUTE
	-- end

	S.tangoDesire, S.tangoTarget = ConsiderUseTango()
	if S.tangoDesire > 0 then
		return BOT_MODE_DESIRE_ABSOLUTE
	end

	S.TinkerShouldWaitInBaseToHeal = TinkerWaitInBaseAndHeal()
	if S.TinkerShouldWaitInBaseToHeal
	then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end

	if bot:HasModifier('modifier_fountain_aura_buff') and DotaTime() > 0 and DotaTime() - S.ShouldMoveOutsideFountainCheckTime < 2 then
		return Clamp(bot:GetActiveModeDesire() + 0.2, 0, 1.1)
	else
		S.ShouldMoveOutsideFountain = false
	end

	if ConsiderHeroMoveOutsideFountain() then
		S.ShouldMoveOutsideFountain = true
		S.ShouldMoveOutsideFountainCheckTime = DotaTime()
		return Clamp(bot:GetActiveModeDesire() + 0.2, 0, 1.1)
	end

	-- unit special abilities
	local specialRoaming = S.ConsiderHeroSpecificRoaming[botName]
	if specialRoaming then
		-- return specialRoaming
		local specialDesire = specialRoaming()
		if specialDesire and specialDesire > 0 then
			if specialDesire <= 1 then
				return Clamp(specialDesire, 0, 0.99)
			else
				return specialDesire
			end
		end
	end

	-- general items or conditions.
	local generalRoaming = ConsiderGeneralRoamingInConditions()
	if generalRoaming then
		if generalRoaming > 0 and generalRoaming <= 1 then
			return Clamp(generalRoaming, 0, 0.99)
		else
			return generalRoaming
		end
	end

	-- if J.IsValidHero(botTarget)
	-- and (J.GetModifierTime(botTarget, 'modifier_dazzle_shallow_grave') > 0.5
	-- 	or J.GetModifierTime(botTarget, 'modifier_oracle_false_promise_timer') > 0.5
	-- 	or botTarget:HasModifier('modifier_skeleton_king_reincarnation_scepter_active')
	-- 	or botTarget:HasModifier('modifier_item_helm_of_the_undying_active'))
	-- and J.GetHP(botTarget) < 0.2 and botName ~= "npc_dota_hero_axe"
	-- then
	-- 	local nAttackTarget = J.GetAttackableWeakestUnit( bot, bot:GetAttackRange() + 400, true, true )
	-- 	bot:SetTarget( nAttackTarget )
	-- end

	return BOT_MODE_DESIRE_NONE
end

-- Frame rate limiting for performance
local lastThinkTime = 0
local THINK_INTERVAL = 1/30 -- Limit to 30 FPS max
local lastAction = nil -- {type, target, time}

-- Helper function to record actions
local function recordAction(actionType, target)
    lastAction = {type = actionType, target = target, time = DotaTime()}
end

function Think()
    -- Frame rate limiting
    local now = DotaTime()
    if now - lastThinkTime < THINK_INTERVAL then 
        -- Continue last action to prevent idle bots
        if lastAction and now - lastAction.time < 2.0 then
            if lastAction.type == "attack" and lastAction.target then
                bot:Action_AttackUnit(lastAction.target, true)
            elseif lastAction.type == "move" and lastAction.target then
                bot:Action_MoveToLocation(lastAction.target)
            elseif lastAction.type == "attackMove" and lastAction.target then
                bot:Action_AttackMove(lastAction.target)
            end
        end
        return 
    end
    lastThinkTime = now
    
    if J.CanNotUseAction(bot) then return end
	if J.Utils.IsBotThinkingMeaningfulAction(bot, Customize.ThinkLess, "roam") then return end

	S.nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

	ThinkIndividualRoaming() -- unit special abilities
	ThinkGeneralRoaming() -- general items or conditions.
	ThinkActualGankingInLanes()
end

function OnStart()
end

function OnEnd()
	S.laneToGank = nil
	S.targetGate = nil
	if S.shouldGoBackToFountain and IsInHealthyState() then
		S.shouldGoBackToFountain = false
	end
end

function IsInHealthyState()
	return botName ~= 'npc_dota_hero_huskar' and J.GetHP(bot) > 0.7 and J.GetMP(bot) > 0.6
end

function ConsiderHeroMoveOutsideFountain()
	if DotaTime() < 0 then return false end
	if bot:DistanceFromFountain() > MoveOutsideFountainDistance then return false end

	if ((bot:HasModifier('modifier_fountain_aura_buff') -- in fountain with high hp
		and J.GetHP(bot) > 0.95)
	and (botName == 'npc_dota_hero_huskar' -- is huskar (ignore mana)
		or (bot:GetActiveMode() == BOT_MODE_ITEM -- is stuck in item mode
			and J.GetMP(bot) > 0.95)))
	then
		return true
	end
	if bot:GetActiveMode() == BOT_MODE_ITEM then
		for _, droppedItem in pairs(GetDroppedItemList()) do
            if droppedItem ~= nil
            and GetUnitToLocationDistance(bot, droppedItem.location) < 1200
            then
				local iName = droppedItem.item:GetName()
				if not (iName == 'item_aegis'
				or iName == 'item_rapier'
				or iName == 'item_cheese'
				or iName == 'item_gem')
				then
					return true
				end
            end
        end
	end

	return false
end

