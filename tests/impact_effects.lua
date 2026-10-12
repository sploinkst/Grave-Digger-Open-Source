local existing, calls = {}, {}
local assets={FindFirstChild=function(_,name) return existing[name] end}
local runtime={Assets=function() return assets end,Try=function(_,fn,payload) return pcall(fn,payload) end}
local registry={Functions={
 mine_impact=function(p) calls[#calls+1]={"mine_impact",p} end,
 wood_impact=function(p) calls[#calls+1]={"wood_impact",p} end},Profiles={}}
local module={IsA=function() return true end}
script={Parent={Runtime="Runtime",FindFirstChild=function() return module end}}
game={GetService=function() return {IsClient=function() return true end} end}
require=function(name) return name=="Runtime" and runtime or registry end
Enum={Material={Wood=1,WoodPlanks=2,Glass=3,Sand=4,Ground=5,Metal=6}}
local dispatch=dofile("sync/ReplicatedStorage/Shared/Library/MasterEffects/Dispatch.luau")
assert(dispatch.Surface(nil,{})==false)
assert(dispatch.Surface({Material=6,Position="hit"},{})==false)
existing.ricochet={};existing.woodchip={};existing.glassimpact={};existing.sandimpact={}
for material=1,6 do
 assert(dispatch.Surface({Material=material,Position="hit"},{PelletCount=8,_lastShotOrigin="origin"}))
 local call=calls[#calls]
 assert(call[1]==(material==6 and "mine_impact" or "wood_impact"))
 assert(call[2].point=="hit" and call[2].pellets==8 and call[2].from=="origin")
 assert((call[2].glass==true)==(material==3))
 assert((call[2].sand==true)==(material==4 or material==5))
end
local file=assert(io.open("sync/ReplicatedStorage/Shared/Library/MasterEffects/Visual.luau","rb"))
local source=file:read("*a");file:close()
source=assert(source:match("(local v_u_269 = tick%(%)%s*Effects.blood_impact.-)Effects.rock_break"))
local now=0;local created={};local disabled=false
local vector=setmetatable({Magnitude=0},{__sub=function(self) return self end,__unm=function(self) return self end})
local function object(class)
 local o={class=class,children={}}
 function o:IsA(kind) return self.class==kind end
 function o:FindFirstChild(name) for _,c in ipairs(self.children) do if c.Name==name then return c end end end
 function o:Emit(count) self.count=count end
 function o:Clone() return object(self.class) end
 return setmetatable(o,{__newindex=function(self,key,value)
  rawset(self,key,value)
  if key=="Parent" and value.children then table.insert(value.children,self) end
 end})
end
local world=object("Folder")
local env=setmetatable({Effects={},tick=function() return now end,
 Runtime={Setting=function() return disabled end,Assets=function() return {FindFirstChild=function() return nil end} end,World=function() return world end},
 l_CurrentCamera_0={CFrame={Position=vector}},workspace={Gravity=196.2},
 s_Debris_0={AddItem=function(_,o,life) o.life=life end},v_u_30={raycastline=function() return nil end},v_u_38={},
 Instance={new=function(class) local o=object(class);created[#created+1]=o;return o end},
 Vector3={new=function() return vector end},Vector2={new=function() return {} end},
 Color3={fromRGB=function() return {} end},ColorSequence={new=function() return {} end},
 NumberSequence={new=function() return {} end},NumberRange={new=function() return {} end}}, {__index=_G})
assert(load(source,"blood impact","t",env))()
now=1
env.Effects.blood_impact({point={Position=vector,LookVector=vector},headshot=true})
assert(#created==2 and created[1].Parent==world and created[1].life==2)
assert(not created[1].CanCollide and not created[1].CanQuery)
assert(created[2].Rate==0 and created[2].count==6)
disabled=true;now=2
env.Effects.blood_impact({point={Position=vector,LookVector=vector}})
assert(#created==2)
print("Impact effects: all material routes, missing assets, blood fallback and disabled blood passed")
