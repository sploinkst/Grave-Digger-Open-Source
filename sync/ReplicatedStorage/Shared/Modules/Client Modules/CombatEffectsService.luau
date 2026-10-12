local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")
local Audio = require(game:GetService("ReplicatedStorage").Shared.Library.GameAudio)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Library = ReplicatedStorage.Shared.Library
local Assets = require(Library.AuthoredAssets)
local Playback = require(Library.SoundPlayback)
local Classes = require(Library.ClassDefinitions)
local Rules = require(Library.CombatFeedbackRules)
local Service = {}
local lastWhizz, lastEarRing = -math.huge, -math.huge
local ringingUntil = 0
local ringingSound
local activeSounds, tracks, mufflers = {}, {}, {}
local observed = {}
local epoch = 0
local soundIds = {
	bullet_whizz1 = 3809084884, bullet_whizz2 = 3809085250,
	bullet_whizz3 = 3809085650, bullet_whizz4 = 3809085996, bullet_whizz5 = 3809086455,
	earring = 9069161602, helmet_hit = 18445960698,
}
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
	return Assets.CoreGame()
end

local function image(core, name)
	local object = Assets.Widget(name) or (core and core:FindFirstChild(name))
	return object and (object:IsA("ImageLabel") or object:IsA("ImageButton")) and object or nil
end

local function living()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid and humanoid.Health > 0 and player:GetAttribute("MenuOpen") ~= true
end

local function setting(name)
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("Settings Data")
	local entry = data and data:FindFirstChild(name, true)
	local current = entry and entry:FindFirstChild("Current")
	return current and current:IsA("BoolValue") and current.Value == true
end

local function playSound(name, variation)
	local roots = {ReplicatedStorage.Shared.Assets}
	local source = Assets.Find(name, roots, "Sound")
	local fallback
	if not source and soundIds[name] then
		fallback = Instance.new("Sound")
		fallback.SoundId = "rbxassetid://" .. soundIds[name]
		fallback.Volume = name == "helmet_hit" and 2 or 1
		fallback.PlaybackSpeed = name == "earring" and 1.5 or 1
		source = fallback
	end
	if not source then return end
	local sound = Playback.Play(source, nil, {PitchVariation = variation or 0})
	if fallback then fallback:Destroy() end
	if sound then
		if name == "earring" or name == "helmet_hit" then sound.SoundGroup = nil end
		activeSounds[sound] = true
		sound.Destroying:Once(function() activeSounds[sound] = nil end)
	end
	return sound
end

local function playBody(name, priority, weight, speed)
	local character = player.Character
	if not character or character:FindFirstChild("exec") or character:FindFirstChild("execing") then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end
	local track = tracks[name]
	if not track then
		local source = Assets.Find(name, {ReplicatedStorage}, "Animation")
		if not source then return end
		local ok, loaded = pcall(function() return animator:LoadAnimation(source) end)
		if not ok then return end
		track = loaded; tracks[name] = track
	end
	track.Priority = priority
	track:Play(0.05, weight, speed)
end

local function flinchImmune()
	local character = player.Character
	return not character or Classes.HasPerk(player, "Leatherneck")
		or character:GetAttribute("SuppressionImmune") or character:GetAttribute("IsDreadnought")
		or character:FindFirstChild("dreadnought") ~= nil
		or player:GetAttribute("CantFlinch") or character:GetAttribute("StatusImmune")
		or character:GetAttribute("DamageFlinchImmune")
		or character:GetAttribute("Class") == "Vanguard"
end

function Service.BloodSplatter(count)
	if not living() or setting("HideBloodSmear") or setting("DisableBloodScreen") or setting("disablebloodscreen") then return end
	local core = coreGame()
	local container = core and core:FindFirstChild("splatters")
	if not container then return end
	local template = container:FindFirstChild("ex")
	for _ = 1, math.clamp(math.floor(tonumber(count) or 1), 1, 5) do
		-- Cap accumulation during rapid fire without removing the authored template.
		local existing = {}
		for _, child in container:GetChildren() do if child.Name == "splat" then table.insert(existing, child) end end
		if #existing >= 20 then existing[1]:Destroy() end
		local splat = template and template:Clone() or Instance.new("Frame")
		splat.Name = "splat"; splat.Visible = true
		splat.AnchorPoint = Vector2.new(0.5, 0.5)
		splat.Position = UDim2.fromScale(math.random(10, 90) / 100, math.random(10, 90) / 100)
		if not template then splat.BackgroundTransparency = 1; splat.Size = UDim2.fromScale(0.4, 0.4) end
		local img = splat:FindFirstChild("img")
		if not img then img = Instance.new("ImageLabel"); img.Name = "img"; img.BackgroundTransparency = 1; img.Parent = splat end
		img.Image = "rbxassetid://" .. Rules.BloodImages[math.random(#Rules.BloodImages)]
		img.Rotation = math.random(0, 360)
		local size = math.random(50, 200) / 100
		img.Size = UDim2.fromScale(size, size); img.ImageTransparency = 0
		splat.Parent = container
		TweenService:Create(img, TweenInfo.new(2), {ImageTransparency = 0.5}):Play()
		local version = epoch
		task.delay(math.random(20, 50), function()
			if version ~= epoch or not splat.Parent or not img.Parent then return end
			TweenService:Create(img, TweenInfo.new(0.6), {ImageTransparency = 1}):Play()
			Debris:AddItem(splat, 0.65)
		end)
	end
end

function Service.EarRing(force)
	local character = player.Character
	local immune = Classes.HasPerk(player, "Leatherneck") or (character and character:GetAttribute("ConcussionImmune"))
	local now = os.clock()
	if player:GetAttribute("Concussion") ~= true or not living() or immune then return end
	lastEarRing = now
	ringingUntil = now + 2.5
	if ringingSound then ringingSound:Destroy() end
	ringingSound = playSound("earring")
	if character:GetAttribute("Class") ~= "Vanguard" then
		playBody(math.random(1, 2) == 1 and "coverexplosion_larm" or "coverexplosion_rarm", Enum.AnimationPriority.Action2, 1, 0.5)
	end
	for _, name in {"mainSoundGroup", "maskSoundGroup", "radioSoundGroup"} do
		local group = SoundService:FindFirstChild(name)
		if group and group:IsA("SoundGroup") and not mufflers[group] then
			local effect = Instance.new("EqualizerSoundEffect")
			effect.Name = "CombatEarMuffle"; effect.HighGain = -25; effect.MidGain = -12; effect.LowGain = 0
			effect.Parent = group; mufflers[group] = effect
		end
	end
end

function Service.NearMiss(direction)
	local now = os.clock()
	if not living() or now - lastWhizz < Rules.WhizzCooldown then return end
	lastWhizz = now
	-- The master plays the whizz even when the class/perk suppresses flinching.
	playSound("bullet_whizz" .. math.random(1, 5), 0.1)
	if flinchImmune() then return end
	Service.Flinch(direction)
	playBody("miss_flinch" .. math.random(1, 4), Enum.AnimationPriority.Action4, 0.5, 2)
end

local function reset(core)
	epoch += 1
	lastWhizz, lastEarRing, ringingUntil = -math.huge, -math.huge, 0
	for sound in activeSounds do sound:Destroy() end
	table.clear(activeSounds)
	for _, track in tracks do track:Stop(0); track:Destroy() end
	table.clear(tracks)
	for _, effect in mufflers do effect:Destroy() end
	table.clear(mufflers)
	local splatters = core and core:FindFirstChild("splatters")
	if splatters then
		for _, child in splatters:GetChildren() do if child.Name == "splat" then child:Destroy() end end
	end
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
	if flinchImmune() then return end
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
		flash.Parent = template.Parent
		TweenService:Create(flash, TweenInfo.new(0.6), {ImageTransparency = 1}):Play()
		Debris:AddItem(flash, 0.65)
	end
	-- Retain the existing camera/movement signal used by the framework.
	player:SetAttribute("Flinch", direction or 3)
end

local function observePlayer(target)
	if observed[target] then return end
	local record = {}; observed[target] = record
	local function attach(character)
		if record.health then record.health:Disconnect(); record.health = nil end
		task.spawn(function()
			local humanoid = character:WaitForChild("Humanoid", 10)
			if not humanoid or target.Character ~= character or observed[target] ~= record then return end
			local previous = humanoid.Health
			record.health = humanoid.HealthChanged:Connect(function(health)
				local damage = previous - health; previous = health
				if damage <= 0 or not living() then return end
				if target == player then
					Service.BloodSplatter(damage >= 70 and 2 or 1)
				else
					local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
					local hit = character:FindFirstChild("HumanoidRootPart")
					if root and hit then
						local offset = hit.Position - root.Position
						if Rules.NearBlood(offset.Magnitude, root.CFrame.LookVector:Dot(offset)) then Service.BloodSplatter(math.random(3, 5)) end
					end
				end
			end)
		end)
	end
	record.added = target.CharacterAdded:Connect(attach)
	record.removing = target.CharacterRemoving:Connect(function()
		if record.health then record.health:Disconnect(); record.health = nil end
	end)
	if target.Character then attach(target.Character) end
end

function Service.start_module()
	if started then return end
	started = true
	currentCore = coreGame()
	blur = Instance.new("BlurEffect")
	blur.Name = "CombatInjuryBlur"
	blur.Size = 0
	blur.Enabled = false
	blur.Parent = Lighting
	player.CharacterAdded:Connect(function() reset(coreGame()) end)
	player.CharacterRemoving:Connect(function() reset(coreGame()) end)
	for _, target in Players:GetPlayers() do observePlayer(target) end
	Players.PlayerAdded:Connect(observePlayer)
	Players.PlayerRemoving:Connect(function(target)
		local record = observed[target]
		if record then for _, connection in record do connection:Disconnect() end end
		observed[target] = nil
	end)
	player:GetAttributeChangedSignal("Concussion"):Connect(function()
		if player:GetAttribute("Concussion") then Service.EarRing(1000)
		else
			ringingUntil = 0
			if ringingSound then ringingSound:Destroy(); ringingSound = nil end
		end
	end)
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
		local now = os.clock()
		if ringingSound and (now >= ringingUntil or not living()) then ringingSound:Destroy(); ringingSound = nil end
		for group, effect in mufflers do
			if now >= ringingUntil or not living() then effect:Destroy(); mufflers[group] = nil
			else
				local strength = math.clamp((ringingUntil - now) / 2, 0, 1)
				effect.HighGain = -25 * strength; effect.MidGain = -12 * strength
			end
		end
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
		local targetBlur = concussion and (5 + math.abs(pulse * 50)) or 0
		if concussion then blur.Size += (targetBlur - blur.Size) * alpha else blur.Size = 0 end
		blur.Enabled = alive and blur.Size > 0.01
		if injured and os.clock() - lastHeartbeat >= 1.5 then
			lastHeartbeat = os.clock()
			Audio.Play("Game", "heartbeat")
		end
		if not alive then reset(core) end
	end)
end

return Service
