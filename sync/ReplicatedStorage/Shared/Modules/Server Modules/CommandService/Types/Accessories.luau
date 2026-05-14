local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CmdrUtil = require(script.Parent.Parent.Shared.Util)
local accessories_Folder = ReplicatedStorage.Shared.Assets.Accessories

-- collect all class modules
local function getAccessories()
	local list = {}

	for _, child in ipairs(accessories_Folder:GetDescendants()) do
		if child:IsA("Model") then
			table.insert(list, child.Name)
		end
	end

	return list
end

local classType = {
	Transform = function(text)
		local classList = getAccessories()
		local findClass = CmdrUtil.MakeFuzzyFinder(classList)

		return findClass(text)
	end;

	Validate = function(Accessories)
		return #Accessories > 0, "No class with that name found."
	end;

	Autocomplete = function(Accessories)
		return Accessories
	end;


	Parse = function(Accessories)
		return Accessories[1]
	end;
}

-- listable version
local AccessoriesType = {
	Listable = true;
	Transform = classType.Transform;
	Validate = classType.Validate;
	Autocomplete = classType.Autocomplete;


	Parse = function(Accessories)
		return Accessories -- Accessories are string names
	end;
}

return function(cmdr)
	cmdr:RegisterType("accessory", classType)
	cmdr:RegisterType("accessories", AccessoriesType)
end