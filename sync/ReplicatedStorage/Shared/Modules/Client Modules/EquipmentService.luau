local EquipmentService = {}
local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer

local EquipmentClasses = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Classes"):WaitForChild("EquipmentClasses")
local Classes = {}


local function FetchClasses()
	for _, module in EquipmentClasses:GetDescendants() do
		if module:IsA("ModuleScript") then
			local success, result = pcall(require, module)
			if success then
				Classes[module.Name] = result
			else
				warn("Failed to require module:", module.Name, "-", result)
			end
		end
	end
end
local function TrackEquipment(character)
	if not character:GetAttribute("Equipment") then character:SetAttribute("Equipment", "") end
	
	character:GetAttributeChangedSignal("Equipment"):Connect(function()
		local value = character:GetAttribute("Equipment")
		if value == "" then return end
		
		local class = Classes[value]
		if not class then print("Class not found for", value, Classes) return end
		
		local object = class.new()
		object:Start(character)
		print("Started", object.className, "for", character.Name)
	end)
end


function EquipmentService.start_module()
	FetchClasses()
	
	if LocalPlayer.Character then
		TrackEquipment(LocalPlayer.Character)
	end
	
	LocalPlayer.CharacterAdded:Connect(function(character)
		TrackEquipment(LocalPlayer.Character)
	end)
end

return EquipmentService
