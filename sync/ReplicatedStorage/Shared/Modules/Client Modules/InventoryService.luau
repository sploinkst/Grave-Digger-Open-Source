--!strict

local Module = {}

-- // Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")

-- // References
local LocalPlayer = game.Players.LocalPlayer

-- // Constants
local EmptyIcon = "rbxassetid://112388032303745"
local TweenInfoDefault = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local FadeDelay = 5

local EquipmentBB = ReplicatedStorageService:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Equipment_BB")
local Utils = require(ReplicatedStorageService:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local InventorySlots = {
	["1"] = { Keybind = Enum.KeyCode.One, Tool = nil, UI = nil, Designation = "Primary", PermanentUISpot = true },
	["2"] = { Keybind = Enum.KeyCode.Two, Tool = nil, UI = nil, Designation = "Secondary", PermanentUISpot = true },
	["3"] = { Keybind = Enum.KeyCode.Three, Tool = nil, UI = nil, Designation = "Melee", PermanentUISpot = true },
	["4"] = { Keybind = Enum.KeyCode.Four, Tool = nil, UI = nil, Designation = "Mining", PermanentUISpot = true },
	["5"] = { Keybind = Enum.KeyCode.Five, Tool = nil, UI = nil, Designation = "Medkit", PermanentUISpot = true },
	["6"] = { Keybind = Enum.KeyCode.Six, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false },
	["7"] = { Keybind = Enum.KeyCode.Seven, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false },
	["8"] = { Keybind = Enum.KeyCode.Eight, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false },
	["9"] = { Keybind = Enum.KeyCode.Nine, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false },
	["0"] = { Keybind = Enum.KeyCode.Zero, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false },
}

local SlotOrder = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

-- // State
local currentEquipped = nil
local slotsVisible = false
local fadeToken = 0
local selectedKey = nil
local equipBusy = false
local equipmentDebounce = false
local equipmentBBClone = nil

-- // Helpers

local function GetSlotParts(ui)
	if not ui or not ui.Parent then return nil, nil, nil end
	local frame = ui:FindFirstChild("Frame", true)
	local image = ui:FindFirstChild("ImageLabel", true)
	local text = ui:FindFirstChild("Hotkey", true)
	return frame, image, text
end

local function TweenSlot(ui, props)
	local frame, image, text = GetSlotParts(ui)
	if not frame or not image or not text then
		return
	end

	if props.BackgroundTransparency then
		TweenService:Create(frame, TweenInfoDefault, { BackgroundTransparency = props.BackgroundTransparency }):Play()
	end
	if props.ImageTransparency then
		TweenService:Create(image, TweenInfoDefault, { ImageTransparency = props.ImageTransparency }):Play()
	end
	if props.TextTransparency then
		TweenService:Create(text, TweenInfoDefault, { TextTransparency = props.TextTransparency }):Play()
	end
	if props.BackgroundColor3 then
		TweenService:Create(frame, TweenInfoDefault, { BackgroundColor3 = props.BackgroundColor3 }):Play()
	end
	if props.ImageColor3 then
		TweenService:Create(image, TweenInfoDefault, { ImageColor3 = props.ImageColor3 }):Play()
	end
	if props.TextColor3 then
		TweenService:Create(text, TweenInfoDefault, { TextColor3 = props.TextColor3 }):Play()
	end
end

local function CreateSlotUI(slotNumber, slot)
	if slot.UI and slot.UI.Parent then
		-- // Already has a UI instance (e.g. AssignTool created it before
		-- // this loop ran) — don't spawn a duplicate.
		return
	end
	slot.UI = nil

	local ui = LocalPlayer.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main").Example:Clone()
	ui.Name = "Slot_" .. slotNumber
	ui.Parent = LocalPlayer.PlayerGui.Inventory:WaitForChild("Main")
	ui.Visible = true

	local frame, image, text = GetSlotParts(ui)
	if not frame or not image or not text then
		warn("[Inventory] Slot template is missing Frame, ImageLabel, or Hotkey")
		ui:Destroy()
		return
	end

	text.Text = slotNumber
	image.Image = EmptyIcon
	frame.BackgroundTransparency = 1
	image.ImageTransparency = 1
	text.TextTransparency = 1

	slot.UI = ui
end

local function UpdateSlotUI(slot)
	if not slot or not slot.UI then
		return
	end
	local _, image = GetSlotParts(slot.UI)
	if not image then return end
	local img = (slot.Tool and slot.Tool.item_image) or EmptyIcon
	image.Image = img
end

-- // Slot Colors

local function SetSlotWhite(key)
	local ui = InventorySlots[key].UI
	if not ui then
		return
	end
	TweenSlot(ui, {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		TextColor3 = Color3.fromRGB(255, 255, 255),
	})
end

local function SetSlotBlack(key)
	local ui = InventorySlots[key].UI
	if not ui then
		return
	end
	TweenSlot(ui, {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		TextColor3 = Color3.fromRGB(0, 0, 0),
	})
end

-- // Slot Visibilities

local function CanShowSlots(): boolean
	if LocalPlayer:GetAttribute("MenuOpen") == true then return false end
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local function RevealSlots()
	if not CanShowSlots() then
		return
	end
	slotsVisible = true
	for _, key in ipairs(SlotOrder) do
		local ui = InventorySlots[key].UI
		if ui then
			TweenSlot(ui, {
				BackgroundTransparency = 0,
				ImageTransparency = 0,
				TextTransparency = 0,
			})
		end
	end
end

local function FadeSlots()
	slotsVisible = false
	for _, key in ipairs(SlotOrder) do
		local ui = InventorySlots[key].UI
		if ui then
			TweenSlot(ui, {
				BackgroundTransparency = 1,
				ImageTransparency = 1,
				TextTransparency = 1,
			})
		end
	end
end

-- // Inputs

local function UpdateHighlight(newKey)
	for _, key in ipairs(SlotOrder) do
		if InventorySlots[key].UI then
			if key == newKey then
				SetSlotWhite(key)
			else
				SetSlotBlack(key)
			end
		end
	end
end

local function OnInventoryKey(pressedKey)
	fadeToken += 1
	local myToken = fadeToken

	if not slotsVisible then
		RevealSlots()
	end

	selectedKey = pressedKey
	UpdateHighlight(pressedKey)

	task.delay(FadeDelay, function()
		if fadeToken ~= myToken then
			return
		end
		FadeSlots()
	end)
end

-- // Tool Management

local function FindExistingTool(toolObject)
	for _, key in ipairs(SlotOrder) do
		if InventorySlots[key].Tool == toolObject then
			return true
		end
	end
	return false
end

local function FindFirstEmptySlot(designation)
	for _, key in ipairs(SlotOrder) do
		local slot = InventorySlots[key]
		if not slot.Tool and slot.Designation == designation then
			return key
		end
	end

	if designation == "Primary" or designation == "Secondary" then
		for _, key in ipairs(SlotOrder) do
			local slot = InventorySlots[key]
			if not slot.Tool and (slot.Designation == "Primary" or slot.Designation == "Secondary") then
				return key
			end
		end
	end

	for _, key in ipairs(SlotOrder) do
		local slot = InventorySlots[key]
		if not slot.Tool and slot.Designation == "Miscellaneous" then
			return key
		end
	end

	return nil
end

-- // Equip (single, debounced entry point — used by every key press)

local function EquipTool(toolObject)
	if equipBusy then
		return false
	end
	equipBusy = true

	local ok, err = pcall(function()
		if currentEquipped == toolObject then
			if currentEquipped then
				currentEquipped:unequip()
			end
			currentEquipped = nil
		else
			if currentEquipped then
				currentEquipped:unequip()
			end
			currentEquipped = nil

			if toolObject then
				if type(toolObject.setDualWieldWeapon) == "function" then
					toolObject:setDualWieldWeapon(InventorySlots["2"].Tool)
				end
				toolObject:equip()
				currentEquipped = toolObject
			end
		end
	end)

	equipBusy = false

	if not ok then
		warn("[Inventory] EquipTool failed: " .. tostring(err))
		currentEquipped = nil
	end

	return ok
end

local function AssignTool(toolObject)
	if toolObject.Designation == "Nil" then
		return
	end

	if FindExistingTool(toolObject) then
		return
	end

	local designation = toolObject.Designation or "Miscellaneous"

	local slotNumber = FindFirstEmptySlot(designation)
	if not slotNumber then
		return
	end

	local slot = InventorySlots[slotNumber]
	slot.Tool = toolObject

	if not slot.UI then
		CreateSlotUI(slotNumber, slot)
	end

	UpdateSlotUI(slot)

	fadeToken += 1
	local myToken = fadeToken

	RevealSlots()

	task.delay(FadeDelay, function()
		if fadeToken ~= myToken then
			return
		end
		FadeSlots()
	end)
end

local function RemoveTool(toolObject)
	for _, key in ipairs(SlotOrder) do
		local slot = InventorySlots[key]
		if slot.Tool == toolObject then
			if currentEquipped == toolObject then
				currentEquipped = nil
			end

			slot.Tool = nil

			if slot.UI then
				if slot.PermanentUISpot then
					UpdateSlotUI(slot)
				else
					slot.UI:Destroy()
					slot.UI = nil
				end
			end
		end
	end
end

-- // Respawn Reset

local function AddEquipmentBB(character)
	if equipmentBBClone then
		equipmentBBClone:Destroy()
		equipmentBBClone = nil
	end

	local characterHRP = character:WaitForChild("HumanoidRootPart")
	equipmentBBClone = EquipmentBB:Clone()

	equipmentBBClone.Parent = characterHRP

	local weld = Utils.quick_weld(characterHRP, equipmentBBClone, characterHRP, "EquipmentBB")
	weld.C0 = CFrame.new(3, 2, 0)
end

local function OnCharacterAdded(character)
	-- // Flip InventoryReady off immediately so any other LocalScript
	-- // (e.g. ToolService) waiting on this attribute doesn't race us —
	-- // they'll see false during the reset and re-wait for the true edge below.
	character:SetAttribute("InventoryReady", false)

	-- // Always release the equip lock on respawn, in case a previous
	-- // equip/unequip call was interrupted (e.g. tool destroyed on death)
	equipBusy = false
	currentEquipped = nil
	selectedKey = nil
	fadeToken += 1
	slotsVisible = false

	for _, key in ipairs(SlotOrder) do
		local slot = InventorySlots[key]
		slot.Tool = nil
		if slot.UI then
			slot.UI:Destroy()
			slot.UI = nil
		end
	end

	for _, key in ipairs(SlotOrder) do
		local slot = InventorySlots[key]
		if slot.PermanentUISpot then
			CreateSlotUI(key, slot)
		end
	end

	AddEquipmentBB(character)
	FadeSlots()

	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
	if humanoid then
		humanoid.Died:Once(function()
			fadeToken += 1
			FadeSlots()
		end)
	end

	-- // Signal that slots have been fully reset and rebuilt for this
	-- // character. ToolService waits on this before scanning the backpack
	-- // and calling AssignTool, so tool registration can never race
	-- // ahead of (and get wiped by) this reset.
	character:SetAttribute("InventoryReady", true)
end

-- // Init

function Module.start_module()
	for _, key in ipairs(SlotOrder) do
		local slot = InventorySlots[key]
		if slot.PermanentUISpot then
			CreateSlotUI(key, slot)
		end
	end

	if LocalPlayer.Character then
		OnCharacterAdded(LocalPlayer.Character)
	end

	LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
	LocalPlayer:GetAttributeChangedSignal("MenuOpen"):Connect(function()
		if LocalPlayer:GetAttribute("MenuOpen") == true then
			fadeToken += 1
			FadeSlots()
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then
			return
		end
		if LocalPlayer.Character.Humanoid.Health <= 0 then
			return
		end
		if LocalPlayer.Character:GetAttribute("DontRotate") then
			return
		end

		if input.KeyCode == Enum.KeyCode.G then
			if equipmentDebounce then
				return
			end
			if not equipmentBBClone then
				return
			end

			equipmentDebounce = true

			local count = equipmentBBClone.bb.count
			local image1 = equipmentBBClone.bb.progress.frame1.img
			local image2 = equipmentBBClone.bb.progress.frame2.img

			local tween1 = TweenService:Create(count, TweenInfo.new(0.2), { TextTransparency = 0 })
			local tween2 = TweenService:Create(image1, TweenInfo.new(0.2), { ImageTransparency = 0 })
			local tween3 = TweenService:Create(image2, TweenInfo.new(0.2), { ImageTransparency = 0 })

			tween1:Play()
			tween2:Play()
			tween3:Play()

			task.delay(4, function()
				local fadeOutTween1 = TweenService:Create(count, TweenInfo.new(0.2), { TextTransparency = 1 })
				local fadeOutTween2 = TweenService:Create(image1, TweenInfo.new(0.2), { ImageTransparency = 1 })
				local fadeOutTween3 = TweenService:Create(image2, TweenInfo.new(0.2), { ImageTransparency = 1 })

				fadeOutTween1:Play()
				fadeOutTween2:Play()
				fadeOutTween3:Play()

				fadeOutTween3.Completed:Connect(function()
					equipmentDebounce = false
				end)
			end)
		end

		if LocalPlayer:GetAttribute("CantUnequip") then
			return
		end

		-- // Slot key handling — routed entirely through EquipTool()
		-- // so rapid key presses can't desync currentEquipped
		for _, key in ipairs(SlotOrder) do
			local slot = InventorySlots[key]

			if input.KeyCode == slot.Keybind then
				local tool = slot.Tool

				-- // Empty slot: void the press entirely — no unequip, no highlight
				if not tool then
					break
				end

				OnInventoryKey(key)

				if not EquipTool(tool) then
					-- // Debounced: another equip was already in progress, ignore this press
					break
				end

				if currentEquipped == tool then
					selectedKey = key
				else
					selectedKey = nil
				end
				UpdateHighlight(selectedKey)

				break
			end
		end
	end)
end

function Module.AssignTool(tool)
	AssignTool(tool)
end

function Module.RemoveTool(tool)
	RemoveTool(tool)
end

return Module
