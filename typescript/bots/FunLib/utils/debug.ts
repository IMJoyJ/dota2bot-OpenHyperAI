// utils/debug.ts - Auto-generated sub-module

import { Unit, UnitType } from "bots/ts_libs/dota";
import { Request } from "bots/ts_libs/utils/http_utils/http_req";
import { IsValidHero } from "bots/FunLib/utils/validation";
import { GetLocationToLocationDistance } from "bots/FunLib/utils/misc";


export function PrintTable(tbl: any | null, indent: number = 0) {
    if (tbl === null) {
        print("nil");
        return;
    }

    for (const [key, value] of Object.entries(tbl)) {
        const prefix = string.rep("  ", indent) + key + ": ";
        if (type(value) == "table") {
            if (indent < 3) {
                print(prefix);
                PrintTable(value, indent + 1);
            } else {
                print(prefix + "[WARN] Table has deep nested tables in it, stop printing more nested tables.");
            }
        } else {
            print(prefix + value);
        }
    }
}




export function PrintUnitModifiers(unit: Unit) {
    const modifierCount = unit.NumModifiers();
    for (let i = 0; i < modifierCount; i++) {
        const modifierName = unit.GetModifierName(i);
        const stackCount = unit.GetModifierStackCount(i);
        print(`Unit ${unit.GetUnitName()} has modifier ${modifierName} with stack count ${stackCount}`);
    }
}




export function PrintPings(pingTimeGap: number): void {
    const listPings = [];

    // for (const [_, zone] of GetAvoidanceZones().entries()) {
    //     PrintTable(zone);
    // }

    for (const playerId of GetTeamPlayers(GetTeam())) {
        const allyHero = GetTeamMember(playerId);
        if (allyHero === null || allyHero.IsIllusion()) {
            continue;
        }
        const ping = allyHero.GetMostRecentPing();
        if (ping.time !== 0 && GameTime() - ping.time < pingTimeGap) {
            listPings.push(ping);

            // print units and modifiers.
            for (const unit of GetUnitList(UnitType.All)) {
                if (IsValidHero(unit) && GetLocationToLocationDistance(ping.location, unit.GetLocation()) < 400) {
                    print(unit.GetUnitName());
                    PrintUnitModifiers(unit);
                }
            }
        }
    }
    if (listPings.length > 0) {
        PrintTable(listPings);
    }
}




export function PrintAllAbilities(unit: Unit) {
    print(`Get all abilities of bot ${unit.GetUnitName()}`);
    for (let index of $range(0, 10)) {
        const ability = unit.GetAbilityInSlot(index);
        if (ability && !ability.IsNull()) {
            print(`Ability At Index ${index}: ${ability.GetName()}`);
        } else {
            print(`Ability At Index ${index} is nil`);
        }
    }
}




// TODO: Just trying. Does not work.
export function QueryCounters(heroId: number) {
    print("heroId=" + heroId);
    Request.RawGetRequest(`https://api.opendota.com/api/heroes/${heroId}/matchups`, function (res) {
        PrintTable(res);
    });
}


export function InitiStats() {
    Request.GetUUID(function (uuid) {
        print("uuid=" + uuid);
    });
}


