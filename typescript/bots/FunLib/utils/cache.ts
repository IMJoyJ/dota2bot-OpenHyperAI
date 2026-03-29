// utils/cache.ts - Auto-generated sub-module

import { GameStates, CachedVarsCleanTime } from "bots/FunLib/utils/constants";


export function SetCachedVars(key: string, value: any) {
    // Not helpful for now. Disable it.
    // return;

    if (!GameStates.cachedVars) {
        GameStates.cachedVars = {};
    }
    GameStates.cachedVars[key] = value;
    GameStates.cachedVars[`${key}-Time`] = DotaTime();
}




export function GetCachedVars(key: string, withinTime: number) {
    // Not helpful for now. Disable it.
    // return null;

    if (!GameStates.cachedVars || !GameStates.cachedVars[key]) {
        return null;
    }
    if (DotaTime() - GameStates.cachedVars[`${key}-Time`] <= withinTime) {
        return GameStates.cachedVars[key];
    }
    return null;
}




export function CleanupCachedVars() {
    // Not helpful for now. Disable it.
    return;

    if (!GameStates.cachedVars) {
        return;
    }
    for (const key in GameStates.cachedVars) {
        if (key.endsWith("-Time")) {
            const originalKey = key.slice(0, -5);
            if (DotaTime() - GameStates.cachedVars[key] > CachedVarsCleanTime) {
                delete GameStates.cachedVars[originalKey];
                delete GameStates.cachedVars[key];
            }
        }
    }
}


