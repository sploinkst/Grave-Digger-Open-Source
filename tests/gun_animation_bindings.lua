-- All gun folders from the playtest inventory go through the actual shared binder.
local function object(name,class,children)
 local o={Name=name,ClassName=class,children=children or {},attributes={}}
 for _,child in ipairs(o.children) do child.Parent=o end
 function o:IsA(kind) return self.ClassName==kind end
 function o:GetChildren() return self.children end
 function o:GetDescendants()
  local result={}
  for _,c in ipairs(self.children) do result[#result+1]=c; for _,d in ipairs(c:GetDescendants()) do result[#result+1]=d end end
  return result
 end
 function o:FindFirstChild(n) for _,c in ipairs(self.children) do if c.Name==n then return c end end end
 function o:FindFirstChildWhichIsA(kind,recursive)
  for _,c in ipairs(recursive and self:GetDescendants() or self.children) do if c:IsA(kind) then return c end end
 end
 function o:GetAttribute(n) return self.attributes[n] end
 function o:GetFullName() return self.Name end
 return o
end
local folders={}
-- The fixture is generated from the user's actual 493 authored sequences.
local fixture=dofile("tests/fixtures/gun_animation_inventory.lua")
local count=0
for gun,names in pairs(fixture) do
 local clips={}
 for _,name in ipairs(names) do
  local sequence=object(name,"KeyframeSequence")
  local wrapper=object(name,"Animation",{sequence});wrapper.AnimationId="rbxassetid://116542843259676"
  clips[#clips+1]=wrapper;count=count+1
 end
 folders[#folders+1]=object(gun,"Folder",clips)
end
local guns=object("Guns","Folder",folders)
local assets=object("Assets","Folder",{object("Animations","Folder",{object("Tools","Folder",{guns})})})
local rs=object("ReplicatedStorage","Folder");rs.Shared={Assets=assets}
local studio=true;local registrations=0
local ids={Aliases=function(name) return {name} end,Canonical=function(n) return n end,AssetName=function(n) return n end,MasterSourceName=function(n) return n end}
game={GetService=function(_,name)
 if name=="ReplicatedStorage" then return rs end
 if name=="RunService" then return {IsStudio=function() return studio end} end
 return {RegisterKeyframeSequence=function() registrations=registrations+1; return "hash://local"..registrations end}
end}
script={Parent={WeaponIds="Ids",Parent={Parent={WeaponIds="Ids"}}}}
require=function() return ids end
Instance={new=function(class) return object("",class) end}
warn=function(message) error(message) end
local bindings=dofile("sync/ReplicatedStorage/Shared/Library/GunAnimationBindings.luau")
for gun,names in pairs(fixture) do
 local c={IsFirearm=true,className=gun,AnimationGunType=gun,animations={}}
 bindings.Prepare(c)
 for _,name in ipairs(names) do
  local action=name:gsub("^%l",string.upper):gsub("_(%l)",function(char) return "_"..char:upper() end)
  assert(c.animations[action],gun.." missing "..name)
 end
end
local c={IsFirearm=true,className="VolkRifle",AnimationGunType="mosin",animations={}}
bindings.Prepare(c);assert(c.animations.Hold.Name=="held" and c.animations.Reload_Clip and c.animations.Reload_Start_Vet)
local pistol={IsFirearm=true,className="HonourPistol",AnimationGunType="HonourPistol",animations={}}
bindings.Prepare(pistol);assert(pistol.animations.Draw.Name=="draw")
local omitted={IsFirearm=true,className="VolkRifle",AnimationGunType="mosin",AnimationOmissions={Reload_Clip=true},animations={}}
bindings.Prepare(omitted);assert(not omitted.animations.Reload_Clip)
local file=assert(io.open("sync/ReplicatedStorage/Shared/Library/Classes/GunClasses/AnimationResolver.luau","rb"))
local source=file:read("*a");file:close()
source=source:gsub('local sequenceCache:[^\n]+','local sequenceCache = {}')
source=source:gsub(': Instance', ''):gsub(': Animation', ''):gsub(': KeyframeSequence', ''):gsub(': string', ''):gsub(': boolean', '')
source=source:gsub('%?', '')
source=source:gsub('if wrapper:IsA%("KeyframeSequence"%) then wrapper else fallbackSequence%(wrapper, gunType, bindingName%)','(wrapper:IsA("KeyframeSequence") and wrapper or fallbackSequence(wrapper, gunType, bindingName))')
local resolver=assert(load(source,"animation resolver","t",_G))()
local wrapper=c.animations.Reload_Clip
local resolved=resolver.Resolve(wrapper,"mosin","Reload_Clip")
assert(resolved.AnimationId=="hash://local1")
assert(resolver.Resolve(wrapper,"mosin","Reload_Clip")==resolved and registrations==1)
studio=false
assert(resolver.Resolve(wrapper,"mosin","Reload_Clip")==wrapper)
wrapper.children[1].attributes.PublishedAnimationId=123456
assert(resolver.Resolve(wrapper,"mosin","Reload_Clip").AnimationId=="rbxassetid://123456")
assert(resolver.Resolve(object("unpublished","KeyframeSequence"),"none","None")==nil)
print("Gun animations: "..count.." authored clips bound; Studio fallback, live IDs, omissions and cache verified")
