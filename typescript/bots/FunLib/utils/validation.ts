// utils/validation.ts - Auto-generated sub-module

import { Ability, Unit } from "bots/ts_libs/dota";
import { RecentlyTookDamage } from "bots/FunLib/utils/misc";


/**
 * Check if the target is a valid unit. can be hero, creep, or building.
 * @param target - The unit to check.
 * @returns True if the target is a valid unit, false otherwise.
 */
export function IsValidUnit(target: Unit | null): boolean {
    if (target === null) {
        return false;
    }
    return !target.IsNull() && target.CanBeSeen() && target.IsAlive() && !target.IsInvulnerable();
}




/**
 * Check if the target is a valid hero.
 * @param target - The unit to check.
 * @returns True if the target is a valid hero, false otherwise.
 */
export function IsValidHero(target: Unit | null): boolean {
    if (target === null) {
        return false;
    }
    return IsValidUnit(target) && target.IsHero();
}




/**
 * Check if the target is a valid creep.
 * @param target - The unit to check.
 * @returns True if the target is a valid creep, false otherwise.
 */
export function IsValidCreep(target: Unit | null): boolean {
    if (target === null) {
        return false;
    }
    return IsValidUnit(target) && target.GetHealth() < 5000 && !target.IsHero() && (GetBot().GetLevel() > 9 || !target.IsAncientCreep());
}




/**
 * Check if the target is a valid building.
 * @param target - The unit to check.
 * @returns True if the target is a valid building, false otherwise.
 */
export function IsValidBuilding(target: Unit | null): boolean {
    if (target === null) {
        return false;
    }
    return IsValidUnit(target) && target.IsBuilding();
}




export function IsWithoutSpellShield(npcEnemy: Unit): boolean {
    return (
        !npcEnemy.HasModifier("modifier_item_sphere_target") &&
        !npcEnemy.HasModifier("modifier_antimage_spell_shield") &&
        !npcEnemy.HasModifier("modifier_item_lotus_orb_active")
    );
}




/**
 * Check if the unit is truely invisible.
 * @param unit - The unit to check.
 * @returns True if the unit is truely invisible, false otherwise.
 */
export function IsTruelyInvisible(unit: Unit): boolean {
    return unit.IsInvisible() && !unit.HasModifier("modifier_item_dustofappearance") && !RecentlyTookDamage(unit, 1.5); // use 1.5s because invisibility may have delayed effect.
}




/**
 * Check if the unit has a modifier containing a specific name.
 * @param unit - The unit to check.
 * @param name - The name to check.
 * @returns True if the unit has a modifier containing the name, false otherwise.
 */
export function HasModifierContainsName(unit: Unit, name: string): boolean {
    if (!IsValidUnit(unit)) {
        return false;
    }
    const modifierCount = unit.NumModifiers();
    for (let i = 0; i < modifierCount; i++) {
        const modifierName = unit.GetModifierName(i);
        if (modifierName.indexOf(name) > -1) {
            return true;
        }
    }
    return false;
}




/**
 * Check if the ability is valid.
 * @param ability - The ability to check.
 * @returns True if the ability is valid, false otherwise.
 */
export function IsValidAbility(ability: Ability): boolean {
    if (ability === null || ability.IsNull() || ability.GetName() === "" || ability.IsHidden() || !ability.IsTrained() || !ability.IsActivated()) {
        return false;
    }
    return true;
}


