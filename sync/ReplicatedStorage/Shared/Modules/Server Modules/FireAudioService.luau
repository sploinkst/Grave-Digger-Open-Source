local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Playback = require(RS.Shared.Library.SoundPlayback)
local Service = {}
local bound = setmetatable({}, {__mode = "k"})
local function choose(name)
	local sounds = RS.Shared.Assets:FindFirstChild("Sounds")
	local folder = sounds and sounds:FindFirstChild("fire_fx")
	if not folder then return nil end
	local exact = folder:FindFirstChild(name)
	if exact and exact:IsA("Sound") then return exact end
	local clips = {}
	for _, sound in folder:GetChildren() do
		if sound:IsA("Sound") and sound.Name:sub(1,#name)==name and sound.Name:sub(#name+1):match("^%d+$") then table.insert(clips,sound) end
	end
	return #clips>0 and clips[math.random(#clips)] or nil
end
local function bind(character)
	if bound[character] then return end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end
	bound[character] = true
	local loop, generation, active = nil, 0, false
	local function stop()
		generation += 1; active = false
		if loop then loop:Destroy(); loop = nil end
	end
	local function update()
		local burning = character:GetAttribute("Burning") == true and humanoid.Health > 0
		if not burning then stop(); return end
		if active then return end
		active = true; generation += 1
		local token = generation
		local ignite = choose("fire_ignite")
		if ignite then Playback.Play(ignite,root,{RollOffMaxDistance=75}) end
		local source = choose("fire_loop")
		if source then
			loop = source:Clone(); loop.Looped = true; loop.RollOffMaxDistance = 75
			loop.RollOffMinDistance = math.min(loop.RollOffMinDistance,75)
			loop.Parent = root; loop:Play()
		end
		task.spawn(function()
			while active and generation == token and character.Parent and humanoid.Health > 0 do
				if character:GetAttribute("LethalBurning") or character:GetAttribute("DamageDealingBlocked") then
					local extra = choose("fire_extra")
					if extra then Playback.Play(extra,root,{RollOffMaxDistance=75}) end
				end
				task.wait(1)
			end
		end)
	end
	character:GetAttributeChangedSignal("Burning"):Connect(update)
	humanoid.Died:Connect(stop)
	character.Destroying:Connect(stop)
	character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(workspace) then stop() end
	end)
	update()
end
function Service.start_module()
	if Service.started then return end
	Service.started = true
	local function playerAdded(player)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("Humanoid"); character:WaitForChild("HumanoidRootPart"); bind(character)
		end)
		if player.Character then task.defer(bind,player.Character) end
	end
	Players.PlayerAdded:Connect(playerAdded)
	for _, player in Players:GetPlayers() do playerAdded(player) end
	workspace.ChildAdded:Connect(function(model)
		if model:IsA("Model") then task.defer(bind,model) end
	end)
	for _, model in workspace:GetChildren() do if model:IsA("Model") then bind(model) end end
end
return Service
