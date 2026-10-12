-- Bridges game-native controllers and server presentation payloads to master effects.
local RunService = game:GetService("RunService")
local Runtime = require(script.Parent.Runtime)
local Dispatch = {}
local registries = {}
local function registry(kind)
 if not RunService:IsClient() then return nil end
 if registries[kind] == false then return nil end
 if not registries[kind] then
  local module = script.Parent:FindFirstChild(kind)
  if not module or not module:IsA("ModuleScript") then
   registries[kind] = false
   warn("[MasterEffects] Missing registry: " .. kind)
   return nil
  end
  local ok, result = pcall(require, module)
  if not ok or type(result) ~= "table" or type(result.Functions) ~= "table" then
   registries[kind] = false
   warn("[MasterEffects] Cannot load " .. kind .. ": " .. tostring(result))
   return nil
  end
  registries[kind] = result
 end
 return registries[kind]
end
function Dispatch.Visual(name, payload)
 local effects = registry("Visual")
 local callback = effects and effects.Functions[name]
 if not callback or type(payload) ~= "table" then return false end
 return Runtime.Try(name, callback, payload)
end
function Dispatch.Weapon(controller, marker)
 if controller.IsFirearm then return false end
 if not controller.actual_model or not controller.actual_model.Parent then return false end
 local name = marker:gsub("^vfx_", "")
 if controller.HandlesCasingKeyframes and (name:find("eject") or name:find("casing")) then return false end
 local effects = registry("Weapon")
 local callback = effects and effects.Functions[name]
 if not callback then return false end
 local asset = controller.MasterAssetName or controller.className
 local core = {
  ammo_mag = controller.Capacity or 0, loading_slugs = controller.LoadingSlugs == true,
  stim_selected = controller.SelectedStimulant or 1, reloading = controller.Reloading, lefthand = controller.lefthand == true,
 }
 local character = game:GetService("Players").LocalPlayer.Character
 local payload = {main = {model = controller.actual_model, char = character, weapon = asset, core = core, module = controller},
  origin = game:GetService("Players").LocalPlayer, stats = effects.Profiles[asset],}
 local ok = Runtime.Try(name, callback, payload)
 if ok then
  local event = game:GetService("ReplicatedStorage").Shared.Library.Events:FindFirstChild("WeaponEffect")
  if event and controller.tool then event:FireServer(name,controller.tool,controller.actual_model,core) end
 end
 return ok
end
function Dispatch.Has(kind, name)
 local effects = registry(kind)
 return effects and effects.Functions[name] ~= nil or false
end
function Dispatch.LegacyWeapon(name, payload)
 -- Native weapon effects already replicate; do not run the duplicate registry.
 return false
end

function Dispatch.Surface(result, controller)
 if not result then return false end
 local material = result.Material
 local name, asset = "mine_impact", "ricochet"
 local payload = {point = result.Position, normal = result.Normal, hit = result.Instance,
  hit_mat = material, bullet = true, pellets = controller.PelletCount, from = controller._lastShotOrigin}
 if material == Enum.Material.Wood or material == Enum.Material.WoodPlanks then
  name, asset = "wood_impact", "woodchip"
 elseif material == Enum.Material.Glass then
  name, asset = "wood_impact", "glassimpact"; payload.glass = true
 elseif material == Enum.Material.Sand or material == Enum.Material.Ground then
  name, asset = "wood_impact", "sandimpact"; payload.sand = true
 end
 if not Runtime.Assets("effects"):FindFirstChild(asset) then return false end
 return Dispatch.Visual(name, payload)
end
return Dispatch
