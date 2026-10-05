local RS = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Chemicals = require(RS.Shared.Library.ChemicalRules)
local Medical = require(RS.Shared.Library.MedicalRules)
local Readout = {}
function Readout.ForPlayer(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return "", "" end
	local condition = Medical.Patient(humanoid.Health, humanoid.MaxHealth, false).label
	if player:GetAttribute("Sickness") then condition = "I'm feeling sick right now."
	elseif humanoid.Health < Medical.SurgeryThreshold then condition ..= ". I need Surgery."
	elseif humanoid.Health >= humanoid.MaxHealth then condition = "I'm all good." end
	local ok, snapshot = pcall(HttpService.JSONDecode, HttpService, character:GetAttribute("ChemicalSnapshot") or "[]")
	return condition, Chemicals.DescribeBloodstream(ok and snapshot or {}, workspace:GetServerTimeNow())
end
return Readout
