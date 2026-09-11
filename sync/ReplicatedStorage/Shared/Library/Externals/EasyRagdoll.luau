---@module Easy Ragdoll by theonlyflare

--- Services ---
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")

local AccessoryService = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules")["Server Modules"]:WaitForChild("AccessoryService"))
local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))
local ClassAppearance = require(ReplicatedStorage.Shared.Library.ClassAppearance)

local BodySounds = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("BodySounds")
--- Module ---
local RagdollModule = {}

--- Constants ---
-- Names of instances created by the ragdoll system, used for cleanup.
local RAGDOLL_INSTANCE_NAMES = {
	["RagdollAttachment"] = true,
	["RagdollConstraint"] = true,
	["ColliderPart"] = true, -- Keep this for cleanup in case old ragdolls had them
}

-- States the Humanoid could otherwise fall into once the engine decides to
-- leave Ragdoll on its own. Disabling all of them leaves Ragdoll as the only
-- reachable destination, so ChangeState(Ragdoll) actually holds instead of
-- getting immediately overridden by Running/Landed/etc.
-- Deliberately excludes Dead (breaks health-zero handling) and
-- PlatformStanding (used internally by ragdoll-adjacent physics).
local STATES_TO_DISABLE = {
	Enum.HumanoidStateType.GettingUp,
	Enum.HumanoidStateType.Running,
	Enum.HumanoidStateType.RunningNoPhysics,
	Enum.HumanoidStateType.Landed,
	Enum.HumanoidStateType.Jumping,
	Enum.HumanoidStateType.Climbing,
	Enum.HumanoidStateType.Flying,
	Enum.HumanoidStateType.Swimming,
}

--- State ---
-- Tracks the Humanoid.StateChanged connection per-character that keeps a
-- ragdolled character locked in the Ragdoll state. Roblox's Humanoid state
-- machine will otherwise try to leave Ragdoll on its own once it decides the
-- character has settled, which snaps the body upright with no transition.
local ragdollWatchers: {[Model]: RBXScriptConnection} = {}

--- Helper Functions ---

--[[
	@param humanoid: Humanoid -- The humanoid to lock or unlock.
	@param locked: boolean -- True disables every alternative state (leaving
	only Ragdoll reachable); false re-enables them all.
	@brief Toggles every Humanoid state that could compete with Ragdoll.
]]
local function lockRagdollStates(humanoid: Humanoid, locked: boolean)
	for _, state in STATES_TO_DISABLE do
		humanoid:SetStateEnabled(state, not locked)
	end
end

--[[
	@param character: Model -- The character to keep locked in the Ragdoll state.
	@param humanoid: Humanoid -- The humanoid object within the character.
	@brief Connects a watcher that forces the Humanoid back into the Ragdoll
	state the instant the engine tries to leave it on its own. Replaces any
	existing watcher for this character.
]]
local function watchRagdollState(character: Model, humanoid: Humanoid)
	local existing = ragdollWatchers[character]
	if existing then
		existing:Disconnect()
	end

	ragdollWatchers[character] = humanoid.StateChanged:Connect(function(_, newState)
		if newState ~= Enum.HumanoidStateType.Ragdoll then
			-- Re-assert immediately, synchronously, in the same callback.
			lockRagdollStates(humanoid, true)
			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
		end
	end)
end

--[[
	@param character: Model -- The character whose ragdoll watcher should stop.
	@brief Disconnects and clears the ragdoll-state watcher for this character,
	if one exists. Must be called before restoring normal Humanoid states,
	otherwise the watcher will fight the intentional stand-up.
]]
local function stopWatchingRagdollState(character: Model)
	local existing = ragdollWatchers[character]
	if existing then
		existing:Disconnect()
		ragdollWatchers[character] = nil
	end
end

--[[
	@param character: Model -- The character model to ragdoll.
	@param humanoid: Humanoid -- The humanoid object within the character.
	@brief Converts Motor6D joints into BallSocketConstraints to enable ragdolling.
	This process involves disabling existing Motor6D joints and replacing them
	with physics-based constraints.
]]
local function replaceJoints(character: Model, humanoid: Humanoid)
	-- Necessary for Ragdolling to function properly
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = true

	-- Disable the 'Animate' script to stop character animations
	local animateScript = character:FindFirstChild("Animate")
	if animateScript and animateScript:IsA("LocalScript") then
		animateScript.Enabled = false
	end

	-- Stop all playing animations on the humanoid's animator
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			track:Stop()
		end
	end

	-- Iterate through all descendants to find Motor6D joints
	for _, motor: Motor6D in pairs(character:GetDescendants()) do
		if motor:IsA("Motor6D") and motor.Part0 and motor.Part1 then -- Ensure parts exist for the Motor6D
			motor.Enabled = false -- Disable the Motor6D to allow physics to take over

			-- Create attachments for the BallSocketConstraint
			local attachment0 = Instance.new("Attachment")
			local attachment1 = Instance.new("Attachment")

			-- Set Attachment CFrames based on Motor6D's C0 and C1
			attachment0.CFrame = motor.C0
			attachment1.CFrame = motor.C1

			attachment0.Name = "RagdollAttachment"
			attachment1.Name = "RagdollAttachment"

			-- Create the BallSocketConstraint
			local ballSocketConstraint = Instance.new("BallSocketConstraint")
			ballSocketConstraint.Attachment0 = attachment0
			ballSocketConstraint.Attachment1 = attachment1
			ballSocketConstraint.Name = "RagdollConstraint"

			-- Generic BallSocketConstraint properties. These can be fine-tuned
			-- for specific joints for more realistic ragdoll behavior.
			ballSocketConstraint.Radius = 0.15
			ballSocketConstraint.LimitsEnabled = true
			ballSocketConstraint.TwistLimitsEnabled = true -- Allow some twist, but with limits
			ballSocketConstraint.MaxFrictionTorque = 0 -- No friction at the joint
			ballSocketConstraint.Restitution = 0 -- No bounce at the joint
			ballSocketConstraint.UpperAngle = 90
			ballSocketConstraint.TwistLowerAngle = -45
			ballSocketConstraint.TwistUpperAngle = 45

			-- Apply specific overrides for certain joints for better control
			if motor.Name:find("Neck") then
				ballSocketConstraint.UpperAngle = 45
				ballSocketConstraint.TwistLowerAngle = -90
				ballSocketConstraint.TwistUpperAngle = 90
			elseif motor.Name:find("Hip") then
				ballSocketConstraint.UpperAngle = 60
				ballSocketConstraint.TwistLowerAngle = -50
				ballSocketConstraint.TwistUpperAngle = 50
			elseif motor.Name:find("Shoulder") then
				ballSocketConstraint.UpperAngle = 75
				ballSocketConstraint.TwistLowerAngle = -90
				ballSocketConstraint.TwistUpperAngle = 90
			end

			-- Parent the attachments and constraint
			attachment0.Parent = motor.Part0
			attachment1.Parent = motor.Part1
			ballSocketConstraint.Parent = motor.Parent
		end
	end



	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.CanCollide = part.Name ~= "HumanoidRootPart"
			part.CollisionGroup = "Default"

			local TouchConn

			TouchConn = part.Touched:Connect(function(touched)
				if touched.Parent == character then return end

				local sound:Sound = BodySounds:FindFirstChild("bodyhit" .. math.random(0, #BodySounds:GetChildren())):Clone()

				sound.Parent = part
				sound:Play()

				sound.Ended:Once(function()
					sound:Destroy()
				end)

				task.delay(2, function()
					TouchConn:Disconnect()
				end)
			end)
		end
	end

	humanoid.AutoRotate = false -- Disabling AutoRotate prevents the Character rotating in first person or Shift-Lock
	character:SetAttribute("LastRag", tick()) -- Used for anti-cheats to prevent flying Ragdolls from getting flagged
end

--[[
	@param character: Model -- The character model to unragdoll.
	@param humanoid: Humanoid -- The humanoid object within the character.
	@brief Destroys all Ragdoll-related instances (attachments, constraints, colliders)
	and re-enables the original Motor6D's to restore normal character animation.
]]
local function resetJoints(character: Model, humanoid: Humanoid)
	-- Do not unragdoll if the humanoid is dead
	if humanoid.Health < 1 then return end

	for _, instance in pairs(character:GetDescendants()) do
		-- Destroy instances created by the ragdoll system
		if RAGDOLL_INSTANCE_NAMES[instance.Name] then
			instance:Destroy()
		end

		-- Re-enable original Motor6D joints
		if instance:IsA("Motor6D") then
			instance.Enabled = true
		end
	end

	humanoid.AutoRotate = true

	-- Re-enable the 'Animate' script
	local animateScript = character:FindFirstChild("Animate")
	if animateScript and animateScript:IsA("LocalScript") then
		animateScript.Enabled = true
	end
end

--[[
	@param character: Model -- The character model to push.
	@param magnitude: number -- The magnitude of the push to apply.
	@brief Applies an impulse to the character's HumanoidRootPart or Torso.
]]
local function applyPush(character: Model, magnitude: number)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if rootPart and rootPart:IsA("BasePart") then
		-- Apply impulse in the opposite direction of the character's forward vector
		rootPart:ApplyImpulse(rootPart.CFrame.LookVector * -magnitude)
	end
end

--- Module Functions ---

--[[
	@param character: Model -- The character model to apply or remove ragdoll from.
	@param value: boolean -- True to ragdoll, false to unragdoll.
	@param applyPushOnRagdoll: boolean? -- Optional: Whether to apply a push when ragdolling. Defaults to false.
	@param pushMagnitude: number? -- Optional: The magnitude of the push if applyPushOnRagdoll is true. Defaults to 100.
	@brief Toggles the ragdoll state of the given character, with an option to apply an extra push.
]]
function RagdollModule.SetRagdoll(character: Model, value: boolean, applyPushOnRagdoll: boolean?, pushMagnitude: number?, break_tool_welds:boolean?, helmet: Model)
	-- Validate inputs
	if not character then
		warn("RagdollModule.SetRagdoll: No character provided.")
		return
	end

	local player = Players:FindFirstChild(character.Name)

	if break_tool_welds then
		print("Breaking tool welds")

		for _, descendant in ipairs(character:GetDescendants()) do
			-- Remove your custom attachment joints
			if descendant:IsA("Motor6D") then
				if descendant.Name == "ToolMotor" or descendant.Name == "Round_Motor6d" then
					descendant:Destroy()
				end
			end
		end

		-- Drop weapon model into the world
		local equipment = character:FindFirstChild("CharacterData")
			and character.CharacterData:FindFirstChild("Equipment")

		if equipment then
			for _, model in ipairs(equipment:GetChildren()) do
				if model:IsA("Model") then
					model.Parent = workspace

					-- optional but important for realism
					for _, part in ipairs(model:GetDescendants()) do
						if part:IsA("BasePart") then
							part.Anchored = false
							part.CanCollide = true
							part:SetNetworkOwner(nil)
						end
					end
				end
			end
		end

		-- Drop Round if it exists
		local rightArm = character:FindFirstChild("Right Arm")
		if rightArm then
			for _, obj in ipairs(rightArm:GetChildren()) do
				if obj:IsA("BasePart") and obj.Name == "Round" then
					obj.Parent = workspace
					obj.Anchored = false
					obj.CanCollide = true
					obj:SetNetworkOwner(nil)
				end
			end
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		warn("RagdollModule.SetRagdoll: Character does not have a Humanoid.")
		return
	end

	-- Set default optional parameters
	applyPushOnRagdoll = applyPushOnRagdoll or false
	pushMagnitude = pushMagnitude or 100


	if value then -- Ragdoll the character
		ClassAppearance.Apply(character, player.Team.Name, player:GetAttribute("SelectedClass"))
		replaceJoints(character, humanoid)

		--> Check to see if the module is being called from client/server
		if RunService:IsClient() then
			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			lockRagdollStates(humanoid, true)

		elseif RunService:IsServer() then
			character.PrimaryPart:SetNetworkOwner(nil)

			humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
			lockRagdollStates(humanoid, true)
		end

		-- Keep the Humanoid locked in the Ragdoll state. Without this, the
		-- engine's own state machine will try to leave Ragdoll once the body
		-- settles and snap it upright instead of staying down.
		watchRagdollState(character, humanoid)

		-- Apply push only if explicitly requested
		if applyPushOnRagdoll then
			applyPush(character, pushMagnitude)
		end

		for _, child in pairs(character:GetDescendants()) do
			if child:IsA("BodyVelocity") then
				child:Destroy()
			end
		end

		--[[for _, child in pairs(player.GameData.Accessorys:GetChildren()) do
			local Accessory = Util.fetch_accessory(child.Name)
			if not Accessory or not Accessory:IsA("Model") then continue end
			Util.create_object(character, Accessory)
		end]]

	
	else -- Unragdoll the character
		-- Must happen before resetJoints/ChangeState below, otherwise the
		-- watcher will immediately force the Humanoid back into Ragdoll and
		-- fight the intentional stand-up.
		stopWatchingRagdollState(character)
		lockRagdollStates(humanoid, false)

		resetJoints(character, humanoid)

		if RunService:IsClient() then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

		elseif RunService:IsServer() then
			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

			-- Fix network ownership for players
			local player: Player? = Players:GetPlayerFromCharacter(character)
			if player then
				character.PrimaryPart:SetNetworkOwner(player)
			end
		end
	end
end

-- Return the module
return RagdollModule