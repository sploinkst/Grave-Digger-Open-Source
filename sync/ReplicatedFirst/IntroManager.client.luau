local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local function removeIntro(child)
	if child.Name == "Intro" then child:Destroy() end
end
playerGui.ChildAdded:Connect(removeIntro)
for _, child in playerGui:GetChildren() do
	removeIntro(child)
end
