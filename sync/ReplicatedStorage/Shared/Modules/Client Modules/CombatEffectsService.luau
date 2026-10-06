local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Audio = require(game:GetService("ReplicatedStorage").Shared.Library.GameAudio)
local Service = {}
local player = Players.LocalPlayer
local started = false
local lastFlinch = -math.huge
local lastHeartbeat = -math.huge
local currentCore
local huntTween
local huntActive = false
local huntVersion = 0
local blur
local cameraKick = Vector2.zero

local function coreGame()
	local gui = player:FindFirstChildOfClass("PlayerGui")
	local main = gui and gui:FindFirstChild("main")
	return main and main:FindFirstChild("core_game")
end

local function image(core, name)
	local object = core and core:FindFirstChild(name)
	return object and (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object or nil
end

local function reset(core)
	huntVersion += 1
	if huntTween then huntTween:Cancel(); huntTween = nil end
	huntActive = false
	cameraKick = Vector2.zero
	for _, name in {"hunt_vignette", "healthlow", "injuredhealth", "morale", "flinch"} do
		local overlay = image(core, name)
		if overlay then overlay.ImageTransparency = 1; overlay.Visible = false end
	end
	local hunt = image(core, "hunt_vignette")
	if hunt then hunt:SetAttribute("active", false) end
	if core then
		for _, child in core:GetChildren() do
			if child.Name == "CombatFlinch" then child:Destroy() end
		end
	end
	if blur then blur.Size = 0; blur.Enabled = false end
	lastFlinch = -math.huge
	lastHeartbeat = -math.huge
end

function Service.Flinch(direction)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	if player:GetAttribute("CantFlinch") or character:GetAttribute("StatusImmune")
		or character:GetAttribute("DamageFlinchImmune") then return end
	local now = os.clock()
	if now - lastFlinch < 0.35 then return end
	lastFlinch = now
	cameraKick = Vector2.new(math.rad(1.5), math.rad(math.random(-10, 10) / 10))
	local core = coreGame()
	local template = image(core, "flinch")
	if template then
		local flash = template:Clone()
		flash.Name = "CombatFlinch"
		flash.Visible = true
		flash.ImageTransparency = 0
		flash.Parent = core
		TweenService:Create(flash, TweenInfo.new(0.6), {ImageTransparency = 1}):Play()
		Debris:AddItem(flash, 0.65)
	end
	-- Retain the existing camera/movement signal used by the framework.
	player:SetAttribute("Flinch", direction or 3)
end

function Service.start_module()
	if started then return end
	started = true
	blur = Instance.new("BlurEffect")
	blur.Name = "CombatInjuryBlur"
	blur.Size = 0
	blur.Enabled = false
	blur.Parent = Lighting
	player.CharacterAdded:Connect(function() reset(coreGame()) end)
	RunService:BindToRenderStep("CombatFlinchCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
		local camera = workspace.CurrentCamera
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if camera and humanoid and humanoid.Health > 0 and player:GetAttribute("MenuOpen") ~= true then
			camera.CFrame *= CFrame.Angles(cameraKick.X, cameraKick.Y, 0)
		end
		cameraKick *= math.exp(-18 * dt)
	end)
	RunService.RenderStepped:Connect(function(dt)
		local core = coreGame()
		if core ~= currentCore then reset(currentCore); currentCore = core; reset(core) end
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local alive = humanoid ~= nil and humanoid.Health > 0
		local injured = alive and humanoid.Health < 100
		local concussion = alive and player:GetAttribute("Concussion") == true
		local hunted = alive and (player:GetAttribute("Hunted") == true or character:FindFirstChild("geist_hunted") ~= nil)
		local hunt = image(core, "hunt_vignette")
		if hunt and hunted ~= huntActive then
			huntActive = hunted
			huntVersion += 1
			local version = huntVersion
			if huntTween then huntTween:Cancel() end
			hunt:SetAttribute("active", hunted)
			hunt.Visible = true
			huntTween = TweenService:Create(hunt, TweenInfo.new(hunted and 0.25 or 1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {ImageTransparency = hunted and 0 or 1})
			huntTween.Completed:Once(function(state)
				if state == Enum.PlaybackState.Completed and version == huntVersion and not hunted then hunt.Visible = false end
			end)
			huntTween:Play()
		end
		local alpha = 1 - math.exp(-6.32 * dt)
		local pulse = math.sin(os.clock() * 1.5) / 10
		local morale = alive and player:GetAttribute("Morale") == true
		for _, entry in {{"healthlow", injured and 0 or 1}, {"injuredhealth", (injured or concussion) and 0.5 or 1}, {"morale", morale and 0.95 or 1}} do
			local overlay = image(core, entry[1])
			if overlay then
				overlay.ImageTransparency += (entry[2] - overlay.ImageTransparency) * alpha
				overlay.Visible = alive and overlay.ImageTransparency < 0.999
				if entry[1] == "injuredhealth" and (injured or concussion) then
					overlay.Size = overlay.Size:Lerp(UDim2.fromScale(1.1 - pulse, 1.1 - pulse), alpha)
				end
			end
		end
		local targetBlur = (injured or concussion) and (5 + math.abs(pulse * 50)) or 0
		blur.Size += (targetBlur - blur.Size) * alpha
		blur.Enabled = alive and blur.Size > 0.01
		if injured and os.clock() - lastHeartbeat >= 1.5 then
			lastHeartbeat = os.clock()
			Audio.Play("Game", "heartbeat")
		end
		if not alive then reset(core) end
	end)
end

return Service
