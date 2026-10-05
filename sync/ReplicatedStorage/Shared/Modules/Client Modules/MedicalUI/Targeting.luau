local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Targeting = {}

function Targeting.Find(range)
	local player = Players.LocalPlayer
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	if not root or not camera or not player.Team then return nil end
	local pointer = UIS:GetMouseLocation()
	local ray = camera:ScreenPointToRay(pointer.X, pointer.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {character}
	local hit = workspace:Raycast(ray.Origin, ray.Direction * (range + (camera.CFrame.Position - root.Position).Magnitude), params)
	local model = hit and hit.Instance
	local ally
	while model and model ~= workspace do
		if model:IsA("Model") then ally = Players:GetPlayerFromCharacter(model); if ally then break end end
		model = model.Parent
	end
	if not ally or ally == player or ally.Team ~= player.Team then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local targetRoot = model:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not targetRoot or (targetRoot.Position - root.Position).Magnitude > range then return nil end
	return {player = ally, character = model, root = targetRoot, humanoid = humanoid}
end

return Targeting
