local Shared=game:GetService("ReplicatedStorage").Shared
local Ids=require(Shared.Library.WeaponIds)
local Cosmetics=require(Shared.Library.MasterCosmetics)
local Skins={}
function Skins.Select(player, request)
 if type(request)~="table" or type(request.weapon)~="string" or type(request.skin)~="string" then return false end
 if not player:GetAttribute("PlayerDataReady") then return false end
 local weapon=Ids.Canonical(request.weapon)
 if #request.weapon>80 or #request.skin>80 or not Ids.CanonicalToLegacyAsset[weapon] then return false end
 local asset=Ids.AssetName(weapon)
 local definition
 if request.skin~="stock" then
  for _,entry in ipairs(Cosmetics.skins[asset] or {}) do if entry.int==request.skin then definition=entry;break end end
  if not definition then return false end
 end
 local root=player:FindFirstChild("PlayerData")
 local data=root and root:FindFirstChild("PlayerData")
 if not data then return false end
 if definition then
  local mastery=data:FindFirstChild("Mastery")
  local kills=mastery and (mastery:FindFirstChild(asset) or mastery:FindFirstChild(weapon))
  if (kills and kills.Value or 0)<(definition.kill_req or 0) then return false end
  if definition.spec then
   local unlocks=data:FindFirstChild("CosmeticUnlocks")
   local unlocked=unlocks and unlocks:FindFirstChild(definition.spec)
   if not unlocked or not unlocked:IsA("BoolValue") or not unlocked.Value then return false end
  end
 end
 local slot=request.slot==2 and 2 or 1
 local folder=data:FindFirstChild("Skins")
 if not folder then folder=Instance.new("Folder");folder.Name="Skins";folder.Parent=data end
 local name=Ids.MasterSourceName(weapon)..slot
 local value=folder:FindFirstChild(name)
 if not value then value=Instance.new("StringValue");value.Name=name;value.Parent=folder end
 if not value:IsA("StringValue") then return false end
 value.Value=request.skin
 return true
end
return Skins
