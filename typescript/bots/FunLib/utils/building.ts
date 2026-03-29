// utils/building.ts - Auto-generated sub-module

import { Barracks, BotMode, Lane, Team, Unit, UnitType, Vector } from "bots/ts_libs/dota";
import { AllTowers, BarrackList, BARRACKS, HighGroundTowers, LEVEL_3_TOWERS, NonTier1Towers, SecondTierTowers } from "bots/FunLib/utils/constants";
import { GetCachedVars, SetCachedVars } from "bots/FunLib/utils/cache";
import { IsValidBuilding, IsValidHero } from "bots/FunLib/utils/validation";
import { GetLastSeenEnemyIdsNearLocation, GetNumOfAliveHeroes } from "bots/FunLib/utils/team";


// --- High-ground edge & threat helpers ---
export function CountEnemyHeroesNear(loc: Vector, r: number): number {
    let n = 0;
    for (const u of GetUnitList(UnitType.EnemyHeroes)) {
        if (IsValidHero(u) && GetUnitToLocationDistance(u, loc) <= r) n++;
    }
    return n;
}



export function CountEnemyHeroesOnHighGround(team: Team): number {
    const cacheKey = `CountEnemyHeroesOnHighGround:${team ?? -1}`;
    const cachedVar = GetCachedVars(cacheKey, 1);
    if (cachedVar != null) {
        return cachedVar;
    }

    const anchors: Unit[] = [];
    for (const t of LEVEL_3_TOWERS) {
        const tw = GetTower(team, t);
        if (IsValidBuilding(tw)) anchors.push(tw as Unit);
    }
    for (const b of BARRACKS) {
        const bb = GetBarracks(team, b);
        if (IsValidBuilding(bb)) anchors.push(bb as Unit);
    }
    let maxSeen = 0;
    for (const a of anchors) {
        const c = CountEnemyHeroesNear(a.GetLocation(), 1600);
        if (c > maxSeen) maxSeen = c;
    }
    SetCachedVars(cacheKey, maxSeen);
    return maxSeen;
}




export function IsBuildingAttackedByEnemy(building: Unit): Unit | null {
    for (const hero of GetUnitList(UnitType.EnemyHeroes)) {
        if (IsValidHero(hero) && GetUnitToUnitDistance(building, hero) <= hero.GetAttackRange() + 200 && hero.GetAttackTarget() == building) {
            return building;
        }
    }
    // if (building.WasRecentlyDamagedByAnyHero(2) || building.WasRecentlyDamagedByCreep(2)) {
    //     return building
    // }
    return null;
}




export function IsAnyBarrackAttackByEnemyHero(): Unit | null {
    for (const barrackE of BarrackList) {
        const barrack = GetBarracks(GetTeam(), barrackE);
        if (barrack != null && barrack.GetHealth() > 0) {
            const bar = IsBuildingAttackedByEnemy(barrack);
            if (bar != null) {
                return bar;
            }
        }
    }
    return null;
}




export function IsAnyBarracksOnLaneAlive(bEnemy: boolean, lane: Lane): boolean {
    let barracks: (Unit | null)[] = [];
    let team = GetTeam();
    if (bEnemy) {
        team = GetOpposingTeam();
    }

    if (lane == Lane.Top) {
        barracks = [GetBarracks(team, Barracks.TopMelee), GetBarracks(team, Barracks.TopRanged)];
    } else if (lane == Lane.Mid) {
        barracks = [GetBarracks(team, Barracks.MidMelee), GetBarracks(team, Barracks.MidRanged)];
    } else if (lane == Lane.Bot) {
        barracks = [GetBarracks(team, Barracks.BotMelee), GetBarracks(team, Barracks.BotRanged)];
    }
    return IsAnyOfTheBuildingsAlive(barracks);
}




export function IsAnyOfTheBuildingsAlive(buildings: (Unit | null)[]): boolean {
    for (const building of buildings) {
        if (building != null && (!building.CanBeSeen() || building.GetHealth() > 0)) {
            return true;
        }
    }
    return false;
}




/**
 * Check if the unit is near an enemy second tier tower.
 * @param unit - The unit to check.
 * @param range - The range to check.
 * @returns True if the unit is near an enemy second tier tower, false otherwise.
 */
export function IsNearEnemySecondTierTower(unit: Unit, range: number): boolean {
    for (const towerId of SecondTierTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (tower !== null && IsValidBuilding(tower) && GetUnitToUnitDistance(unit, tower) < range) {
            return true;
        }
    }
    return false;
}




/**
 * Get the enemy ids near non-tier 1 towers.
 * @param range - The range to check.
 * @returns An object with tower ids as keys and their corresponding enemy ids.
 */
export function GetEnemyIdsNearNonTier1Towers(range: number) {
    let result = {} as { [key: number]: { tower: Unit; enemyIds: number[] } };
    for (const towerId of NonTier1Towers) {
        const tower = GetTower(GetTeam(), towerId);
        if (tower !== null && IsValidBuilding(tower)) {
            const eIds = GetLastSeenEnemyIdsNearLocation(tower.GetLocation(), range);
            result[towerId] = {
                tower: tower,
                enemyIds: eIds,
            };
        }
    }
    return result;
}




/**
 * Get the non-tier 1 tower with the least enemies around.
 * @param range - The range to check.
 * @returns The non-tier 1 tower with the least enemies around.
 */
export function GetNonTier1TowerWithLeastEnemiesAround(range: number): Unit | null {
    const towerEneCounts = GetEnemyIdsNearNonTier1Towers(range);
    let minCount = 999;
    let minCountTower = null;
    for (const towerId of NonTier1Towers) {
        const te = towerEneCounts[towerId];
        if (te !== null && te.enemyIds.length <= minCount) {
            minCountTower = te.tower;
            minCount = te.enemyIds.length;
        }
    }
    // if 0, no enemy near those towers anymore.
    if (minCount != 0) {
        return minCountTower;
    }
    return null;
}




/**
 * Get the closest tower or barrack to attack.
 * @param unit - The unit to check.
 * @returns The closest tower or barrack to attack.
 */
export function GetClosestTowerOrBarrackToAttack(unit: Unit): Unit | null {
    let closestBuilding: Unit | null = null;
    let closestDistance: number = Number.MAX_VALUE;

    for (const barrackE of BarrackList) {
        const barrack = GetBarracks(GetOpposingTeam(), barrackE);
        if (
            barrack != null &&
            barrack.GetHealth() > 0 &&
            !(
                barrack.HasModifier("modifier_fountain_glyph") ||
                barrack.HasModifier("modifier_invulnerable") ||
                barrack.HasModifier("modifier_backdoor_protection_active")
            )
        ) {
            const distance = GetUnitToUnitDistance(unit, barrack);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestBuilding = barrack;
            }
        }
    }
    for (const towerId of HighGroundTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (
            tower !== null &&
            IsValidBuilding(tower) &&
            !(tower.HasModifier("modifier_fountain_glyph") || tower.HasModifier("modifier_invulnerable") || tower.HasModifier("modifier_backdoor_protection_active"))
        ) {
            const distance = GetUnitToUnitDistance(unit, tower);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestBuilding = tower;
            }
        }
    }

    return closestBuilding;
}




/**
 * Check if the unit is near an enemy high ground tower.
 * @param unit - The unit to check.
 * @param range - The range to check.
 * @returns True if the unit is near an enemy high ground tower, false otherwise.
 */
export function IsNearEnemyHighGroundTower(unit: Unit, range: number): boolean {
    for (const towerId of HighGroundTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (tower !== null && IsValidBuilding(tower) && GetUnitToUnitDistance(unit, tower) < range) {
            return true;
        }
    }
    return false;
}




/**
 * Check if the team is pushing second tier or high ground.
 * @param bot - The bot to check.
 * @returns True if the team is pushing second tier or high ground, false otherwise.
 */
export function IsTeamPushingSecondTierOrHighGround(bot: Unit): boolean {
    const cacheKey = "IsTeamPushingSecondTierOrHighGround" + bot.GetTeam();
    const cachedRes = GetCachedVars(cacheKey, 1);
    if (cachedRes !== null) {
        return cachedRes;
    }
    const enemyAncient = GetAncient(GetOpposingTeam());
    if (enemyAncient !== null) {
        for (let playerdId of GetTeamPlayers(bot.GetTeam())) {
            if (IsHeroAlive(playerdId)) {
                const teamMember = GetTeamMember(playerdId);
                if (
                    teamMember !== null &&
                    teamMember.GetNearbyHeroes(2000, false, BotMode.None).length >= 2 &&
                    (IsNearEnemySecondTierTower(teamMember, 2000) ||
                        IsNearEnemyHighGroundTower(teamMember, 3000) ||
                        GetUnitToUnitDistance(teamMember, enemyAncient) < 3000)
                ) {
                    SetCachedVars(cacheKey, true);
                    return true;
                }
            }
        }
    }
    SetCachedVars(cacheKey, false);
    return false;
}




/**
 * Check if the bot is pushing a tower in danger.
 * @param bot - The bot to check.
 * @returns True if the bot is pushing a tower in danger, false otherwise.
 */
export function IsBotPushingTowerInDanger(bot: Unit): boolean {
    const enemyTowerNearby = bot.GetNearbyTowers(1100, true).length >= 1; // want to come a bit closer to the tower and be cautious while seducing enemy to defend.
    if (!enemyTowerNearby) {
        return false;
    }

    const nearbyAllies = bot.GetNearbyHeroes(1600, false, BotMode.None);
    const countAliveEnemies = GetNumOfAliveHeroes(true);

    const nearbyEnemy = GetLastSeenEnemyIdsNearLocation(bot.GetLocation(), 2000);

    if (enemyTowerNearby && nearbyAllies.length < countAliveEnemies && nearbyEnemy.length >= nearbyAllies.length) {
        return true;
    }
    return false;
}




/**
 * Get the distance to the closest enemy tower.
 * @param bot - The bot to check.
 * @returns The distance to the closest enemy tower.
 */
export function GetDistanceToCloestEnemyTower(bot: Unit): LuaMultiReturn<[number, Unit | null]> {
    let cTower = null;
    let cDistance = 99999;
    for (const towerId of AllTowers) {
        const tower = GetTower(GetOpposingTeam(), towerId);
        if (
            tower !== null &&
            IsValidBuilding(tower) &&
            !(tower.HasModifier("modifier_fountain_glyph") || tower.HasModifier("modifier_invulnerable") || tower.HasModifier("modifier_backdoor_protection_active"))
        ) {
            const tDistance = GetUnitToUnitDistance(bot, tower);
            if (tDistance < cDistance) {
                cTower = tower;
                cDistance = tDistance;
            }
        }
    }
    return $multi(cDistance, cTower);
}


