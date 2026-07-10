local module = {}

local types_module = require(game:GetService("ReplicatedStorage").Shared.Library.Types)
local type_checker_module = require(game:GetService("ReplicatedStorage").Shared.Library.Externals.TypeChecker)

local item_classes = game:GetService("ReplicatedStorage").Shared.Library.Classes.ToolClasses
local gun_classes = game:GetService("ReplicatedStorage").Shared.Library.Classes.GunClasses


function module.give_item(player: Player, item: string, given_ammo: number)
	print("Received with:", player.Name, item)
	
	if not player.Character then
		player.CharacterAdded:Wait()
	end

	local item_module = item_classes:FindFirstChild(item) or gun_classes:FindFirstChild(item)
    if not item_module then
        warn("ItemsService: Item class not found:", item)
        return "ItemService: Item Class not found.", item
    end

    -- require class
    local class = require(item_module)

    -- create instance of the class
    local object = class.new({
        name = item
    })

    -- create roblox tool
    local tool = Instance.new("Tool")
    tool.Name = object.name
    tool.Parent = player:WaitForChild("Backpack")

	tool.RequiresHandle = false
	tool.CanBeDropped = false
    print("ItemsService: Gave item", item, "to", player.Name)

	local clip_size

	if object.Max_Capacity then
		if not given_ammo then
			clip_size = object.Max_Capacity * 3
		else
			clip_size = math.clamp(given_ammo, 0, object.Max_Capacity * 3)
		end
	end

	local number_value = Instance.new("NumberValue")
	number_value.Name = "Reserve_Ammo"
	number_value.Parent = tool
	number_value.Value = clip_size or 0  -- default to 0 for tools with no ammo
	
	local number_value = Instance.new("NumberValue")
	number_value.Name = "Max_Ammo"
	number_value.Parent = tool
	number_value.Value = clip_size or 0  -- default to 0 for tools with no ammo

    -- check instance property (not class property)
    if object.holster_reference then
        print("Has Holster", object)

        local string_value = Instance.new("BoolValue")
        string_value.Name = object.holster_reference.Name
		string_value.Parent = player.GameData.Accessorys.Holsters
		string_value.Value = true		
				
		tool.Equipped:Connect(function()
			string_value.Value = false

			if object.model_reference then
				local clone = object.model_reference:Clone()
				clone.Parent = player.Character.CharacterData.Equipment
				object.actual_model = clone


				local character = player.Character

				-- Resolve Part0 safely (supports fallback)
				local part0 = character:FindFirstChild(object.motor_6d_data.Part0)
					or character:FindFirstChild(object.motor_6d_data.Parent)

				if not part0 then
					return
				end

				-- Resolve Part1 from cloned model
				local part1 = clone:FindFirstChild(object.motor_6d_data.Part1.Name, true)

				if not part1 then
					return
				end

				local motor6d: Motor6D = Instance.new("Motor6D")
				motor6d.Name = "ToolMotor"
				motor6d.Parent = part0

				motor6d.Part0 = part0
				motor6d.Part1 = part1
				motor6d.C0 = object.motor_6d_data.C0
			end
			
			-- // has a round it wants to be weld too
			if object.Round then
				local object_bullet_clone = object.Round:Clone()
				object_bullet_clone.Parent = player.Character["Right Arm"]
				
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
			end
		end)
		
		tool.Unequipped:Connect(function()
			string_value.Value = true
			
			if player.Character.CharacterData.Equipment:FindFirstChild(object.model_reference.Name) then
				player.Character.CharacterData.Equipment:FindFirstChild(object.model_reference.Name):Destroy()
			end
			
			if object.Round then
				if object.Round_Target_Part then
					if not player.Character:FindFirstChild(object.Round_Target_Part) then return end
					local round = player.Character:FindFirstChild(object.Round_Target_Part):FindFirstChild(object.Round.Name)
					local roundm6 = player.Character:FindFirstChild(object.Round_Target_Part):FindFirstChild("Round_Motor6d")
					
					if round then
						round:Destroy()
					end
					
					if roundm6 then
						roundm6:Destroy()
					end
				else
					player.Character["Right Arm"]:FindFirstChild(object.Round.Name):Destroy()
					player.Character["Right Arm"]:FindFirstChild("Round_Motor6d"):Destroy()
				end
			end
			
			local ToolMotor = player.Character:FindFirstChild("ToolMotor", true)
			ToolMotor:Destroy()
		end)
	end
	
	if object.model_reference then
	end

    return "Successfully gave item."
end

function module.remove_item(player: Player, item: string)

	local backpack = player:FindFirstChild("Backpack")
	local character = player.Character

	local removed = false

	-- Remove from Backpack
	if backpack then
		local tool = backpack:FindFirstChild(item)
		if tool then
			tool:Destroy()
			removed = true
		end
	end

	-- Remove if currently equipped
	if character then
		local tool = character:FindFirstChild(item)
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
			local model = equipmentFolder:FindFirstChild(item)
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
		local holster_value = holsters_folder:FindFirstChild(item .. "Holster")
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