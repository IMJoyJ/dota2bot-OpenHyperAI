--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____dota = require("bots.ts_libs.dota.index")
local Barracks = ____dota.Barracks
local BotMode = ____dota.BotMode
local Lane = ____dota.Lane
local UnitType = ____dota.UnitType
local ____constants = require("bots.FunLib.utils.constants")
local AllTowers = ____constants.AllTowers
local BarrackList = ____constants.BarrackList
local BARRACKS = ____constants.BARRACKS
local HighGroundTowers = ____constants.HighGroundTowers
local LEVEL_3_TOWERS = ____constants.LEVEL_3_TOWERS
local NonTier1Towers = ____constants.NonTier1Towers
local SecondTierTowers = ____constants.SecondTierTowers
local ____cache = require("bots.FunLib.utils.cache")
local GetCachedVars = ____cache.GetCachedVars
local SetCachedVars = ____cache.SetCachedVars
local ____validation = require("bots.FunLib.utils.validation")
local IsValidBuilding = ____validation.IsValidBuilding
local IsValidHero = ____validation.IsValidHero
local ____team = require("bots.FunLib.utils.team")
local GetLastSeenEnemyIdsNearLocation = ____team.GetLastSeenEnemyIdsNearLocation
local GetNumOfAliveHeroes = ____team.GetNumOfAliveHeroes
function ____exports.IsAnyOfTheBuildingsAlive(buildings)
    for ____, building in ipairs(buildings) do
        if building ~= nil and (not building:CanBeSeen() or building:GetHealth() > 0) then
            return true
        end
    end
    return false
end
function ____exports.CountEnemyHeroesNear(loc, r)
    local n = 0
    for ____, u in ipairs(GetUnitList(UnitType.EnemyHeroes)) do
        if IsValidHero(u) and GetUnitToLocationDistance(u, loc) <= r then
            n = n + 1
        end
    end
    return n
end
function ____exports.CountEnemyHeroesOnHighGround(team)
    local cacheKey = "CountEnemyHeroesOnHighGround:" .. tostring(team or -1)
    local cachedVar = GetCachedVars(cacheKey, 1)
    if cachedVar ~= nil then
        return cachedVar
    end
    local anchors = {}
    for ____, t in ipairs(LEVEL_3_TOWERS) do
        local tw = GetTower(team, t)
        if IsValidBuilding(tw) then
            anchors[#anchors + 1] = tw
        end
    end
    for ____, b in ipairs(BARRACKS) do
        local bb = GetBarracks(team, b)
        if IsValidBuilding(bb) then
            anchors[#anchors + 1] = bb
        end
    end
    local maxSeen = 0
    for ____, a in ipairs(anchors) do
        local c = ____exports.CountEnemyHeroesNear(
            a:GetLocation(),
            1600
        )
        if c > maxSeen then
            maxSeen = c
        end
    end
    SetCachedVars(cacheKey, maxSeen)
    return maxSeen
end
function ____exports.IsBuildingAttackedByEnemy(building)
    for ____, hero in ipairs(GetUnitList(UnitType.EnemyHeroes)) do
        if IsValidHero(hero) and GetUnitToUnitDistance(building, hero) <= hero:GetAttackRange() + 200 and hero:GetAttackTarget() == building then
            return building
        end
    end
    return nil
end
function ____exports.IsAnyBarrackAttackByEnemyHero()
    for ____, barrackE in ipairs(BarrackList) do
        local barrack = GetBarracks(
            GetTeam(),
            barrackE
        )
        if barrack ~= nil and barrack:GetHealth() > 0 then
            local bar = ____exports.IsBuildingAttackedByEnemy(barrack)
            if bar ~= nil then
                return bar
            end
        end
    end
    return nil
end
function ____exports.IsAnyBarracksOnLaneAlive(bEnemy, lane)
    local barracks = {}
    local team = GetTeam()
    if bEnemy then
        team = GetOpposingTeam()
    end
    if lane == Lane.Top then
        barracks = {
            GetBarracks(team, Barracks.TopMelee),
            GetBarracks(team, Barracks.TopRanged)
        }
    elseif lane == Lane.Mid then
        barracks = {
            GetBarracks(team, Barracks.MidMelee),
            GetBarracks(team, Barracks.MidRanged)
        }
    elseif lane == Lane.Bot then
        barracks = {
            GetBarracks(team, Barracks.BotMelee),
            GetBarracks(team, Barracks.BotRanged)
        }
    end
    return ____exports.IsAnyOfTheBuildingsAlive(barracks)
end
--- Check if the unit is near an enemy second tier tower.
-- 
-- @param unit - The unit to check.
-- @param range - The range to check.
-- @returns True if the unit is near an enemy second tier tower, false otherwise.
function ____exports.IsNearEnemySecondTierTower(unit, range)
    for ____, towerId in ipairs(SecondTierTowers) do
        local tower = GetTower(
            GetOpposingTeam(),
            towerId
        )
        if tower ~= nil and IsValidBuilding(tower) and GetUnitToUnitDistance(unit, tower) < range then
            return true
        end
    end
    return false
end
--- Get the enemy ids near non-tier 1 towers.
-- 
-- @param range - The range to check.
-- @returns An object with tower ids as keys and their corresponding enemy ids.
function ____exports.GetEnemyIdsNearNonTier1Towers(range)
    local result = {}
    for ____, towerId in ipairs(NonTier1Towers) do
        local tower = GetTower(
            GetTeam(),
            towerId
        )
        if tower ~= nil and IsValidBuilding(tower) then
            local eIds = GetLastSeenEnemyIdsNearLocation(
                tower:GetLocation(),
                range
            )
            result[towerId] = {tower = tower, enemyIds = eIds}
        end
    end
    return result
end
--- Get the non-tier 1 tower with the least enemies around.
-- 
-- @param range - The range to check.
-- @returns The non-tier 1 tower with the least enemies around.
function ____exports.GetNonTier1TowerWithLeastEnemiesAround(range)
    local towerEneCounts = ____exports.GetEnemyIdsNearNonTier1Towers(range)
    local minCount = 999
    local minCountTower = nil
    for ____, towerId in ipairs(NonTier1Towers) do
        local te = towerEneCounts[towerId]
        if te ~= nil and #te.enemyIds <= minCount then
            minCountTower = te.tower
            minCount = #te.enemyIds
        end
    end
    if minCount ~= 0 then
        return minCountTower
    end
    return nil
end
--- Get the closest tower or barrack to attack.
-- 
-- @param unit - The unit to check.
-- @returns The closest tower or barrack to attack.
function ____exports.GetClosestTowerOrBarrackToAttack(unit)
    local closestBuilding = nil
    local closestDistance = 2 ^ 1024
    for ____, barrackE in ipairs(BarrackList) do
        local barrack = GetBarracks(
            GetOpposingTeam(),
            barrackE
        )
        if barrack ~= nil and barrack:GetHealth() > 0 and not (barrack:HasModifier("modifier_fountain_glyph") or barrack:HasModifier("modifier_invulnerable") or barrack:HasModifier("modifier_backdoor_protection_active")) then
            local distance = GetUnitToUnitDistance(unit, barrack)
            if distance < closestDistance then
                closestDistance = distance
                closestBuilding = barrack
            end
        end
    end
    for ____, towerId in ipairs(HighGroundTowers) do
        local tower = GetTower(
            GetOpposingTeam(),
            towerId
        )
        if tower ~= nil and IsValidBuilding(tower) and not (tower:HasModifier("modifier_fountain_glyph") or tower:HasModifier("modifier_invulnerable") or tower:HasModifier("modifier_backdoor_protection_active")) then
            local distance = GetUnitToUnitDistance(unit, tower)
            if distance < closestDistance then
                closestDistance = distance
                closestBuilding = tower
            end
        end
    end
    return closestBuilding
end
--- Check if the unit is near an enemy high ground tower.
-- 
-- @param unit - The unit to check.
-- @param range - The range to check.
-- @returns True if the unit is near an enemy high ground tower, false otherwise.
function ____exports.IsNearEnemyHighGroundTower(unit, range)
    for ____, towerId in ipairs(HighGroundTowers) do
        local tower = GetTower(
            GetOpposingTeam(),
            towerId
        )
        if tower ~= nil and IsValidBuilding(tower) and GetUnitToUnitDistance(unit, tower) < range then
            return true
        end
    end
    return false
end
--- Check if the team is pushing second tier or high ground.
-- 
-- @param bot - The bot to check.
-- @returns True if the team is pushing second tier or high ground, false otherwise.
function ____exports.IsTeamPushingSecondTierOrHighGround(bot)
    local cacheKey = "IsTeamPushingSecondTierOrHighGround" .. tostring(bot:GetTeam())
    local cachedRes = GetCachedVars(cacheKey, 1)
    if cachedRes ~= nil then
        return cachedRes
    end
    local enemyAncient = GetAncient(GetOpposingTeam())
    if enemyAncient ~= nil then
        for ____, playerdId in ipairs(GetTeamPlayers(bot:GetTeam())) do
            if IsHeroAlive(playerdId) then
                local teamMember = GetTeamMember(playerdId)
                if teamMember ~= nil and #teamMember:GetNearbyHeroes(2000, false, BotMode.None) >= 2 and (____exports.IsNearEnemySecondTierTower(teamMember, 2000) or ____exports.IsNearEnemyHighGroundTower(teamMember, 3000) or GetUnitToUnitDistance(teamMember, enemyAncient) < 3000) then
                    SetCachedVars(cacheKey, true)
                    return true
                end
            end
        end
    end
    SetCachedVars(cacheKey, false)
    return false
end
--- Check if the bot is pushing a tower in danger.
-- 
-- @param bot - The bot to check.
-- @returns True if the bot is pushing a tower in danger, false otherwise.
function ____exports.IsBotPushingTowerInDanger(bot)
    local enemyTowerNearby = #bot:GetNearbyTowers(1100, true) >= 1
    if not enemyTowerNearby then
        return false
    end
    local nearbyAllies = bot:GetNearbyHeroes(1600, false, BotMode.None)
    local countAliveEnemies = GetNumOfAliveHeroes(true)
    local nearbyEnemy = GetLastSeenEnemyIdsNearLocation(
        bot:GetLocation(),
        2000
    )
    if enemyTowerNearby and #nearbyAllies < countAliveEnemies and #nearbyEnemy >= #nearbyAllies then
        return true
    end
    return false
end
--- Get the distance to the closest enemy tower.
-- 
-- @param bot - The bot to check.
-- @returns The distance to the closest enemy tower.
function ____exports.GetDistanceToCloestEnemyTower(bot)
    local cTower = nil
    local cDistance = 99999
    for ____, towerId in ipairs(AllTowers) do
        local tower = GetTower(
            GetOpposingTeam(),
            towerId
        )
        if tower ~= nil and IsValidBuilding(tower) and not (tower:HasModifier("modifier_fountain_glyph") or tower:HasModifier("modifier_invulnerable") or tower:HasModifier("modifier_backdoor_protection_active")) then
            local tDistance = GetUnitToUnitDistance(bot, tower)
            if tDistance < cDistance then
                cTower = tower
                cDistance = tDistance
            end
        end
    end
    return cDistance, cTower
end
return ____exports
