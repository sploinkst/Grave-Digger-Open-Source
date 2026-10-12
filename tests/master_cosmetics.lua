local function folder(name, children, class)
 local o={Name=name,children=children or {},instance=true}
 function o:GetChildren() return self.children end
 function o:FindFirstChild(key) for _,c in ipairs(self.children) do if c.Name==key then return c end end end
 function o:IsA(kind) return kind==(class or "Folder") end
 return o
end
typeof=function(v) return type(v)=="table" and v.instance and "Instance" or type(v) end
Color3={fromRGB=function() return {} end}
local skin=folder("gold",{},"Model")
local skins=folder("Skins",{folder("mosin",{skin})})
local rs={Shared={Assets=folder("Assets",{folder("Guns",{skins})})}}
game={GetService=function() return rs end}
script={Parent={WeaponIds="Ids",WeaponModModelRules="Rules"}}
local ids={AssetName=function() return "mosin" end,MasterSourceName=function() return "mosin" end,Canonical=function() return "VolkRifle" end}
require=function(name) return name=="Ids" and ids or {} end
local cosmetics=dofile("sync/ReplicatedStorage/Shared/Library/MasterCosmetics.luau")
assert(cosmetics.SkinModel("VolkRifle","gold")==skin)
assert(cosmetics.SkinModel("VolkRifle","missing")==nil)
rs.Shared.Assets={}
assert(cosmetics.SkinAssets()==nil)
assert(cosmetics.SkinModel("VolkRifle","gold")==nil)
print("Master cosmetics: table roots are safe and replacement skins resolve correctly")
