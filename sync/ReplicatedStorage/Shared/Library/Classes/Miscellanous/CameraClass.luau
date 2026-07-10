--!strict
--!native
--!optimize 2

local Types = require(script.Parent.Parent.Parent.Types);

-- Class Definition
--[=[
	@class CameraClass

	The CameraClass class is The Base Camera Type
]=]

local CameraClass = {};
CameraClass.__index = CameraClass;

-- Type Definition
export type CameraClass = typeof(setmetatable({} :: {
	className : "CameraClass";
}, {} :: typeof(CameraClass)))

export type Camera_Type = {
    name: string,
    priority: number,
}

--[=[
	@within CameraClass

	The CameraClass class is The Base Camera Type

	@param CameraClassCreateInfo Camera_Type
	@return CameraClass
]=]
function CameraClass.new(CameraClassCreateInfo : Camera_Type) : CameraClass
    local class = setmetatable({}, CameraClass);
    class.className = "CameraClass";
    class.name = CameraClassCreateInfo.name;
    class.priority = CameraClassCreateInfo.priority;
    

    return class;
end

--[=[
	@within CameraClass

]=]

-- // Starts Itself Regularly
function CameraClass:Start()

end

-- // Ends itself regularly
function CameraClass:End()

end

-- // Abruptly Cuts itself
function CameraClass:Cut()
    
end
return CameraClass;