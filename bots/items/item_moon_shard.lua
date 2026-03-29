--银月
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Utils = require(GetScriptDirectory()..'/FunLib/utils')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	if bot:GetNetWorth() < 18000 or Utils.CountBackpackEmptySpace(bot) >= 3
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = 2000
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil


	if not bot:HasModifier( "modifier_item_moon_shard_consumed" )
	then
		if bot.moonSharedTime == nil --添加使用延迟避免吃得过快以为没出
		then
			bot.moonSharedTime = DotaTime()
		elseif bot.moonSharedTime < DotaTime() - 2.0
		then
			bot.moonSharedTime = nil
			hEffectTarget = bot
			sCastMotive = "自己吃"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local targetMember = nil
	local targetDamage = 0
	for i = 1, #GetTeamPlayers( GetTeam() )
	do
		local member = GetTeamMember( i )
		if member ~= nil and member:IsAlive()
		 and member:GetAttackDamage() > targetDamage
		 and not member:HasModifier( "modifier_item_moon_shard_consumed" )
		then
			targetMember = member
			targetDamage = member:GetAttackDamage()
		end
	end
	if targetMember ~= nil
	then
		if bot.moonSharedTime == nil
		then
			bot.moonSharedTime = DotaTime()
		elseif bot.moonSharedTime < DotaTime() - 3.0
		then
			bot.moonSharedTime = nil
			hEffectTarget = targetMember
			sCastMotive = "给队友"
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end


	return BOT_ACTION_DESIRE_NONE

end

return X
