--莲花
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local aetherRange = ctx.aetherRange


	local nCastRange = 1000 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nNearAllyList = J.GetNearbyHeroes(bot, nCastRange, false, BOT_MODE_NONE )


	for _, npcAlly in pairs( nNearAllyList )
	do
		if J.IsValid( npcAlly )
			and not npcAlly:IsIllusion()
			and not npcAlly:IsMagicImmune()
			and not npcAlly:IsInvulnerable()
			and not npcAlly:HasModifier( 'modifier_item_lotus_orb_active' )
			and not npcAlly:HasModifier( 'modifier_antimage_spell_shield' )
		then

			if J.IsUnitTargetProjectileIncoming( npcAlly, 800 )
			then
				hEffectTarget = npcAlly
				sCastMotive = '反弹弹道'
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if npcAlly:IsRooted()
				or ( npcAlly:IsSilenced() and not npcAlly:HasModifier( "modifier_item_mask_of_madness_berserk" ) )
				or ( npcAlly:IsDisarmed() and not npcAlly:HasModifier( "modifier_oracle_fates_edict" ) )
			then
				hEffectTarget = npcAlly
				sCastMotive = '驱散队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if J.IsWillBeCastUnitTargetSpell( npcAlly, 1200 )
			then
				hEffectTarget = npcAlly
				sCastMotive = '给队友反弹技能:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
