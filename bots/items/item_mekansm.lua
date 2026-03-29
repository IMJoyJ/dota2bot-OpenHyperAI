local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList

	local nCastRange = 1200
	local sCastType = 'none'
	local hEffectTarget = nil
	local sCastMotive = nil


	local hAllyList = J.GetAllyList( bot, nCastRange )
	for _, npcAlly in pairs( hAllyList ) 
	do
		if npcAlly ~= nil and npcAlly:IsAlive()
			and J.GetHP( npcAlly ) < 0.45
			and #hNearbyEnemyHeroList > 0
		then
			hEffectTarget = npcAlly
			sCastMotive = '治疗队友'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	local needHPCount = 0
	for _, npcAlly in pairs( hAllyList )
	do
		if npcAlly ~= nil
			and npcAlly:GetMaxHealth()- npcAlly:GetHealth() > 400
		then
			needHPCount = needHPCount + 1

			if needHPCount >= 2 and npcAlly:GetHealth() / npcAlly:GetMaxHealth() < 0.55
			then
				hEffectTarget = npcAlly
				sCastMotive = '治疗二队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end

			if needHPCount >= 3
			then
				hEffectTarget = npcAlly
				sCastMotive = '治疗多个队友:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end
	end

	if bot:GetHealth() / bot:GetMaxHealth() < 0.5
		or bot:IsSilenced()
		or bot:IsRooted()
		or bot:HasModifier( "modifier_item_urn_damage" )
		or bot:HasModifier( "modifier_item_spirit_vessel_damage" )
	then
		hEffectTarget = bot
		sCastMotive = '治疗自己:'..J.Chat.GetNormName( hEffectTarget )
		return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
	end

	return BOT_ACTION_DESIRE_NONE
end

return X
