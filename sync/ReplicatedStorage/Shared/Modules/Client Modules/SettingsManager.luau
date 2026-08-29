local SettingsManager = {}

-- // Services
local Players 					= game:GetService("Players")
local InputService 				= game:GetService("UserInputService")
local ReplicatedStorage 		= game:GetService("ReplicatedStorage")

-- // Constants
local LocalPlayer
local PlayerData
local SettingsData
local InputsData

-- // Variables
local Inputs = {}      -- [InputName] = Enum.KeyCode
local BoundKeys = {}   -- [Enum.KeyCode] = {InputName1, InputName2, ...}
local Hooks = {}       -- [InputName] = {Callbacks}

local InputsLoaded = false

local function BindInput(inputName: string, keyCode: Enum.KeyCode)
	-- Remove old binding
	local oldKey = Inputs[inputName]
	if oldKey and BoundKeys[oldKey] then
		for i = #BoundKeys[oldKey], 1, -1 do
			if BoundKeys[oldKey][i] == inputName then
				table.remove(BoundKeys[oldKey], i)
			end
		end

		if #BoundKeys[oldKey] == 0 then
			BoundKeys[oldKey] = nil
		end
	end

	-- Store new binding
	Inputs[inputName] = keyCode

	BoundKeys[keyCode] = BoundKeys[keyCode] or {}
	table.insert(BoundKeys[keyCode], inputName)
end

local function RegisterInputs()
	table.clear(Inputs)
	table.clear(BoundKeys)

	for _, inputFolder in ipairs(InputsData.Binds:GetChildren()) do
		local currentValue = inputFolder:FindFirstChild("Current")

		if not currentValue then
			continue
		end

		local keyCode = Enum.KeyCode[currentValue.Value]

		if not keyCode then
			continue
		end

		BindInput(inputFolder.Name, keyCode)

		-- Update automatically when the player changes the binding
		currentValue:GetPropertyChangedSignal("Value"):Connect(function()
			local newKeyCode = Enum.KeyCode[currentValue.Value]

			if not newKeyCode then
				return
			end

			BindInput(inputFolder.Name, newKeyCode)
		end)
	end
	
	InputsLoaded = true
end

local function FireHooks(keyCode: Enum.KeyCode, pressed: boolean)
	local bindings = BoundKeys[keyCode]
	if not bindings then
		return
	end

	for _, inputName in ipairs(bindings) do
		local callbacks = Hooks[inputName]

		if callbacks then
			for _, callback in ipairs(callbacks) do
				callback(inputName, pressed)
			end
		end
	end
end

function SettingsManager.HookInput(inputName: string, callback)
	while not InputsLoaded do
		task.wait(1)
	end
	
	if not Inputs[inputName] then
		return
	end

	Hooks[inputName] = Hooks[inputName] or {}
	table.insert(Hooks[inputName], callback)
end

function SettingsManager.UnhookInput(inputName: string, callback)
	local callbacks = Hooks[inputName]
	if not callbacks then
		return
	end

	for i = #callbacks, 1, -1 do
		if callbacks[i] == callback then
			table.remove(callbacks, i)
		end
	end

	if #callbacks == 0 then
		Hooks[inputName] = nil
	end
end

function SettingsManager.start_module()
 	LocalPlayer 				= Players.LocalPlayer
 	PlayerData 				= LocalPlayer:WaitForChild("PlayerData")
 	SettingsData 				= PlayerData:WaitForChild("Settings Data")
 	InputsData 				= SettingsData:WaitForChild("Inputs")
	
	RegisterInputs()
end


InputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	FireHooks(input.KeyCode, true)
end)

InputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	FireHooks(input.KeyCode, false)
end)

return SettingsManager