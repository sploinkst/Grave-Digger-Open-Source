--!strict
--!optimize 2

local UserInputService          = game:GetService("UserInputService")
local ReplicatedStorage         = game:GetService("ReplicatedStorage")
local player_service            = game:GetService("Players")

local BaseTool                  = require(script.Parent.Parent.BaseTool)

local Holster_Folder            = ReplicatedStorage.Shared.Assets.Guns.Holsters
local Tool_Folder               = ReplicatedStorage.Shared.Assets.Guns.ToolModels
local Animations_Folder         = ReplicatedStorage.Shared.Assets.Animations.Tools.Utility.Medkit

local Heal_RemoteEvent          = ReplicatedStorage.Shared.Library.Events.Heal
local HealNotify_RemoteEvent    = ReplicatedStorage.Shared.Library.Events.HealNotify
local Status_RemoteEvent        = ReplicatedStorage.Shared.Library.Events.Status
local Helmet_RemoteEvent        = ReplicatedStorage.Shared.Library.Events.Helmet

local local_player = player_service.LocalPlayer
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local Medkit = {}
Medkit.__index = Medkit
Medkit.className = "Medkit"

setmetatable(Medkit, { __index = BaseTool })

export type Medkit = BaseTool.BaseTool & {
	className: "Medkit",
	name: string,
}

function Medkit.new(info: { name: string }): Medkit
	local self = BaseTool.new(info) :: any
	setmetatable(self, Medkit)

	self.className = "Medkit"
	self.name = info.name
	self.Equipped = false

	self.Healing   = false
	self.HoldingM1 = false
	self.Aiming    = false
	self.locked_in = false

	self.Checking           = false
	self.original_walkspeed = nil

	self.item_image  = "rbxassetid://17778483663"
	self.Designation = "Medkit"

	self.holster_reference = Holster_Folder and Holster_Folder:FindFirstChild("MedkitHolster")
	self.actual_holster    = nil

	self.model_reference = Tool_Folder:FindFirstChild("Medkit")
	self.actual_model    = nil

	self.motor_6d_data = {
		Parent = "Left Arm",
		Part0  = "Left Arm",
		Part1  = self.model_reference and self.model_reference:FindFirstChild("Medkit_Hitbox"),
		C0     = CFrame.new(0.499, -0.707, -0.444)
			* CFrame.Angles(math.rad(-90), math.rad(-180), 0),
	}

	self.animations = {
		Draw    = Animations_Folder.Medkit_Draw,
		Hold    = Animations_Folder.Medkit_Held,
		Unequip = Animations_Folder.Medkit_Unequip,
		Check   = Animations_Folder["Medkit HealthCheck"],
		Special_Aim = Animations_Folder["Medkit Aim"],

		LeftArm_Suture   = Animations_Folder["Left Arm Suture"],
		LeftArm_Tweezer  = Animations_Folder["Left Arm Tweezer"],
		RightArm_Suture  = Animations_Folder["Right Arm Suture"],
		RightArm_Tweezer = Animations_Folder["Right Arm Tweezer"],
		RightLeg_Suture  = Animations_Folder["Right Leg Suture"],
		RightLeg_Tweezer = Animations_Folder["Right Leg Tweezer"],
		LeftLeg_Tweezer  = Animations_Folder["Left Leg Tweezer"],
		Torso_Tweezer    = Animations_Folder["Torso Tweezer"],
		Torso_Suture     = Animations_Folder["Torso Suture"],

		AfterHeal_Water = Animations_Folder["AfterHeal Water"],
		Suture_Others   = Animations_Folder["Suture Others"],
		Tweezer_Others  = Animations_Folder["Tweezer Others"],
		
		HelmetPlace 	= Animations_Folder["Helmet Place"],
		HelmetRemove    = Animations_Folder["Helmet Remove"],
	}

	return self
end

local function split_string(str: string, sep: string): {string}
	local result = {}
	for token in string.gmatch(str, "[^" .. sep .. "]+") do
		table.insert(result, token)
	end
	return result
end

function Medkit:_get_animation(origin: string, step: string, isOther: boolean?)
	local anims = self.RegisteredAnimations

	if isOther then
		if step == "Suture" then
			return anims.Suture_Others
		elseif step == "Tweezer" then
			return anims.Tweezer_Others
		end
	end

	local normalized_origin = string.gsub(origin, "%s+", "")
	local key = normalized_origin .. "_" .. step

	if anims[key] then
		return anims[key]
	end

	return anims["Torso_" .. step]
end

function Medkit:_raycast_target()
	local camera = workspace.CurrentCamera
	local rayOrigin    = camera.CFrame.Position
	local rayDirection = camera.CFrame.LookVector * 500

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.Character }

	local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if rayResult then
		local hitPart      = rayResult.Instance
		local hitCharacter = hitPart:FindFirstAncestorWhichIsA("Model")

		if hitCharacter and hitCharacter:FindFirstChildOfClass("Humanoid") then
			if not hitCharacter:FindFirstChild("HumanoidRootPart") then return end
			
			local distance = (self.Character.HumanoidRootPart.Position - hitCharacter.HumanoidRootPart.Position).Magnitude
			if distance <= 6 then
				print("[MEDKIT] Target detected:", hitCharacter.Name)
				return hitCharacter
			end
		end
	end

	return nil
end

function Medkit:_play_heal_sequence(wound_value: StringValue, is_last_wound: boolean, target: Model?)
	local data = split_string(wound_value.Value, ",")
	if #data < 3 then return false end

	local origin    = data[2]
	local anims     = self.RegisteredAnimations
	local startTime = tick()

	local fired_concussion = false
	local is_leg_wound     = string.find(origin, "Leg") ~= nil
	local humanoid         = self.Character:FindFirstChildOfClass("Humanoid")

	local function set_leg_slow()
		if target then return end
		if is_leg_wound and humanoid then
			if self.original_walkspeed == nil then
				self.original_walkspeed = humanoid.WalkSpeed
			end
			humanoid.WalkSpeed = 0.1
		end
	end

	local function restore_speed()
		if target then return end
		if humanoid and self.original_walkspeed ~= nil then
			humanoid.WalkSpeed = self.original_walkspeed
			self.original_walkspeed = nil
		end
	end

	local function can_cancel()
		local elapsed = tick() - startTime
		if target then return false end
		return elapsed < 2.5
	end

	if not target then
		set_leg_slow()
		local pre = anims.AfterHeal_Water
		pre:Play()

		while pre.IsPlaying do
			if can_cancel() and (not self.HoldingM1 or not self.Equipped) then
				print("[MEDKIT] Self-Heal cancelled during prep.")
				pre:Stop()
				restore_speed()
				return false
			end
			task.wait()
		end
	end

	for i = 3, #data do
		local elapsed = tick() - startTime

		if not target then
			if elapsed >= 2.5 and not self.Character:GetAttribute("Tool_Locked") then
				self.Character:SetAttribute("Tool_Locked", true)
			end
		end

		if can_cancel() and (not self.HoldingM1 or not self.Equipped) then
			print("[MEDKIT] Surgery cancelled mid-sequence.")
			restore_speed()
			return false
		end

		if target then
			local distance = (self.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
			if distance > 6 or not target:FindFirstChildOfClass("Humanoid") or target.Humanoid.Health <= 0 then
				print("[MEDKIT] Sequence failed: Patient lost or out of range.")
				restore_speed()
				return false
			end
		end

		local step  = data[i]
		local track: AnimationTrack = self:_get_animation(origin, step, target ~= nil)
		if not track then continue end

		local connection
		connection = track.KeyframeReached:Connect(function(name)
			if name == "vfx_firstaid_tweezer_round" then
				-- FIX: nil-safe access to tweezer model parts
				local tweezers = self.actual_model and self.actual_model:FindFirstChild("Medkit_Tweezers")
				if tweezers then
					local round    = tweezers:FindFirstChild("Medkit_Round")
					local pellet   = tweezers:FindFirstChild("Medkit_Pellet")
					local shrapnel = tweezers:FindFirstChild("Medkit_Shrapnel")

					if data[4] == "Round" and round then
						round.Transparency = 0
					elseif data[4] == "Pellet" and pellet then
						pellet.Transparency = 0
					elseif data[4] == "Sharpnel" and shrapnel then
						shrapnel.Transparency = 0
					end
				end

				if is_last_wound and not fired_concussion then
					fired_concussion = true
					Status_RemoteEvent:FireServer("ConcussionStatus")
				end

			elseif name == "vfx_firstaid_tweezer_throw" then
				-- FIX: nil-safe access to tweezer model parts
				local tweezers = self.actual_model and self.actual_model:FindFirstChild("Medkit_Tweezers")
				if tweezers then
					local round    = tweezers:FindFirstChild("Medkit_Round")
					local pellet   = tweezers:FindFirstChild("Medkit_Pellet")
					local shrapnel = tweezers:FindFirstChild("Medkit_Shrapnel")
					if round    then round.Transparency    = 1 end
					if pellet   then pellet.Transparency   = 1 end
					if shrapnel then shrapnel.Transparency = 1 end
				end
			end
		end)

		track:Play()

		while track.IsPlaying do
			if can_cancel() and (not self.HoldingM1 or not self.Equipped) then
				track:Stop()
				connection:Disconnect()
				restore_speed()
				return false
			end
			task.wait()
		end

		connection:Disconnect()
	end

	restore_speed()
	if is_last_wound and not fired_concussion then
		Status_RemoteEvent:FireServer("ConcussionStatus")
	end

	return true
end

function Medkit:_perform_surgery(wound: StringValue, target: Model?)
	if self.Healing then return false end

	self.Healing = true
	self.Character:SetAttribute("SprintBlocked", true)

	local ok, result = pcall(function()
		local target_wounds = target
			and target:FindFirstChild("CharacterData")
			and target.CharacterData:FindFirstChild("Wounds")
			or self.Wounds_folder

		local is_last_wound = (#target_wounds:GetChildren() == 1)

		print("[MEDKIT] Starting Surgery. Target:", target and target.Name or "Self", "| Wound:", wound.Name)

		return self:_play_heal_sequence(wound, is_last_wound, target)
	end)

	local success = ok and result

	if success then
		print("[MEDKIT] Surgery Complete. Firing Remote.")
		Heal_RemoteEvent:FireServer(target or local_player, wound)
		Helmet_RemoteEvent:FireServer(false)
		local track = self.RegisteredAnimations.HelmetRemove:Play()
		
	elseif not ok then
		warn("[MEDKIT] Surgery error:", result)
	else
		print("[MEDKIT] Surgery Failed or Cancelled.")
	end
	
	self.Character:SetAttribute("SprintBlocked", nil)
	self.Character:SetAttribute("Tool_Locked", nil)
	self.Healing = false

	return success
end

function Medkit:_process_self_heal()
	if self.Character.Humanoid.Health >= 100 then
		print("[MEDKIT] Self-Heal aborted: Health full.")
		return false
	end

	local wounds = self.Wounds_folder:GetChildren()
	if #wounds == 0 then
		print("[MEDKIT] Self-Heal aborted: No wounds.")
		if self.Equipped then
			self:notify("I'm not hurt enough to need Surgery")
		end
		return false
	end

	if Util.check_for_helmet(game.Players.LocalPlayer.Character) then
		print("[MEDKIT] Has helmet while healing.") 
		
		local track = self.RegisteredAnimations.HelmetRemove:Play()
		print("[MEDKIT] Helmet removed.")
		Helmet_RemoteEvent:FireServer(true)
	end
	
	local wound = wounds[math.random(1, #wounds)]
	return self:_perform_surgery(wound)
end

function Medkit:_process_target_heal(target: Model)
	local actual_player = player_service:GetPlayerFromCharacter(target)
		or player_service:GetPlayerFromCharacter(target.Parent)

	if not actual_player then
		print("[MEDKIT] Target-Heal aborted: Could not resolve player.")
		return false
	end

	if local_player.Team == nil or actual_player.Team == nil then
		print("[MEDKIT] Target-Heal aborted: Team missing.")
		return false
	end

	if local_player.Team.Name ~= actual_player.Team.Name then
		print("[MEDKIT] Target-Heal aborted: Enemy team.")
		return false
	end

	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		print("[MEDKIT] Target-Heal aborted: Target invalid or dead.")
		return false
	end

	local distance = (self.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
	if distance > 6 then
		print("[MEDKIT] Target-Heal aborted: Target too far ("..math.floor(distance).." studs).")
		self:notify("Patient is too far away")
		return false
	end

	local target_data   = target:FindFirstChild("CharacterData")
	local target_wounds = target_data and target_data:FindFirstChild("Wounds")

	if not target_wounds or #target_wounds:GetChildren() == 0 then
		print("[MEDKIT] Target-Heal aborted: Target has no wounds.")
		self:notify("Patient does not need Surgery")
		return false
	end

	local wounds = target_wounds:GetChildren()
	local wound  = wounds[math.random(1, #wounds)]

	HealNotify_RemoteEvent:FireServer(actual_player)
	print("[MEDKIT] Firing HealNotify for", actual_player.Name)
	return self:_perform_surgery(wound, target)
end

function Medkit:_begin_heal_loop(target: Model?)
	if self.Healing then
		print("[MEDKIT] Loop blocked: Already healing.")
		return
	end

	-- FIX: renamed to _healLoopThread to accurately reflect it holds a task thread, not a RBXScriptConnection
	self._healLoopThread = task.spawn(function()
		print("[MEDKIT] Starting heal loop.")
		while self.HoldingM1 and self.Equipped do
			local success = false

			-- FIX: re-raycast each loop iteration so target is always fresh
			local current_target = self.Aiming and self:_raycast_target() or nil

			if current_target and self.Aiming then
				success = self:_process_target_heal(current_target)
			elseif not self.Aiming then
				success = self:_process_self_heal()
			end

			if not success then
				print("[MEDKIT] Loop ending: Process returned false.")
				break
			end

			task.wait(0.1)
		end
		print("[MEDKIT] Heal loop terminated.")
	end)
end

function Medkit:ammo_check()
	if self.Checking then return end
	if self.Equipped == false then return end

	self.Checking = true
	print("[MEDKIT] Performing Health Check animation.")
	local health = self.Character.Humanoid.Health
	self.RegisteredAnimations.Check:Play()
	self.RegisteredAnimations.Check.Stopped:Wait()
	self.Checking = false

	if health >= 200 then
		self:notify("I'm all good. DEBUG: " .. health)
	elseif health >= 100 then
		self:notify("I'm fine, just slightly in pain DEBUG: " .. health)
	elseif health > 50 then
		self:notify("I'm injured and need Surgery DEBUG: " .. health)
	else
		self:notify("I'm heavily wounded, I really need Surgery DEBUG: " .. health)
	end
end

function Medkit:_update_aim_animation()
	local aimTrack = self.RegisteredAnimations.Special_Aim
	if self.Aiming then
		if not aimTrack.IsPlaying then aimTrack:Play() end
	else
		if aimTrack.IsPlaying then aimTrack:Stop() end
	end
end

function Medkit:_reset_aim_state()
	self._smoothedYaw  = nil
	self._lastYaw      = nil
	self._fpLeftRot    = nil
	self._fpRightRot   = nil
end

function Medkit:_on_equip()
	print("[MEDKIT] Equipped.")
	self.Equipped = true
	self:_connectInput()

	self._inputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.HoldingM1 = true
			local target = self:_raycast_target()
			self:_begin_heal_loop(target)

		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self:_reset_aim_state()
			self.Aiming = true
			self:_update_aim_animation()
		end
	end)

	self._inputEnded = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.HoldingM1 = false

		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			self.Aiming = false
			self:_reset_aim_state()
			self:_update_aim_animation()
		end
	end)
end

function Medkit:_on_unequip()
	print("[MEDKIT] Unequipped.")

	-- Stop the aim tracking loop first, before any flags change,
	-- so it doesn't fight the unequip animation or leave shoulders frozen
	self:_stopAimTracking()

	self.Equipped  = false
	self.HoldingM1 = false
	self.Aiming    = false
	self.Healing   = false

	-- Clear all cached rotation/yaw state so next equip starts clean
	self:_reset_aim_state()

	self:_disconnectInput()

	if self.Character then
		self.Character:SetAttribute("Tool_Locked", nil)
		self.Character:SetAttribute("SprintBlocked", nil)
	end

	if self._inputBegan then self._inputBegan:Disconnect() end
	if self._inputEnded then self._inputEnded:Disconnect() end

	if self._healLoopThread then
		task.cancel(self._healLoopThread)
		self._healLoopThread = nil
	end

	if self.RegisteredAnimations.Special_Aim.IsPlaying then
		self.RegisteredAnimations.Special_Aim:Stop()
	end

	local humanoid = self.Character and self.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and self.original_walkspeed then
		humanoid.WalkSpeed = self.original_walkspeed
		self.original_walkspeed = nil
	end
end

function Medkit:on_give(tool: Tool, holster: Model?, model: Model?)
	BaseTool.on_give(self, tool, holster)

	self.tool = tool
	self.Character = local_player.Character

	if self.Character then
		self.Character_data = self.Character:WaitForChild("CharacterData")
		self.Wounds_folder = self.Character_data:WaitForChild("Wounds")
	end

	self.RegisteredAnimations = Util.register_animations(
		local_player,
		self.animations
	)

	if not self.RegisteredAnimations then
		warn("[Medkit] Failed to register animations")
	end

	if holster then
		self.actual_holster = holster
	elseif self.holster_reference then
		self.actual_holster = Util.reverse_search_holster(
			local_player,
			self.holster_reference.Name
		)
	else
		warn("[Medkit] Missing holster_reference")
	end
end

return Medkit