local module = {}

local player_service = game:GetService("Players")
local workspace_service = game:GetService("Workspace")
local collection_service = game:GetService("CollectionService")
local replicatedstorage_service = game:GetService("ReplicatedStorage")

local Interaction_Communication = replicatedstorage_service:WaitForChild("Shared"):WaitForChild('Library'):WaitForChild("Events"):WaitForChild("Interaction_Communication")
local Interaction_Connection = Interaction_Communication.Interact_Connection

local local_player = player_service.LocalPlayer
local mouse = local_player:GetMouse()

local function add_highlight(parent)
	local highlight = Instance.new("Highlight")
	highlight.Parent = parent
	highlight.FillTransparency = 1
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	
	return highlight
end

function module.start_module()
	print("[INTERACTIONSERVICE] Started!")
	-- // if mouse hits a part named 'click' then highlight the parent of it
	for _, descendant in pairs(workspace_service:GetDescendants()) do
		if descendant:IsA("ClickDetector") then
			local highlight

			descendant.MouseHoverEnter:Connect(function()
				highlight = add_highlight(descendant.Parent.Parent)
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
				if local_player.Character:FindFirstChildWhichIsA("Tool") then return end
				
				Interaction_Connection:FireServer(descendant.Parent.Parent)
			end)
		end
	end
end

return module
