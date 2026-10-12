local RS=game:GetService("ReplicatedStorage")
local Player=game:GetService("Players").LocalPlayer
local Ids=require(RS.Shared.Library.WeaponIds)
local Cosmetics=require(RS.Shared.Library.MasterCosmetics)
local Scope=require(script.Parent.Scope)
local View={}
local rows
function View.Render(panel, weapon, slot)
 if rows then rows:Destroy();rows=nil end
 local mastery=panel and panel:FindFirstChild("masterylist")
 local list=mastery and mastery:FindFirstChild("skinlist")
 local template=list and list:FindFirstChild("ex")
 if not template then return end
 template.Visible=false
 rows=Scope.new()
 local asset=Ids.AssetName(weapon)
 local root=Player:FindFirstChild("PlayerData")
 local data=root and root:FindFirstChild("PlayerData")
 local counts=data and data:FindFirstChild("Mastery")
 local count=counts and (counts:FindFirstChild(asset) or counts:FindFirstChild(Ids.Canonical(weapon)))
 local kills=count and count.Value or 0
 local entries={{name="Stock",int="stock",col=Color3.new(1,1,1),kill_req=0}}
 for _,entry in ipairs(Cosmetics.skins[asset] or {}) do table.insert(entries,entry) end
 for index,entry in ipairs(entries) do
  local row=rows:Own(template:Clone());row.Name="MasterSkin_"..entry.int;row.LayoutOrder=index;row.Visible=true;row.Parent=list
  local color=row:FindFirstChild("col");if color then color.ImageColor3=entry.col or Color3.new(1,1,1) end
  local locked=row:FindFirstChild("skinlocked");if locked then locked.Visible=kills<(entry.kill_req or 0) end
  rows:Connect(row.MouseEnter,function()
   local label=mastery:FindFirstChild("skinsubtext")
   if label then label.Text=entry.name.." ("..kills.."/"..(entry.kill_req or 0).." kills)" end
  end)
  rows:Connect(row.Activated,function()
   RS.Shared.Library.Events:WaitForChild("Appearance"):FireServer("WeaponSkin",{weapon=weapon,skin=entry.int,slot=slot=="Secondary" and 2 or 1})
  end)
 end
end
return View
