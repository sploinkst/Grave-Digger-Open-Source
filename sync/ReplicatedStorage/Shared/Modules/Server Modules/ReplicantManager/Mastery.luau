local Ids=require(game:GetService("ReplicatedStorage").Shared.Library.WeaponIds)
local Base=require(game:GetService("ReplicatedStorage").Shared.Library.MasterReference.Base)
local Mastery={}
local recorded=setmetatable({}, {__mode="k"})
function Mastery.Kill(player, character, weapon)
 if recorded[character] then return end
 recorded[character]=true
 local root=player:FindFirstChild("PlayerData")
 local data=root and root:FindFirstChild("PlayerData")
 local progress=data and data:FindFirstChild("Progression")
 if progress then
  local kills=progress:FindFirstChild("Kills");if kills then kills.Value=kills.Value+1 end
  local duty=progress:FindFirstChild("Duty");if duty then duty.Value=duty.Value+(Base.xp_on_kill or 2) end
 end
 local folder=data and data:FindFirstChild("Mastery")
 if folder and type(weapon)=="string" and weapon~="" then
  local name=Ids.AssetName(weapon)
  local count=folder:FindFirstChild(name)
  if not count then count=Instance.new("NumberValue");count.Name=name;count.Parent=folder end
  if count:IsA("NumberValue") then count.Value=count.Value+1 end
 end
end
return Mastery
