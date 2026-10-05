-- Validates Mortician tool requests; delegates inventory and throws to focused modules.
local Service = {}
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Rules = require(RS.Shared.Library.ChemicalRules)
local Mixtures = require(script.Parent.Medical.Mixtures)
local State = require(script.Parent.Medical.MixtureState)
local Bottle = require(script.Parent.Medical.Bottle)
local Remote = RS.Shared.Library.Events:WaitForChild("StimulantCompounds")

function Service.Restock(player) Mixtures.Restock(player) end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	Remote.OnServerEvent:Connect(function(player, action, argument)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local tool = character and character:FindFirstChild("StimulantCompounds")
		if not humanoid or humanoid.Health <= 0 or not tool or not tool:IsA("Tool")
			or character:GetAttribute("Class") ~= "Mortician" or character:GetAttribute("ActionBlocked")
			or character:GetAttribute("CombatStunned") then return end
		local state = Mixtures.Get(character)
		if os.clock() < state.ready then return end
		if action == "Mix" then
			if type(argument) ~= "string" or not Rules.Definitions[argument] or state.supplies < 1 then return end
			State.Mix(state, argument); state.ready = os.clock() + 0.73
		elseif action == "Discard" then
			State.Discard(state); state.ready = os.clock() + 0.75
		elseif action == "Throw" then
			if #state.mix == 0 or typeof(argument) ~= "Vector3" or argument.X ~= argument.X
				or argument.Y ~= argument.Y or argument.Z ~= argument.Z or argument.Magnitude < 0.99 or argument.Magnitude > 1.01 then return end
			if not Bottle.Throw(player, character, argument, state.mix) then return end
			State.Discard(state); state.ready = os.clock() + 0.75
		else return end
		Mixtures.Publish(character, state)
	end)

	task.spawn(function()
		while true do
			for _, player in Players:GetPlayers() do
				local character = player.Character
				if character and character:GetAttribute("Class") == "Mortician" then Mixtures.Get(character) end
			end
			task.wait(0.25)
		end
	end)
end

return Service
