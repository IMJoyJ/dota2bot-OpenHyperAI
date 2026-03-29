--天堂
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange


	local nCastRange = 700 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )


	local targetHero = nil
	local targetHeroDamage = 0
	for _, npcEnemy in pairs( nInRangeEnmyList )
	do
		if J.IsValidHero( npcEnemy )
			and not npcEnemy:IsDisarmed()
			and not J.IsDisabled( npcEnemy )
			and J.CanCastOnNonMagicImmune( npcEnemy )
			and Common.IsWithoutSpellShield( npcEnemy )
			and npcEnemy:GetAttackTarget() ~= nil
			and ( npcEnemy:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT or npcEnemy:GetAttackDamage() > 180 )
		then
			local nEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL )
			if ( nEnemyDamage > targetHeroDamage )
			then
				targetHeroDamage = nEnemyDamage
				targetHero = npcEnemy
			end
		end
	end
	if targetHero ~= nil
	then
		hEffectTarget = targetHero
		sCastMotive = '缴械敌人:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN )
	then
		local botTarget = bot:GetAttackTarget()
		if J.IsRoshan( botTarget )
			and not J.IsDisabled( botTarget )
			and not botTarget:IsDisarmed()
		then
			hEffectTarget = botTarget
			sCastMotive = '缴械肉山'
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
