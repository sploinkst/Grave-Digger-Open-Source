local RS = game:GetService("ReplicatedStorage")
local Remote = RS.Shared.Library.Events:WaitForChild("MedicalAction")
local Action = {}

function Action.Cancel(controller)
	if not controller.TabletToken then return end
	controller.TabletToken = nil
	local track = controller.RegisteredAnimations and controller.RegisteredAnimations.AfterHeal_Item
	if track then track:Stop(0.1) end
	Remote:FireServer("CancelTablets")
end

function Action.Begin(controller)
	if not controller.Equipped or controller.Equipping or controller.Healing or controller.TabletToken then return end
	local token = {}
	controller.TabletToken = token
	local track = controller.RegisteredAnimations and controller.RegisteredAnimations.AfterHeal_Item
	if track then track:Play(0.1, 1, 1) end
	Remote:FireServer("TakeTablets")
	task.delay(2.1, function()
		if controller.TabletToken == token then
			controller.TabletToken = nil
			if track then track:Stop(0.1) end
		end
	end)
end

return Action
