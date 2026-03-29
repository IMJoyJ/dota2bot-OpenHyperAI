--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__NumberToFixed(self, fractionDigits)
    if math.abs(self) >= 1e+21 or self ~= self then
        return tostring(self)
    end
    local f = math.floor(fractionDigits or 0)
    if f < 0 or f > 99 then
        error("toFixed() digits argument must be between 0 and 99", 0)
    end
    return string.format(
        ("%." .. tostring(f)) .. "f",
        self
    )
end

local function __TS__ArraySome(self, callbackfn, thisArg)
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            return true
        end
    end
    return false
end

local function __TS__StringTrim(self)
    local result = string.gsub(self, "^[%s ﻿]*(.-)[%s ﻿]*$", "%1")
    return result
end

local function __TS__ArrayIncludes(self, searchElement, fromIndex)
    if fromIndex == nil then
        fromIndex = 0
    end
    local len = #self
    local k = fromIndex
    if fromIndex < 0 then
        k = len + fromIndex
    end
    if k < 0 then
        k = 0
    end
    for i = k + 1, len do
        if self[i] == searchElement then
            return true
        end
    end
    return false
end
-- End of Lua Library inline imports
local ____exports = {}
local ____dota = require("bots.ts_libs.dota.index")
local BotActionType = ____dota.BotActionType
local Team = ____dota.Team
local UnitType = ____dota.UnitType
local ____constants = require("bots.FunLib.utils.constants")
local FrameProcessTime = ____constants.FrameProcessTime
local ImportantSpells = ____constants.ImportantSpells
local RadiantFountainTpPoint = ____constants.RadiantFountainTpPoint
local DireFountainTpPoint = ____constants.DireFountainTpPoint
local meaningfulActivities = ____constants.meaningfulActivities
local ____cache = require("bots.FunLib.utils.cache")
local GetCachedVars = ____cache.GetCachedVars
local SetCachedVars = ____cache.SetCachedVars
local ____validation = require("bots.FunLib.utils.validation")
local IsValidAbility = ____validation.IsValidAbility
local ____collection = require("bots.FunLib.utils.collection")
local NewTable = ____collection.NewTable
--- Get an item from the bot's inventory with a specific total slots count.
-- 
-- @param bot - The bot to check.
-- @param itemName - The name of the item to get.
-- @param count - The number of slots in inventory to check.
-- @returns The item if found, null otherwise.
function ____exports.GetItemFromCountedInventory(bot, itemName, count)
    do
        local i = 0
        while i < count do
            local item = bot:GetItemInSlot(i)
            if item and item:GetName() == itemName then
                return item
            end
            i = i + 1
        end
    end
    return nil
end
function ____exports.GetEnemyFountainTpPoint()
    if GetTeam() == Team.Dire then
        return RadiantFountainTpPoint
    end
    return DireFountainTpPoint
end
function ____exports.GetTeamFountainTpPoint()
    if GetTeam() == Team.Dire then
        return DireFountainTpPoint
    end
    return RadiantFountainTpPoint
end
--- Get the direction of the team side.
-- 
-- @param team - The team to get the direction for.
-- @returns The direction of the team side.
function ____exports.GetTeamSideDirection(team)
    if team == Team.Radiant then
        return Vector(-1, -1, 0):Normalized()
    else
        return Vector(1, 1, 0):Normalized()
    end
end
function ____exports.SetFrameProcessTime(bot)
    if bot.frameProcessTime == nil then
        bot.frameProcessTime = FrameProcessTime + __TS__NumberToFixed(
            math.fmod(
                bot:GetPlayerID() / 1000,
                FrameProcessTime / 10
            ) * 3,
            2
        )
    end
end
function ____exports.GetDistanceFromAncient(bot, enemy)
    local ancient = GetAncient(enemy and GetOpposingTeam() or GetTeam())
    return GetUnitToUnitDistance(bot, ancient)
end
--- Check if the bot has the item in its inventory.
-- 
-- @param bot - The bot to check.
-- @param itemName - The name of the item to check.
-- @returns True if the bot has the item, false otherwise.
function ____exports.HasItem(bot, itemName)
    local slot = bot:FindItemSlot(itemName)
    return slot >= 0 and slot <= 8
end
--- Get the distance between two locations.
-- 
-- @param fLoc - The first location.
-- @param sLoc - The second location.
-- @returns The distance between the two locations.
function ____exports.GetLocationToLocationDistance(fLoc, sLoc)
    local x1 = fLoc.x
    local x2 = sLoc.x
    local y1 = fLoc.y
    local y2 = sLoc.y
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1))
end
function ____exports.NumActionTypeInQueue(bot, searchedActionType)
    local count = 0
    for index = 1, bot:NumQueuedActions() do
        local actionType = bot:GetQueuedActionType(index)
        if actionType == searchedActionType then
            count = count + 1
        end
    end
    return count
end
function ____exports.CountBackpackEmptySpace(bot)
    local count = 3
    for ____, slot in ipairs({6, 7, 8}) do
        if bot:GetItemInSlot(slot) ~= nil then
            count = count - 1
        end
    end
    return count
end
function ____exports.FloatEqual(a, b)
    return math.abs(a - b) < 0.000001
end
function ____exports.AbilityBehaviorHasFlag(behavior, flag)
    return bit.band(behavior, flag) == flag
end
local everySecondsCallRegistry = {}
local function EveryManySeconds(second, oldFunction)
    local functionName = tostring(oldFunction)
    everySecondsCallRegistry[functionName] = {
        lastCallTime = DotaTime() + RandomInt(0, second * 1000) / 1000,
        interval = second,
        startup = true
    }
    return function(...)
        local callTable = everySecondsCallRegistry[functionName]
        if callTable.startup then
            callTable.startup = nil
            return oldFunction(...)
        elseif callTable.lastCallTime <= DotaTime() - callTable.interval then
            callTable.lastCallTime = DotaTime()
            return oldFunction(...)
        end
        return NewTable()
    end
end
function ____exports.RecentlyTookDamage(bot, delta)
    return bot:WasRecentlyDamagedByAnyHero(delta) or bot:WasRecentlyDamagedByTower(delta) or bot:WasRecentlyDamagedByCreep(delta)
end
function ____exports.IsUnitWithName(unit, name)
    local result = {string.find(
        unit:GetUnitName(),
        name
    )}
    return result ~= nil
end
function ____exports.IsBear(unit)
    return ____exports.IsUnitWithName(unit, "lone_druid_bear")
end
function ____exports.TimeNeedToHealHP(bot)
    local r = bot:GetHealthRegen()
    return r > 0 and (bot:GetMaxHealth() - bot:GetHealth()) / r or math.huge
end
function ____exports.TimeNeedToHealMP(bot)
    local r = bot:GetManaRegen()
    return r > 0 and (bot:GetMaxMana() - bot:GetMana()) / r or math.huge
end
function ____exports.HasAnyEffect(unit, ...)
    local effects = {...}
    return __TS__ArraySome(
        effects,
        function(____, effect) return unit:HasModifier(effect) end
    )
end
function ____exports.IsModeTurbo()
    for ____, u in ipairs(GetUnitList(UnitType.Allies)) do
        if u and u:GetUnitName() == "npc_dota_courier" and u:GetCurrentMovementSpeed() == 1100 then
            return true
        end
    end
    return false
end
function ____exports.TrimString(str)
    return __TS__StringTrim(str)
end
--- Check if the bot has a critical spell with a cooldown greater than nDuration.
-- 
-- @param bot - The bot to check.
-- @param nDuration - The duration to check against.
-- @returns True if the bot has a critical spell with a cooldown greater than nDuration, false otherwise.
function ____exports.HasCriticalSpellWithCooldown(bot, nDuration)
    local heroName = bot:GetUnitName()
    if ImportantSpells[heroName] ~= nil then
        local ability = bot:GetAbilityByName(ImportantSpells[heroName][1])
        if IsValidAbility(ability) and ability:GetCooldownTimeRemaining() > nDuration then
            return true
        end
    end
    return false
end
--- Get an item from the bot's active inventory.
-- 
-- @param bot - The bot to check.
-- @param itemName - The name of the item to get.
-- @returns The item if found, null otherwise.
function ____exports.GetItem(bot, itemName)
    return ____exports.GetItemFromCountedInventory(bot, itemName, 6)
end
--- Get an item from the bot's full inventory.
-- 
-- @param bot - The bot to check.
-- @param itemName - The name of the item to get.
-- @returns The item if found, null otherwise.
function ____exports.GetItemFromFullInventory(bot, itemName)
    return ____exports.GetItemFromCountedInventory(bot, itemName, 16)
end
--- Checks if the bot is currently thinking meaningful actions that would make
-- re-computing the Think() method unnecessary.
-- 
-- @param bot - The bot unit to check
-- @param thinkLess - The think less value, 0: fully think, 1 to 10: think less and less frequently.
-- @param type - The type of action to check, "all": check all actions, "farm": check farm actions, etc.
-- @returns True if the bot is doing something meaningful, false otherwise
function ____exports.IsBotThinkingMeaningfulAction(bot, thinkLess, ____type)
    if thinkLess == nil then
        thinkLess = 1
    end
    if ____type == nil then
        ____type = "all"
    end
    if thinkLess < 0 then
        thinkLess = 0
    elseif thinkLess > 10 then
        thinkLess = 10
    end
    local cacheKey = (("IsBotThinkingMeaningfulAction" .. tostring(bot:GetPlayerID())) .. "_") .. ____type
    local cachedRes = GetCachedVars(cacheKey, 0.11 * thinkLess)
    if cachedRes ~= nil then
        return cachedRes
    end
    do
        local ____try, ____hasReturned, ____returnValue = pcall(function()
            if __TS__ArrayIncludes(
                meaningfulActivities,
                bot:GetAnimActivity()
            ) then
                SetCachedVars(cacheKey, true)
                return true, true
            end
        end)
        if ____try and ____hasReturned then
            return ____returnValue
        end
    end
    local numQueuedActions = bot:NumQueuedActions()
    if numQueuedActions > 0 then
        for index = 1, numQueuedActions do
            local actionType = bot:GetQueuedActionType(index)
            if actionType ~= BotActionType.None then
                SetCachedVars(cacheKey, true)
                return true
            end
        end
    end
    SetCachedVars(cacheKey, false)
    return false
end
return ____exports
