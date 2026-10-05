-- Patient condition is a player-level HUD feature, independent of tool controllers.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Medical = require(RS.Shared.Library.MedicalRules)
local Targeting = require(script.Parent.MedicalUI.Targeting)
local PatientView = require(script.Parent.MedicalUI.PatientView)
local Service = {}

local function hasChemist(character)
	local data = character:FindFirstChild("CharacterData")
	local perks = data and data:FindFirstChild("Perks")
	local perk = perks and perks:FindFirstChild("Chemist")
	return perk and (not perk:IsA("BoolValue") or perk.Value)
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	local view = PatientView.new()
	local elapsed = 0
	RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.1 then return end
		elapsed = 0
		local player = Players.LocalPlayer
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 or player:GetAttribute("MenuOpen") then view:Hide(); return end
		local mortician = character:GetAttribute("Class") == "Mortician"
		if not mortician and not character:FindFirstChild("Medkit") then view:Hide(); return end
		local patient = Targeting.Find(mortician and Medical.PatientRange or Medical.FirstAidPatientRange)
		if not patient then view:Hide(); return end
		local report = Medical.Patient(patient.humanoid.Health, patient.humanoid.MaxHealth, patient.character:GetAttribute("IsDreadnought"))
		view:Show(patient, report, patient.character:GetAttribute("ChemicalUnits") or 0,
			patient.player:GetAttribute("Sickness") == true, hasChemist(character))
	end)
	Players.LocalPlayer.CharacterRemoving:Connect(function() view:Hide() end)
end

return Service
