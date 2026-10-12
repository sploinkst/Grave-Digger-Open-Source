local RS = game:GetService("ReplicatedStorage")
local V = require(script.Parent.MasterActions.Validation)
local Rules = require(RS.Shared.Library.RookLauncherRules)
local Ordnance = require(script.Parent.OrdnanceService)
local Service = {}
local remote = V.Remote("RookLauncherAction")
local sessions = setmetatable({}, {__mode = "k"})
local function track(player, tool)
	if sessions[tool] then return sessions[tool] end
	local state = {ready = os.clock() + Rules.DrawTime}
	sessions[tool] = state
	tool:GetPropertyChangedSignal("Parent"):Connect(function()
		state.token = nil
		tool:SetAttribute("LauncherReloading", false)
		state.ready = os.clock() + Rules.DrawTime
		remote:FireClient(player, tool, "Cancelled")
	end)
	return state
end

local function eligible(player)
	local character, root, humanoid = V.Living(player)
	if not character or V.State(character, "Class") ~= "Rook"
		or V.State(character, "Equipment") ~= "MiningBombLauncher" then return nil end
	return character, root, humanoid
end

function Service.Handle(player, tool, action, direction)
	local character, _, humanoid = eligible(player)
	if action == "ToggleEquip" then
		if not character or not V.Cooldown(player, "RookLauncherToggle", 0.3) then return end
		local held = character:FindFirstChild("RookLauncher")
		if held then humanoid:UnequipTools(); return end
		local backpack = player:FindFirstChild("Backpack")
		if not backpack then return end
		tool = backpack:FindFirstChild("RookLauncher")
		if not tool then
			require(script.Parent.ItemsService).give_item(player, "RookLauncher", nil, "Nil")
			tool = backpack:FindFirstChild("RookLauncher")
		end
		if tool and eligible(player) == character then track(player, tool); humanoid:EquipTool(tool) end
		return
	end
	if not character or not V.Tool(player, tool, {"RookLauncher"}) then
		remote:FireClient(player, tool, "Rejected"); return
	end
	local state = track(player, tool)
	local charges = Ordnance.GetCount(player, "MiningBombLauncher")
	local loaded = tool:GetAttribute("LauncherLoaded") == true
	local reloading = tool:GetAttribute("LauncherReloading") == true
	if action == "Fire" then
		local serverStuff = workspace and workspace:FindFirstChild("serverStuff")
		local values = serverStuff and serverStuff:FindFirstChild("values")
		local mode = values and values:FindFirstChild("gamemode")
		if character:FindFirstChild("oathbroken") or character:GetAttribute("Oathbroken")
			or (mode and mode.Value == "truce" and not character:FindFirstChild("engage")) then
			remote:FireClient(player, tool, "Rejected"); return
		end
		if not Rules.CanFire(loaded, reloading, charges) or not V.Direction(direction)
			or os.clock() < state.ready then
			remote:FireClient(player, tool, charges <= 0 and "Empty" or "Rejected"); return
		end
		if not Ordnance.Fire(player, "MiningBombLauncher", direction, tool) then
			remote:FireClient(player, tool, "Rejected"); return
		end
		tool:SetAttribute("LauncherLoaded", false)
		state.ready = os.clock() + Rules.FireInterval
		remote:FireClient(player, tool, "Fired")
	elseif action == "Reload" then
		if not Rules.CanReload(loaded, reloading, charges) then
			remote:FireClient(player, tool, charges <= 0 and "Empty" or "Rejected"); return
		end
		local token = {}
		state.token = token
		tool:SetAttribute("LauncherReloading", true)
		remote:FireClient(player, tool, "Reloading")
		local reloadTime = Rules.ReloadTime * (character:GetAttribute("Veteran") and 0.7 or 1)
		task.delay(reloadTime, function()
			if state.token ~= token then return end
			state.token = nil
			tool:SetAttribute("LauncherReloading", false)
			if eligible(player) ~= character or not V.Tool(player, tool, {"RookLauncher"})
				or Ordnance.GetCount(player, "MiningBombLauncher") <= 0 then
				remote:FireClient(player, tool, "Cancelled"); return
			end
			tool:SetAttribute("LauncherLoaded", true)
			remote:FireClient(player, tool, "Reloaded")
		end)
	else remote:FireClient(player, tool, "Rejected") end
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	remote.OnServerEvent:Connect(Service.Handle)
end
return Service
