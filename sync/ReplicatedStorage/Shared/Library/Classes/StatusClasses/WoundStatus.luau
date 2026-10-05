local WoundStatus = {}
WoundStatus.__index = WoundStatus

local BaseStatus = require(script.Parent.Parent.BaseStatus)

setmetatable(WoundStatus, { __index = BaseStatus })
export type WoundStatus = typeof(setmetatable({} :: {
	className: "WoundStatus",
	name: string,
}, WoundStatus))

local wound_types = {
	["Bullet"] = {
		[1] = "Tweezer",
	},
	["Laceration"] = {
		[1] = "Suture",	
	},
	["Burn"] = {
		
	},
	["Fall"] = {
		[1]	 = "Suture",
	},	
}

WoundStatus.name = "Wounded"

function WoundStatus.new(): WoundStatus
	local self = BaseStatus.new({
		name = "Wounded"
	})

	
	setmetatable(self, WoundStatus)

	self.className = "WoundStatus"
	self._remove_interception = true

	return self
end

local function create_wound_value(parent, name, value)
	local string_value = Instance.new("StringValue")
	string_value.Name = name
	string_value.Value = value
	string_value.Parent = parent
end

function WoundStatus:_apply(player: Player, ...)
	local args = {...}
	print("WoundStatus Applied with:", player, args)

	-- // Validate wound type
	local wound_type_name = args[1]
	local healing_steps = wound_types[wound_type_name]

	if not healing_steps then
		warn("Invalid wound type:", wound_type_name, "reverting to Bullet")
		wound_type_name = "Bullet"
		healing_steps = wound_types[wound_type_name]
	end

	-- // Validate wound origin
	local wound_origin = args[2]
	if not wound_origin then
		warn("Invalid wound origin:", args[2], "reverting to Torso")
		wound_origin = "Torso"
	end

	-- // Character setup
	local character: Model? = player.Character
	local character_data: Folder = character:FindFirstChild("CharacterData")
	local wound_folder: Folder = character_data:FindFirstChild("Wounds")

	if not wound_folder then
		wound_folder = Instance.new("Folder")
		wound_folder.Name = "Wounds"
		wound_folder.Parent = character_data
	end

	-- // Build value string
	local value_parts = {}

	-- Base info
	table.insert(value_parts, wound_type_name)
	table.insert(value_parts, wound_origin)

	-- Healing steps (THIS is the new part)
	for _, step in ipairs(healing_steps) do
		table.insert(value_parts, step)
	end

	-- Extra args (start from 3)
	for i = 3, #args do
		table.insert(value_parts, tostring(args[i]))
	end

	local final_value = table.concat(value_parts, ",")

	create_wound_value(
		wound_folder,
		tostring(#wound_folder:GetChildren() + 1),
		final_value
	)
end

function WoundStatus:_un_apply(player, wound)
	local wound_folder 				 = player.Character:FindFirstChild("CharacterData"):FindFirstChild("Wounds")
	
	local treated = wound and wound.Parent == wound_folder and wound or wound_folder:GetChildren()[1]
	if treated then treated:Destroy() end
	
	if #wound_folder:GetChildren() == 0 then
		player:SetAttribute(self.name, nil)
	end
end
return WoundStatus
