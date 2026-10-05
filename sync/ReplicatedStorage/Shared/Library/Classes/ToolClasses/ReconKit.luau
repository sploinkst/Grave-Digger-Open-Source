local Controller=require(script.Parent.BinocularController)
local Class=setmetatable({}, {__index=Controller}); Class.__index=Class
function Class.new(info)
 local self=Controller.new(info); self.className="ReconKit"; self.name="ReconKit"
 return setmetatable(self,Class)
end
return Class
