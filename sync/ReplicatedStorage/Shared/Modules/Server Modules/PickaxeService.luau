local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Rules = require(ReplicatedStorage.Shared.Library.PickaxeRules)
local Validation = require(script.Parent.MasterActions.Validation)
local GunloadingSounds = require(ReplicatedStorage.Shared.Library.GunloadingSounds)
local SoundPlayback = require(ReplicatedStorage.Shared.Library.SoundPlayback)
local remote = Validation.Remote("PickaxeAction")
local Service = {}
local sharpening = setmetatable({}, {__mode = "k"})

function Service.Initialize(tool)
	if tool.Name ~= "HeavyPickaxe" then return end
	tool:SetAttribute("PickDurability", Rules.MaxDurability)
	tool:SetAttribute("MaxPickDurability", Rules.MaxDurability)
	tool:SetAttribute("SharpeningStones", Rules.MaxStones)
	tool:SetAttribute("WeakMining", false)
	tool:SetAttribute("Sharpening", false)
end

local function tools(player)
	local result = {}
	for _, container in pairs({player.Character, player:FindFirstChildOfClass("Backpack")}) do
		for _, tool in ipairs(container:GetChildren()) do
			if tool:IsA("Tool") and tool.Name == "HeavyPickaxe" then table.insert(result, tool) end
		end
	end
	return result
end

function Service.NeedsRestock(player)
	for _, tool in ipairs(tools(player)) do
		if (tool:GetAttribute("SharpeningStones") or 0) < Rules.MaxStones then return true end
	end
	return false
end

function Service.Restock(player)
	for _, tool in ipairs(tools(player)) do
		-- Resupply replaces the stone; sharpening remains a separate player action.
		tool:SetAttribute("SharpeningStones", Rules.MaxStones)
	end
end

function Service.MiningMode(tool, precise)
	if tool.Name ~= "HeavyPickaxe" then return precise and "Precise" or "Regular" end
	return Rules.Strike(tool:GetAttribute("PickDurability") or 0, tool:GetAttribute("WeakMining") == true, precise)
end

function Service.RecordHit(player, tool, precise)
	if tool.Name ~= "HeavyPickaxe" then return end
	local before = tool:GetAttribute("PickDurability") or 0
	local _, after = Rules.Strike(before, tool:GetAttribute("WeakMining") == true, precise)
	tool:SetAttribute("PickDurability", after)
	if before > 0 and after == 0 then remote:FireClient(player, tool, "Message", "Dulled") end
end

local function finish(player, tool, state, cancelled)
	if sharpening[tool] ~= state then return end
	sharpening[tool] = nil
	for _, connection in ipairs(state.connections) do connection:Disconnect() end
	tool:SetAttribute("Sharpening", false)
	if player.Parent then remote:FireClient(player, tool, cancelled and "Cancelled" or "Finished") end
end

local function startSharpen(player, tool, character, humanoid)
	if sharpening[tool] then return end
	local reason = Rules.SharpenError(tool:GetAttribute("PickDurability") or 0, tool:GetAttribute("SharpeningStones") or 0)
	if reason then remote:FireClient(player, tool, "Message", reason); return end
	local state = {connections = {}}
	sharpening[tool] = state
	tool:SetAttribute("SharpeningStones", tool:GetAttribute("SharpeningStones") - 1)
	tool:SetAttribute("Sharpening", true)
	local function valid()
		return sharpening[tool] == state and player.Character == character
			and Validation.Tool(player, tool, {"HeavyPickaxe"}) ~= nil
	end
	table.insert(state.connections, tool:GetPropertyChangedSignal("Parent"):Connect(function()
		if tool.Parent ~= character then finish(player, tool, state, true) end
	end))
	table.insert(state.connections, humanoid.Died:Connect(function() finish(player, tool, state, true) end))
	remote:FireClient(player, tool, "Started")
	task.delay(Rules.SharpenTime, function()
		if not valid() then finish(player, tool, state, true); return end
		tool:SetAttribute("PickDurability", Rules.MaxDurability)
		local sound = GunloadingSounds.Find("finishsharpen")
		local root = character:FindFirstChild("HumanoidRootPart")
		if sound and root then SoundPlayback.Play(sound, root, {PitchVariation = 0.1}) end
	end)
	task.delay(Rules.SharpenTime + Rules.SharpenRecovery, function()
		finish(player, tool, state, not valid())
	end)
end

local function spark(character)
	local arm = character:FindFirstChild("Left Arm")
	if not arm then return end
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, -0.8, 0)
	attachment.Parent = arm
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 198, 90))
	emitter.Size = NumberSequence.new(0.08)
	emitter.Lifetime = NumberRange.new(0.1, 0.25)
	emitter.Speed = NumberRange.new(2, 5)
	emitter.SpreadAngle = Vector2.new(40, 40)
	emitter.LightEmission = 1
	emitter.Rate = 0
	emitter.Parent = attachment
	task.delay(0.05, function()
		if emitter.Parent then emitter:Emit(8) end
	end)
	Debris:AddItem(attachment, 1)
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	remote.OnServerEvent:Connect(function(player, tool, action)
		if type(action) ~= "string" then return end
		local character, _, humanoid = Validation.Tool(player, tool, {"HeavyPickaxe"})
		if not character then return end
		if action == "Cancel" then
			local state = sharpening[tool]
			if state then finish(player, tool, state, true) end
		elseif action == "Spark" then
			if sharpening[tool] and Validation.Cooldown(player, "PickSpark", 0.1) then spark(character) end
		elseif not tool:GetAttribute("Sharpening") and Validation.Cooldown(player, "PickAction", 0.15) then
			if action == "ToggleStrength" then
				if (tool:GetAttribute("PickDurability") or 0) <= 0 then
					remote:FireClient(player, tool, "Message", "Dulled")
					return
				end
				local weak = not tool:GetAttribute("WeakMining")
				tool:SetAttribute("WeakMining", weak)
				remote:FireClient(player, tool, "Message", weak and "Weak" or "Heavy")
			elseif action == "Sharpen" then
				startSharpen(player, tool, character, humanoid)
			end
		end
	end)
end

return Service
