-- Mock only the Roblox boundaries; the runner loads production module bodies.
local now = 100
local os = {clock = function() return now end}
local function node(name, children, className)
	local object = children or {}
	object.Name = name; object.Parent = true; object.attributes = {}; object.ClassName = className or "Folder"
	function object:FindFirstChild(key) return self[key] end
	function object:WaitForChild(key) return self[key] end
	function object:IsA(kind) return self.ClassName == kind end
	function object:GetChildren()
		local result = {}
		for key, child in self do
			if type(key) == "string" and type(child) == "table" and child.ClassName then table.insert(result, child) end
		end
		return result
	end
	function object:ClearAllChildren()
		for key, child in self do
			if type(key) == "string" and type(child) == "table" and child.ClassName then self[key] = nil end
		end
	end
	function object:Destroy() self.Parent = nil end
	function object:GetAttribute(key) return self.attributes[key] end
	function object:SetAttribute(key, value) self.attributes[key] = value end
	return object
end
local Instance = {new = function(className) return node(className, {}, className) end}
local function value(name, text) return node(name, {Value = text}, "StringValue") end
local grants = {}
local Items = {give_item = function(player, name) table.insert(grants, name) end}
local warnings = {}
local warn = function(message) table.insert(warnings, message) end
local classes = {
	GunClasses = node("GunClasses", {
		PrinceRifle = node("PrinceRifle", {Weight = 2, Designation = "Primary"}, "ModuleScript"),
		GraceRevolver = node("GraceRevolver", {Weight = 1, Designation = "Secondary"}, "ModuleScript"),
		HeavyGun = node("HeavyGun", {Weight = 3, Designation = "Primary"}, "ModuleScript"),
	}),
	ToolClasses = node("ToolClasses", {
		Pickaxe = node("Pickaxe", {Weight = 0}, "ModuleScript"),
		HeavyPickaxe = node("HeavyPickaxe", {Weight = 0}, "ModuleScript"),
		Compass = node("Compass", {Weight = 0}, "ModuleScript"),
		Medkit = node("Medkit", {Weight = 0}, "ModuleScript"),
	}),
	EquipmentClasses = node("EquipmentClasses", {AmmoPack = {}}),
}
for _, folder in {classes.GunClasses, classes.ToolClasses} do
	for _, child in folder do
		if type(child) == "table" and child.ClassName == "ModuleScript" then child.Parent = folder end
	end
end
local storage = {Shared = {Library = {ClassDefinitions = Definitions, Classes = classes,
	Events = node("Events", {ClassIntel = {}, Datapush = {OnServerEvent = {Connect = function(self, callback) self.callback = callback end}}})}}}
storage.Shared.Library = node("Library", storage.Shared.Library)
local game = {GetService = function(_, name) return if name == "ReplicatedStorage" then storage else {} end}
local script = {Parent = {ItemsService = Items}}
local require = function(module) return module end
local function player(className, primary, secondary)
	local equipment = node("Equipment", {Class = value("Class", className or "Soldat"),
		Primary = value("Primary", primary or "PrinceRifle"), Secondary = value("Secondary", secondary or "GraceRevolver")})
	local result = node("Player", {PlayerData = node("PlayerData", {PlayerData = node("PlayerData", {Equipment = equipment})})})
	result.Character = node("Character", {CharacterData = node("CharacterData")}, "Model")
	return result, equipment
end
local checks = 0
local function equal(actual, expected, message)
	checks += 1
	assert(actual == expected, message .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function includes(list, value)
	for _, entry in list do if entry == value then return true end end
	return false
end
