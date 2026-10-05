-- Resolve authored instances without manufacturing replacement models or GUIs.
local RS = game:GetService("ReplicatedStorage")
local Assets = {}
function Assets.Find(name, roots, className)
	for _, root in ipairs(roots) do
		local direct = root:FindFirstChild(name)
		if direct and (not className or direct:IsA(className)) then return direct end
		for _, child in ipairs(root:GetDescendants()) do
			if child.Name == name and (not className or child:IsA(className)) then return child end
		end
	end
	return nil
end
function Assets.Roots()
	local roots = {RS.Shared.Assets}
	if game:GetService("RunService"):IsServer() then table.insert(roots, game:GetService("ServerStorage")) end
	return roots
end
function Assets.Deployable(name)
	local folder = RS.Shared.Assets:FindFirstChild("deployables")
	return folder and folder:FindFirstChild(name)
end
function Assets.CoreGame()
	local player = game:GetService("Players").LocalPlayer
	local gui = player and player:FindFirstChildOfClass("PlayerGui")
	if not gui then return nil end
	-- The place has both a Folder and a ScreenGui named main.
	for _, main in ipairs(gui:GetChildren()) do
		local core = main.Name == "main" and main:FindFirstChild("core_game")
		if core then return core end
	end
	return nil
end
return Assets
