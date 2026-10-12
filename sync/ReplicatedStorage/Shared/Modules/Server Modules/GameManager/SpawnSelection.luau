-- Server-owned destinations for the master death-screen spawn selector.
local Collection = game:GetService("CollectionService")
local Selection = {}
local function destination(player, kind)
 if not player.Team then return nil end
 local tag = kind=="train" and "TrainSpawn"  or nil
 if not tag then return nil end
 for _, item in ipairs(Collection:GetTagged(tag)) do
  if item:IsDescendantOf(workspace) and item:GetAttribute("Team")==player.Team.Name then
   local part=item:IsA("BasePart") and item or item:FindFirstChild("spawn",true) or (item:IsA("Model") and item.PrimaryPart)
   if part and part:IsA("BasePart") then return part end
  end
 end
end
function Selection.Options(player)
 return {base=player.Team~=nil,train=destination(player,"train")~=nil,engineer=false}
end
function Selection.Select(player, kind)
 if type(kind)~="string" or not Selection.Options(player)[kind] then return false end
 player:SetAttribute("SpawnChoice",kind)
 return true
end
function Selection.CFrame(player)
 local kind=player:GetAttribute("SpawnChoice")
 if kind==nil or kind=="base" then return nil end
 local part=destination(player,kind)
 if not part then player:SetAttribute("SpawnChoice","base");return nil end
 return part.CFrame+Vector3.new(0,3,0)
end
return Selection
