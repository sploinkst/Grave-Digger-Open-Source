-- Internal visual API plus a validated relay for owned weapon animation effects.
local RS = game:GetService("ReplicatedStorage")
local Events = RS.Shared.Library.Events
local Allowed = require(RS.Shared.Library.MasterEffects.NetworkRules)
local WeaponIds = require(RS.Shared.Library.WeaponIds)
local last = setmetatable({}, {__mode = "k"})
local Relay = {}
function Relay.Visual(name, data)
 local event = Events:FindFirstChild("Presentation")
 if event then event:FireAllClients("master_effect", {name = name, data = data}) end
end
function Relay.start_module()
 if Relay.started then return end; Relay.started = true
 local event = Events:FindFirstChild("WeaponEffect")
 if not event then event = Instance.new("RemoteEvent"); event.Name = "WeaponEffect"; event.Parent = Events end
 event.OnServerEvent:Connect(function(player, name, tool, model, core)
  if type(name) ~= "string" or not Allowed[name] or typeof(tool) ~= "Instance" or not tool:IsA("Tool") then return end
  local character = player.Character
  local humanoid = character and character:FindFirstChildOfClass("Humanoid")
  if not humanoid or humanoid.Health <= 0 or tool.Parent ~= character then return end
  local reference = tool:FindFirstChild("model")
  local data = character:FindFirstChild("CharacterData")
  local equipment = data and data:FindFirstChild("Equipment")
  local owned = reference and (reference:IsA("ObjectValue") and reference.Value or reference:IsA("StringValue") and equipment and equipment:FindFirstChild(reference.Value))
  if typeof(model) ~= "Instance" or not model:IsA("Model") or model ~= owned or not model:IsDescendantOf(character) then return end
  local now = os.clock()
  local window = last[player]
  if not window or now - window.time >= 1 then window = {time = now, count = 0}; last[player] = window end
  window.count += 1; if window.count > 120 then return end
  core = type(core) == "table" and core or {}
  local ammo = type(core.ammo_mag) == "number" and core.ammo_mag == core.ammo_mag and math.clamp(core.ammo_mag, 0, 500) or 0
  local payload = {main = {char = character, model = model, weapon = WeaponIds.MasterSourceName(tool.Name) or tool.Name,
   module = {lefthand = core.lefthand == true}, core = {ammo_mag = ammo, loading_slugs = core.loading_slugs == true, stim_selected = 1}}, origin = player}
  local presentation = Events:FindFirstChild("Presentation")
  if presentation then
   for _, recipient in game:GetService("Players"):GetPlayers() do
    if recipient ~= player then presentation:FireClient(recipient, "master_weapon_effect", {name = name, data = payload}) end
   end
  end
 end)
end
return Relay
