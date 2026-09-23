-- Each mounted panel owns its callbacks, tasks, and generated instances.
local Scope = {}
Scope.__index = Scope
function Scope.new() return setmetatable({items = {}, alive = true}, Scope) end
function Scope:Own(item)
    table.insert(self.items, item)
    return item
end
function Scope:Connect(signal, callback)
    return self:Own(signal:Connect(function(...)
        if self.alive then callback(...) end
    end))
end
function Scope:Destroy()
    if not self.alive then return end
    self.alive = false
    for i = #self.items, 1, -1 do
        local item = self.items[i]
        if typeof(item) == "RBXScriptConnection" then item:Disconnect()
        elseif typeof(item) == "Instance" then item:Destroy()
        elseif type(item) == "function" then item() end
    end
    table.clear(self.items)
end
return Scope
