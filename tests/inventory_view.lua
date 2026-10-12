local function object(name,class,children)
 local o={Name=name,ClassName=class,children=children or {},attrs={},ZIndex=1}
 for _,c in ipairs(o.children) do c.Parent=o end
 function o:IsA(kind) return kind==self.ClassName or kind=="GuiObject" and (class=="Frame" or class=="TextLabel" or class=="ImageLabel" or class=="TextButton") end
 function o:GetAttribute(n) return self.attrs[n] end
 function o:SetAttribute(n,v) self.attrs[n]=v end
 function o:GetChildren() return self.children end
 function o:GetDescendants()
  local result={};for _,c in ipairs(self.children) do result[#result+1]=c;for _,d in ipairs(c:GetDescendants()) do result[#result+1]=d end end;return result
 end
 function o:FindFirstChild(n,recursive)
  for _,c in ipairs(recursive and self:GetDescendants() or self.children) do if c.Name==n then return c end end
 end
 function o:FindFirstChildOfClass(kind) for _,c in ipairs(self.children) do if c:IsA(kind) then return c end end end
 function o:Clone()
  local children={};for _,c in ipairs(self.children) do children[#children+1]=c:Clone() end;return object(self.Name,self.ClassName,children)
 end
 function o:Destroy() self.Parent=nil end
 if class=="TextButton" then o.Activated={Connect=function(self,fn) self.callback=fn end} end
 return setmetatable(o,{__newindex=function(self,key,value)
  rawset(self,key,value);if key=="Parent" and value then value.children[#value.children+1]=self end
 end})
end
local template=object("ex","Frame",{object("icon","ImageLabel"),object("line","Frame"),object("num","TextLabel")})
local placeholder=template:Clone();placeholder.Name="lebel1"
local holder=object("inventory","Frame",{template,placeholder})
local core=object("core_game","Frame",{holder})
script={Parent={AuthoredAssets="Assets"}}
local screen=object("Inventory","ScreenGui",{holder});screen.Enabled=false
require=function() return {CoreGame=function() return core end,MainGui=function() return screen end} end
local view=dofile("sync/ReplicatedStorage/Shared/Library/InventoryView.luau")
local gui=object("PlayerGui","PlayerGui",{screen})
assert(view.Template(gui)==holder and template.Visible==false and placeholder.Visible==false)
assert(screen.Enabled==true)
local f=assert(io.open("sync/ReplicatedStorage/Shared/Modules/Client Modules/InventoryService.luau","rb"))
local source=f:read("*a");f:close()
local create=assert(source:match("(local function CreateSlotUI.-)\nlocal function UpdateSlotUI"))
local equip=assert(source:match("(local function EquipTool.-)\nlocal function AssignTool"))
local public=assert(source:match("(function Module.EquipTool.-)\nfunction Module.UnequipCurrent"))
local env=setmetatable({InventoryView=view,GetSlotParts=view.Parts,LocalPlayer={PlayerGui=gui},EmptyIcon="empty",Module={},InventorySlots={},SlotOrder={"1"},
 Instance={new=function(class) return object(class,class) end},UDim2={fromScale=function() return {} end},OnInventoryKey=function() end,UpdateHighlight=function() end}, {__index=_G})
local playerAttrs={}
function env.LocalPlayer:GetAttribute(n) return playerAttrs[n] end
local humanoid=object("Humanoid","Humanoid");humanoid.Health=100
env.LocalPlayer.Character=object("Character","Model",{humanoid})
local calls=0
local weapon={item_image="weapon-icon",equip=function(self) self.Equipped=true;calls=calls+1 end,unequip=function(self) self.Equipped=false end}
local slot={Tool=weapon};env.InventorySlots["1"]=slot
env.FindExistingTool=function(t) return t==weapon end
assert(load(create.."\nreturn CreateSlotUI","inventory create","t",env))()("1",slot)
assert(slot.UI.Parent==holder and slot.UI:FindFirstChild("icon").Image=="weapon-icon" and slot.UI:FindFirstChild("num").Text=="1")
local row=slot.UI
assert(load(create.."\nreturn CreateSlotUI","inventory create","t",env))()("1",slot)
assert(slot.UI==row)
env.EquipTool=assert(load(equip.."\nreturn EquipTool","inventory equip","t",env))()
assert(load(public,"inventory public equip","t",env))()
local click=slot.UI:FindFirstChild("EquipButton").Activated.callback
click();assert(calls==1 and weapon.Equipped and env.currentEquipped==weapon and env.selectedKey=="1")
click();assert(not weapon.Equipped and env.currentEquipped==nil and env.selectedKey==nil)
playerAttrs.MenuOpen=true;click();assert(calls==1)
playerAttrs.MenuOpen=false;playerAttrs.CantUnequip=true;click();assert(calls==1)
playerAttrs.CantUnequip=nil;humanoid.Health=0;click();assert(calls==1)
humanoid.Health=100
weapon.className='BrowningMachineGun'
env.LocalPlayer.Character:SetAttribute('IsDreadnought',true)
assert(env.Module.EquipTool(weapon) and weapon.Equipped)
local dreadCalls=calls
assert(env.Module.EquipTool(weapon) and calls==dreadCalls and weapon.Equipped)
assert(not env.EquipTool(nil) and weapon.Equipped)
assert(not env.EquipTool({className='Medkit'}) and weapon.Equipped)
env.LocalPlayer.Character:SetAttribute('IsDreadnought',false)
gui.children={}
local delayed={Tool=weapon}
assert(load(create.."\nreturn CreateSlotUI","inventory create","t",env))()("1",delayed)
assert(delayed.UI==nil)
local canShow=true
local revealed,hidden=0,0
env.CanShowSlots=function() return canShow end
env.RevealSlots=function() revealed=revealed+1 end
env.FadeInventoryItemName=function() end
env.TweenSlot=function(_,props) if props.ImageTransparency==1 then hidden=hidden+1 end end
local fade=assert(source:match("(local function FadeSlots.-)\n%-%- // Inputs"))
local fadeSlots=assert(load(fade.."\nreturn FadeSlots","inventory visibility","t",env))()
fadeSlots();assert(revealed==1 and hidden==0)
canShow=false;fadeSlots();assert(hidden==1)
print("Inventory: authored slots, icons, duplicate prevention, equip toggle, menu/death locks and delayed HUD passed")
