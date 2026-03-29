--大根
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange


	local nCastRange = hItem:GetCastRange() + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange + 100, true, BOT_MODE_NONE )
	local nDamage = hItem:GetSpecialValueInt( "damage" )

	if bot:HasModifier('modifier_nyx_assassin_vendetta')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	--击杀
	for _, npcEnemy in pairs( nInRangeEnmyList )
	do
		if J.IsValidHero( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and Common.IsWithoutSpellShield( npcEnemy )
			and J.CanKillTarget( npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL )
		then
			hEffectTarget = npcEnemy
			sCastMotive = "击杀:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	--攻击
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and Common.IsWithoutSpellShield( botTarget )
			and J.IsInRange( bot, botTarget, nCastRange )
		then
			hEffectTarget = botTarget
			sCastMotive = "进攻:"..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
