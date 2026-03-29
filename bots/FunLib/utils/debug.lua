--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ObjectEntries(obj)
    local result = {}
    local len = 0
    for key in pairs(obj) do
        len = len + 1
        result[len] = {key, obj[key]}
    end
    return result
end
-- End of Lua Library inline imports
local ____exports = {}
local ____dota = require("bots.ts_libs.dota.index")
local UnitType = ____dota.UnitType
local ____http_req = require("bots.ts_libs.utils.http_utils.http_req")
local Request = ____http_req.Request
local ____validation = require("bots.FunLib.utils.validation")
local IsValidHero = ____validation.IsValidHero
local ____misc = require("bots.FunLib.utils.misc")
local GetLocationToLocationDistance = ____misc.GetLocationToLocationDistance
function ____exports.PrintTable(tbl, indent)
    if indent == nil then
        indent = 0
    end
    if tbl == nil then
        print("nil")
        return
    end
    for ____, ____value in ipairs(__TS__ObjectEntries(tbl)) do
        local key = ____value[1]
        local value = ____value[2]
        local prefix = (string.rep("  ", indent) .. tostring(key)) .. ": "
        if type(value) == "table" then
            if indent < 3 then
                print(prefix)
                ____exports.PrintTable(value, indent + 1)
            else
                print(prefix .. "[WARN] Table has deep nested tables in it, stop printing more nested tables.")
            end
        else
            print(prefix .. tostring(value))
        end
    end
end
function ____exports.PrintUnitModifiers(unit)
    local modifierCount = unit:NumModifiers()
    do
        local i = 0
        while i < modifierCount do
            local modifierName = unit:GetModifierName(i)
            local stackCount = unit:GetModifierStackCount(i)
            print((((("Unit " .. unit:GetUnitName()) .. " has modifier ") .. modifierName) .. " with stack count ") .. tostring(stackCount))
            i = i + 1
        end
    end
end
function ____exports.PrintPings(pingTimeGap)
    local listPings = {}
    for ____, playerId in ipairs(GetTeamPlayers(GetTeam())) do
        do
            local __continue13
            repeat
                local allyHero = GetTeamMember(playerId)
                if allyHero == nil or allyHero:IsIllusion() then
                    __continue13 = true
                    break
                end
                local ping = allyHero:GetMostRecentPing()
                if ping.time ~= 0 and GameTime() - ping.time < pingTimeGap then
                    listPings[#listPings + 1] = ping
                    for ____, unit in ipairs(GetUnitList(UnitType.All)) do
                        if IsValidHero(unit) and GetLocationToLocationDistance(
                            ping.location,
                            unit:GetLocation()
                        ) < 400 then
                            print(unit:GetUnitName())
                            ____exports.PrintUnitModifiers(unit)
                        end
                    end
                end
                __continue13 = true
            until true
            if not __continue13 then
                break
            end
        end
    end
    if #listPings > 0 then
        ____exports.PrintTable(listPings)
    end
end
function ____exports.PrintAllAbilities(unit)
    print("Get all abilities of bot " .. unit:GetUnitName())
    for index = 0, 10 do
        local ability = unit:GetAbilityInSlot(index)
        if ability and not ability:IsNull() then
            print((("Ability At Index " .. tostring(index)) .. ": ") .. ability:GetName())
        else
            print(("Ability At Index " .. tostring(index)) .. " is nil")
        end
    end
end
function ____exports.QueryCounters(heroId)
    print("heroId=" .. tostring(heroId))
    Request:RawGetRequest(
        ("https://api.opendota.com/api/heroes/" .. tostring(heroId)) .. "/matchups",
        function(res)
            ____exports.PrintTable(res)
        end
    )
end
function ____exports.InitiStats()
    Request:GetUUID(function(uuid)
        print("uuid=" .. uuid)
    end)
end
return ____exports
