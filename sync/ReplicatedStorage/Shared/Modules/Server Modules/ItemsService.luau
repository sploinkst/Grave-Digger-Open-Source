local module = {}

local types_module = require(game:GetService("ReplicatedStorage").Shared.Library.Types)
local type_checker_module = require(game:GetService("ReplicatedStorage").Shared.Library.Externals.TypeChecker)

local item_classes = game:GetService("ReplicatedStorage").Shared.Library.Classes.ToolClasses
local gun_classes = game:GetService("ReplicatedStorage").Shared.Library.Classes.GunClasses
local elite_classes = game:GetService("ReplicatedStorage").Shared.Library.Classes:FindFirstChild("EliteClasses")
local weapon_ids = require(game:GetService("ReplicatedStorage").Shared.Library.WeaponIds)


local function animatedMount(object, character, clone, part1)
	local storage = game:GetService("ServerStorage")
	local animations = storage:FindFirstChild("animations")
	local tools = animations and animations:FindFirstChild("tools")
	local source = tools and object.AnimationGunType and tools:FindFirstChild(object.AnimationGunType)

	local part0 = character:FindFirstChild(object.motor_6d_data.Part0)
	local rootName = part1.Name
	if source then
		local clip = source:FindFirstChild("held", true) or source:FindFirstChild("aim", true)
			or source:FindFirstChildWhichIsA("KeyframeSequence", true)
		if clip and clip:IsA("KeyframeSequence") then
			for _, pose in clip:GetDescendants() do
				if pose:IsA("Pose") and (pose.Name == part1.Name or pose.Name == "hitbox") then
					local parentPart = character:FindFirstChild(pose.Parent.Name)
					if parentPart and parentPart:IsA("BasePart") then
						part0 = parentPart
						rootName = pose.Name
						break
					end
				end
			end
		end
	end
	-- Keep authored bind offsets when the model includes its attachment joint.
	-- Otherwise use a neutral joint; no hand-tuned pose is applied by scripts.
	local c0, c1 = CFrame.identity, CFrame.identity
	for _, joint in clone:GetDescendants() do
		if joint:IsA("Motor6D") and joint.Part1 == part1 and joint.Part0
			and not joint.Part0:IsDescendantOf(clone) then
			c0, c1 = joint.C0, joint.C1
			joint:Destroy()
			break
		end
	end
	if part1.Name ~= rootName then
		part1:SetAttribute("OriginalPartName", part1.Name)
		part1.Name = rootName
	end
	return part0, c0, c1
end

-- Some melee models carry an authored, unbound Motor6D/Weld that was made in
-- Studio against the arm.  Reuse its offsets instead of treating every model
-- as a gun grip; shields otherwise end up at their source/world transform.
local function authoredGrip(clone, part1)
	for _, joint in clone:GetDescendants() do
		if (joint:IsA("Motor6D") or joint:IsA("Weld")) and joint.Part1 == part1 and joint.Part0 == nil then
			local c0, c1 = joint.C0, joint.C1
			joint:Destroy()
			return c0, c1
		end
	end
	return nil, nil
end

local function findItemModule(item: string)
	for _, itemName in weapon_ids.Aliases(item) do
		local direct = item_classes:FindFirstChild(itemName)
			or gun_classes:FindFirstChild(itemName)
			or (elite_classes and elite_classes:FindFirstChild(itemName))
		if direct then return direct, direct.Name end
	end

	for _, folder in { gun_classes, item_classes, elite_classes } do
		if not folder then continue end
		for _, child in ipairs(folder:GetChildren()) do
			if not child:IsA("ModuleScript") then continue end
			local ok, class = pcall(require, child)
			if ok and (
				class.Display_Name == item
				or class.name == item
				or class.Name == item
				or weapon_ids.Canonical(class.className or child.Name) == weapon_ids.Canonical(item)
				or weapon_ids.Canonical(class.Display_Name or "") == weapon_ids.Canonical(item)
				or weapon_ids.Canonical(class.name or "") == weapon_ids.Canonical(item)
			) then
				return child, child.Name
			end
		end
	end

	return nil, item
end

function module.give_item(player: Player, item: string, given_ammo: number)
	print("Received with:", player.Name, item)
	local stage = "waiting for character"
	local function run()

	if not player.Character then
		player.CharacterAdded:Wait()
	end

	stage = "finding item module"
	local item_module, class_item = findItemModule(item)
    if not item_module then
        warn("ItemsService: Item class not found:", item)
        return "ItemService: Item Class not found.", item
    end
	item = class_item

	-- require class
	stage = "requiring " .. item
	print("ItemsService: Requiring item class", item)
    local class = require(item_module)

    -- create instance of the class
	stage = "constructing " .. item
	local object = class.new({
		name = item,
		player = player,
    })

	print("ItemService: Object is", object)
    -- create roblox tool
	local tool = Instance.new("Tool")
	-- Runtime Tool names are controller/module keys. Display names can include
	-- quotes/spaces and must not be used for GunClasses lookup on the client.
	tool.Name = class_item
	tool.TextureId = object.item_image or ""

	tool.RequiresHandle = false
	tool.CanBeDropped = false
    print("ItemsService: Gave item", item, "to", player.Name)

	local clip_size
	local max_ammo

	if object.Max_Capacity then
		if not given_ammo then
			clip_size = object.Starting_Reserve_Ammo or object.Max_Capacity * 3
		else
			clip_size = math.clamp(given_ammo, 0, object.Max_Reserve_Ammo or object.Max_Capacity * 3)
		end
		max_ammo = object.Max_Reserve_Ammo or object.Max_Capacity * 3
	end

	-- Generic item data is useful to the equip/aim system. Ammo data, however,
	-- belongs exclusively to firearms; medkits, tools, and class equipment must
	-- never look like empty guns.
	local function weaponValue(className: string, name: string, value: any)
		local entry = Instance.new(className)
		entry.Name = name
		entry.Value = value
		entry.Parent = tool
		return entry
	end
	weaponValue("BoolValue", "left_aiming", false)
	weaponValue("StringValue", "model", object.model_reference and object.model_reference.Name or object.name)
	weaponValue("StringValue", "slot", object.Designation or "")
	weaponValue("StringValue", "weapon", class_item)
	local weaponEvent = Instance.new("RemoteEvent")
	weaponEvent.Name = "event"
	weaponEvent.Parent = tool

	if object.IsFirearm == true then
		local reserveAmmo = Instance.new("NumberValue")
		reserveAmmo.Name = "Reserve_Ammo"
		reserveAmmo.Value = clip_size or 0
		reserveAmmo.Parent = tool
		local maximumAmmo = Instance.new("NumberValue")
		maximumAmmo.Name = "Max_Ammo"
		maximumAmmo.Value = max_ammo or 0
		maximumAmmo.Parent = tool

		local ammo = weaponValue("NumberValue", "ammo", clip_size or 0)
		weaponValue("NumberValue", "max_ammo", max_ammo or 0)
		local emptyAmmo = weaponValue("BoolValue", "empty_ammo", (clip_size or 0) <= 0)
		weaponValue("BoolValue", "pistol", object.WeaponCategory == "Pistol")

		local function updateFullAmmo()
			local character = player.Character
			local fullAmmo = character and character:FindFirstChild("full_ammo")
			if not fullAmmo or not fullAmmo:IsA("BoolValue") then return end
			for _, container in { player:FindFirstChild("Backpack"), character } do
				if container then
					for _, candidate in container:GetChildren() do
						local reserve = candidate:FindFirstChild("Reserve_Ammo")
						local maximum = candidate:FindFirstChild("Max_Ammo")
						if reserve and maximum and reserve:IsA("NumberValue") and maximum:IsA("NumberValue")
							and reserve.Value < maximum.Value then
							fullAmmo.Value = false
							return
						end
					end
				end
			end
			fullAmmo.Value = true
		end
		local function syncAmmo()
			ammo.Value = reserveAmmo.Value
			emptyAmmo.Value = ammo.Value <= 0
			updateFullAmmo()
		end
		reserveAmmo:GetPropertyChangedSignal("Value"):Connect(syncAmmo)
	end
	weaponEvent.OnServerEvent:Connect(function(sender, kind, enabled)
		if sender ~= player or kind ~= "left_aiming" or type(enabled) ~= "boolean" then return end
		if tool.Parent == player.Character then
			local state = tool:FindFirstChild("left_aiming")
			if state and state:IsA("BoolValue") then state.Value = enabled end
		end
	end)
	tool.Equipped:Connect(function()
		local character = player.Character
		local lastEquip = character and character:FindFirstChild("last_equip")
		if lastEquip and lastEquip:IsA("StringValue") then lastEquip.Value = object.name end
	end)
	if object.Starting_Grenades then
		local grenades=Instance.new("NumberValue"); grenades.Name="Grenades"; grenades.Value=object.Starting_Grenades
		grenades:SetAttribute("Maximum",object.Max_Grenades or object.Starting_Grenades); grenades.Parent=tool
	end

    -- check instance property (not class property)
	-- Models can be equipped even when a weapon does not have a separate holster model.
	if object.holster_reference or object.model_reference then
		local string_value
		if object.holster_reference then
			print("Has Holster", object)
			string_value = Instance.new("BoolValue")
			string_value.Name = object.holster_reference.Name
			string_value.Parent = player.GameData.Accessorys.Holsters
			string_value.Value = true
		end

		tool.Equipped:Connect(function()
			print("Equipped")
			if string_value then
				string_value.Value = false
			end

			if object.model_reference then
				print("[MODEL REFERENCE]", object.Name, "has an actual model!")
				local clone = object.model_reference:Clone()
				clone.Parent = player.Character.CharacterData.Equipment
				object.actual_model = clone
				print("[MODEL REFERENCE] cloned!")


				local character = player.Character

				clone:PivotTo(character:GetPivot())
				-- Resolve Part0 safely (supports fallback)
				local part0 = character:FindFirstChild(object.motor_6d_data.Part0)
					or character:FindFirstChild(object.motor_6d_data.Parent)
				print("Found Part0")
				if not part0 then
					print("No Part0 found")
					return
				end

				-- Resolve Part1 from cloned model
				local rootReference = object.motor_6d_data.Part1
				local part1 = rootReference and clone:FindFirstChild(rootReference.Name, true)

				if not part1 then
					print("No Part1 found")
					return
				end

				if object.UseAuthoredGrip then
					for _, part in clone:GetDescendants() do
						if part:IsA("BasePart") then
							part.Anchored = false; part.CanCollide = false; part.CanTouch = false; part.Massless = true
						end
					end
					local connected = {[part1] = true}
					for _, part in part1:GetConnectedParts(true) do connected[part] = true end
					for _, part in clone:GetDescendants() do
						if part:IsA("BasePart") and not connected[part] then
							local weld = Instance.new("WeldConstraint")
							weld.Part0 = part1; weld.Part1 = part; weld.Parent = part1
						end
					end
				end

				local authoredC0, authoredC1
				if object.AnimationDrivenGrip then
					part0, authoredC0, authoredC1 = animatedMount(object, character, clone, part1)
				elseif object.UseAuthoredGrip then
					authoredC0, authoredC1 = authoredGrip(clone, part1)
				end
				if not part0 then clone:Destroy(); return end
				local motor6d: Motor6D = Instance.new("Motor6D")
				motor6d.Name = "ToolMotor"
				motor6d.Parent = part0

				motor6d.Part0 = part0
				motor6d.Part1 = part1
				local armGrip = object.motor_6d_data.UseRightGripAttachment
					and part0:FindFirstChild("RightGripAttachment")
				if object.AnimationDrivenGrip then
					motor6d.C0 = authoredC0
				elseif armGrip and armGrip:IsA("Attachment") then
					motor6d.C0 = armGrip.CFrame
				else
					motor6d.C0 = authoredC0 or object.motor_6d_data.C0
				end
				motor6d.C1 = authoredC1 or object.motor_6d_data.C1 or CFrame.identity
				print("Set Motor6D")
			end

			-- // has a round it wants to be weld too
			if object.Round then
				local object_bullet_clone = object.Round:Clone()

				local roundtargetpart

				if object.Round_Target_Part then
					roundtargetpart = player.Character:FindFirstChild(object.Round_Target_Part)
				else
					roundtargetpart = player.Character["Right Arm"]
				end

				object_bullet_clone.Parent = roundtargetpart

				local motor6d = Instance.new("Motor6D")

				local reference_part = player.Character["Right Arm"]

				if object.Round_Target_Part then
					if not player.Character:FindFirstChild(object.Round_Target_Part) then return end
					reference_part = player.Character:FindFirstChild(object.Round_Target_Part)
				end

				motor6d.Parent = reference_part
				motor6d.Part0 =  reference_part
				motor6d.Part1 = object_bullet_clone

				motor6d.C1 = CFrame.new(0, 0, 0)
				motor6d.Name = "Round_Motor6d"

				if object.RoundMotor_6d_Data then
					motor6d.C0 = object.RoundMotor_6d_Data.C0
				end
			end
		end)

		tool.Unequipped:Connect(function()
			if string_value then
				string_value.Value = true
			end

			if player.Character.CharacterData.Equipment:FindFirstChild(object.model_reference.Name) then
				player.Character.CharacterData.Equipment:FindFirstChild(object.model_reference.Name):Destroy()
			end

			if object.Round then
				local objectround = player.Character:FindFirstChild(object.Round.Name, true)
				local Motor6d = player.Character:FindFirstChild("Round_Motor6d", true)

				if objectround then
					objectround:Destroy()
				end
				if Motor6d then
					Motor6d:Destroy()
				end
			end

			local ToolMotor = player.Character:FindFirstChild("ToolMotor", true)
			if ToolMotor then
				ToolMotor:Destroy()
			end
			-- A tool model is only valid while its Tool is equipped.  Leaving it in
			-- CharacterData.Equipment after the motor is removed is what caused the
			-- shield/lance to remain on the floor beside the player.
			if item == "shield" and player.Character then player.Character:SetAttribute("ShieldRaised", nil) end
			if object.actual_model then
				object.actual_model:Destroy()
				object.actual_model = nil
			end
		end)
	end

	-- Parent the tool only after all of its values and connections are ready so
	-- clients cannot equip a partially replicated tool.
	stage = "parenting tool to Backpack"
	tool.Parent = player:WaitForChild("Backpack")

    return "Successfully gave item."
	end

	local ok, result, extra = xpcall(run, debug.traceback)
	if not ok then
		error(("ItemsService failed while %s:\n%s"):format(stage, tostring(result)), 0)
	end
	return result, extra
end

function module.remove_item(player: Player, item: string, model_name: string?)
	local itemAliases = weapon_ids.Aliases(item)

	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	local removed = false
	local function findAliasChild(parent)
		if not parent then return nil end
		for _, itemName in itemAliases do
			local found = parent:FindFirstChild(itemName)
			if found then return found end
		end
		return parent:FindFirstChild(item)
	end

	-- Remove from Backpack
	if backpack then
		local tool = findAliasChild(backpack)
		if tool then
			tool:Destroy()
			removed = true
		end
	end

	-- Remove if currently equipped
	if character then
		local tool = findAliasChild(character)
		if tool then
			character.Humanoid:UnequipTools()
			tool:Destroy()
			removed = true
		end


		for _, descendant in ipairs(character:GetDescendants()) do
			if descendant:IsA("Motor6D") then
				if descendant.Name == "ToolMotor" or descendant.Name == "Round_Motor6d" then
					descendant:Destroy()
				end
			end
		end


		local equipmentFolder = character:FindFirstChild("CharacterData")
			and character.CharacterData:FindFirstChild("Equipment")

		if equipmentFolder then
			local model = model_name and equipmentFolder:FindFirstChild(model_name) or findAliasChild(equipmentFolder)
			if model then
				model:Destroy()
			end
		end


		local rightArm = character:FindFirstChild("Right Arm")
		if rightArm then
			local round = rightArm:FindFirstChild("Round") -- adjust if different name
			if round then
				round:Destroy()
			end
		end
	end

	-- Remove holster reference
	local holsters_folder = player:FindFirstChild("GameData")
		and player.GameData:FindFirstChild("Accessorys")
		and player.GameData.Accessorys:FindFirstChild("Holsters")

	if holsters_folder then
		local holster_value
		for _, itemName in itemAliases do
			holster_value = holsters_folder:FindFirstChild(itemName .. "Holster") or holsters_folder:FindFirstChild(itemName)
			if holster_value then break end
		end
		if holster_value then
			holster_value:Destroy()
		end
	end

	if removed then
		return "Successfully removed item."
	else
		return "Item not found."
	end
end

function module.start_module()
    -- validate item class modules
    for _, child in ipairs(item_classes:GetChildren()) do

        local class = require(child)

        if type_checker_module.new(types_module.BaseToolClass, class) then
        else
            warn("ItemsService: Item class", child.Name, "is missing required fields!")
            child:Destroy()
        end

    end
end


return module
