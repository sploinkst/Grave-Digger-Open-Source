-- Run in Studio's Command Bar in Edit mode; this only reads existing assets.
local RS = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")
local guns = RS.Shared.Assets.Animations.Tools.Guns
local report = {}
local checked = {}
local missing, denied = 0, 0
local function fetch(id)
 if not id or id == "" or id == "rbxassetid://0" then missing = missing + 1; return "Missing published ID" end
 if not checked[id] then
  local animation = Instance.new("Animation")
  animation.AnimationId = id
  local ok, err = pcall(function()
   ContentProvider:PreloadAsync({animation}, function(_, result) checked[id] = result.Name end)
  end)
  animation:Destroy()
  checked[id] = checked[id] or (ok and "Unknown" or tostring(err))
 end
 if checked[id] ~= "Success" then denied = denied + 1 end
 return checked[id]
end
for _, folder in ipairs(guns:GetChildren()) do
 local entries = {}
 local sequences = 0
 for _, item in ipairs(folder:GetDescendants()) do
  if item:IsA("KeyframeSequence") then
   sequences = sequences + 1
   local wrapper = item.Parent
   local published = item:GetAttribute("PublishedAnimationId") or wrapper:GetAttribute("PublishedAnimationId")
   local number = published and tostring(published):match("%d+")
   local id = number and ("rbxassetid://" .. number) or (wrapper:IsA("Animation") and wrapper.AnimationId or "")
   local status = fetch(id)
   table.insert(entries, {clip = item:GetFullName(), id = id, status = status})
  end
 end
 -- Some guns supply uploaded Animation objects without local keyframes.
 for _, item in ipairs(folder:GetDescendants()) do
  if item:IsA("Animation") and not item:FindFirstChildWhichIsA("KeyframeSequence", true) then
   table.insert(entries, {clip = item:GetFullName(), id = item.AnimationId, status = fetch(item.AnimationId), embedded = false})
  end
 end
 report[folder.Name] = entries
 if sequences == 0 then warn("[AnimationAudit] " .. folder.Name .. " has no embedded sequences; inspect its uploaded IDs or ServerStorage.animations.tools") end
end
print("[AnimationAudit] Missing published IDs: " .. missing .. "; failed clip fetches: " .. denied)
print(HttpService:JSONEncode(report))
