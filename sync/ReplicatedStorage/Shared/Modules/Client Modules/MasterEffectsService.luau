-- Server-confirmed world presentation uses the existing one-way presentation channel.
local RS = game:GetService("ReplicatedStorage")
local Dispatch = require(RS.Shared.Library.MasterEffects.Dispatch)
local Runtime = require(RS.Shared.Library.MasterEffects.Runtime)
local Service = {}
function Service.start_module()
 if Service.started then return end; Service.started = true
 RS.Shared.Library.Events:WaitForChild("Presentation").OnClientEvent:Connect(function(action, payload)
  if action ~= "master_effect" or type(payload) ~= "table" or type(payload.name) ~= "string" then return end
  task.spawn(function()
   Dispatch.Visual(payload.name,payload.data)
  end)
 end)
end
return Service
