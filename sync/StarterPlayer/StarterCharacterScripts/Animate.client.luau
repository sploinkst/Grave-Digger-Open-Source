-- // (Praxitos)
-- // (Animation Handler)

-- // (Services)
local input_service              = game:GetService("UserInputService")
local replicatedstorage_service  = game:GetService("ReplicatedStorage")
local run_service               = game:GetService("RunService")
local player_service             = game:GetService("Players")
local keyframe_sequence_provider = game:GetService("KeyframeSequenceProvider")

local sound_module = require(script:WaitForChild("Sound"))

-- // (Variables)
local local_player = player_service.LocalPlayer
local character    = script.Parent
local humanoid: Humanoid = character:WaitForChild("Humanoid")

local playing_sprint_arms = false

local animator: Animator = humanoid:FindFirstChildOfClass("Animator")
if not animator then
	animator = Instance.new("Animator")
	animator.Parent = humanoid
end

local humanoid_root_part = character:WaitForChild("HumanoidRootPart")

local animations_folder = replicatedstorage_service.Shared.Assets.Animations.Character
local sprint_folder = animations_folder:FindFirstChild("Sprint")

local function sprint_animation(name: string): Instance?
	local candidate = sprint_folder and sprint_folder:FindFirstChild(name)

	return candidate
		and (candidate:IsA("Animation") or candidate:IsA("KeyframeSequence"))
		and candidate
		or nil
end

local animations_table = {
	animations_folder.Idles.Stand_Idle,

	animations_folder.Walking.Standing.Walk_Forward,
	animations_folder.Walking.Standing.Walk_Left,
	animations_folder.Walking.Standing.Walk_Right,
	animations_folder.Walking.Standing.Walk_Arms,

	animations_folder.Jumping.Jump_Arms,
	animations_folder.Jumping.Jump_Land,
	animations_folder.Jumping.Jump_MidAir,

	animations_folder.Jumping.Climb,

	-- Sprint
	sprint_animation("Sprint"),
	sprint_animation("Sprint_Lean"),
	sprint_animation("Sprinting_Full"),
	sprint_animation("Sprint_Arms"),
	sprint_animation("PrinceRifle_Sprint"),
	sprint_animation("GraceRevolver_Sprint"),

	animations_folder.Walking.Crouch.CrouchWalk_Forward,
	animations_folder.Walking.Crouch.CrouchWalk_Left,
	animations_folder.Walking.Crouch.CrouchWalk_Right,
	animations_folder.Idles.Crouch_Idle,
	animations_folder.Walking.Crouch.Crouch_Arms,

	animations_folder.Flinches.Flinch1,
	animations_folder.Flinches.Flinch2,
	animations_folder.Flinches.Flinch3,
	animations_folder.Flinches.Flinch4,
	animations_folder.Flinches.Flinch5,

	animations_folder.Flinches.Miss_Flinch1,
	animations_folder.Flinches.Miss_Flinch2,
	animations_folder.Flinches.Miss_Flinch3,
	animations_folder.Flinches.Miss_Flinch4,
}

local loaded_animations: {[string]: AnimationTrack} = {}

local directional_table = {
	Forward = false,
	Left = false,
	Right = false
}

local active_base: AnimationTrack? = nil
local active_overlays: {[string]: AnimationTrack} = {}

local current_base_name: string? = nil
local current_state = nil

local is_airborne = false
local crouching = false
local is_climbing = false

-- // Hip system
local left_hip: Motor6D?
local right_hip: Motor6D?

local hip_adjustment_enabled = true
local current_hip_offset = 0
local target_hip_offset = 0
local hip_adjustment_speed = 0.12

local left_hip_original_c1: CFrame?
local right_hip_original_c1: CFrame?

local climb_connection

local ORIGINAL_HIP_HEIGHT = humanoid.HipHeight

-- // Sprint overlays
local SPRINT_OVERLAY_NAMES = {
	"Sprint_Lean",
	"Sprint_Arms",
	"PrinceRifle_Sprint",
	"GraceRevolver_Sprint",
}

-- // (Utils)

local function load_animations()
	for _, animation in pairs(animations_table) do
		if not animation then
			continue
		end

		local playable = animation

		if animation:IsA("KeyframeSequence") then
			playable = Instance.new("Animation")
			playable.Name = animation.Name
			playable.AnimationId =
				keyframe_sequence_provider:RegisterKeyframeSequence(animation)
		end

		-- Ignore empty legacy Animation objects.
		if playable:IsA("Animation") and playable.AnimationId == "" then
			warn("[Animate] Skipping empty animation:", animation.Name)
			continue
		end

		local track = animator:LoadAnimation(playable)

		-- PRIORITIES
		if animation.Name == "Climb" then
			track.Priority = Enum.AnimationPriority.Action

		elseif string.find(animation.Name, "Jump")
			or string.find(animation.Name, "Sprint") then

			track.Priority = Enum.AnimationPriority.Action

		elseif string.find(animation.Name, "Flinch") then
			track.Priority = Enum.AnimationPriority.Action4

		else
			track.Priority = Enum.AnimationPriority.Movement
		end

		-- LOOPING
		if animation.Name == "Jump_MidAir"
			or animation.Name == "Climb" then

			track.Looped = true
		end

		loaded_animations[animation.Name] = track

		track:GetMarkerReachedSignal("Footstep"):Connect(function()
			sound_module.Play_WalkSFX()
		end)
	end
end

local function initialize_hips()
	local torso =
		character:FindFirstChild("Torso")
		or character:FindFirstChild("UpperTorso")

	if not torso then
		hip_adjustment_enabled = false
		return
	end

	left_hip = torso:FindFirstChild("Left Hip")
	right_hip = torso:FindFirstChild("Right Hip")

	if not left_hip or not right_hip then
		hip_adjustment_enabled = false
		return
	end

	left_hip_original_c1 = left_hip.C1
	right_hip_original_c1 = right_hip.C1
end

local function set_state(new_state)
	if current_state == new_state then
		return false
	end

	current_state = new_state
	return true
end

local function set_target_hip_offset(offset: number)
	target_hip_offset = offset
end

local function update_hip_offset(dt: number)
	if not hip_adjustment_enabled
		or not left_hip
		or not right_hip then

		return
	end

	if not left_hip_original_c1
		or not right_hip_original_c1 then

		return
	end

	local alpha = math.min(dt / hip_adjustment_speed, 1)

	current_hip_offset +=
		(target_hip_offset - current_hip_offset) * alpha

	local left_new =
		left_hip_original_c1.Position
		+ Vector3.new(0, current_hip_offset, 0)

	local right_new =
		right_hip_original_c1.Position
		+ Vector3.new(0, current_hip_offset, 0)

	local lx, ly, lz =
		left_hip_original_c1:ToEulerAnglesXYZ()

	local rx, ry, rz =
		right_hip_original_c1:ToEulerAnglesXYZ()

	left_hip.C1 =
		CFrame.new(left_new)
		* CFrame.Angles(lx, ly, lz)

	right_hip.C1 =
		CFrame.new(right_new)
		* CFrame.Angles(rx, ry, rz)

	humanoid.HipHeight =
		ORIGINAL_HIP_HEIGHT + current_hip_offset
end

local function if_tool_equipped()
	local tool = character:FindFirstChildOfClass("Tool")

	if not tool then
		return false
	end

	return true
end

local function is_aiming()
	return character:GetAttribute("Aiming") == true
end

local function sprint_arms_overlay()
	if character:GetAttribute("Sprint_Animation") then
		return tostring(
			character:GetAttribute("Sprint_Animation")
		) .. "_Sprint"
	else
		return "Sprint_Arms"
	end
end

local function get_walk_animation()
	-- Forward ALWAYS wins.
	if directional_table.Forward then
		return "Walk_Forward"
	end

	-- Lateral movement only when forward isn't pressed.
	if directional_table.Left then
		return "Walk_Left"
	end

	if directional_table.Right then
		return "Walk_Right"
	end

	return "Walk_Forward"
end

local function get_crouch_animation()
	if directional_table.Forward then
		return "CrouchWalk_Forward"
	end

	if directional_table.Left then
		return "CrouchWalk_Left"
	end

	if directional_table.Right then
		return "CrouchWalk_Right"
	end

	return "CrouchWalk_Forward"
end

-- // (Base / Overlay)

local function play_base(
	name: string,
	fade: number?,
	reversed: boolean?,
	speed: number?
)
	local track = loaded_animations[name]

	if not track then
		return
	end

	fade = fade or 0.18

	if current_base_name == name
		and active_base
		and active_base.IsPlaying then

		if speed then
			active_base:AdjustSpeed(speed)

		elseif reversed ~= nil then
			active_base:AdjustSpeed(
				reversed and -1 or 1
			)
		end

		return
	end

	if active_base then
		active_base:Stop(fade)
	end

	track:Play(fade)

	if speed then
		track:AdjustSpeed(speed)
	else
		track:AdjustSpeed(
			reversed and -1 or 1
		)
	end

	active_base = track
	current_base_name = name
end

local function play_overlay(
	name: string,
	fade: number?,
	speed: number?,
	weight: number?
)
	local track = loaded_animations[name]

	if not track then
		return
	end

	if active_overlays[name]
		and active_overlays[name].IsPlaying then

		return
	end

	track:Play(fade or 0.12)

	active_overlays[name] = track

	if speed then
		track:AdjustSpeed(speed)
	end

	if weight then
		track:AdjustWeight(weight)
	end
end

local function stop_overlay(
	name: string,
	fade: number?
)
	local track =
		active_overlays[name]
		or loaded_animations[name]

	if not track then
		return
	end

	if track.IsPlaying then
		track:Stop(fade or 0.12)
	end

	active_overlays[name] = nil
end

local function clear_overlays()
	for name, track in pairs(active_overlays) do
		if track.IsPlaying then
			track:Stop(0.12)
		end
	end

	active_overlays = {}
end

local function clear_sprint_overlays(fade: number?)
	for _, name in ipairs(SPRINT_OVERLAY_NAMES) do
		local track =
			active_overlays[name]
			or loaded_animations[name]

		if track and track.IsPlaying then
			track:Stop(fade or 0.12)
		end

		active_overlays[name] = nil
	end

	playing_sprint_arms = false
end

-- // Stop sprint and return to normal walking.
-- This is specifically used when aiming interrupts sprint buildup.

local function cancel_sprint_for_aim()
	clear_sprint_overlays(0.08)

	if active_base then
		if current_base_name == "Sprinting_Full"
			or current_base_name == "Walk_Forward" then

			active_base:Stop(0.08)
			active_base = nil
			current_base_name = nil
		end
	end

	current_state = nil
	set_target_hip_offset(0)

	local freelook =
		local_player:GetAttribute("FreeLook") == true

	if freelook then
		play_base("Walk_Forward", 0.08, nil, 1)
	else
		play_base(get_walk_animation(), 0.08, nil, 1)
	end

	play_overlay("Walk_Arms", 0.08)
end

-- // (Movement)

local function update_movement(speed: number)

	-- HARD BLOCKS
	if is_airborne then
		return
	end

	if is_climbing then
		return
	end

	local moving =
		humanoid.MoveDirection.Magnitude > 0.1
		and speed > 1

	-- IDLE
	if not moving then
		local target =
			crouching
			and "CROUCH_IDLE"
			or "IDLE"

		if set_state(target) then

			if crouching then
				play_base(
					"Crouch_Idle",
					nil,
					nil,
					1
				)

				set_target_hip_offset(-0.85)

				clear_overlays()

				play_overlay("Crouch_Arms")
			else
				play_base(
					"Stand_Idle",
					nil,
					nil,
					1
				)

				set_target_hip_offset(0)

				clear_overlays()
			end
		end

		return
	end

	local freelook =
		local_player:GetAttribute("FreeLook") == true

	-- CROUCH
	if crouching then

		if set_state("CROUCH_WALK") then
			set_target_hip_offset(-0.85)

			clear_overlays()

			play_overlay("Crouch_Arms")
		end

		if freelook then
			play_base("CrouchWalk_Forward")
		else
			play_base(get_crouch_animation())
		end

		return
	end

	-- AIMING
	--
	-- Aiming takes priority over sprint buildup.
	-- If the movement controller hasn't lowered WalkSpeed yet,
	-- we still prevent the sprint animation from playing.

	if is_aiming() then

		-- If we were previously sprinting or transitioning,
		-- immediately clear those animations.

		if current_state == "SPRINT_TRANSITION"
			or current_state == "SPRINT" then

			cancel_sprint_for_aim()
		end

		if set_state("WALK") then
			set_target_hip_offset(0)

			clear_sprint_overlays()

			-- Don't clear every overlay here because
			-- the weapon system may have its own overlays.
			stop_overlay("Sprint_Lean")

			if freelook then
				play_base(
					"Walk_Forward",
					0.08,
					nil,
					1
				)
			else
				play_base(
					get_walk_animation(),
					0.08,
					nil,
					1
				)
			end

			play_overlay("Walk_Arms")
		end

		-- Keep the walking animation active while aiming,
		-- regardless of whether WalkSpeed has visually entered
		-- the sprint threshold yet.

		if freelook then
			play_base(
				"Walk_Forward",
				0.08,
				nil,
				1
			)
		else
			play_base(
				get_walk_animation(),
				0.08,
				nil,
				1
			)
		end

		return
	end

	-- WALK
	if speed < 13 then

		if set_state("WALK") then
			set_target_hip_offset(0)

			clear_overlays()
		end

		if freelook then
			play_base("Walk_Forward")
		else
			play_base(get_walk_animation())
		end

		play_overlay("Walk_Arms")

		return
	end

	-- SPRINT TRANSITION
	if speed >= 13 and speed < 17 then

		-- AIMING CHECK
		--
		-- This is the important fix.
		-- Even if WalkSpeed hasn't been reduced yet,
		-- aiming prevents sprint buildup.

		if is_aiming() then
			cancel_sprint_for_aim()
			return
		end

		if set_state("SPRINT_TRANSITION") then

			set_target_hip_offset(0)

			clear_overlays()

			play_base(
				"Walk_Forward",
				0.1,
				nil,
				1 - speed / 100
			)

			play_overlay(
				"Walk_Arms"
			)

			play_overlay(
				"Sprint_Lean",
				0.15
			)
		end

		-- Keep transition animation synced to speed.
		if active_base ==
			loaded_animations["Walk_Forward"] then

			active_base:AdjustSpeed(
				1 - speed / 100
			)
		end

		return
	end

	-- FULL SPRINT
	if speed >= 17 then

		-- AIMING CHECK
		--
		-- Never allow full sprint animation while aiming.

		if is_aiming() then
			cancel_sprint_for_aim()
			return
		end

		if set_state("SPRINT") then

			set_target_hip_offset(0)

			clear_overlays()

			-- Stop previous base animation.
			if active_base then
				active_base:Stop(0.05)

				active_base = nil
				current_base_name = nil
			end

			-- Full-body sprint.
			play_base(
				"Sprinting_Full",
				0,
				nil,
				1
			)

			-- Sprint arms.
			if not character:GetAttribute(
				"No_Sprint_Animation"
				) then

				play_overlay(
					sprint_arms_overlay(),
					0.1,
					nil,
					1
				)
			end

			playing_sprint_arms = true
		end

		return
	end
end

-- // (Input)

input_service.InputBegan:Connect(function(io, gp)
	if gp then
		return
	end

	if io.KeyCode == Enum.KeyCode.W then
		directional_table.Forward = true
	end

	if io.KeyCode == Enum.KeyCode.A then
		directional_table.Left = true
	end

	if io.KeyCode == Enum.KeyCode.D then
		directional_table.Right = true
	end
end)

input_service.InputEnded:Connect(function(io, gp)
	if gp then
		return
	end

	if io.KeyCode == Enum.KeyCode.W then
		directional_table.Forward = false
	end

	if io.KeyCode == Enum.KeyCode.A then
		directional_table.Left = false
	end

	if io.KeyCode == Enum.KeyCode.D then
		directional_table.Right = false
	end
end)

-- // (Crouching)

character:GetAttributeChangedSignal("Crouching"):Connect(function()

	crouching =
		character:GetAttribute("Crouching") == true

	current_state = nil
	current_base_name = nil

	clear_overlays()

	if active_base then
		active_base:Stop(0)

		active_base = nil
	end
end)

-- // (Vaulting)

character:GetAttributeChangedSignal("Vaulting"):Connect(function()

	local vaulting =
		character:GetAttribute("Vaulting") == true

	if vaulting then
		print("VAULTING")

		stop_overlay(
			"Jump_MidAir"
		)

		stop_overlay(
			"Jump_Arms"
		)
	end
end)

-- // (Aiming)

character:GetAttributeChangedSignal("Aiming"):Connect(function()

	if not is_aiming() then
		return
	end

	-- If the player starts aiming during sprint buildup,
	-- immediately cancel the sprint animation.

	if current_state == "SPRINT_TRANSITION"
		or current_state == "SPRINT" then

		cancel_sprint_for_aim()
	end
end)

-- // (Flinch)

local_player:GetAttributeChangedSignal("Flinch"):Connect(function()

	print("FLINCHING")

	if local_player:GetAttribute("Flinch") then

		local_player:SetAttribute(
			"Flinch",
			nil
		)

		print("FLINCHING")

		play_overlay(
			"Miss_Flinch" .. math.random(1, 4),
			0,
			2,
			0.05
		)

		print("FLINCHING")
	end
end)

-- // (Render)

run_service.RenderStepped:Connect(function(dt)

	local speed =
		humanoid.MoveDirection.Magnitude
		* humanoid.WalkSpeed

	update_movement(speed)
	update_hip_offset(dt)
end)

-- // (Humanoid State)

humanoid.StateChanged:Connect(function(_, new_state)

	-- JUMP
	if new_state == Enum.HumanoidStateType.Jumping then

		is_airborne = true
		is_climbing = false

		if current_base_name == "Climb"
			and active_base then

			active_base:Stop(0.1)

			active_base = nil
			current_base_name = nil
		end

		if not if_tool_equipped() then
			play_overlay(
				"Jump_Arms",
				0.2
			)
		end

		return
	end

	-- FREEFALL
	if new_state == Enum.HumanoidStateType.Freefall then

		is_airborne = true
		is_climbing = false

		if current_base_name == "Climb"
			and active_base then

			active_base:Stop(0.1)

			active_base = nil
			current_base_name = nil
		end

		play_overlay(
			"Jump_MidAir",
			0.2
		)

		return
	end

	-- LANDED
	if new_state == Enum.HumanoidStateType.Landed then

		is_airborne = false
		is_climbing = false

		stop_overlay(
			"Jump_MidAir"
		)

		stop_overlay(
			"Jump_Arms"
		)

		play_overlay(
			"Jump_Land"
		)

		current_state = nil

		return
	end

	-- CLIMBING
	if new_state == Enum.HumanoidStateType.Climbing then

		if is_climbing then
			return
		end

		is_climbing = true
		is_airborne = false

		current_state = nil

		-- Stop all sprint overlays.
		clear_sprint_overlays(0.1)

		-- Stop jump overlays.
		stop_overlay(
			"Jump_MidAir",
			0.1
		)

		stop_overlay(
			"Jump_Arms",
			0.1
		)

		clear_overlays()

		if active_base then
			active_base:Stop(0.1)
		end

		active_base = nil
		current_base_name = nil

		play_base(
			"Climb",
			0.1,
			nil,
			0.5
		)

		play_overlay(
			"Walk_Forward"
		)

		climb_connection =
			run_service.RenderStepped:Connect(function()

				if not active_base then
					return
				end

				local vertical_velocity =
				math.abs(
					humanoid_root_part
					.AssemblyLinearVelocity.Y
				)

				if vertical_velocity < 0.05 then

					active_base:AdjustSpeed(0)

					local walk_track =
					loaded_animations["Walk_Forward"]

					if walk_track then
						walk_track:AdjustSpeed(0)
					end

				else

					active_base:AdjustSpeed(0.5)

					local walk_track =
					loaded_animations["Walk_Forward"]

					if walk_track then
						walk_track:AdjustSpeed(0.5)
					end
				end
			end)

		return
	end

	-- LEFT CLIMBING
	if is_climbing then

		is_climbing = false

		if climb_connection then
			climb_connection:Disconnect()
			climb_connection = nil
		end

		if current_base_name == "Climb"
			and active_base then

			active_base:Stop(0.1)

			active_base = nil
			current_base_name = nil
		end

		current_state = nil
	end
end)

-- // (Died)

humanoid.Died:Connect(function()

	if climb_connection then
		climb_connection:Disconnect()
		climb_connection = nil
	end

	if active_base then
		active_base:Stop(0)
	end

	clear_overlays()
end)

-- // (Init)

load_animations()
initialize_hips()