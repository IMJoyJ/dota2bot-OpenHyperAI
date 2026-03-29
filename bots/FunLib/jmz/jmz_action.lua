-- jmz_func sub-module: jmz_action
return function(J)

local LastActionTime = {}
local botIdelStateTimeThreshold = 3 -- relatively big number in case it's things like casting/being casted with long durating spells, in base healing, or other unexpected stuff.
local deltaIdleDistance = 100
local botIdleStateTracker = { }


function J.HasQueuedAction( bot )
	if bot ~= GetBot()
	then
		return false
	end
	return bot:NumQueuedActions() > 0
end


function J.IsTryingtoUseAbility(bot)
	return bot:IsCastingAbility()
	or bot:IsUsingAbility()
	or bot:IsChanneling()
end


function J.CanNotUseAction( bot )
	return not bot:IsAlive()
			or J.HasQueuedAction( bot )
			or (bot:IsInvulnerable() and not bot:HasModifier('modifier_fountain_invulnerability') and not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff'))
			or bot:IsCastingAbility()
			or bot:IsUsingAbility()
			or bot:IsChanneling()
			or (bot:IsStunned() and not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff'))
			or bot:IsNightmared()
			or bot:HasModifier( 'modifier_ringmaster_the_box_buff' )
			or bot:HasModifier( 'modifier_item_forcestaff_active' )
			or bot:HasModifier( 'modifier_phantom_lancer_phantom_edge_boost' )
			or bot:HasModifier( 'modifier_tinker_rearm' )

end


function J.CanNotUseAbility( bot )
	return not bot:IsAlive()
			or J.HasQueuedAction( bot )
			or (bot:IsInvulnerable() and not bot:HasModifier('modifier_fountain_invulnerability') and not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff'))
			or bot:IsCastingAbility()
			or bot:IsUsingAbility()
			or bot:IsChanneling()
			or bot:IsSilenced()
			or (bot:IsStunned() and not bot:HasModifier('modifier_dazzle_nothl_projection_soul_debuff'))
			or bot:IsHexed()
			or bot:IsNightmared()
			or bot:HasModifier( 'modifier_ringmaster_the_box_buff' )
			or bot:HasModifier( "modifier_doom_bringer_doom" )
			or bot:HasModifier( 'modifier_item_forcestaff_active' )

end


function J.IsDisabled( npcTarget )

	if npcTarget:GetTeam() ~= GetTeam() and npcTarget:CanBeSeen()
	then
		return npcTarget:IsRooted()
				or npcTarget:IsStunned()
				or npcTarget:IsHexed()
				or npcTarget:IsNightmared()
				or J.IsTaunted( npcTarget )
	else

		if npcTarget:IsStunned() and J.GetRemainStunTime( npcTarget ) > 0.8
		then
			return true
		end

		if npcTarget:IsSilenced()
			and not npcTarget:HasModifier( "modifier_item_mask_of_madness_berserk" )
			and J.IsWithoutTarget( npcTarget )
		then
			return true
		end

		return npcTarget:IsRooted()
				or npcTarget:IsHexed()
				or npcTarget:IsNightmared()
				or J.IsTaunted( npcTarget )

	end

end



function J.IsTaunted( npcTarget )
	if not npcTarget:CanBeSeen() then
		return false
	end

	return npcTarget:HasModifier( "modifier_axe_berserkers_call" )
		or npcTarget:HasModifier( "modifier_legion_commander_duel" )
		or npcTarget:HasModifier( "modifier_winter_wyvern_winters_curse" )
		or npcTarget:HasModifier( "modifier_winter_wyvern_winters_curse_aura" )

end



function J.HasNotActionLast( nCD, nNumber )

	if LastActionTime[nNumber] == nil then LastActionTime[nNumber] = -90 end

	if DotaTime() > LastActionTime[nNumber] + nCD
	then
		LastActionTime[nNumber] = DotaTime()
		return true
	end

	return false

end


-- Check if any bot is stuck/idle for some time.

function J.CheckBotIdleState()
	if DotaTime() <= 0 then return false end

	local bot = GetBot()
	if not bot:IsAlive() then return false end

	local botName = bot:GetUnitName();
	local botId = bot:GetPlayerID();
	local botMode = bot:GetActiveMode();

	-- print('Checking bot '..botName..' idle state.')
	local botState = botIdleStateTracker[botId]
	if botState then
		if DotaTime() - botState.lastCheckTime >= botIdelStateTimeThreshold then
			local diffDistance = J.GetLocationToLocationDistance( botState.botLocation, bot:GetLocation())
			if not J.IsTryingtoUseAbility(bot)
			-- and not bot:WasRecentlyDamagedByAnyHero(3)
			and not J.IsAttacking(bot)
			and diffDistance <= deltaIdleDistance -- normally a bot gets stuck if it stopped moving.
			then
				botState.idleCount = botState.idleCount + 1
				if bot:GetCurrentActionType() == BOT_ACTION_TYPE_IDLE
				or botMode == BOT_MODE_ITEM
				or botMode == BOT_MODE_FARM then
					local nActions = bot:NumQueuedActions()
					if nActions > 0 then
						for i=1, nActions do
							local aType = bot:GetQueuedActionType(i)
							print('Bot '..botName.." has enqueued actions i="..i..", type="..tostring(aType))
						end
					end
					bot:Action_ClearActions(true);

					-- Should send it to most desire farming lane, if in laning or send it to desire push lane.
					local frontLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0);
					bot:ActionQueue_AttackMove(frontLoc)
					print('[ERROR] Relocating the idle bot: '..botName..'. Sending it to the lane# it was originally assigned: '..tostring(bot:GetAssignedLane()))
				else
					print('Bot '..botName..' is in idle state for unknown reasons. N/A.')
				end
				return true
			else
				botState.idleCount = 0
				-- print('Bot '..botName..' is not in idle state.')
			end

			botState.botLocation = bot:GetLocation()
			botState.lastCheckTime = DotaTime()
		end
	else
		local botIdleState = {
			botLocation = bot:GetLocation(),
			lastCheckTime = DotaTime(),
			idleCount = 0
		}
		botIdleStateTracker[botId] = botIdleState
	end
	return false
end

end
