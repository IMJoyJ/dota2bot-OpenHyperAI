// utils/movement.ts - Auto-generated sub-module

import { BotMode, Unit, UnitType, Vector } from "bots/ts_libs/dota";
import { AvoidanceZone } from "bots/ts_libs/bots";
import { add, dot, length2D, length3D, multiply, sub } from "bots/ts_libs/utils/native-operators";
import { HeroName } from "bots/ts_libs/dota/heroes";
import { SpecialAOEHeroesDetails, AOEHeroThreat, specialOffensiveHeroes } from "bots/FunLib/utils/constants";
import { IsValidHero, IsValidUnit } from "bots/FunLib/utils/validation";
import { GetDistanceFromAncient, GetEnemyFountainTpPoint, GetTeamFountainTpPoint, GetTeamSideDirection, HasItem } from "bots/FunLib/utils/misc";


// Global array to store avoidance zones
let avoidanceZones: AvoidanceZone[] = [];




export function GetOffsetLocationTowardsTargetLocation(initLoc: Vector, targetLoc: Vector, offsetDist: number) {
    const direrction = sub(targetLoc, initLoc).Normalized();
    return add(initLoc, multiply(direrction, offsetDist));
}




/**
 * TODO: AvoidanceZone work in progress.
 *
 * Example: Adds a zone that expires after 10 seconds: addCustomAvoidanceZone(Vector(1000, 2000), 500, 10);
 * Example: Adds a zone lasts indefinitely: addCustomAvoidanceZone(Vector(1000, 2000), 500);
 * @param center
 * @param radius
 * @param duration
 */
export function addCustomAvoidanceZone(center: Vector, radius: number, duration?: number): void {
    const currentTime = DotaTime();
    const expirationTime = duration !== undefined ? currentTime + duration : Number.POSITIVE_INFINITY;

    avoidanceZones.push({ center, radius, expirationTime });
}




export function cleanExpiredAvoidanceZones(): void {
    const currentTime = DotaTime();
    avoidanceZones = avoidanceZones.filter(zone => zone.expirationTime > currentTime);
}




export function getCustomAvoidanceZones(): Array<{
    center: Vector;
    radius: number;
}> {
    return avoidanceZones;
}

export function IsSpecialOffensiveHero(name: string): boolean {
    return specialOffensiveHeroes.includes(name as any);
}




export function isPositionInAvoidanceZone(position: Vector): boolean {
    for (const zone of avoidanceZones) {
        const distance = length2D(sub(position, zone.center));
        if (distance <= zone.radius) {
            return true;
        }
    }
    return false;
}




export function moveToPositionAvoidingZones(bot: Unit, targetPosition: Vector): void {
    if (isPositionInAvoidanceZone(targetPosition)) {
        const safePosition = findSafePosition(bot.GetLocation(), targetPosition);
        bot.Action_MoveToLocation(safePosition);
    } else {
        bot.Action_MoveToLocation(targetPosition);
    }
}




export function findSafePosition(currentPosition: Vector, targetPosition: Vector): Vector {
    // Move towards the target but stop before entering the avoidance zone
    const direction = sub(targetPosition, currentPosition).Normalized();
    const safeDistance = getSafeDistance(currentPosition, targetPosition);
    return add(currentPosition, multiply(direction, safeDistance));
}




export function getSafeDistance(currentPosition: Vector, targetPosition: Vector): number {
    const maxDistance = length2D(sub(targetPosition, currentPosition));
    for (const zone of avoidanceZones) {
        const projectedPoint = projectPointOntoLine(currentPosition, targetPosition, zone.center);
        const distanceToZone = length2D(sub(projectedPoint, zone.center));
        if (distanceToZone <= zone.radius) {
            const distanceToAvoid = length2D(sub(projectedPoint, currentPosition)) - zone.radius;
            return Math.max(0, distanceToAvoid);
        }
    }
    return maxDistance;
}




export function projectPointOntoLine(startPoint: Vector, endPoint: Vector, point: Vector): Vector {
    const lineDir = sub(endPoint, startPoint).Normalized();
    const toPoint = sub(point, startPoint);
    const projectionLength = dot(toPoint, lineDir);
    return add(startPoint, multiply(lineDir, projectionLength));
}




export function drawAvoidanceZones(): void {
    for (const zone of avoidanceZones) {
        DebugDrawCircle(zone.center, zone.radius, 0, 255, 0);
    }
}




export function findPathAvoidingZones(
    // @ts-ignore
    startPosition: Vector,
    // @ts-ignore
    endPosition: Vector
): Vector[] {
    // Implement A* pathfinding algorithm here
    // Each node should check for collision with avoidance zones
    // Return a path array of Vectors that avoids the zones
    return [];
}




/**
 * Check if the given enemy hero meets the "threat conditions" for special AOE.
 *
 * @param enemy - The enemy hero unit.
 * @param threatInfo - The conditions for that hero (level, items, modifiers).
 * @returns true if the enemy meets the condition, otherwise false.
 */
function DoesHeroMeetThreatConditions(enemy: Unit, threatInfo: AOEHeroThreat): boolean {
    // Check level requirement
    if (enemy.GetLevel() < threatInfo.minLevel) {
        return false;
    }

    // Check items
    for (const itemName of threatInfo.requiredItems) {
        // If the hero does not have at least one instance of 'itemName', fail
        if (!HasItem(enemy, itemName)) {
            return false;
        }
    }

    // Check required modifiers
    for (const modName of threatInfo.requiredModifiers) {
        // If the hero does not have 'modName' active, fail
        if (!enemy.HasModifier(modName)) {
            return false;
        }
    }

    return true;
}




/**
 * Determine if there's at least one dangerous "Special AOE hero" nearby
 * that meets the threat conditions for big combos.
 *
 * @param bot - The bot unit to check around.
 * @param nRadius - The search radius (e.g. 500 or 2000).
 * @returns true if we found at least one special AOE threat in range.
 */
const blinkBuffer = 1200;


export function IsAnySpecialAOEThreatNearby(bot: Unit, nRadius: number): boolean {
    // 1) Grab the list of nearby enemy heroes
    // const nearbyEnemies = bot.GetNearbyHeroes(radius, true, BotMode.None);
    // if (!nearbyEnemies || nearbyEnemies.length === 0) {
    //     return false;
    // }

    // 2) Iterate each enemy hero
    for (const enemy of GetUnitList(UnitType.EnemyHeroes)) {
        if (!IsValidHero(enemy)) continue;
        const enemyName = enemy.GetUnitName() as HeroName;
        if (!(enemyName in SpecialAOEHeroesDetails)) continue;

        if (GetUnitToUnitDistance(bot, enemy) > nRadius + blinkBuffer) continue;
        if (bot.GetNearbyHeroes(nRadius, false, BotMode.None).length <= 1 && bot.GetNearbyLaneCreeps(nRadius, false).length <= 2) continue;

        if (DoesHeroMeetThreatConditions(enemy, SpecialAOEHeroesDetails[enemyName])) return true;
    }
    return false;
}




/**
 * Check if the bots should spread out.
 * @param bot - The bot to check.
 * @param minDistance - The minimum distance to check.
 * @returns True if the bots should spread out, false otherwise.
 */
export function ShouldBotsSpreadOut(bot: Unit, minDistance: number): boolean {
    // const cacheKey = "ShouldBotsSpreadOut" + bot.GetPlayerID();
    // const cachedRes = GetCachedVars(cacheKey, 0.1);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }

    let bResult = false;
    const threatNearby = IsAnySpecialAOEThreatNearby(bot, minDistance);
    if (threatNearby) {
        bResult = true;
    }
    // SetCachedVars(cacheKey, bResult);
    return bResult;
}




/**
 * Get the nearby ally units.
 * @param bot - The bot to check.
 * @param allyDistanceThreshold - The distance threshold to check for allies.
 * @returns An array of ally units.
 */
export function GetNearbyAllyUnits(bot: Unit, allyDistanceThreshold: number): Unit[] {
    // const cacheKey = "GetNearbyAllyUnits" + bot.GetPlayerID();
    // const cachedRes = GetCachedVars(cacheKey, 0.1);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }
    const hNearbyAllies = bot.GetNearbyHeroes(allyDistanceThreshold, false, BotMode.None);
    const hNearbyLaneCreeps = bot.GetNearbyLaneCreeps(allyDistanceThreshold, false);
    const hNearbyUnits = hNearbyAllies.concat(hNearbyLaneCreeps);
    // SetCachedVars(cacheKey, hNearbyUnits);
    return hNearbyUnits;
}




/**
 * Smart spread out the bots.
 * Emphasizes moving away from allies/enemies quickly while still
 * giving a mild pull toward fountain side if needed.
 *
 * @param bot - The bot to move.
 * @param allyDistanceThreshold - Distance threshold to check for allies.
 * @param minDistance - The minimum distance to keep from allies.
 * @param avoidEnemyUnits - The enemy units to avoid.
 * @param onlyAvoidEnemyUnits - If true, only avoid enemy units (ignore allies).
 */
export function SmartSpreadOut(bot: Unit, allyDistanceThreshold: number, minDistance: number, avoidEnemyUnits: Unit[] = [], onlyAvoidEnemyUnits: boolean = false) {
    let hNearbyUnits: Unit[] = [];
    if (onlyAvoidEnemyUnits) {
        hNearbyUnits = avoidEnemyUnits;
    } else {
        hNearbyUnits = GetNearbyAllyUnits(bot, allyDistanceThreshold).concat(avoidEnemyUnits);
    }

    // 2) Get the direction that moves the bot away from any nearby allies/enemies:
    const dirAwayFromAlly = SpreadBotApartDir(bot, minDistance, hNearbyUnits);
    if (!dirAwayFromAlly) {
        // If there is no particular direction needed, move back to fountain
        bot.Action_MoveToLocation(add(GetTeamFountainTpPoint(), RandomVector(50)));
        return;
    }

    // Current location
    const botLoc = bot.GetLocation();

    // 3) A mild pull in the direction of our "team side"
    //    (this helps ensure we don't drift too far forward if no enemies are nearby).
    //    If you want to completely remove fountain logic, set fountainWeight to 0.
    const awayFromAllyWeight = 0.7; // Primary emphasis: spread away from allies/enemies
    const fountainWeight = 0.3; // Mild emphasis toward bot's own side
    let teamFountainDir = GetTeamSideDirection(GetTeam());

    // If absolutely no enemies to avoid, we could reduce the fountain direction:
    if (avoidEnemyUnits.length === 0) {
        teamFountainDir = multiply(teamFountainDir, 0.5);
    }

    // 4) Combine directions with weights, then normalize
    const combinedDir = add(multiply(dirAwayFromAlly, awayFromAllyWeight), multiply(teamFountainDir, fountainWeight)).Normalized();

    // 5) Multiply by desired spread distance:
    let finalDir = multiply(combinedDir, minDistance);

    // 6) Ensure we do NOT move toward the enemy fountain
    const enemyFountainDir = sub(GetEnemyFountainTpPoint(), botLoc).Normalized();

    // If finalDir is pointing in the same general direction as the enemy fountain, fix it
    if (dot(finalDir.Normalized(), enemyFountainDir) > 0) {
        // Override: push away from enemy fountain instead
        // or at least pull back with the 'team side' direction
        finalDir = multiply(teamFountainDir, minDistance);
    }

    let targetLoc = add(botLoc, finalDir);

    // 7) Another fail-safe check: if the bot is already quite close to the enemy base,
    //    do not proceed further in that direction.
    if (GetDistanceFromAncient(bot, true) < 2600) {
        // If the chosen target is still forward, override
        if (dot(sub(targetLoc, botLoc), enemyFountainDir) > 0) {
            finalDir = multiply(teamFountainDir, minDistance);
            targetLoc = add(botLoc, finalDir);
        }
    }

    // 8) Move the bot to the new target location with a small random offset
    bot.Action_MoveToLocation(add(targetLoc, RandomVector(50)));
}




/**
 * Spread the bot apart from the allies.
 * @param bot - The bot to check.
 * @param minDistance - The distance to check.
 * @param hNearbyUnits - The units to check.
 * @returns The direction to spread the bot apart.
 */
export function SpreadBotApartDir(bot: Unit, minDistance: number, hNearbyUnits: Unit[]): Vector | null {
    const botLoc = bot.GetLocation();

    for (const unit of hNearbyUnits) {
        if (IsValidUnit(unit) && unit !== bot && GetUnitToUnitDistance(bot, unit) <= minDistance) {
            // dir = botLoc - ally:GetLocation() in Lua
            const dir = sub(botLoc, unit.GetLocation());
            // dir:Normalized() * distance in Lua
            return multiply(dir.Normalized(), minDistance);
        }
    }

    return null;
}




/**
 * Spread the bot apart from the allies.
 * @param bot - The bot to check.
 * @param minDistance - The distance to check.
 * @param hNearbyUnits - The units to check.
 * @returns The direction to spread the bot apart.
 */
export function SpreadBotApartDir_2(bot: Unit, minDistance: number, hNearbyUnits: Unit[]): Vector | null {
    // const cacheKey = "SpreadBotApartDir" + bot.GetPlayerID();
    // const cachedRes = GetCachedVars(cacheKey, 0.1);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }

    const botLoc = bot.GetLocation();

    // We'll accumulate a combined direction vector here.
    // Start it at the zero vector.
    let combinedDir = Vector(0, 0, 0);

    // 1) Check each unit and, if within minDistance, add the direction away from that unit.
    for (const unit of hNearbyUnits) {
        if (IsValidUnit(unit) && unit !== bot) {
            const dist = GetUnitToUnitDistance(bot, unit);
            if (dist <= minDistance) {
                // Direction from 'unit' to 'bot'
                // In Lua: dir = botLoc - unit:GetLocation()
                const dir = sub(botLoc, unit.GetLocation());
                // Accumulate it in combinedDir
                combinedDir = add(combinedDir, dir);
            }
        }
    }

    // 2) Check the length of our summed direction.
    const dirLength = length3D(combinedDir);
    if (dirLength < 1e-5) {
        // Either no units in range or they balanced each other out
        // SetCachedVars(cacheKey, null);
        return null;
    }

    // 3) Normalize and multiply to get a final direction of length minDistance.
    //    i.e., direction * minDistance
    const finalDir = multiply(combinedDir.Normalized(), minDistance);
    // SetCachedVars(cacheKey, finalDir);
    return finalDir;
}




/**
 * Get circular points around a center point.
 * @param vCenter - The center point.
 * @param nRadius - The radius of the circle.
 * @param numPoints - The number of points to get.
 * @returns An array of vectors representing the points.
 */
export function GetCirclarPointsAroundCenterPoint(vCenter: Vector, nRadius: number, numPoints: number): Vector[] {
    const points: Vector[] = [vCenter];
    const angleStep = 360 / numPoints;

    for (let i = 1; i <= numPoints; i++) {
        const angleRad = angleStep * i * (Math.PI / 180); // Convert degrees to radians
        const point: Vector = Vector(vCenter.x + nRadius * Math.cos(angleRad), vCenter.y + nRadius * Math.sin(angleRad), vCenter.z);
        points.push(point);
    }

    return points;
}




export function HasPossibleWallOfReplicaAround(bot: Unit): boolean {
    // const cacheKey = "HasPossibleWallOfReplicaAround" + bot.GetPlayerID();
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }
    if (bot.HasModifier("modifier_dark_seer_wall_slow")) {
        // SetCachedVars(cacheKey, true);
        return true;
    }
    // SetCachedVars(cacheKey, false);
    return false;
}




/**
 * Retrieves positions where the Wall of illusion can be.
 *
 * These positions serve as the centers for the potential danger zones.
 *
 * @returns {Vector[]} An array of Vector positions marking danger zone centers.
 */
export function GetWallIllusionPositions(bot: Unit): Vector[] {
    // const cacheKey = "GetWallIllusionPositions" + GetTeam();
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }

    const positions: Vector[] = [];
    if (HasPossibleWallOfReplicaAround(bot)) {
        const enemies = bot.GetNearbyHeroes(1600, true, BotMode.None);
        // Loop over each enemy hero found within the search radius
        for (const enemy of enemies) {
            // Check if the enemy has the wall illusion modifier
            if (enemy.HasModifier("modifier_darkseer_wallofreplica_illusion")) {
                // Add the enemy's location to the list of danger zone centers
                positions.push(enemy.GetLocation());
            }
        }
    }
    // SetCachedVars(cacheKey, positions);
    return positions;
}




/**
 * Determines whether a given target location is inside any danger zone.
 *
 * Danger zones are defined as circular areas centered on the location,
 * using the ability's effective radius (e.g., 1000 units) as the zone radius.
 *
 * @param {Vector} targetPos - The position to test.
 * @returns {{ inDanger: boolean, dangerCenter?: Vector }} An object indicating whether
 *          the target is in danger and, if so, providing the center of the danger zone.
 */
export function IsLocationInDangerZone(bot: Unit, targetPos: Vector): { inDanger: boolean; dangerCenter?: Vector } {
    const radius = 1000 + 500; // Effective radius e.g. for the ability's danger zone + buffer.
    const dangerZones: Vector[] = GetWallIllusionPositions(bot);

    // Check each danger zone center to see if the target position is within its radius
    for (const zoneCenter of dangerZones) {
        // Calculate the distance from the danger zone center to the target position
        const diff = sub(targetPos, zoneCenter);
        if (length2D(diff) < radius) {
            // Target is within the danger zone, return true and the center position
            return { inDanger: true, dangerCenter: zoneCenter };
        }
    }
    // Target is not in any danger zone
    return { inDanger: false };
}

/**
 * Rotates a 2D vector by a given angle (in radians).
 *
 * @param {Vector} v - The vector to rotate.
 * @param {number} angle - The angle in radians.
 * @returns {Vector} The rotated vector.
 */
export function RotateVector(v: Vector, angle: number): Vector {
    const cosTheta = Math.cos(angle);
    const sinTheta = Math.sin(angle);
    return Vector(
        v.x * cosTheta - v.y * sinTheta,
        v.x * sinTheta + v.y * cosTheta,
        v.z // Retain z value if available.
    );
}




/**
 * Calculates a safe destination based on a target position.
 *
 * If the target position falls within a danger zone, this function computes a new
 * position that lies just outside the danger zone (by moving away from its center),
 * adding a safety margin. If no target is provided, the bot's current location is used.
 * Finally, the code checks that the computed location is passable via IsLocationPassable.
 * If the candidate is blocked, the function rotates the offset vector in increments until
 * a passable location is found (up to a maximum number of attempts). If no passable location is
 * found, the bot remains at its current location.
 *
 * @param {Unit} bot - The bot unit.
 * @param {Vector} [targetPos] - (Optional) The original target position.
 * @returns {Vector} A safe position to move to. If no valid safe destination is found,
 *                   returns the bot's current location.
 */
export function GetSafeDestination(bot: Unit, targetPos?: Vector): Vector {
    // const cacheKey = "GetSafeDestination" + bot.GetPlayerID();
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }

    // Use the provided target position; if not available, fall back to the bot's current location.
    const referencePos: Vector = targetPos || add(bot.GetLocation(), RandomVector(260));

    // Check if the reference position is inside a danger zone.
    const result = IsLocationInDangerZone(bot, referencePos);
    if (result.inDanger && result.dangerCenter) {
        // The effective danger radius (ability radius plus buffer).
        const abilityRadius = 1000 + 500; // Example: 1000 + 500 units.
        const margin = 250; // Additional safety margin.
        // Calculate the offset vector from the danger center toward the reference position.
        let offsetVec = sub(referencePos, result.dangerCenter);

        // If the reference position coincides with the danger center, pick a random offset.
        if (length2D(offsetVec) === 0) {
            offsetVec = RandomVector(100);
        }
        // Normalize the offset vector.
        offsetVec = offsetVec.Normalized();

        // Compute an initial candidate safe position by moving outwards from the danger center.
        let safePos = add(result.dangerCenter, multiply(offsetVec, abilityRadius + margin));

        // Attempt to find a passable location by rotating the offset vector if necessary.
        const maxAttempts = 5;
        let attempt = 0;
        while (!IsLocationPassable(safePos) && attempt < maxAttempts) {
            // Rotate the offset vector by 36° (converted to radians).
            offsetVec = RotateVector(offsetVec, 36 * (Math.PI / 180));
            safePos = add(result.dangerCenter, multiply(offsetVec, abilityRadius + margin));
            attempt++;
        }

        // If no passable safe destination is found, return the bot's current location.
        if (!IsLocationPassable(safePos)) {
            // SetCachedVars(cacheKey, bot.GetLocation());
            return bot.GetLocation();
        }
        // SetCachedVars(cacheKey, safePos);
        return safePos;
    }
    // If the reference position is not in danger, simply return it.
    // SetCachedVars(cacheKey, referencePos);
    return referencePos;
}




/**
 * Checks if the bot's intended destination is within a danger zone and commands the bot to move
 * to a safe destination if necessary.
 *
 * @param {Vector} targetPos - The original target destination.
 */
export function MoveBotSafely(bot: Unit, targetPos?: Vector): void {
    const botPos = bot.GetLocation();

    // Determine a safe destination based on current danger zones
    const safeDestination = GetSafeDestination(bot, targetPos);
    // Check if the bot is already within 100 units of the target
    if (length2D(sub(botPos, safeDestination)) <= 100) {
        // If close enough, move directly to the target without avoiding danger zones
        bot.Action_MoveToLocation(safeDestination);
        return;
    }

    // Command the bot to move to the safe destination
    bot.Action_MoveToLocation(safeDestination);
}


