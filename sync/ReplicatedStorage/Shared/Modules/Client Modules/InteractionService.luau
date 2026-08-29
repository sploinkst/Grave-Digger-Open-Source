--!strict

local Module = {}

-- // Services
local PlayerService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorageService = game:GetService("ReplicatedStorage")

-- // Constants
local InteractionConnection = ReplicatedStorageService:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Events"):WaitForChild("Interact")
local LocalPlayer = PlayerService.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // Utilities

local function AddHighlight(parent)
	local highlight = Instance.new("Highlight")
	highlight.Parent = parent
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded

	return highlight
end

-- // Core

function Module.start_module()
	print("[INTERACTIONSERVICE] Started!")

	-- // if mouse hits a part named 'click' then highlight the parent of it
	for _, descendant in pairs(WorkspaceService:GetDescendants()) do
		if descendant:IsA("ClickDetector") then
			local highlight

			descendant.MouseHoverEnter:Connect(function()
				highlight = AddHighlight(descendant.Parent.Parent)
				print("[INTERACTIONSERVICE] Highlighted!")
			end)

			descendant.MouseHoverLeave:Connect(function()
				if highlight then
					highlight:Destroy()
					highlight = nil
				end

				print("[INTERACTIONSERVICE] Unhighlighted!")
			end)

			descendant.MouseClick:Connect(function()
				print("[INTERACTIONSERVICE] Clicked!")
				if LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
					return
				end

				InteractionConnection:FireServer(descendant.Parent.Parent)
			end)
		end
	end
end

return Module