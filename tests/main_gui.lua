local function instance(name,class,children)
 local o={Name=name,children=children or {}}
 function o:GetChildren() return self.children end
 function o:IsA(kind) return kind==class end
 function o:FindFirstChild(key) for _,c in ipairs(self.children) do if c.Name==key then return c end end end
 return o
end
local holder=instance("inventory","Frame")
local screen=instance("Inventory","ScreenGui",{holder})
local gui=instance("PlayerGui","PlayerGui",{instance("main","ScreenGui"),screen})
local extras=instance("Extras","ScreenGui",{instance("hunt_vignette","ImageLabel")})
table.insert(gui.children,extras)
local player={FindFirstChildOfClass=function() return gui end}
game={GetService=function(_,name) return name=="Players" and {LocalPlayer=player} or {} end}
local assets=dofile("sync/ReplicatedStorage/Shared/Library/AuthoredAssets.luau")
assert(assets.MainGui()==nil and assets.CoreGame()==extras)
assert(assets.Widget("hunt_vignette")==extras.children[1])
assert(assets.Screen("Inventory")==screen and assets.Widget("inventory")==holder)
assert(assets.Widget("huntedtext")==nil)
gui.children={};assert(assets.Widget("inventory")==nil)
local replacement=instance("Inventory","ScreenGui",{holder});gui.children={replacement}
assert(assets.Screen("Inventory")==replacement)
print("Library UI: screen mapping, retired StarterGui main, missing widgets and replacement selection passed")
