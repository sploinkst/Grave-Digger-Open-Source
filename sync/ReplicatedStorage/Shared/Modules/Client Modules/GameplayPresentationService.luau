--!strict

-- Client presentation behavior retained from the legacy ingame controller.
-- Authoritative combat, movement, inventory, and interaction behavior belongs
-- to their dedicated services; this module only owns local UI/preferences.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local ClientModules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Client Modules")
local SettingsManager = require(ClientModules:WaitForChild("SettingsManager"))

local Service = {}
local started = false
local hudHidden = false
local characterConnections: { RBXScriptConnection } = {}

local function disconnectCharacterConnections()
	for _, connection in characterConnections do
		connection:Disconnect()
	end
	table.clear(characterConnections)
end

local function getCoreGame(): GuiObject?
	local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	local main = playerGui and playerGui:FindFirstChild("main")
	local coreGame = main and main:FindFirstChild("core_game")
	return if coreGame and coreGame:IsA("GuiObject") then coreGame else nil
end

local function clearTransientChildren(container: Instance?, preservedName: string)
	if not container then return end
	for _, child in container:GetChildren() do
		if child.Name ~= preservedName then
			child:Destroy()
		end
	end
end

local function setVisible(parent: Instance?, name: string, visible: boolean)
	local object = parent and parent:FindFirstChild(name)
	if object and object:IsA("GuiObject") then
		object.Visible = visible
	end
end

local function isDreadnought(character: Model): boolean
	return character:GetAttribute("IsDreadnought") == true
		or character:GetAttribute("Dreadnought") == true
		or character:FindFirstChild("dreadnought") ~= nil
end

local function refreshHelmetOverlay(character: Model)
	if character ~= LocalPlayer.Character then return end
	setVisible(getCoreGame(), "helmetoverlay", isDreadnought(character))
end

local function resetCharacterHud(character: Model)
	local coreGame = getCoreGame()
	if not coreGame then return end

	setVisible(coreGame, "akimbocrosshair", false)
	setVisible(coreGame, "barrelobstruction", false)
	setVisible(coreGame, "binocsoverlay", false)
	setVisible(coreGame, "voicewheel", false)
	clearTransientChildren(coreGame:FindFirstChild("splatters"), "ex")
	clearTransientChildren(coreGame:FindFirstChild("rotating_indicator"), "ex")
	refreshHelmetOverlay(character)

	local main = coreGame.Parent
	setVisible(main, "dot_crosshair", false)
	coreGame.Visible = not hudHidden
end

local function currentBooleanSetting(categoryName: string, settingName: string): boolean
	local playerData = LocalPlayer:FindFirstChild("PlayerData")
	local settings = playerData and playerData:FindFirstChild("Settings Data")
	local category = settings and settings:FindFirstChild(categoryName)
	local setting = category and category:FindFirstChild(settingName)
	local current = setting and setting:FindFirstChild("Current")
	return current ~= nil and current:IsA("BoolValue") and current.Value
end

local function applyAutomaticFirstPerson(character: Model)
	if not currentBooleanSetting("Immersion", "AutomaticFirstPerson") then return end
	task.defer(function()
		if character ~= LocalPlayer.Character then return end
		local cameraService = require(ClientModules:WaitForChild("CameraService"))
		for _ = 1, 120 do
			if character ~= LocalPlayer.Character then return end
			local cameraController = cameraService.GetCurrentCamera()
			if cameraController and type(cameraController.Switch_Camera) == "function" then
				cameraController:Switch_Camera("FirstPerson")
				return
			end
			task.wait(0.05)
		end
		warn("[GameplayPresentationService] Camera was not ready for AutomaticFirstPerson")
	end)
end

local function bindCharacter(character: Model)
	disconnectCharacterConnections()
	resetCharacterHud(character)
	applyAutomaticFirstPerson(character)

	table.insert(characterConnections, character:GetAttributeChangedSignal("IsDreadnought"):Connect(function()
		refreshHelmetOverlay(character)
	end))
	table.insert(characterConnections, character:GetAttributeChangedSignal("Dreadnought"):Connect(function()
		refreshHelmetOverlay(character)
	end))
	table.insert(characterConnections, character.ChildAdded:Connect(function(child)
		if string.lower(child.Name) == "dreadnought" then refreshHelmetOverlay(character) end
	end))
	table.insert(characterConnections, character.ChildRemoved:Connect(function(child)
		if string.lower(child.Name) == "dreadnought" then refreshHelmetOverlay(character) end
	end))

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)
	if humanoid and humanoid:IsA("Humanoid") then
		table.insert(characterConnections, humanoid.Died:Connect(function()
			resetCharacterHud(character)
			setVisible(getCoreGame(), "helmetoverlay", false)
		end))
	end
end

local function toggleHud(_: string, pressed: boolean)
	if not pressed then return end
	hudHidden = not hudHidden
	local coreGame = getCoreGame()
	if coreGame then coreGame.Visible = not hudHidden end
end

local function wipeFace(_: string, pressed: boolean)
	if not pressed then return end
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local coreGame = getCoreGame()
	local splatters = coreGame and coreGame:FindFirstChild("splatters")
	if not splatters then return end
	for _, splatter in splatters:GetChildren() do
		if splatter.Name == "splat" or string.find(string.lower(splatter.Name), "facewipe", 1, true) then
			splatter:Destroy()
		end
	end
end

function Service.start_module()
	if started then return end
	started = true

	SettingsManager.HookInput("Hide Hud", toggleHud)
	SettingsManager.HookInput("Wipe Face", wipeFace)
	LocalPlayer.CharacterAdded:Connect(bindCharacter)
	LocalPlayer.CharacterRemoving:Connect(disconnectCharacterConnections)
	if LocalPlayer.Character then bindCharacter(LocalPlayer.Character) end
end

return Service
