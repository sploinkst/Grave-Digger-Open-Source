-- Server-owned swept flight. Clients supply direction, never impact or damage.
local RunService=game:GetService("RunService")
local Debris=game:GetService("Debris")
local Projectile={}
function Projectile.Launch(character,source,direction,speed,onImpact,options)
	local head=character:FindFirstChild("Head")
	if not head or not source or not (source:IsA("Model") or source:IsA("BasePart")) then return false end
	local clone=source:Clone()
	local parts=clone:GetDescendants()
	if clone:IsA("BasePart") then table.insert(parts,clone) end
	for _,part in ipairs(parts) do
		if part:IsA("BasePart") then part.Anchored=true; part.CanCollide=false; part.CanTouch=false; part.CanQuery=false
		elseif part:IsA("Script") or part:IsA("LocalScript") or part:IsA("JointInstance") then part:Destroy() end
	end
	clone.Parent=workspace
	local position=head.Position
	local velocity=direction*speed
	local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances={character,clone}
	local elapsed=0
	local connection
	local function finish(hit)
		connection:Disconnect()
		if hit then onImpact(hit,clone) end
		if not options or not options.retain then clone:Destroy() end
	end
	connection=RunService.Heartbeat:Connect(function(dt)
		if not clone.Parent then connection:Disconnect(); return end
		elapsed+=dt
		if elapsed>(options and options.lifetime or 8) then finish(nil); clone:Destroy(); return end
		local remaining=math.min(dt,0.25)
		while remaining>0 do
			local step=math.min(remaining,1/60); remaining-=step
			local delta=velocity*step-Vector3.yAxis*workspace.Gravity*step*step/2
			local hit=workspace:Raycast(position,delta,params)
			if hit then clone:PivotTo(CFrame.new(hit.Position)); finish(hit); return end
			position+=delta; velocity-=Vector3.yAxis*workspace.Gravity*step
		end
		clone:PivotTo(CFrame.lookAt(position,position+velocity)*CFrame.Angles(elapsed*4,0,0))
	end)
	Debris:AddItem(clone,30)
	return true
end
return Projectile
