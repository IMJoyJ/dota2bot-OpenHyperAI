--风之杖
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')
local Common = require(GetScriptDirectory()..'/items/_common')

local X = {}

function X.ConsiderItemDesire(bot, hItem, ctx)
	local botTarget = ctx.botTarget
	local aetherRange = ctx.aetherRange
	local hNearbyEnemyHeroList = ctx.hNearbyEnemyHeroList
	local botName = ctx.botName


	--return X.ConsiderItemDesire["item_cyclone"]( hItem )
	-- [inlined from item_cyclone]

	local nCastRange = 650 + aetherRange
	local sCastType = 'unit'
	local hEffectTarget = nil
	local sCastMotive = nil
	local nInRangeEnmyList = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	if bot:HasModifier('modifier_nyx_assassin_vendetta')
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.IsValid( botTarget )
		and J.CanCastOnNonMagicImmune( botTarget )
		and Common.IsWithoutSpellShield( botTarget )
		and J.IsInRange( bot, botTarget, nCastRange + 200 )
	then
		---- Invoker combo with item_cyclone ----
		if botName == "npc_dota_hero_invoker" and J.IsGoingOnSomeone(bot) then
			if J.IsValidHero(botTarget)
			and not J.IsSuspiciousIllusion(botTarget)
			and J.GetMP(bot) > 0.5 then
				-- Should check if the target is already stuned etc.
				hEffectTarget = botTarget
				sCastMotive = '预设连招:'..J.Chat.GetNormName( hEffectTarget )
				return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
			end
		end

		-- 别帮电脑减伤害/解状态
		if botTarget:HasModifier( 'modifier_invoker_cold_snap_freeze' ) 
		or botTarget:HasModifier('modifier_invoker_cold_snap') 
		or botTarget:HasModifier('modifier_invoker_chaos_meteor_burn') then
			return BOT_ACTION_DESIRE_NONE
		end

		---- Above for Invoker combo with item_cyclone ----


		if botTarget:HasModifier( 'modifier_teleporting' )
			 or botTarget:HasModifier( 'modifier_abaddon_borrowed_time' )
			 or botTarget:HasModifier( "modifier_ursa_enrage" )
			 or botTarget:HasModifier( "modifier_item_satanic_unholy" )
			 or botTarget:IsChanneling()
		then
			hEffectTarget = botTarget
			sCastMotive = '驱散Buff:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.GetHP( botTarget ) > 0.49 and J.IsCastingUltimateAbility( botTarget )
		then
			hEffectTarget = botTarget
			sCastMotive = '打断大招:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsRunning( botTarget ) and botTarget:GetCurrentMovementSpeed() > 440
		then
			hEffectTarget = botTarget
			sCastMotive = '阻止逃跑:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	if J.CanCastOnNonMagicImmune( bot )
		and #hNearbyEnemyHeroList > 0
	then
		if J.GetHP(bot) < 0.2 and bot:WasRecentlyDamagedByAnyHero( 3.0 )
		then
			hEffectTarget = bot
			sCastMotive = '撤退:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if bot:IsRooted()
			or ( bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and bot:IsSilenced() )
		then
			hEffectTarget = bot
			sCastMotive = '解缠绕:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end

		if J.IsUnitTargetProjectileIncoming( bot, 800 )
		then
			hEffectTarget = bot
			sCastMotive = '防御弹道:'..J.Chat.GetNormName( hEffectTarget )
			return BOT_ACTION_DESIRE_HIGH, hEffectTarget, sCastType, sCastMotive
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

return X
