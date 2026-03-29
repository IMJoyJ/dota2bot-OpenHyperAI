-- jmz_func sub-module: jmz_projectile
return function(J)

local sIgnoreAbilityIndex = {
	["antimage_blink"] = true,
	["arc_warden_magnetic_field"] = true,
	["arc_warden_spark_wraith"] = true,
	["arc_warden_tempest_double"] = true,
	["chaos_knight_phantasm"] = true,
	["clinkz_burning_army"] = true,
	["death_prophet_exorcism"] = true,
	["dragon_knight_elder_dragon_form"] = true,
	["juggernaut_healing_ward"] = true,
	["necrolyte_death_pulse"] = true,
	["necrolyte_sadist"] = true,
	["omniknight_guardian_angel"] = true,
	["phantom_assassin_blur"] = true,
	["pugna_nether_ward"] = true,
	["skeleton_king_mortal_strike"] = true,
	["sven_warcry"] = true,
	["sven_gods_strength"] = true,
	["templar_assassin_refraction"] = true,
	["templar_assassin_psionic_trap"] = true,
	["windrunner_windrun"] = true,
	["witch_doctor_voodoo_restoration"] = true,
}



--可躲避敌方非攻击弹道
function J.IsProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_dodgeable
			and not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil or p.caster:GetTeam() ~= GetTeam() )
			and ( p.ability ~= nil
					and not J.IsOnlyProjectileSpell( p.ability:GetName() )
					and ( p.ability:GetName() ~= "medusa_mystic_snake"
							or p.caster == nil
							or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
		then
			return true
		end
	end

	return false

end



--可反弹敌方非攻击弹道
function J.IsUnitTargetProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil
				 or ( p.caster:GetTeam() ~= bot:GetTeam()
					 and p.caster:IsHero()
					 and p.caster:GetUnitName() ~= "npc_dota_hero_antimage"
					 and p.caster:GetUnitName() ~= "npc_dota_hero_templar_assassin" ) )
			and ( p.ability ~= nil
				 and ( p.ability:GetName() ~= "medusa_mystic_snake"
						or p.caster == nil
						or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
			and ( p.ability:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
				 or not J.IsOnlyProjectileSpell( p.ability:GetName() ) )
		then
			return true
		end
	end

	return false

end



--将被眩晕的弹道
function J.IsStunProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and p.ability ~= nil
			and J.IsStunProjectileSpell( p.ability:GetName() )
		then
			return true
		end
	end

	return false

end



--攻击弹道
function J.IsAttackProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
		then
			return true
		end
	end

	return false

end



--非攻击敌方弹道
function J.IsNotAttackProjectileIncoming( bot, range )

	local incProj = bot:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if not p.is_attack
			and GetUnitToLocationDistance( bot, p.location ) < range
			and ( p.caster == nil or p.caster:GetTeam() ~= bot:GetTeam() )
			and ( p.ability ~= nil
					and ( p.ability:GetName() ~= "medusa_mystic_snake"
							or p.caster == nil
							or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) )
		then
			return true
		end
	end

	return false

end



--以下可少算但不可多算
function J.GetAttackProDelayTime( bot, nCreep )
	if nCreep == nil then
		print('[ERROR] nil creep target')
		print("Stack Trace:", debug.traceback())
		return 0
	end

	local botName = bot:GetUnitName()
	local botAttackRange = bot:GetAttackRange()
	local botAttackPoint = bot:GetAttackPoint()
	local botAttackSpeed = bot:GetAttackSpeed()
	local botProSpeed = bot:GetAttackProjectileSpeed()
	local botMoveSpeed = bot:GetCurrentMovementSpeed()
	local botAttackPointTime = botAttackPoint / botAttackSpeed
	local botAttackIdleTime = bot:GetSecondsPerAttack() - botAttackPointTime
	local nLastAttackRemainIdleTime = 0

	if GameTime() - bot:GetLastAttackTime() < botAttackIdleTime
	then
		nLastAttackRemainIdleTime = botAttackIdleTime - ( GameTime() - bot:GetLastAttackTime() )
	end

	local nAttackDamageDelayTime = botAttackPointTime + nLastAttackRemainIdleTime * 0.98
	local nDist = GetUnitToUnitDistance( bot, nCreep )

	if bot:CanBeSeen()
		and bot:GetAttackTarget() == nCreep
		and bot:GetAnimActivity() == 1503
		and bot:GetAnimCycle() < botAttackPoint
	then
		nAttackDamageDelayTime = 0.9 * ( botAttackPoint - bot:GetAnimCycle() ) / botAttackSpeed
	end

	if botAttackRange > 320 or botName == "npc_dota_hero_templar_assassin"
	then

		local ignoreDist = 39
		if bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT then ignoreDist = 59 end

		local projectMoveDist = nDist - ignoreDist

		if projectMoveDist < 0 then projectMoveDist = 0 end

		if projectMoveDist > botAttackRange then projectMoveDist = botAttackRange - 32 end

		nAttackDamageDelayTime = nAttackDamageDelayTime + projectMoveDist / botProSpeed

		if nDist > botAttackRange + ignoreDist / 1.2 and botName ~= "npc_dota_hero_sniper"
		then
			nAttackDamageDelayTime = nAttackDamageDelayTime + ( nDist - botAttackRange - ignoreDist / 1.2 ) / botMoveSpeed
		end

	end

	if botAttackRange < 326
		and nDist > botAttackRange + 50
		and botName ~= "npc_dota_hero_templar_assassin"
	then
		nAttackDamageDelayTime = nAttackDamageDelayTime + ( nDist - botAttackRange - 50 ) / botMoveSpeed
	end

	return nAttackDamageDelayTime

end



--当前点 * 攻击间隔 / 1.0 = 当前时
function J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )

	local bot = GetBot()
	local botLV = bot:GetLevel()
	local gameTime = GameTime()
	local nDamage = 0
	local othersBeEnemy = true

	if nUnit:GetTeam() ~= bot:GetTeam() then othersBeEnemy = false end

	local nCreeps = bot:GetNearbyLaneCreeps( 1600, othersBeEnemy )
	for _, creep in pairs( nCreeps )
	do
		if creep:CanBeSeen()
			and creep:GetAttackTarget() == nUnit
			and creep:GetAnimActivity() == 1503
			and creep:GetLastAttackTime() < gameTime - 0.2
		then
			local attackPoint	= creep:GetAttackPoint()
			local animCycle	 = creep:GetAnimCycle()
			local attackPerTime = creep:GetSecondsPerAttack()

			if J.IsKeyWordUnit( 'melee', creep )
				and animCycle < attackPoint
				and ( attackPoint - animCycle ) * attackPerTime < nTime * ( 0.99 - botLV / 300 )
			then
				nDamage = nDamage + creep:GetAttackDamage() * 1
			end

			if J.IsKeyWordUnit( 'ranged', creep )
				and animCycle < attackPoint
			then
				local nDist = GetUnitToUnitDistance( creep, nUnit ) - 22
				local nProjectSpeed = creep:GetAttackProjectileSpeed()
				local nProjectTime = nDist / ( nProjectSpeed + 1 )
				if ( attackPoint - animCycle ) * attackPerTime + nProjectTime < nTime * ( 0.98 - botLV / 200 )
				then
					nDamage = nDamage + creep:GetAttackDamage() * 1
				end
			end

			if J.IsKeyWordUnit( 'siege', creep )
				and animCycle < 0.292 --0.285
			then
				local nDist = GetUnitToUnitDistance( creep, nUnit ) - 28
				local nProjectSpeed = creep:GetAttackProjectileSpeed()
				local nProjectTime = nDist / ( nProjectSpeed + 1 )
				if ( 0.292 - animCycle ) * 0.699 / 0.292 + nProjectTime < nTime * ( 0.9 - botLV / 150 )
				then
					nDamage = nDamage + creep:GetAttackDamage() * 1
				end
			end

		end
	end

	return nUnit:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )

end



function J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime )

	local nDamage = 0
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack
			and p.caster ~= nil
		then
			local nProjectSpeed = p.caster:GetAttackProjectileSpeed()
			if p.caster:IsTower() then nProjectSpeed = nProjectSpeed * 0.93 end
			local nProjectDist = nProjectSpeed * nTime * 0.95
			local nDistance	 = GetUnitToLocationDistance( nUnit, p.location )
			if nProjectDist > nDistance * 1.02
			then
				nDamage = nDamage + p.caster:GetAttackDamage() * 1
			end
		end
	end

	return nUnit:GetActualIncomingDamage( nDamage, DAMAGE_TYPE_PHYSICAL )

end



function J.GetTotalAttackWillRealDamage( nUnit, nTime )

	 return J.GetCreepAttackProjectileWillRealDamage( nUnit, nTime ) + J.GetCreepAttackActivityWillRealDamage( nUnit, nTime )

end



function J.GetAttackProjectileDamageByRange( nUnit, nRadius )

	local nDamage = 0
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _, p in pairs( incProj )
	do
		if p.is_attack and p.caster ~= nil
			and GetUnitToLocationDistance( nUnit, p.location ) < nRadius
		then
			nDamage = nDamage + p.caster:GetAttackDamage() * 1
		end
	end

	return nDamage

end

function J.DidEnemyCastAbility()
	local bot = GetBot()
	local nEnemyHeroes = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)

	for _, npcEnemy in pairs(nEnemyHeroes)
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		and npcEnemy:IsFacingLocation(bot:GetLocation(), 30)
		and (npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility())
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility()
			if nAbility ~= nil
			then
				local nAbilityBehavior = nAbility:GetBehavior()
				local sAbilityName = nAbility:GetName()

				if nAbilityBehavior ~= ABILITY_BEHAVIOR_UNIT_TARGET
				and (npcEnemy:IsBot() or npcEnemy:GetLevel() >= 5)
				and not sIgnoreAbilityIndex[sAbilityName]
				then
					return true
				end

				if nAbilityBehavior == ABILITY_BEHAVIOR_UNIT_TARGET
				and npcEnemy:GetLevel() >= 6
				and not npcEnemy:IsBot()
				and not J.IsAllyUnitSpell(sAbilityName)
				and (not J.IsProjectileUnitSpell(sAbilityName) or J.IsInRange(bot, npcEnemy, 400))
				then
					return true
				end
			end
		end
	end

	return false
end

end
