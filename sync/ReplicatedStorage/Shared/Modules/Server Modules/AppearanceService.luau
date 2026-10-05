local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Appearance = require(Shared.Library.CosmeticAppearance)
local module = {}
local started = false
function module.start_module()
	if started then return end
	started = true
	local remote = Shared.Library.Events:FindFirstChild("Appearance") or Instance.new("RemoteEvent")
	remote.Name, remote.Parent = "Appearance", Shared.Library.Events
	local last = {}
	remote.OnServerEvent:Connect(function(player, category, choice)
		if typeof(category) ~= "string" or typeof(choice) ~= "string" or #choice > 100 then return end
		if os.clock() - (last[player] or 0) < 0.1 then return end
		last[player] = os.clock()
		if not player:GetAttribute("PlayerDataReady") then return end
		local data = Appearance.Data(player)
		if not data then return end
		if category ~= "Accessories" then
			local definition
			for _, entry in Appearance.Categories do if entry.Key == category then definition = entry; break end end
			if not definition or not table.find(definition.Choices, choice) then return end
			local value = data:FindFirstChild(category)
			if not value then value = Instance.new("StringValue"); value.Name = category; value.Parent = data end
			if not value:IsA("StringValue") then return end
			value.Value = choice
		elseif category == "Accessories" then
			local assets = Appearance.Assets()
			local source = assets and assets:FindFirstChild(choice)
			if choice ~= "None" and (not source or not (source:IsA("Model") or source:IsA("Accessory") or source:IsA("BasePart"))) then return end
			local folder = data:FindFirstChild("Accessories")
			if not folder then folder = Instance.new("Folder"); folder.Name = "Accessories"; folder.Parent = data end
			if choice == "None" then
				for _, value in folder:GetChildren() do if value:IsA("BoolValue") then value.Value = false end end
			else
				local value = folder:FindFirstChild(choice)
				if not value then value = Instance.new("BoolValue"); value.Name = choice; value.Parent = folder end
				if not value:IsA("BoolValue") then return end
				value.Value = not value.Value
			end
		end
		if player.Character then
			if category == "Helmet" then
				require(Shared.Library.ClassAppearance).Apply(player.Character, player.Team and player.Team.Name, player.Character:GetAttribute("Class") or "Soldat", true)
			end
			Appearance.Apply(player.Character, data)
		end
	end)
	Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
end
return module
