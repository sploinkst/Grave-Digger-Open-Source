-- First-aid alternate action: the server owns the treatment delay and cure.
local RS = game:GetService("ReplicatedStorage")
local Chemicals = require(script.Parent.ChemicalService)
local Remote = RS.Shared.Library.Events:WaitForChild("MedicalAction")
local Service = {}
local pending = setmetatable({}, {__mode = "k"})

local function cancel(player)
	local state = pending[player]
	if not state then return end
	pending[player] = nil
	state.character:SetAttribute("TakingTablets", nil)
	state.character:SetAttribute("TabletMovementMultiplier", nil)
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	Remote.OnServerEvent:Connect(function(player, action)
		if action == "CancelTablets" then cancel(player); return end
		if action ~= "TakeTablets" or pending[player] then return end
		local character = player.Character
		local health = character and character:FindFirstChildOfClass("Humanoid")
		local tool = character and character:FindFirstChild("Medkit")
		if not health or health.Health <= 0 or not tool or not tool:IsA("Tool")
			or character:GetAttribute("ActionBlocked") or character:GetAttribute("CombatStunned") then return end
		local state = {character = character, tool = tool}
		pending[player] = state
		character:SetAttribute("TakingTablets", true)
		character:SetAttribute("TabletMovementMultiplier", if character:GetAttribute("MobileSurgery") then nil else 0.6)
		task.delay(2, function()
			if pending[player] ~= state then return end
			if player.Character == character and health.Health > 0 and tool.Parent == character
				and not character:GetAttribute("ActionBlocked") then Chemicals.Detoxify(player) end
			cancel(player)
		end)
	end)
	game:GetService("Players").PlayerRemoving:Connect(cancel)
end

return Service
