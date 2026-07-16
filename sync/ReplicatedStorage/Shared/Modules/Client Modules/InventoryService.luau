--!strict
local module = {}

local player = game.Players.LocalPlayer

local UIS           = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")

local empty_icon = "rbxassetid://112388032303745"

local TWEEN_INFO  = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local FADE_DELAY  = 3
local EquipmentDebounce = false

local InventorySlots = {
	["1"] = {Keybind = Enum.KeyCode.One,   Tool = nil, UI = nil, Designation = "Primary",       PermanentUISpot = true},
	["2"] = {Keybind = Enum.KeyCode.Two,   Tool = nil, UI = nil, Designation = "Secondary",     PermanentUISpot = true},
	["3"] = {Keybind = Enum.KeyCode.Three, Tool = nil, UI = nil, Designation = "Melee",         PermanentUISpot = true},
	["4"] = {Keybind = Enum.KeyCode.Four,  Tool = nil, UI = nil, Designation = "Mining",        PermanentUISpot = true},
	["5"] = {Keybind = Enum.KeyCode.Five,  Tool = nil, UI = nil, Designation = "Medkit", 		PermanentUISpot = true},
	["6"] = {Keybind = Enum.KeyCode.Six,   Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false},
	["7"] = {Keybind = Enum.KeyCode.Seven, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false},
	["8"] = {Keybind = Enum.KeyCode.Eight, Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false},
	["9"] = {Keybind = Enum.KeyCode.Nine,  Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false},
	["0"] = {Keybind = Enum.KeyCode.Zero,  Tool = nil, UI = nil, Designation = "Miscellaneous", PermanentUISpot = false},
}

local SLOT_ORDER = {"1","2","3","4","5","6","7","8","9","0"}

local current_equipped = nil
local slots_visible    = false
local fade_token       = 0
local selected_key     = nil
local EquipBusy = false

local Equipment_BB = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("Equipment_BB")
local Utils = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local EquipmentBBClone = nil

-- // Helpers

local function tween_slot(ui, props)
	local frame = ui.Frame
	local image = ui.ImageLabel
	local text  = ui.Hotkey
	if not frame or not image or not text then
		return
	end

	if props.BackgroundTransparency then
		tween_service:Create(frame, TWEEN_INFO, {BackgroundTransparency = props.BackgroundTransparency}):Play()
	end
	if props.ImageTransparency then
		tween_service:Create(image, TWEEN_INFO, {ImageTransparency = props.ImageTransparency}):Play()
	end
	if props.TextTransparency then
		tween_service:Create(text, TWEEN_INFO, {TextTransparency = props.TextTransparency}):Play()
	end
	if props.BackgroundColor3 then
		tween_service:Create(frame, TWEEN_INFO, {BackgroundColor3 = props.BackgroundColor3}):Play()
	end
	if props.ImageColor3 then
		tween_service:Create(image, TWEEN_INFO, {ImageColor3 = props.ImageColor3}):Play()
	end
	if props.TextColor3 then
		tween_service:Create(text, TWEEN_INFO, {TextColor3 = props.TextColor3}):Play()
	end
end

local function create_slot_ui(slotNumber, slot)
	if slot.UI then
		-- // Already has a UI instance (e.g. assign_tool created it before
		-- // this loop ran) — don't spawn a duplicate.
		return
	end

	local ui = player.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main").Example:Clone()
	ui.Name = "Slot_" .. slotNumber
	ui.Parent =  player.PlayerGui.Inventory:WaitForChild("Main")
	ui.Visible = true

	ui.Hotkey.Text = slotNumber
	ui.ImageLabel.Image = empty_icon

	ui.Frame.BackgroundTransparency = 1
	ui.ImageLabel.ImageTransparency = 1
	ui.Hotkey.TextTransparency = 1

	slot.UI = ui
end

local function update_slot_ui(slot)
	if not slot or not slot.UI then
		return
	end
	local img = (slot.Tool and slot.Tool.item_image) or empty_icon
	slot.UI.ImageLabel.Image = img
end

-- // Slot Colors

local function set_slot_white(key)
	local ui = InventorySlots[key].UI
	if not ui then return end
	tween_slot(ui, {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ImageColor3      = Color3.fromRGB(255, 255, 255),
		TextColor3       = Color3.fromRGB(255, 255, 255),
	})
end

local function set_slot_black(key)
	local ui = InventorySlots[key].UI
	if not ui then return end
	tween_slot(ui, {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		ImageColor3      = Color3.fromRGB(0, 0, 0),
		TextColor3       = Color3.fromRGB(0, 0, 0),
	})
end

-- // Slot Visibilities

local function reveal_slots()
	slots_visible = true
	for _, key in ipairs(SLOT_ORDER) do
		local ui = InventorySlots[key].UI
		if ui then
			tween_slot(ui, {
				BackgroundTransparency = 0,
				ImageTransparency      = 0,
				TextTransparency       = 0,
			})
		end
	end
end

local function fade_slots()
	slots_visible = false
	for _, key in ipairs(SLOT_ORDER) do
		local ui = InventorySlots[key].UI
		if ui then
			tween_slot(ui, {
				BackgroundTransparency = 0.8,
				ImageTransparency      = 0.8,
				TextTransparency       = 0.8,
			})
		end
	end
end

-- // Inputs

local function update_highlight(new_key)
	for _, key in ipairs(SLOT_ORDER) do
		if InventorySlots[key].UI then
			if key == new_key then
				set_slot_white(key)
			else
				set_slot_black(key)
			end
		end
	end
end

local function on_inventory_key(pressedKey)
	fade_token += 1
	local my_token = fade_token

	if not slots_visible then
		reveal_slots()
	end

	selected_key = pressedKey
	update_highlight(pressedKey)

	task.delay(FADE_DELAY, function()
		if fade_token ~= my_token then return end
		fade_slots()
	end)
end

-- // Tool Management

local function find_existing_tool(toolObject)
	for _, key in ipairs(SLOT_ORDER) do
		if InventorySlots[key].Tool == toolObject then
			return true
		end
	end
	return false
end

local function find_first_empty_slot(designation)
	for _, key in ipairs(SLOT_ORDER) do
		local slot = InventorySlots[key]
		if not slot.Tool and slot.Designation == designation then
			return key
		end
	end

	if designation == "Primary" or designation == "Secondary" then
		for _, key in ipairs(SLOT_ORDER) do
			local slot = InventorySlots[key]
			if not slot.Tool and (slot.Designation == "Primary" or slot.Designation == "Secondary") then
				return key
			end
		end
	end

	for _, key in ipairs(SLOT_ORDER) do
		local slot = InventorySlots[key]
		if not slot.Tool and slot.Designation == "Miscellaneous" then
			return key
		end
	end

	return nil
end

-- // Equip (single, debounced entry point — used by every key press)

local function equip_tool(toolObject)
	if EquipBusy then
		return false
	end
	EquipBusy = true

	local ok, err = pcall(function()
		if current_equipped == toolObject then
			if current_equipped then
				current_equipped:unequip()
			end
			current_equipped = nil
		else
			if current_equipped then
				current_equipped:unequip()
			end
			current_equipped = nil

			if toolObject then
				toolObject:equip()
				current_equipped = toolObject
			end
		end
	end)

	EquipBusy = false

	if not ok then
		warn("[Inventory] equip_tool failed: " .. tostring(err))
		current_equipped = nil
	end

	return ok
end

local function assign_tool(toolObject)
	if toolObject.Designation == "Nil" then
		return
	end

	if find_existing_tool(toolObject) then
		return
	end

	local designation = toolObject.Designation or "Miscellaneous"

	local slot_number = find_first_empty_slot(designation)
	if not slot_number then
		return
	end

	local slot = InventorySlots[slot_number]
	slot.Tool = toolObject

	if not slot.UI then
		create_slot_ui(slot_number, slot)
	end

	update_slot_ui(slot)

	fade_token += 1
	local my_token = fade_token

	reveal_slots()

	task.delay(FADE_DELAY, function()
		if fade_token ~= my_token then return end
		fade_slots()
	end)
end

local function remove_tool(toolObject)
	for _, key in ipairs(SLOT_ORDER) do
		local slot = InventorySlots[key]
		if slot.Tool == toolObject then
			if current_equipped == toolObject then
				current_equipped = nil
			end

			slot.Tool = nil

			if slot.UI then
				if slot.PermanentUISpot then
					update_slot_ui(slot)
				else
					slot.UI:Destroy()
					slot.UI = nil
				end
			end
		end
	end
end

-- // Respawn Reset

local function Add_EquipmentBB(character)
	if EquipmentBBClone then
		EquipmentBBClone:Destroy()
		EquipmentBBClone = nil
	end

	local character_hrp = character:WaitForChild("HumanoidRootPart")
	EquipmentBBClone = Equipment_BB:Clone()

	EquipmentBBClone.Parent = character_hrp

	local weld = Utils.quick_weld(character_hrp, EquipmentBBClone, character_hrp, "EquipmentBB")
	weld.C0 = CFrame.new(3,2,0)
end

local function on_character_added(character)
	-- // Flip InventoryReady off immediately so any other LocalScript
	-- // (e.g. ToolService) waiting on this attribute doesn't race us —
	-- // they'll see false during the reset and re-wait for the true edge below.
	character:SetAttribute("InventoryReady", false)

	-- // Always release the equip lock on respawn, in case a previous
	-- // equip/unequip call was interrupted (e.g. tool destroyed on death)
	EquipBusy         = false
	current_equipped  = nil
	selected_key      = nil
	fade_token       += 1
	slots_visible     = false

	for _, key in ipairs(SLOT_ORDER) do
		local slot = InventorySlots[key]
		slot.Tool = nil
		if slot.UI then
			slot.UI:Destroy()
			slot.UI = nil
		end
	end

	for _, key in ipairs(SLOT_ORDER) do
		local slot = InventorySlots[key]
		if slot.PermanentUISpot then
			create_slot_ui(key, slot)
		end
	end

	Add_EquipmentBB(character)

	-- // Signal that slots have been fully reset and rebuilt for this
	-- // character. ToolService waits on this before scanning the backpack
	-- // and calling assign_tool, so tool registration can never race
	-- // ahead of (and get wiped by) this reset.
	character:SetAttribute("InventoryReady", true)
end

-- // Init

function module.start_module()

	for _, key in ipairs(SLOT_ORDER) do
		local slot = InventorySlots[key]
		if slot.PermanentUISpot then
			create_slot_ui(key, slot)
		end
	end
	if player.Character then
		on_character_added(player.Character)
	end

	player.CharacterAdded:Connect(on_character_added)

	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if not game.Players.LocalPlayer.Character or not game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then return end
		if game.Players.LocalPlayer.Character.Humanoid.Health <= 0 then return end
		if game.Players.LocalPlayer.Character:GetAttribute("DontRotate") then return end

		if input.KeyCode == Enum.KeyCode.G then
			if EquipmentDebounce then return end
			if not EquipmentBBClone then return end

			EquipmentDebounce = true

			local count = EquipmentBBClone.bb.count
			local image1 = EquipmentBBClone.bb.progress.frame1.img
			local image2 = EquipmentBBClone.bb.progress.frame2.img

			local tween1 = tween_service:Create(count, TweenInfo.new(0.2), {TextTransparency = 0})
			local tween2 = tween_service:Create(image1, TweenInfo.new(0.2), {ImageTransparency = 0})
			local tween3 = tween_service:Create(image2, TweenInfo.new(0.2), {ImageTransparency = 0})

			tween1:Play()
			tween2:Play()
			tween3:Play()
			task.delay(4, function()
				local tween1 = tween_service:Create(count, TweenInfo.new(0.2), {TextTransparency = 1})
				local tween2 = tween_service:Create(image1, TweenInfo.new(0.2), {ImageTransparency = 1})
				local tween3 = tween_service:Create(image2, TweenInfo.new(0.2), {ImageTransparency = 1})

				tween1:Play()
				tween2:Play()
				tween3:Play()
				tween3.Completed:Connect(function()
					EquipmentDebounce = false
				end)
			end)

		end

		if player:GetAttribute("CantUnequip") then return end

		-- // Slot key handling — routed entirely through equip_tool()
		-- // so rapid key presses can't desync current_equipped
		for _, key in ipairs(SLOT_ORDER) do
			local slot = InventorySlots[key]

			if input.KeyCode == slot.Keybind then
				local tool = slot.Tool

				on_inventory_key(key)

				if not equip_tool(tool) then
					-- // Debounced: another equip was already in progress, ignore this press
					break
				end

				if tool and current_equipped == tool then
					selected_key = key
				else
					selected_key = nil
				end
				update_highlight(selected_key)

				break
			end
		end
	end)
end


function module.assign_tool(tool)
	assign_tool(tool)
end

function module.remove_tool(tool)
	remove_tool(tool)
end

return module