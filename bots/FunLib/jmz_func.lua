local J = {}

local bDebugMode = ( 1 == 10 )
local tAllyIDList = GetTeamPlayers( GetTeam() )
local tAllyHeroList = {}
local tAllyHumanList = {}

local RadiantFountain = Vector( -6619, -6336, 384 )
local DireFountain = Vector( 6928, 6372, 392 )
local RadiantTormentorLoc = Vector(7499, -7847, 256)
local DireTormentorLoc = Vector(-7229, 7933, 256)

local fKeepManaPercent = 0.39

for i, id in pairs( tAllyIDList )
do

	local bHuman = not IsPlayerBot( id )
	local hHero = GetTeamMember( i )

	if hHero ~= nil
	then
		if bHuman then table.insert( tAllyHumanList, hHero ) end
		table.insert( tAllyHeroList, hHero )
	end

end

J.Site = require( GetScriptDirectory()..'/FunLib/aba_site' )
J.Item = require( GetScriptDirectory()..'/FunLib/aba_item' )
J.Buff = require( GetScriptDirectory()..'/FunLib/aba_buff' )
J.Role = require( GetScriptDirectory()..'/FunLib/aba_role' )
J.Skill = require( GetScriptDirectory()..'/FunLib/aba_skill' )
J.Chat = require( GetScriptDirectory()..'/FunLib/aba_chat' )
J.Utils = require( GetScriptDirectory()..'/FunLib/utils' )
J.Customize = require(GetScriptDirectory()..'/FunLib/custom_loader')


-- Load sub-modules
local submodules = {
	'jmz_init',
	'jmz_action',
	'jmz_unit_query',
	'jmz_targeting',
	'jmz_combat',
	'jmz_cast',
	'jmz_projectile',
	'jmz_mode',
	'jmz_team',
	'jmz_geo',
	'jmz_modifier',
	'jmz_illusion',
	'jmz_validate',
	'jmz_status',
	'jmz_item',
	'jmz_between',
	'jmz_util',
}
for _, name in ipairs(submodules) do
	require(GetScriptDirectory()..'/FunLib/jmz/'..name)(J)
end

return J
