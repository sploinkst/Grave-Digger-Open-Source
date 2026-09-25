
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local function ready()
    return player:GetAttribute("Whitelisted") and player:GetAttribute("ClientDependenciesReady") and player:GetAttribute("PlayerDataReady")
end
while not ready() do task.wait(0.25) end
local modules = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Client Modules")
require(modules:WaitForChild("InteractionService")).start_module()
require(modules:WaitForChild("MenuService")).start_module()
