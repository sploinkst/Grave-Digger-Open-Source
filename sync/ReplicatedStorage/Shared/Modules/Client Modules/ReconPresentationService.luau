-- The master's rotating_indicator.ex is the only marker UI template.
local RS=game:GetService("ReplicatedStorage")
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local Assets=require(RS.Shared.Library.AuthoredAssets)
local Service={}
local indicators={}
function Service.start_module()
	if Service.started then return end; Service.started=true
	RS.Shared.Library.Events:WaitForChild("ReconAction").OnClientEvent:Connect(function(action,position,source)
		if action~="Ping" or typeof(position)~="Vector3" then return end
		local core=Assets.CoreGame(); local holder=core and core:FindFirstChild("rotating_indicator")
		local template=holder and holder:FindFirstChild("ex")
		if not template then return end
		local old=indicators[source]; if old then old.gui:Destroy() end
		local clone=template:Clone(); clone.Name="ReconPing"; clone.Visible=true; clone.Parent=holder
		clone.icon.Image="rbxassetid://9953839287"; clone.icon.ImageTransparency=0
		indicators[source]={gui=clone,position=position,created=os.clock(),expires=os.clock()+4,
			transition=os.clock(),onScreen=false,startPosition=clone.Position,startAnchor=clone.AnchorPoint}
	end)
	Players.LocalPlayer.CharacterAdded:Connect(function()
		for _,indicator in pairs(indicators) do indicator.gui:Destroy() end; table.clear(indicators)
	end)
	RunService.RenderStepped:Connect(function()
		local camera=workspace.CurrentCamera
		local character=Players.LocalPlayer.Character; local root=character and character:FindFirstChild("HumanoidRootPart")
		if not camera or not root then return end
		for source,indicator in pairs(indicators) do
			if not indicator.gui.Parent or os.clock()>=indicator.expires then indicator.gui:Destroy(); indicators[source]=nil; continue end
			local gui=indicator.gui
			local point,onScreen=camera:WorldToViewportPoint(indicator.position)
			if onScreen~=indicator.onScreen then
				indicator.transition=os.clock(); indicator.startPosition=gui.Position; indicator.startAnchor=gui.AnchorPoint
				indicator.onScreen=onScreen
			end
			local t=math.clamp((os.clock()-indicator.transition)/0.25,0,1); t=t*t*(3-2*t)
			local targetPosition=onScreen and UDim2.fromOffset(point.X,point.Y) or UDim2.fromScale(0.5,0.5)
			gui.Position=indicator.startPosition:Lerp(targetPosition,t)
			gui.AnchorPoint=indicator.startAnchor:Lerp(onScreen and Vector2.zero or Vector2.new(0.5,0.5),t)
			local _,cameraYaw=camera.CFrame:ToOrientation()
			local _,targetYaw=CFrame.lookAt(camera.CFrame.Position,indicator.position):ToOrientation()
			gui.Rotation=onScreen and 0 or math.deg(cameraYaw-targetYaw)
			gui.icon.Rotation=-gui.Rotation
			gui.icon.Position=onScreen and UDim2.fromScale(0.5,1) or UDim2.new(0,0,-8,0)
			gui.arrow.Visible=not onScreen; gui.dist.Visible=onScreen
			gui.dist.Text=tostring(math.ceil((root.Position-indicator.position).Magnitude))
			local fade=math.clamp(os.clock()-indicator.created-3,0,1)
			gui.icon.ImageTransparency=fade; gui.arrow.TextTransparency=fade; gui.dist.TextTransparency=fade
		end
	end)
end
return Service
