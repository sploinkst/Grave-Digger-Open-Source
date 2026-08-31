
--]]

--Types
export type LuauTypes =
	"string"
| "boolean"
| "number"
| "nil"
| "any"
| "unknown"
| "thread"
| "table"
| "userdata"
| "function"
| "Instance"
| "Vector3"
| "Vector2"
| "CFrame"
| "UDim"
| "UDim2"
| "Color3"
| "BrickColor"
| "Ray"
| "Enum"
| "EnumItem"
| "RBXScriptConnection"
| "RBXScriptSignal"
| "TweenInfo"
| "Faces"
| "Axes"
| "Rect"
| "Region3"
| "Region3int16"
| "PhysicalProperties"
| "NumberRange"
| "NumberSequence"
| "NumberSequenceKeypoint"
| "ColorSequence"
| "ColorSequenceKeypoint"
| "Font"
| "PathWaypoint"
-- Variables

--OOP
local Type_Checker = {}

function Type_Checker.type(LuauType:LuauTypes)
	return function(value:any)
		if typeof(value) ~= LuauType then
			warn(string.format('[Type_Checker] The value should be of type %s but was called as type %s. ',LuauType,typeof(value)))
		end
		return (typeof(value) == LuauType)
	end
end

function Type_Checker.array(...)
	local types = table.pack(...)
	return function(...)
		local args = table.pack(...)
		local pass = true
		
		for index,typecheck in types do
			if typeof(index) ~= "number" then continue end
			if args[index] == nil then
				warn('[Type_Checker] The index must not be nil.')
				pass = false
				continue
			end
			if not typecheck(args[index]) then
				pass = false
				continue
			end
		end
		
		return pass
	end
end

function Type_Checker.new(...)
	local types = table.pack(...)
	return function(...)
		local args = table.pack(...)
		local pass = true
		
		for index,typecheck in types do
			if typeof(index) ~= "number" then continue end
			if args[index] == nil then
				warn('[Type_Checker] The index must not be nil.')
				pass = false
				continue
			end
			local resault = false
			if typeof(args[index]) == "table" then
				resault = typecheck(table.unpack(args[index]))
			else
				resault = typecheck(args[index])
			end
			pass = resault
		end
		return pass
	end
end

function Type_Checker.fromString(...)
	local types = table.pack(...)
	return function(...)
		local args = table.pack(...)
		local pass = true
		
		for index,type in types do
			if typeof(types[index]) ~= "string" or typeof(index) ~= "number" then continue end
			if args[index] == nil then
				warn('[Type_Checker] The index must not be nil.')
			end
			if not Type_Checker.type(type)(args[index]) then
				pass = false
				continue
			end
		end

		return pass
	end
end

return Type_Checker