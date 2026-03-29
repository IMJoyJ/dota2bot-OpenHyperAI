--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArrayIsArray(value)
    return type(value) == "table" and (value[1] ~= nil or next(value) == nil)
end

local function __TS__ArrayConcat(self, ...)
    local items = {...}
    local result = {}
    local len = 0
    for i = 1, #self do
        len = len + 1
        result[len] = self[i]
    end
    for i = 1, #items do
        local item = items[i]
        if __TS__ArrayIsArray(item) then
            for j = 1, #item do
                len = len + 1
                result[len] = item[j]
            end
        else
            len = len + 1
            result[len] = item
        end
    end
    return result
end
-- End of Lua Library inline imports
local ____exports = {}
local IsHumanPlayerInTeamCache
local ____dota = require("bots.ts_libs.dota.index")
local Team = ____dota.Team
local UnitType = ____dota.UnitType
local ____constants = require("bots.FunLib.utils.constants")
local EstimatedEnemyRoles = ____constants.EstimatedEnemyRoles
local ImportantItems = ____constants.ImportantItems
local LoneDruid = ____constants.LoneDruid
local ____validation = require("bots.FunLib.utils.validation")
local IsValidHero = ____validation.IsValidHero
local ____misc = require("bots.FunLib.utils.misc")
local GetLocationToLocationDistance = ____misc.GetLocationToLocationDistance
local HasCriticalSpellWithCooldown = ____misc.HasCriticalSpellWithCooldown
local GetItem = ____misc.GetItem
function ____exports.IsHumanPlayerInTeam(team)
    if IsHumanPlayerInTeamCache[team] ~= nil then
        return IsHumanPlayerInTeamCache[team]
    end
    for ____, playerdId in ipairs(GetTeamPlayers(team)) do
        if not IsPlayerBot(playerdId) then
            IsHumanPlayerInTeamCache[team] = true
            return true
        end
    end
    IsHumanPlayerInTeamCache[team] = false
    return false
end
--- Get the enemy ids in teleport to a location.
-- 
-- @param vLoc - The location to check.
-- @param nDistance - The distance to check.
-- @returns An array of enemy ids.
function ____exports.GetEnemyIdsInTpToLocation(vLoc, nDistance)
    local enemies = {}
    for ____, tp in ipairs(GetIncomingTeleports()) do
        if tp ~= nil and GetLocationToLocationDistance(vLoc, tp.location) <= nDistance and not IsTeamPlayer(tp.playerid) then
            enemies[#enemies + 1] = tp.playerid
        end
    end
    return enemies
end
function ____exports.GetHumanPing()
    for ____, playerId in ipairs(GetTeamPlayers(GetTeam())) do
        local teamMember = GetTeamMember(playerId)
        if teamMember ~= nil and not teamMember:IsBot() then
            return teamMember, teamMember:GetMostRecentPing()
        end
    end
    return nil, nil
end
function ____exports.IsPingedByAnyPlayer(bot, pingTimeGap, minDistance, maxDistance)
    if not bot:IsAlive() then
        return nil
    end
    local pings = {}
    minDistance = minDistance or 1500
    maxDistance = maxDistance or 10000
    for ____, playerId in ipairs(GetTeamPlayers(GetTeam())) do
        do
            local __continue8
            repeat
                local teamMember = GetTeamMember(playerId)
                if teamMember == nil or teamMember:IsIllusion() or teamMember == bot then
                    __continue8 = true
                    break
                end
                local ping = teamMember:GetMostRecentPing()
                if ping and ping.time and GameTime() - ping.time < pingTimeGap then
                    pings[#pings + 1] = ping
                end
                __continue8 = true
            until true
            if not __continue8 then
                break
            end
        end
    end
    for ____, ping in ipairs(pings) do
        local distanceToBot = GetLocationToLocationDistance(
            ping.location,
            bot:GetLocation()
        )
        local withinRange = minDistance <= distanceToBot and distanceToBot <= maxDistance
        local withinTimeRange = GameTime() - ping.time < pingTimeGap
        if withinRange and withinTimeRange then
            print(("Bot " .. bot:GetUnitName()) .. " noticed the ping")
            return ping
        end
    end
    return nil
end
--- Find an ally with the given name.
-- 
-- @param name - The name of the ally to find.
-- @returns The ally if found, null otherwise.
function ____exports.FindAllyWithName(name)
    for ____, ally in ipairs(GetUnitList(UnitType.AlliedHeroes)) do
        if IsValidHero(ally) and ({string.find(
            ally:GetUnitName(),
            name
        )}) then
            return ally
        end
    end
    return nil
end
local humanCountCache = {}
function ____exports.NumHumanBotPlayersInTeam(team)
    if not (humanCountCache[team] ~= nil) then
        local humans = 0
        local bots = 0
        for ____, playerdId in ipairs(GetTeamPlayers(team)) do
            if IsPlayerBot(playerdId) then
                bots = bots + 1
            else
                humans = humans + 1
            end
        end
        humanCountCache[team] = {humans, bots}
    end
    return humanCountCache[team][1], humanCountCache[team][2]
end
function ____exports.GetNearbyAllyAverageHpPercent(bot, radius)
    local sum = 0
    local cnt = 0
    for ____, playerId in ipairs(GetTeamPlayers(bot:GetTeam())) do
        local ally = GetTeamMember(playerId)
        if ally and ally:IsAlive() and GetUnitToUnitDistance(ally, bot) <= radius then
            sum = sum + ally:GetHealth() / ally:GetMaxHealth()
            cnt = cnt + 1
        end
    end
    return cnt ~= nil and sum / cnt or 0
end
function ____exports.DetermineEnemyBotRole(bot)
    local botName = bot:GetUnitName()
    local estimatedRole = EstimatedEnemyRoles[botName]
    if estimatedRole == nil then
        print(("Enemy bot " .. botName) .. " role not cached yet.")
        return 3
    end
    return estimatedRole.role
end
function ____exports.GetLoneDruid(bot)
    local res = LoneDruid[bot:GetPlayerID()]
    if res == nil then
        LoneDruid[bot:GetPlayerID()] = {}
        res = LoneDruid[bot:GetPlayerID()]
    end
    return res
end
IsHumanPlayerInTeamCache = {[Team.Radiant] = nil, [Team.Dire] = nil}
function ____exports.IsHumanPlayerInAnyTeam()
    return ____exports.IsHumanPlayerInTeam(Team.Radiant) or ____exports.IsHumanPlayerInTeam(Team.Dire)
end
--- Get the enemy hero by player id.
-- 
-- @param id - The player id to check.
-- @returns The enemy hero if found, null otherwise.
function ____exports.GetEnemyHeroByPlayerId(id)
    for ____, hero in ipairs(GetUnitList(UnitType.EnemyHeroes)) do
        if IsValidHero(hero) and hero:GetPlayerID() == id then
            return hero
        end
    end
    return nil
end
--- Get the number of alive heroes.
-- 
-- @param bEnemy - Whether to count enemy heroes.
-- @returns The number of alive heroes.
function ____exports.GetNumOfAliveHeroes(bEnemy)
    local count = 0
    local nTeam = GetTeam()
    if bEnemy then
        nTeam = GetOpposingTeam()
    end
    for ____, playerdId in ipairs(GetTeamPlayers(nTeam)) do
        if IsHeroAlive(playerdId) then
            count = count + 1
        end
    end
    return count
end
--- Count the missing enemy heroes.
-- 
-- @returns The number of missing enemy heroes.
function ____exports.CountMissingEnemyHeroes()
    local count = 0
    for ____, playerdId in ipairs(GetTeamPlayers(GetOpposingTeam())) do
        do
            local __continue49
            repeat
                if IsHeroAlive(playerdId) then
                    local lastSeenInfo = GetHeroLastSeenInfo(playerdId)
                    if lastSeenInfo ~= nil and lastSeenInfo[1] ~= nil then
                        local firstInfo = lastSeenInfo[1]
                        if firstInfo.time_since_seen >= 2.5 then
                            count = count + 1
                            __continue49 = true
                            break
                        end
                    end
                end
                __continue49 = true
            until true
            if not __continue49 then
                break
            end
        end
    end
    return count
end
--- Find an ally with at least a certain distance away from a bot.
-- 
-- @param bot - The bot to check.
-- @param nDistance - The minimum distance to check.
-- @returns The ally if found, null otherwise.
function ____exports.FindAllyWithAtLeastDistanceAway(bot, nDistance)
    if bot:GetTeam() ~= GetTeam() then
        print("[ERROR] Wrong usage of the method")
        return nil
    end
    for ____, playerId in ipairs(GetTeamPlayers(GetTeam())) do
        local teamMember = GetTeamMember(playerId)
        if teamMember ~= nil and teamMember:IsAlive() and GetUnitToUnitDistance(teamMember, bot) >= nDistance then
            return teamMember
        end
    end
    return nil
end
--- Get the last seen enemy ids near a location.
-- 
-- @param vLoc - The location to check.
-- @param nDistance - The distance to check.
-- @returns An array of enemy ids.
function ____exports.GetLastSeenEnemyIdsNearLocation(vLoc, nDistance)
    local enemies = {}
    for ____, playerdId in ipairs(GetTeamPlayers(GetOpposingTeam())) do
        if IsHeroAlive(playerdId) then
            local lastSeenInfo = GetHeroLastSeenInfo(playerdId)
            if lastSeenInfo ~= nil and lastSeenInfo[1] ~= nil then
                local firstInfo = lastSeenInfo[1]
                if GetLocationToLocationDistance(firstInfo.location, vLoc) <= nDistance and firstInfo.time_since_seen <= 3 then
                    enemies[#enemies + 1] = playerdId
                end
            end
        end
    end
    enemies = __TS__ArrayConcat(
        enemies,
        ____exports.GetEnemyIdsInTpToLocation(vLoc, nDistance)
    )
    return enemies
end
--- Get the ally ids in teleport to a location.
-- 
-- @param vLoc - The location to check.
-- @param nDistance - The distance to check.
-- @returns An array of ally ids.
function ____exports.GetAllyIdsInTpToLocation(vLoc, nDistance)
    local allies = {}
    for ____, tp in ipairs(GetIncomingTeleports()) do
        if tp ~= nil and GetLocationToLocationDistance(vLoc, tp.location) <= nDistance and IsTeamPlayer(tp.playerid) then
            allies[#allies + 1] = tp.playerid
        end
    end
    return allies
end
--- Check if the team has a member with a critical spell in cooldown when the bot walks & arrives to the location.
-- 
-- @param bot - The bot to check.
-- @param targetLoc - The location to check.
-- @returns True if the team has a member with a critical spell in cooldown, false otherwise.
function ____exports.HasTeamMemberWithCriticalSpellInCooldown(targetLoc)
    for ____, playerId in ipairs(GetTeamPlayers(GetTeam())) do
        local teamMember = GetTeamMember(playerId)
        if teamMember ~= nil and teamMember:IsAlive() then
            local nDuration = GetUnitToLocationDistance(teamMember, targetLoc) / teamMember:GetCurrentMovementSpeed()
            if HasCriticalSpellWithCooldown(teamMember, nDuration) then
                return true
            end
        end
    end
    return false
end
--- Check if the team has a member with a critical item in cooldown when the bot walks & arrives to the location.
-- 
-- @param bot - The bot to check.
-- @param targetLoc - The location to check.
-- @returns True if the team has a member with a critical item in cooldown, false otherwise.
function ____exports.HasTeamMemberWithCriticalItemInCooldown(targetLoc)
    for ____, playerId in ipairs(GetTeamPlayers(GetTeam())) do
        local teamMember = GetTeamMember(playerId)
        if teamMember ~= nil and teamMember:IsAlive() then
            local nDuration = GetUnitToLocationDistance(teamMember, targetLoc) / teamMember:GetCurrentMovementSpeed()
            for ____, itemName in ipairs(ImportantItems) do
                local item = GetItem(teamMember, itemName)
                if item and item:GetCooldownTimeRemaining() > nDuration then
                    return true
                end
            end
        end
    end
    return false
end
return ____exports
