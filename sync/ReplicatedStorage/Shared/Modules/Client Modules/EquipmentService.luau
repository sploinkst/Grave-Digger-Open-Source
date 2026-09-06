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

local activeEquipment
local equipmentConnection
local trackedCharacter
local function stopEquipment()
	if activeEquipment then
		if activeEquipment.Stop then activeEquipment:Stop() end
		activeEquipment = nil
	end
end
local function handleEquipment(character)
	stopEquipment()
	if character ~= LocalPlayer.Character then return end
	local state = character:FindFirstChild("CharacterData") and character.CharacterData:FindFirstChild("State")
	local equipmentValue = state and state:FindFirstChild("Equipment")
	local value = equipmentValue and equipmentValue:IsA("StringValue") and equipmentValue.Value
		or character:GetAttribute("Equipment") -- compatibility while remaining producers migrate
	local class = value and Classes[value]
	if not class then
		local root = character:FindFirstChild("HumanoidRootPart")
		local container = root and root:FindFirstChild("Equipment_BB")
		local gui = container and container:FindFirstChild("bb")
		if gui and gui:IsA("BillboardGui") then gui.Enabled = false end
		return
	end
	local object = class.new()
	activeEquipment = object
	object:Start(character)
end
local function TrackEquipment(character)
	if trackedCharacter == character then return end
	trackedCharacter = character
	if equipmentConnection then equipmentConnection:Disconnect() end
	stopEquipment()
	local state = character:WaitForChild("CharacterData"):WaitForChild("State")
	local equipmentValue = state:WaitForChild("Equipment") :: StringValue
	equipmentConnection = equipmentValue:GetPropertyChangedSignal("Value"):Connect(function()
		handleEquipment(character)
	end)
	handleEquipment(character)
end


function EquipmentService.start_module()
	FetchClasses()
	
	if LocalPlayer.Character then
		TrackEquipment(LocalPlayer.Character)
	end
	
	LocalPlayer.CharacterAdded:Connect(function(character)
		TrackEquipment(character)
	end)
	LocalPlayer.CharacterRemoving:Connect(function()
		if equipmentConnection then equipmentConnection:Disconnect(); equipmentConnection = nil end
		trackedCharacter = nil
		stopEquipment()
	end)
end

return EquipmentService
