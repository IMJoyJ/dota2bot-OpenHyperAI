// utils/team.ts - Auto-generated sub-module

import { Ping, Team, Unit, UnitType, Vector } from "bots/ts_libs/dota";
import { EstimatedEnemyRoles, ImportantItems, LoneDruid } from "bots/FunLib/utils/constants";
import { IsValidHero } from "bots/FunLib/utils/validation";
import { GetLocationToLocationDistance, HasCriticalSpellWithCooldown, GetItem } from "bots/FunLib/utils/misc";


export function GetHumanPing(): LuaMultiReturn<[Unit, Ping] | [null, null]> {
    for (const playerId of GetTeamPlayers(GetTeam())) {
        const teamMember = GetTeamMember(playerId);
        if (teamMember !== null && !teamMember.IsBot()) {
            return $multi(teamMember, teamMember.GetMostRecentPing());
        }
    }
    return $multi(null, null);
}




export function IsPingedByAnyPlayer(bot: Unit, pingTimeGap: number, minDistance: number | null, maxDistance: number | null): Ping | null {
    if (!bot.IsAlive()) {
        return null;
    }

    const pings = [];

    minDistance = minDistance || 1500;
    maxDistance = maxDistance || 10000;
    for (const playerId of GetTeamPlayers(GetTeam())) {
        const teamMember = GetTeamMember(playerId);
        if (teamMember === null || teamMember.IsIllusion() || teamMember === bot) {
            continue;
        }

        const ping = teamMember.GetMostRecentPing();
        if (ping && ping.time && GameTime() - ping.time < pingTimeGap) pings.push(ping);
    }

    for (const ping of pings) {
        const distanceToBot = GetLocationToLocationDistance(ping.location, bot.GetLocation());
        const withinRange = minDistance <= distanceToBot && distanceToBot <= maxDistance;
        const withinTimeRange = GameTime() - ping.time < pingTimeGap;
        if (
            withinRange &&
            withinTimeRange
            // && ping.player_id != -1
        ) {
            print(`Bot ${bot.GetUnitName()} noticed the ping`);
            return ping;
        }
    }
    return null;
}




/**
 * Find an ally with the given name.
 * @param name - The name of the ally to find.
 * @returns The ally if found, null otherwise.
 */
export function FindAllyWithName(name: string): Unit | null {
    for (const ally of GetUnitList(UnitType.AlliedHeroes)) {
        if (IsValidHero(ally) && string.find(ally.GetUnitName(), name)) {
            return ally;
        }
    }
    return null;
}




const humanCountCache: { [key in Team]: [number, number] } = {};




export function NumHumanBotPlayersInTeam(team: Team): LuaMultiReturn<[number, number]> {
    if (!(team in humanCountCache)) {
        let humans = 0;
        let bots = 0;

        for (let playerdId of GetTeamPlayers(team)) {
            if (IsPlayerBot(playerdId)) {
                bots += 1;
            } else {
                humans += 1;
            }
        }
        humanCountCache[team] = [humans, bots];
    }
    return $multi(humanCountCache[team][0], humanCountCache[team][1]);
}




export function GetNearbyAllyAverageHpPercent(bot: Unit, radius: number): number {
    let sum = 0,
        cnt = 0;
    for (const playerId of GetTeamPlayers(bot.GetTeam())) {
        const ally = GetTeamMember(playerId);
        if (ally && ally.IsAlive() && GetUnitToUnitDistance(ally, bot) <= radius) {
            sum += ally.GetHealth() / ally.GetMaxHealth();
            cnt++;
        }
    }
    return cnt != null ? sum / cnt : 0;
}




// TODO: To guess the role of an enemy bot. Role should be determine around 1-2mins in the game based on lanes. In mid-late game, re-determine by networth.
export function DetermineEnemyBotRole(bot: Unit): number {
    const botName = bot.GetUnitName();
    const estimatedRole = EstimatedEnemyRoles[botName];
    if (estimatedRole == null) {
        print(`Enemy bot ${botName} role not cached yet.`);
        return 3;
    }

    return estimatedRole.role;
}




export function GetLoneDruid(bot: Unit): any {
    let res = LoneDruid[bot.GetPlayerID()];
    if (res == null) {
        LoneDruid[bot.GetPlayerID()] = {};
        res = LoneDruid[bot.GetPlayerID()];
    }
    return res;
}




// @ts-ignore
let IsHumanPlayerInTeamCache: { [key: number]: boolean } = {
    [Team.Radiant]: null,
    [Team.Dire]: null,
};

export function IsHumanPlayerInAnyTeam(): boolean {
    return IsHumanPlayerInTeam(Team.Radiant) || IsHumanPlayerInTeam(Team.Dire);
}




export function IsHumanPlayerInTeam(team: Team): boolean {
    if (IsHumanPlayerInTeamCache[team] !== null) {
        return IsHumanPlayerInTeamCache[team];
    }

    for (let playerdId of GetTeamPlayers(team)) {
        if (!IsPlayerBot(playerdId)) {
            IsHumanPlayerInTeamCache[team] = true;
            return true;
        }
    }
    IsHumanPlayerInTeamCache[team] = false;
    return false;
}




/**
 * Get the enemy hero by player id.
 * @param id - The player id to check.
 * @returns The enemy hero if found, null otherwise.
 */
export function GetEnemyHeroByPlayerId(id: number): Unit | null {
    for (const hero of GetUnitList(UnitType.EnemyHeroes)) {
        if (IsValidHero(hero) && hero.GetPlayerID() == id) {
            return hero;
        }
    }
    return null;
}




/**
 * Get the number of alive heroes.
 * @param bEnemy - Whether to count enemy heroes.
 * @returns The number of alive heroes.
 */
export function GetNumOfAliveHeroes(bEnemy: boolean): number {
    let count = 0;
    let nTeam = GetTeam();
    if (bEnemy) {
        nTeam = GetOpposingTeam();
    }
    for (let playerdId of GetTeamPlayers(nTeam)) {
        if (IsHeroAlive(playerdId)) {
            count += 1;
        }
    }

    // print(`count alive hero for enemy: ${bEnemy} is ${count}`);
    return count;
}




/**
 * Count the missing enemy heroes.
 * @returns The number of missing enemy heroes.
 */
export function CountMissingEnemyHeroes(): number {
    // const cacheKey = "CountMissingEnemyHeroes" + GetTeam();
    // const cachedRes = GetCachedVars(cacheKey, 0.5);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }

    let count = 0;
    for (let playerdId of GetTeamPlayers(GetOpposingTeam())) {
        if (IsHeroAlive(playerdId)) {
            const lastSeenInfo = GetHeroLastSeenInfo(playerdId);
            if (lastSeenInfo !== null && lastSeenInfo[0] !== null) {
                const firstInfo = lastSeenInfo[0];
                if (firstInfo.time_since_seen >= 2.5) {
                    count += 1;
                    continue;
                }
                // const enemyHero = GetEnemyHeroByPlayerId(playerdId);
                // if (
                //     enemyHero &&
                //     enemyHero.HasModifier("modifier_teleporting")
                // ) {
                //     count += 1;
                // }
            }
        }
    }
    // print(`count missing alive hero for enemy: ${count}`);
    // SetCachedVars(cacheKey, count);
    return count;
}




/**
 * Find an ally with at least a certain distance away from a bot.
 * @param bot - The bot to check.
 * @param nDistance - The minimum distance to check.
 * @returns The ally if found, null otherwise.
 */
export function FindAllyWithAtLeastDistanceAway(bot: Unit, nDistance: number) {
    if (bot.GetTeam() !== GetTeam()) {
        print("[ERROR] Wrong usage of the method");
        return null;
    }

    for (const playerId of GetTeamPlayers(GetTeam())) {
        const teamMember = GetTeamMember(playerId);
        if (teamMember !== null && teamMember.IsAlive() && GetUnitToUnitDistance(teamMember, bot) >= nDistance) {
            return teamMember;
        }
    }
    return null;
}




/**
 * Get the last seen enemy ids near a location.
 * @param vLoc - The location to check.
 * @param nDistance - The distance to check.
 * @returns An array of enemy ids.
 */
export function GetLastSeenEnemyIdsNearLocation(vLoc: Vector, nDistance: number): number[] {
    let enemies = [];
    for (let playerdId of GetTeamPlayers(GetOpposingTeam())) {
        if (IsHeroAlive(playerdId)) {
            const lastSeenInfo = GetHeroLastSeenInfo(playerdId);
            if (lastSeenInfo !== null && lastSeenInfo[0] !== null) {
                const firstInfo = lastSeenInfo[0];
                if (GetLocationToLocationDistance(firstInfo.location, vLoc) <= nDistance && firstInfo.time_since_seen <= 3) {
                    enemies.push(playerdId);
                }
            }
        }
    }

    enemies = enemies.concat(GetEnemyIdsInTpToLocation(vLoc, nDistance));

    return enemies;
}




/**
 * Get the enemy ids in teleport to a location.
 * @param vLoc - The location to check.
 * @param nDistance - The distance to check.
 * @returns An array of enemy ids.
 */
export function GetEnemyIdsInTpToLocation(vLoc: Vector, nDistance: number): number[] {
    const enemies = [];
    for (let tp of GetIncomingTeleports()) {
        if (tp !== null && GetLocationToLocationDistance(vLoc, tp.location) <= nDistance && !IsTeamPlayer(tp.playerid)) {
            enemies.push(tp.playerid);
        }
    }
    return enemies;
}




/**
 * Get the ally ids in teleport to a location.
 * @param vLoc - The location to check.
 * @param nDistance - The distance to check.
 * @returns An array of ally ids.
 */
export function GetAllyIdsInTpToLocation(vLoc: Vector, nDistance: number): number[] {
    const allies = [];
    for (let tp of GetIncomingTeleports()) {
        if (tp !== null && GetLocationToLocationDistance(vLoc, tp.location) <= nDistance && IsTeamPlayer(tp.playerid)) {
            allies.push(tp.playerid);
        }
    }
    return allies;
}




/**
 * Check if the team has a member with a critical spell in cooldown when the bot walks & arrives to the location.
 * @param bot - The bot to check.
 * @param targetLoc - The location to check.
 * @returns True if the team has a member with a critical spell in cooldown, false otherwise.
 */
export function HasTeamMemberWithCriticalSpellInCooldown(targetLoc: Vector): boolean {
    // const cacheKey = "HasTeamMemberWithCriticalSpellInCooldown" + GetTeam();
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }
    for (const playerId of GetTeamPlayers(GetTeam())) {
        const teamMember = GetTeamMember(playerId);
        if (teamMember !== null && teamMember.IsAlive()) {
            const nDuration = GetUnitToLocationDistance(teamMember, targetLoc) / teamMember.GetCurrentMovementSpeed();
            if (HasCriticalSpellWithCooldown(teamMember, nDuration)) {
                // SetCachedVars(cacheKey, true);
                // print("HasTeamMemberWithCriticalSpellInCooldown: " + tostring(teamMember.GetUnitName()) + " " + tostring(nDuration));
                return true;
            }
        }
    }
    // SetCachedVars(cacheKey, false);
    return false;
}




/**
 * Check if the team has a member with a critical item in cooldown when the bot walks & arrives to the location.
 * @param bot - The bot to check.
 * @param targetLoc - The location to check.
 * @returns True if the team has a member with a critical item in cooldown, false otherwise.
 */
export function HasTeamMemberWithCriticalItemInCooldown(targetLoc: Vector): boolean {
    // const cacheKey = "HasTeamMemberWithCriticalItemInCooldown" + GetTeam();
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }
    for (const playerId of GetTeamPlayers(GetTeam())) {
        const teamMember = GetTeamMember(playerId);
        if (teamMember !== null && teamMember.IsAlive()) {
            const nDuration = GetUnitToLocationDistance(teamMember, targetLoc) / teamMember.GetCurrentMovementSpeed();
            for (const itemName of ImportantItems) {
                const item = GetItem(teamMember, itemName);
                if (item && item.GetCooldownTimeRemaining() > nDuration) {
                    // SetCachedVars(cacheKey, true);
                    return true;
                }
            }
        }
    }
    // SetCachedVars(cacheKey, false);
    return false;
}


