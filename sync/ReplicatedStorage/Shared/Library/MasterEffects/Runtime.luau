-- Shared dependency adapter for the imported presentation modules.
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Runtime = {}
local MasterSettings = require(script.Parent.Parent.MasterClientSettings)
local assetRoots = {
 effects = {"Effects", "Guns", "Equipment"}, misc = {"Misc", "Equipment", "UI", "Effects"},
 death_fx = {"DeathEffects", "Deaths", "Effects"}, weapon_models = {"Guns", "Tools", "Equipment"},
 projectiles = {"Projectiles", "Guns", "Equipment"}, sound_library = {"Sounds"}, outfits = {"Outfits", "Cosmetics"},
}
local function child(parent, name, recursive)
 if not parent then return nil end
 local exact = parent:FindFirstChild(name, recursive)
 if exact then return exact end
 for _, item in (recursive and parent:GetDescendants() or parent:GetChildren()) do
  if string.lower(item.Name) == string.lower(name) then return item end
 end
end
local adapters = {}
function Runtime.Assets(category)
 if adapters[category] then return adapters[category] end
 local adapter = {}
 function adapter:FindFirstChild(name, recursive)
  local legacy = RS:FindFirstChild(category)
  local found = child(legacy, name, recursive)
  if found then return found end
  for _, root in assetRoots[category] or {} do
   found = child(child(RS.Shared.Assets, root), name, true)
   if found then return found end
  end
  return child(RS.Shared.Assets, name, true)
 end
 setmetatable(adapter, {__index = function(_, name) return adapter:FindFirstChild(name, true) end})
 adapters[category] = adapter
 return adapter
end
function Runtime.World(name)
 local existing = workspace:FindFirstChild(name)
 if existing then return existing end
 local details = workspace:FindFirstChild("Game_Details") or workspace
 local folder = details:FindFirstChild("MasterPresentation")
 if not folder then folder = Instance.new("Folder"); folder.Name = "MasterPresentation"; folder.Parent = details end
 local item = folder:FindFirstChild(name)
 if not item then
  item = Instance.new(name == "northpoint" and "Part" or "Folder")
  item.Name = name
  if item:IsA("BasePart") then item.Anchored = true; item.Transparency = 1; item.CanCollide = false; item.CanQuery = false; item.CanTouch = false end
  item.Parent = folder
 end
 return item
end
function Runtime.IsCharacter(character)
 return character and character:IsA("Model") and character:FindFirstChildOfClass("Humanoid") ~= nil and character:IsDescendantOf(workspace)
end
local settingNames = {lowgraphics = "LowGraphics", disableblood = "DisableBlood", disablegore = "DisableGore", disablebloodbody = "DisableBloodBody", disablebullettrails = "DisableBulletTrails", disabledeathyells = "DisableDeathYells", reducegunvolume = "ReduceGunVolume"}
function Runtime.Setting(name)
 local player = Players.LocalPlayer
 if not player then return false end
 local canonical = MasterSettings.Names[name] or settingNames[name] or name
 local attribute = player:GetAttribute(canonical)
 if attribute ~= nil then return attribute end
 local data = player:FindFirstChild("PlayerData")
 return MasterSettings.Read(data and data:FindFirstChild("Settings Data"), name)
end

local warnings = {}
function Runtime.Try(name, callback, ...)
 local ok, result = pcall(callback, ...)
 if not ok and not warnings[name] then warnings[name] = true; warn("[MasterEffects] " .. name .. ": " .. tostring(result)) end
 return ok, result
end
function Runtime.Spawn(callback, ...)
 local args = table.pack(...)
 return task.spawn(function() Runtime.Try("async presentation", callback, table.unpack(args, 1, args.n)) end)
end
function Runtime.Delay(seconds, callback, ...)
 local args = table.pack(...)
 return task.delay(seconds, function() Runtime.Try("delayed presentation", callback, table.unpack(args, 1, args.n)) end)
end
return Runtime
