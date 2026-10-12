local RS = game:GetService("ReplicatedStorage")
local Classes = require(RS.Shared.Library.ClassDefinitions)
local Ids = require(RS.Shared.Library.WeaponIds)
local Data = require(RS.Shared.Library.WeaponMenuData)
local Mounts = require(RS.Shared.Library.WeaponPreviewMounts)
local Resolver = require(RS.Shared.Library.Classes.GunClasses.AnimationResolver)
local Preview = {}
local playing = setmetatable({}, {__mode="k"})

-- Clone the appearance, never the live character's animation controller.
function Preview.Clone(character)
 local archivable=character.Archivable
 character.Archivable=true
 local clone=character:Clone()
 character.Archivable=archivable
 if not clone then return end
 clone:SetAttribute("MenuPreviewRig",true)
 for _, object in clone:GetDescendants() do
  if object:IsA("LuaSourceContainer") or object:IsA("Tool") or object:IsA("Animator") or object.Name=="CharacterData" or object.Name=="Equipment_BB" or object:IsA("BillboardGui") or object:IsA("SurfaceGui") or object:IsA("Sound") then
   object:Destroy()
  elseif object:IsA("Light") or object:IsA("ParticleEmitter") or object:IsA("Beam") or object:IsA("Trail") then
   object.Enabled=false
  elseif object:IsA("BasePart") then
   object.LocalTransparencyModifier=0
   object.Anchored=false
   object.CanCollide=false; object.CanTouch=false; object.CanQuery=false
   if object.Parent==clone and object.Name~="HumanoidRootPart" then object.Transparency=0 end
  end
 end
 for _, object in clone:GetDescendants() do
  if object:IsA("JointInstance") or object:IsA("WeldConstraint") then
   if not object.Part0 or not object.Part1 or not object.Part0:IsDescendantOf(clone) or not object.Part1:IsDescendantOf(clone) then object:Destroy() end
  end
 end
 local humanoid=clone:FindFirstChildOfClass("Humanoid")
 if humanoid then Instance.new("Animator").Parent=humanoid end
 return clone
end

function Preview.Place(character, frame, marker)
	local root=character:FindFirstChild("HumanoidRootPart")
	local humanoid=character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end
	local leg=character:FindFirstChild("Left Leg")
	local height=root.Size.Y/2+humanoid.HipHeight+(leg and leg.Size.Y or 0)
	local exclude={character}
	if marker then
		table.insert(exclude,marker)
		for _, child in marker.Parent:GetChildren() do
			if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then table.insert(exclude,child) end
		end
	end
	local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Exclude; params.FilterDescendantsInstances=exclude
	local hit=workspace:Raycast(frame.Position+Vector3.yAxis,-Vector3.yAxis*(height+4),params)
	local floor=hit and hit.Position.Y
 local targetY=floor and floor+height or frame.Position.Y
	for _, part in character:GetDescendants() do
		if part:IsA("BasePart") then part.CanCollide=false; part.CanTouch=false; part.CanQuery=false end
	end
	root.Anchored=true
	local target=CFrame.new(frame.Position.X,targetY,frame.Position.Z)*frame.Rotation
	character:PivotTo(target*root.CFrame:Inverse()*character:GetPivot())
end

function Preview.AnimationName(player)
	local loadout=Classes.GetLoadout(player,Classes.Selected(player))
	local definition=Classes.Get(Classes.Selected(player))
	local primary=loadout and loadout:FindFirstChild("Primary")
	local secondary=loadout and loadout:FindFirstChild("Secondary")
	local name=definition.FixedPrimary or (primary and primary.Value~="" and primary.Value) or (secondary and secondary.Value) or ""
	local asset=Ids.AssetName(name)
	local data=Data[Ids.MasterSourceName(name)] or {}
	local rules=Mounts[Ids.MasterSourceName(name)] or {}
 local variant=rules.variant
 local base=variant and variant~="" and variant or asset
 local size=data.size or rules.size or 2
 if variant=="steyr" or variant=="saa" or asset=="walker" then size=1 end
 local kind="none"
 if name~="" then
  if size>=2 then
   local special={dbgun="db",henry="henry",lance="lance",crossbow="crossbow"}
   kind=variant=="remington" and "db" or special[base] or "rifle"
  else
   kind=({cavsword="cavsword",vanguardshield="shield",shield="shield"})[base] or "pistol"
  end
  if asset=="shield" then kind="shield" end
 end
	return (player.Team and player.Team.Name=="Golden Empire" and "empire_" or "nation_") .. kind
end

function Preview.Stop(character)
	local state=character and playing[character]
	if not state then return end
	playing[character]=nil
	state.connection:Disconnect()
	state.destroying:Disconnect()
	if state.keepPlaying then state.keepPlaying:Disconnect() end
	if state.track then state.track:Stop(0); state.track:Destroy() end
	if state.animate and state.animate.Parent then state.animate.Enabled=state.animateEnabled end

end
function Preview.PlayLoadout(character,player)
	if not character or character==player.Character then return end
	Preview.Stop(character)
	local humanoid=character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local animator=humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator")
	animator.Parent=humanoid
	local animations=RS.Shared.Assets:FindFirstChild("Animations")
	local characters=animations and animations:FindFirstChild("Character")
	local folder=characters and characters:FindFirstChild("Menu")
	local name=Preview.AnimationName(player)
	local clip=folder and folder:FindFirstChild(name)
	local state={}
	playing[character]=state
	local animate=character:FindFirstChild("Animate")
	if animate and animate:IsA("LocalScript") then state.animate=animate; state.animateEnabled=animate.Enabled; animate.Enabled=false end
	for _, track in animator:GetPlayingAnimationTracks() do
		track:Stop(0)
	end
	state.connection=animator.AnimationPlayed:Connect(function(track) if track~=state.track then track:Stop(0) end end)
	state.destroying=character.Destroying:Connect(function() Preview.Stop(character) end)
	local animation=clip and Resolver.Resolve(clip,"menu",name)
	if not animation then warn("[Menu/Loadout] Missing usable menu animation: " .. name); return end
	local ok, track=pcall(function() return animator:LoadAnimation(animation) end)
	if not ok then warn("[Menu/Loadout] Could not load " .. name); return end
	state.track=track; track.Priority=Enum.AnimationPriority.Action4; track.Looped=true

	track:Play(0,1,0.25)
end
return Preview
