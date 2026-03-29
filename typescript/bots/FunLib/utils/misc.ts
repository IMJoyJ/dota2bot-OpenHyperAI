// utils/misc.ts - Auto-generated sub-module

import { BotActionType, Item, Team, Unit, UnitType, Vector } from "bots/ts_libs/dota";
import { FrameProcessTime, ImportantSpells, RadiantFountainTpPoint, DireFountainTpPoint, meaningfulActivities } from "bots/FunLib/utils/constants";
import { GetCachedVars, SetCachedVars } from "bots/FunLib/utils/cache";
import { IsValidAbility } from "bots/FunLib/utils/validation";
import { NewTable } from "bots/FunLib/utils/collection";


export function GetEnemyFountainTpPoint(): Vector {
    if (GetTeam() == Team.Dire) {
        return RadiantFountainTpPoint;
    }
    return DireFountainTpPoint;
}




export function GetTeamFountainTpPoint(): Vector {
    if (GetTeam() == Team.Dire) {
        return DireFountainTpPoint;
    }
    return RadiantFountainTpPoint;
}




/**
 * Get the direction of the team side.
 * @param team - The team to get the direction for.
 * @returns The direction of the team side.
 */
export function GetTeamSideDirection(team: number): Vector {
    // Radiant side => roughly bottom-left
    // Dire side    => roughly top-right
    if (team === Team.Radiant) {
        // e.g. direction (-1, -1) normalized
        return Vector(-1, -1, 0).Normalized();
    } else {
        // e.g. direction (1, 1) normalized
        return Vector(1, 1, 0).Normalized();
    }
}




export function SetFrameProcessTime(bot: Unit): void {
    if (bot.frameProcessTime === null) {
        bot.frameProcessTime = FrameProcessTime + +(math.fmod(bot.GetPlayerID() / 1000, FrameProcessTime / 10) * 3).toFixed(2);
    }
}




export function GetDistanceFromAncient(bot: Unit, enemy: boolean): number {
    const ancient = GetAncient(enemy ? GetOpposingTeam() : GetTeam());
    return GetUnitToUnitDistance(bot, ancient);
}




/**
 * Check if the bot has the item in its inventory.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to check.
 * @returns True if the bot has the item, false otherwise.
 */
export function HasItem(bot: Unit, itemName: string): boolean {
    const slot = bot.FindItemSlot(itemName);
    return slot >= 0 && slot <= 8;
}




/**
 * Get the distance between two locations.
 * @param fLoc - The first location.
 * @param sLoc - The second location.
 * @returns The distance between the two locations.
 */
export function GetLocationToLocationDistance(fLoc: Vector, sLoc: Vector): number {
    const x1 = fLoc.x;
    const x2 = sLoc.x;
    const y1 = fLoc.y;
    const y2 = sLoc.y;
    return math.sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));
}




export function NumActionTypeInQueue(bot: Unit, searchedActionType: BotActionType) {
    let count: number = 0;
    for (const index of $range(1, bot.NumQueuedActions())) {
        const actionType = bot.GetQueuedActionType(index);
        if (actionType === searchedActionType) {
            count++;
        }
    }
    return count;
}




export function CountBackpackEmptySpace(bot: Unit) {
    let count = 3;
    for (const slot of [6, 7, 8]) {
        if (bot.GetItemInSlot(slot) !== null) {
            count--;
        }
    }
    return count;
}




export function FloatEqual(a: number, b: number) {
    return math.abs(a - b) < 0.000001;
}




export function AbilityBehaviorHasFlag(behavior: number, flag: number): boolean {
    // @ts-ignore
    return bit.band(behavior, flag) == flag;
}




interface RegistryMember {
    lastCallTime: number;
    interval: number;
    startup: boolean | null;
}




const everySecondsCallRegistry: { [key: string]: RegistryMember } = {};


//**Doesn't seem to be used*/
// @ts-ignore
function EveryManySeconds(second: number, oldFunction: Function) {
    const functionName = tostring(oldFunction);
    everySecondsCallRegistry[functionName] = {
        lastCallTime: DotaTime() + RandomInt(0, second * 1000) / 1000,
        interval: second,
        startup: true,
    };

    return function (...args: any[]) {
        const callTable = everySecondsCallRegistry[functionName];
        if (callTable.startup) {
            callTable.startup = null;
            return oldFunction(...args);
        } else if (callTable.lastCallTime <= DotaTime() - callTable.interval) {
            callTable.lastCallTime = DotaTime();
            return oldFunction(...args);
        }
        return NewTable();
    };
}




export function RecentlyTookDamage(bot: Unit, delta: number): boolean {
    return bot.WasRecentlyDamagedByAnyHero(delta) || bot.WasRecentlyDamagedByTower(delta) || bot.WasRecentlyDamagedByCreep(delta);
}




export function IsUnitWithName(unit: Unit, name: string): boolean {
    const result = string.find(unit.GetUnitName(), name);
    return result !== null;
}




export function IsBear(unit: Unit) {
    return IsUnitWithName(unit, "lone_druid_bear");
}




export function TimeNeedToHealHP(bot: Unit): number {
    const r = bot.GetHealthRegen();
    return r > 0 ? (bot.GetMaxHealth() - bot.GetHealth()) / r : Infinity;
}




export function TimeNeedToHealMP(bot: Unit): number {
    const r = bot.GetManaRegen();
    return r > 0 ? (bot.GetMaxMana() - bot.GetMana()) / r : Infinity;
}




export function HasAnyEffect(unit: Unit, ...effects: string[]) {
    return effects.some(effect => unit.HasModifier(effect));
}




export function IsModeTurbo(): boolean {
    for (const u of GetUnitList(UnitType.Allies)) {
        if (u && u.GetUnitName() === "npc_dota_courier" && u.GetCurrentMovementSpeed() === 1100) {
            return true;
        }
    }
    return false;
}




export function TrimString(str: string): string {
    return str.trim();
}




/**
 * Check if the bot has a critical spell with a cooldown greater than nDuration.
 * @param bot - The bot to check.
 * @param nDuration - The duration to check against.
 * @returns True if the bot has a critical spell with a cooldown greater than nDuration, false otherwise.
 */
export function HasCriticalSpellWithCooldown(bot: Unit, nDuration: number): boolean {
    // const cacheKey = "HasCriticalSpellWithCooldown" + bot.GetPlayerID() + nDuration;
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }
    const heroName = bot.GetUnitName();
    if (heroName in ImportantSpells) {
        const ability = bot.GetAbilityByName(ImportantSpells[heroName][0]);
        if (IsValidAbility(ability) && ability.GetCooldownTimeRemaining() > nDuration) {
            // SetCachedVars(cacheKey, true);
            return true;
        }
    }
    // SetCachedVars(cacheKey, false);
    return false;
}




/**
 * Get an item from the bot's active inventory.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to get.
 * @returns The item if found, null otherwise.
 */
export function GetItem(bot: Unit, itemName: string): Item | null {
    return GetItemFromCountedInventory(bot, itemName, 6);
}




/**
 * Get an item from the bot's full inventory.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to get.
 * @returns The item if found, null otherwise.
 */
export function GetItemFromFullInventory(bot: Unit, itemName: string): Item | null {
    return GetItemFromCountedInventory(bot, itemName, 16);
}




/**
 * Get an item from the bot's inventory with a specific total slots count.
 * @param bot - The bot to check.
 * @param itemName - The name of the item to get.
 * @param count - The number of slots in inventory to check.
 * @returns The item if found, null otherwise.
 */
export function GetItemFromCountedInventory(bot: Unit, itemName: string, count: number): Item | null {
    // const cacheKey = "GetItemFromCountedInventory" + bot.GetPlayerID() + itemName + count;
    // const cachedRes = GetCachedVars(cacheKey, 2);
    // if (cachedRes !== null) {
    //     return cachedRes;
    // }
    for (let i = 0; i < count; i++) {
        const item = bot.GetItemInSlot(i);

        if (item && item.GetName() === itemName) {
            // SetCachedVars(cacheKey, item);
            return item;
        }
    }
    // SetCachedVars(cacheKey, null);
    return null;
}




/**
 * Checks if the bot is currently thinking meaningful actions that would make
 * re-computing the Think() method unnecessary.
 * @param {Unit} bot - The bot unit to check
 * @param {number} thinkLess - The think less value, 0: fully think, 1 to 10: think less and less frequently.
 * @param {string} type - The type of action to check, "all": check all actions, "farm": check farm actions, etc.
 * @returns {boolean} True if the bot is doing something meaningful, false otherwise
 */
export function IsBotThinkingMeaningfulAction(bot: Unit, thinkLess: number = 1, type: string = "all"): boolean {
    // return false; // TODO: remove this when we have a better way to check if the bot is thinking meaningful actions
    if (thinkLess < 0) {
        thinkLess = 0;
    } else if (thinkLess > 10) {
        thinkLess = 10;
    }
    const cacheKey = "IsBotThinkingMeaningfulAction" + bot.GetPlayerID() + "_" + type;
    const cachedRes = GetCachedVars(cacheKey, 0.11 * thinkLess);
    if (cachedRes !== null) return cachedRes;

    // Check bot's current animation activity for meaningful actions
    try {
        if (meaningfulActivities.includes(bot.GetAnimActivity())) {
            SetCachedVars(cacheKey, true);
            return true;
        }
    } catch (error) {
        // If GetAnimActivity() fails, continue with other checks
        // This provides graceful fallback for cases where the method might not be available
    }

    // Check if bot has any active orders in the action queue
    const numQueuedActions = bot.NumQueuedActions();
    if (numQueuedActions > 0) {
        // Check for meaningful action types
        for (const index of $range(1, numQueuedActions)) {
            const actionType = bot.GetQueuedActionType(index);
            // Check if the action type indicates meaningful activity
            if (actionType !== BotActionType.None) {
                SetCachedVars(cacheKey, true);
                return true;
            }
        }
    }

    // Check if bot was recently attacking
    // const lastAttackTime = bot.GetLastAttackTime();
    // if (lastAttackTime > 0 && GameTime() - lastAttackTime < 0.3) {
    //     SetCachedVars(cacheKey, true);
    //     return true;
    // }

    // Check if bot has a current target
    // const currentTarget = bot.GetTarget();
    // if (currentTarget && IsValidUnit(currentTarget)) {
    //     SetCachedVars(cacheKey, true);
    //     return true;
    // }

    // if (bot.WasRecentlyDamagedByAnyHero(0.3)) {
    //     SetCachedVars(cacheKey, true);
    //     return true;
    // }

    // If none of the above conditions are met, the bot is not doing anything meaningful
    SetCachedVars(cacheKey, false);
    return false;
}

