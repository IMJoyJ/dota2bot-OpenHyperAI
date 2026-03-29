--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArrayFilter(self, callbackfn, thisArg)
    local result = {}
    local len = 0
    for i = 1, #self do
        if callbackfn(thisArg, self[i], i - 1, self) then
            len = len + 1
            result[len] = self[i]
        end
    end
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
local avoidanceZones
local ____dota = require("bots.ts_libs.dota.index")
local BotMode = ____dota.BotMode
local UnitType = ____dota.UnitType
local ____native_2Doperators = require("bots.ts_libs.utils.native-operators")
local add = ____native_2Doperators.add
local dot = ____native_2Doperators.dot
local length2D = ____native_2Doperators.length2D
local length3D = ____native_2Doperators.length3D
local multiply = ____native_2Doperators.multiply
local sub = ____native_2Doperators.sub
local ____constants = require("bots.FunLib.utils.constants")
local SpecialAOEHeroesDetails = ____constants.SpecialAOEHeroesDetails
local specialOffensiveHeroes = ____constants.specialOffensiveHeroes
local ____validation = require("bots.FunLib.utils.validation")
local IsValidHero = ____validation.IsValidHero
local IsValidUnit = ____validation.IsValidUnit
local ____misc = require("bots.FunLib.utils.misc")
local GetDistanceFromAncient = ____misc.GetDistanceFromAncient
local GetEnemyFountainTpPoint = ____misc.GetEnemyFountainTpPoint
local GetTeamFountainTpPoint = ____misc.GetTeamFountainTpPoint
local GetTeamSideDirection = ____misc.GetTeamSideDirection
local HasItem = ____misc.HasItem
function ____exports.findSafePosition(currentPosition, targetPosition)
    local direction = sub(targetPosition, currentPosition):Normalized()
    local safeDistance = ____exports.getSafeDistance(currentPosition, targetPosition)
    return add(
        currentPosition,
        multiply(direction, safeDistance)
    )
end
function ____exports.getSafeDistance(currentPosition, targetPosition)
    local maxDistance = length2D(sub(targetPosition, currentPosition))
    for ____, zone in ipairs(avoidanceZones) do
        local projectedPoint = ____exports.projectPointOntoLine(currentPosition, targetPosition, zone.center)
        local distanceToZone = length2D(sub(projectedPoint, zone.center))
        if distanceToZone <= zone.radius then
            local distanceToAvoid = length2D(sub(projectedPoint, currentPosition)) - zone.radius
            return math.max(0, distanceToAvoid)
        end
    end
    return maxDistance
end
function ____exports.projectPointOntoLine(startPoint, endPoint, point)
    local lineDir = sub(endPoint, startPoint):Normalized()
    local toPoint = sub(point, startPoint)
    local projectionLength = dot(toPoint, lineDir)
    return add(
        startPoint,
        multiply(lineDir, projectionLength)
    )
end
--- Spread the bot apart from the allies.
-- 
-- @param bot - The bot to check.
-- @param minDistance - The distance to check.
-- @param hNearbyUnits - The units to check.
-- @returns The direction to spread the bot apart.
function ____exports.SpreadBotApartDir(bot, minDistance, hNearbyUnits)
    local botLoc = bot:GetLocation()
    for ____, unit in ipairs(hNearbyUnits) do
        if IsValidUnit(unit) and unit ~= bot and GetUnitToUnitDistance(bot, unit) <= minDistance then
            local dir = sub(
                botLoc,
                unit:GetLocation()
            )
            return multiply(
                dir:Normalized(),
                minDistance
            )
        end
    end
    return nil
end
avoidanceZones = {}
function ____exports.GetOffsetLocationTowardsTargetLocation(initLoc, targetLoc, offsetDist)
    local direrction = sub(targetLoc, initLoc):Normalized()
    return add(
        initLoc,
        multiply(direrction, offsetDist)
    )
end
--- TODO: AvoidanceZone work in progress.
-- 
-- Example: Adds a zone that expires after 10 seconds: addCustomAvoidanceZone(Vector(1000, 2000), 500, 10);
-- Example: Adds a zone lasts indefinitely: addCustomAvoidanceZone(Vector(1000, 2000), 500);
-- 
-- @param center
-- @param radius
-- @param duration
function ____exports.addCustomAvoidanceZone(center, radius, duration)
    local currentTime = DotaTime()
    local expirationTime = duration ~= nil and currentTime + duration or math.huge
    avoidanceZones[#avoidanceZones + 1] = {center = center, radius = radius, expirationTime = expirationTime}
end
function ____exports.cleanExpiredAvoidanceZones()
    local currentTime = DotaTime()
    avoidanceZones = __TS__ArrayFilter(
        avoidanceZones,
        function(____, zone) return zone.expirationTime > currentTime end
    )
end
function ____exports.getCustomAvoidanceZones()
    return avoidanceZones
end
function ____exports.IsSpecialOffensiveHero(name)
    return __TS__ArrayIncludes(specialOffensiveHeroes, name)
end
function ____exports.isPositionInAvoidanceZone(position)
    for ____, zone in ipairs(avoidanceZones) do
        local distance = length2D(sub(position, zone.center))
        if distance <= zone.radius then
            return true
        end
    end
    return false
end
function ____exports.moveToPositionAvoidingZones(bot, targetPosition)
    if ____exports.isPositionInAvoidanceZone(targetPosition) then
        local safePosition = ____exports.findSafePosition(
            bot:GetLocation(),
            targetPosition
        )
        bot:Action_MoveToLocation(safePosition)
    else
        bot:Action_MoveToLocation(targetPosition)
    end
end
function ____exports.drawAvoidanceZones()
    for ____, zone in ipairs(avoidanceZones) do
        DebugDrawCircle(
            zone.center,
            zone.radius,
            0,
            255,
            0
        )
    end
end
function ____exports.findPathAvoidingZones(startPosition, endPosition)
    return {}
end
--- Check if the given enemy hero meets the "threat conditions" for special AOE.
-- 
-- @param enemy - The enemy hero unit.
-- @param threatInfo - The conditions for that hero (level, items, modifiers).
-- @returns true if the enemy meets the condition, otherwise false.
local function DoesHeroMeetThreatConditions(enemy, threatInfo)
    if enemy:GetLevel() < threatInfo.minLevel then
        return false
    end
    for ____, itemName in ipairs(threatInfo.requiredItems) do
        if not HasItem(enemy, itemName) then
            return false
        end
    end
    for ____, modName in ipairs(threatInfo.requiredModifiers) do
        if not enemy:HasModifier(modName) then
            return false
        end
    end
    return true
end
--- Determine if there's at least one dangerous "Special AOE hero" nearby
-- that meets the threat conditions for big combos.
-- 
-- @param bot - The bot unit to check around.
-- @param nRadius - The search radius (e.g. 500 or 2000).
-- @returns true if we found at least one special AOE threat in range.
local blinkBuffer = 1200
function ____exports.IsAnySpecialAOEThreatNearby(bot, nRadius)
    for ____, enemy in ipairs(GetUnitList(UnitType.EnemyHeroes)) do
        do
            local __continue34
            repeat
                if not IsValidHero(enemy) then
                    __continue34 = true
                    break
                end
                local enemyName = enemy:GetUnitName()
                if not (SpecialAOEHeroesDetails[enemyName] ~= nil) then
                    __continue34 = true
                    break
                end
                if GetUnitToUnitDistance(bot, enemy) > nRadius + blinkBuffer then
                    __continue34 = true
                    break
                end
                if #bot:GetNearbyHeroes(nRadius, false, BotMode.None) <= 1 and #bot:GetNearbyLaneCreeps(nRadius, false) <= 2 then
                    __continue34 = true
                    break
                end
                if DoesHeroMeetThreatConditions(enemy, SpecialAOEHeroesDetails[enemyName]) then
                    return true
                end
                __continue34 = true
            until true
            if not __continue34 then
                break
            end
        end
    end
    return false
end
--- Check if the bots should spread out.
-- 
-- @param bot - The bot to check.
-- @param minDistance - The minimum distance to check.
-- @returns True if the bots should spread out, false otherwise.
function ____exports.ShouldBotsSpreadOut(bot, minDistance)
    local bResult = false
    local threatNearby = ____exports.IsAnySpecialAOEThreatNearby(bot, minDistance)
    if threatNearby then
        bResult = true
    end
    return bResult
end
--- Get the nearby ally units.
-- 
-- @param bot - The bot to check.
-- @param allyDistanceThreshold - The distance threshold to check for allies.
-- @returns An array of ally units.
function ____exports.GetNearbyAllyUnits(bot, allyDistanceThreshold)
    local hNearbyAllies = bot:GetNearbyHeroes(allyDistanceThreshold, false, BotMode.None)
    local hNearbyLaneCreeps = bot:GetNearbyLaneCreeps(allyDistanceThreshold, false)
    local hNearbyUnits = __TS__ArrayConcat(hNearbyAllies, hNearbyLaneCreeps)
    return hNearbyUnits
end
--- Smart spread out the bots.
-- Emphasizes moving away from allies/enemies quickly while still
-- giving a mild pull toward fountain side if needed.
-- 
-- @param bot - The bot to move.
-- @param allyDistanceThreshold - Distance threshold to check for allies.
-- @param minDistance - The minimum distance to keep from allies.
-- @param avoidEnemyUnits - The enemy units to avoid.
-- @param onlyAvoidEnemyUnits - If true, only avoid enemy units (ignore allies).
function ____exports.SmartSpreadOut(bot, allyDistanceThreshold, minDistance, avoidEnemyUnits, onlyAvoidEnemyUnits)
    if avoidEnemyUnits == nil then
        avoidEnemyUnits = {}
    end
    if onlyAvoidEnemyUnits == nil then
        onlyAvoidEnemyUnits = false
    end
    local hNearbyUnits = {}
    if onlyAvoidEnemyUnits then
        hNearbyUnits = avoidEnemyUnits
    else
        hNearbyUnits = __TS__ArrayConcat(
            ____exports.GetNearbyAllyUnits(bot, allyDistanceThreshold),
            avoidEnemyUnits
        )
    end
    local dirAwayFromAlly = ____exports.SpreadBotApartDir(bot, minDistance, hNearbyUnits)
    if not dirAwayFromAlly then
        bot:Action_MoveToLocation(add(
            GetTeamFountainTpPoint(),
            RandomVector(50)
        ))
        return
    end
    local botLoc = bot:GetLocation()
    local awayFromAllyWeight = 0.7
    local fountainWeight = 0.3
    local teamFountainDir = GetTeamSideDirection(GetTeam())
    if #avoidEnemyUnits == 0 then
        teamFountainDir = multiply(teamFountainDir, 0.5)
    end
    local combinedDir = add(
        multiply(dirAwayFromAlly, awayFromAllyWeight),
        multiply(teamFountainDir, fountainWeight)
    ):Normalized()
    local finalDir = multiply(combinedDir, minDistance)
    local enemyFountainDir = sub(
        GetEnemyFountainTpPoint(),
        botLoc
    ):Normalized()
    if dot(
        finalDir:Normalized(),
        enemyFountainDir
    ) > 0 then
        finalDir = multiply(teamFountainDir, minDistance)
    end
    local targetLoc = add(botLoc, finalDir)
    if GetDistanceFromAncient(bot, true) < 2600 then
        if dot(
            sub(targetLoc, botLoc),
            enemyFountainDir
        ) > 0 then
            finalDir = multiply(teamFountainDir, minDistance)
            targetLoc = add(botLoc, finalDir)
        end
    end
    bot:Action_MoveToLocation(add(
        targetLoc,
        RandomVector(50)
    ))
end
--- Spread the bot apart from the allies.
-- 
-- @param bot - The bot to check.
-- @param minDistance - The distance to check.
-- @param hNearbyUnits - The units to check.
-- @returns The direction to spread the bot apart.
function ____exports.SpreadBotApartDir_2(bot, minDistance, hNearbyUnits)
    local botLoc = bot:GetLocation()
    local combinedDir = Vector(0, 0, 0)
    for ____, unit in ipairs(hNearbyUnits) do
        if IsValidUnit(unit) and unit ~= bot then
            local dist = GetUnitToUnitDistance(bot, unit)
            if dist <= minDistance then
                local dir = sub(
                    botLoc,
                    unit:GetLocation()
                )
                combinedDir = add(combinedDir, dir)
            end
        end
    end
    local dirLength = length3D(combinedDir)
    if dirLength < 0.00001 then
        return nil
    end
    local finalDir = multiply(
        combinedDir:Normalized(),
        minDistance
    )
    return finalDir
end
--- Get circular points around a center point.
-- 
-- @param vCenter - The center point.
-- @param nRadius - The radius of the circle.
-- @param numPoints - The number of points to get.
-- @returns An array of vectors representing the points.
function ____exports.GetCirclarPointsAroundCenterPoint(vCenter, nRadius, numPoints)
    local points = {vCenter}
    local angleStep = 360 / numPoints
    do
        local i = 1
        while i <= numPoints do
            local angleRad = angleStep * i * (math.pi / 180)
            local point = Vector(
                vCenter.x + nRadius * math.cos(angleRad),
                vCenter.y + nRadius * math.sin(angleRad),
                vCenter.z
            )
            points[#points + 1] = point
            i = i + 1
        end
    end
    return points
end
function ____exports.HasPossibleWallOfReplicaAround(bot)
    if bot:HasModifier("modifier_dark_seer_wall_slow") then
        return true
    end
    return false
end
--- Retrieves positions where the Wall of illusion can be.
-- 
-- These positions serve as the centers for the potential danger zones.
-- 
-- @returns An array of Vector positions marking danger zone centers.
function ____exports.GetWallIllusionPositions(bot)
    local positions = {}
    if ____exports.HasPossibleWallOfReplicaAround(bot) then
        local enemies = bot:GetNearbyHeroes(1600, true, BotMode.None)
        for ____, enemy in ipairs(enemies) do
            if enemy:HasModifier("modifier_darkseer_wallofreplica_illusion") then
                positions[#positions + 1] = enemy:GetLocation()
            end
        end
    end
    return positions
end
--- Determines whether a given target location is inside any danger zone.
-- 
-- Danger zones are defined as circular areas centered on the location,
-- using the ability's effective radius (e.g., 1000 units) as the zone radius.
-- 
-- @param targetPos - The position to test.
-- @returns An object indicating whether
-- the target is in danger and, if so, providing the center of the danger zone.
function ____exports.IsLocationInDangerZone(bot, targetPos)
    local radius = 1000 + 500
    local dangerZones = ____exports.GetWallIllusionPositions(bot)
    for ____, zoneCenter in ipairs(dangerZones) do
        local diff = sub(targetPos, zoneCenter)
        if length2D(diff) < radius then
            return {inDanger = true, dangerCenter = zoneCenter}
        end
    end
    return {inDanger = false}
end
--- Rotates a 2D vector by a given angle (in radians).
-- 
-- @param v - The vector to rotate.
-- @param angle - The angle in radians.
-- @returns The rotated vector.
function ____exports.RotateVector(v, angle)
    local cosTheta = math.cos(angle)
    local sinTheta = math.sin(angle)
    return Vector(v.x * cosTheta - v.y * sinTheta, v.x * sinTheta + v.y * cosTheta, v.z)
end
--- Calculates a safe destination based on a target position.
-- 
-- If the target position falls within a danger zone, this function computes a new
-- position that lies just outside the danger zone (by moving away from its center),
-- adding a safety margin. If no target is provided, the bot's current location is used.
-- Finally, the code checks that the computed location is passable via IsLocationPassable.
-- If the candidate is blocked, the function rotates the offset vector in increments until
-- a passable location is found (up to a maximum number of attempts). If no passable location is
-- found, the bot remains at its current location.
-- 
-- @param bot - The bot unit.
-- @param targetPos - (Optional) The original target position.
-- @returns A safe position to move to. If no valid safe destination is found,
-- returns the bot's current location.
function ____exports.GetSafeDestination(bot, targetPos)
    local referencePos = targetPos or add(
        bot:GetLocation(),
        RandomVector(260)
    )
    local result = ____exports.IsLocationInDangerZone(bot, referencePos)
    if result.inDanger and result.dangerCenter then
        local abilityRadius = 1000 + 500
        local margin = 250
        local offsetVec = sub(referencePos, result.dangerCenter)
        if length2D(offsetVec) == 0 then
            offsetVec = RandomVector(100)
        end
        offsetVec = offsetVec:Normalized()
        local safePos = add(
            result.dangerCenter,
            multiply(offsetVec, abilityRadius + margin)
        )
        local maxAttempts = 5
        local attempt = 0
        while not IsLocationPassable(safePos) and attempt < maxAttempts do
            offsetVec = ____exports.RotateVector(offsetVec, 36 * (math.pi / 180))
            safePos = add(
                result.dangerCenter,
                multiply(offsetVec, abilityRadius + margin)
            )
            attempt = attempt + 1
        end
        if not IsLocationPassable(safePos) then
            return bot:GetLocation()
        end
        return safePos
    end
    return referencePos
end
--- Checks if the bot's intended destination is within a danger zone and commands the bot to move
-- to a safe destination if necessary.
-- 
-- @param targetPos - The original target destination.
function ____exports.MoveBotSafely(bot, targetPos)
    local botPos = bot:GetLocation()
    local safeDestination = ____exports.GetSafeDestination(bot, targetPos)
    if length2D(sub(botPos, safeDestination)) <= 100 then
        bot:Action_MoveToLocation(safeDestination)
        return
    end
    bot:Action_MoveToLocation(safeDestination)
end
return ____exports
