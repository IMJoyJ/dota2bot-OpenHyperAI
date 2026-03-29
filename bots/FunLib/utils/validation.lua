--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
local ____exports = {}
local ____misc = require("bots.FunLib.utils.misc")
local RecentlyTookDamage = ____misc.RecentlyTookDamage
--- Check if the target is a valid unit. can be hero, creep, or building.
-- 
-- @param target - The unit to check.
-- @returns True if the target is a valid unit, false otherwise.
function ____exports.IsValidUnit(target)
    if target == nil then
        return false
    end
    return not target:IsNull() and target:CanBeSeen() and target:IsAlive() and not target:IsInvulnerable()
end
--- Check if the target is a valid hero.
-- 
-- @param target - The unit to check.
-- @returns True if the target is a valid hero, false otherwise.
function ____exports.IsValidHero(target)
    if target == nil then
        return false
    end
    return ____exports.IsValidUnit(target) and target:IsHero()
end
--- Check if the target is a valid creep.
-- 
-- @param target - The unit to check.
-- @returns True if the target is a valid creep, false otherwise.
function ____exports.IsValidCreep(target)
    if target == nil then
        return false
    end
    return ____exports.IsValidUnit(target) and target:GetHealth() < 5000 and not target:IsHero() and (GetBot():GetLevel() > 9 or not target:IsAncientCreep())
end
--- Check if the target is a valid building.
-- 
-- @param target - The unit to check.
-- @returns True if the target is a valid building, false otherwise.
function ____exports.IsValidBuilding(target)
    if target == nil then
        return false
    end
    return ____exports.IsValidUnit(target) and target:IsBuilding()
end
function ____exports.IsWithoutSpellShield(npcEnemy)
    return not npcEnemy:HasModifier("modifier_item_sphere_target") and not npcEnemy:HasModifier("modifier_antimage_spell_shield") and not npcEnemy:HasModifier("modifier_item_lotus_orb_active")
end
--- Check if the unit is truely invisible.
-- 
-- @param unit - The unit to check.
-- @returns True if the unit is truely invisible, false otherwise.
function ____exports.IsTruelyInvisible(unit)
    return unit:IsInvisible() and not unit:HasModifier("modifier_item_dustofappearance") and not RecentlyTookDamage(unit, 1.5)
end
--- Check if the unit has a modifier containing a specific name.
-- 
-- @param unit - The unit to check.
-- @param name - The name to check.
-- @returns True if the unit has a modifier containing the name, false otherwise.
function ____exports.HasModifierContainsName(unit, name)
    if not ____exports.IsValidUnit(unit) then
        return false
    end
    local modifierCount = unit:NumModifiers()
    do
        local i = 0
        while i < modifierCount do
            local modifierName = unit:GetModifierName(i)
            if (string.find(modifierName, name, nil, true) or 0) - 1 > -1 then
                return true
            end
            i = i + 1
        end
    end
    return false
end
--- Check if the ability is valid.
-- 
-- @param ability - The ability to check.
-- @returns True if the ability is valid, false otherwise.
function ____exports.IsValidAbility(ability)
    if ability == nil or ability:IsNull() or ability:GetName() == "" or ability:IsHidden() or not ability:IsTrained() or not ability:IsActivated() then
        return false
    end
    return true
end
return ____exports
