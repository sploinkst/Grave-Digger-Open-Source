local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local V = require(script.Parent.MasterActions.Validation)
local Playback = require(RS.Shared.Library.SoundPlayback)
local Effects = {}
local sessions = {}

local function sound(name)
 local sounds=RS.Shared.Assets:FindFirstChild("Sounds")
 local folder=sounds and (sounds:FindFirstChild("weldingtool",true) or sounds:FindFirstChild("WeldingTool",true))
 local source=folder and folder:FindFirstChild(name,true)
 return source and source:IsA("Sound") and source
end

local function enabled(session, contact)
	for _, effect in session.part:GetDescendants() do
		if effect:IsA("ParticleEmitter") or effect:IsA("Light") or effect:IsA("Beam") then effect.Enabled = contact end
	end
end

function Effects.Stop(player, tool)
	local session = sessions[player]
	if not session or tool and session.tool ~= tool then return end
	sessions[player] = nil
	local stopSound=sound("deactive")
	if stopSound then Playback.Play(stopSound,session.part,{PitchVariation=0.1}) end
	session.part:Destroy()
end

function Effects.Start(player, tool)
	local character, root = V.Tool(player, tool, {"WeldingTool", "weldingtool"})
	if not character then return end
	local old = sessions[player]
	if old and old.tool == tool then old.expires = os.clock() + 0.8; return end
	Effects.Stop(player)
	local part = Instance.new("Part")
	part.Name = player.Name .. "_welding"
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Transparency = 1; part.Anchored = true; part.CanCollide = false; part.CanTouch = false; part.CanQuery = false
	part.CFrame = root.CFrame
	local guns = RS.Shared.Assets:FindFirstChild("Guns")
	local folder = guns and guns:FindFirstChild("Effects")
	local template = folder and (folder:FindFirstChild("welding") or folder:FindFirstChild("Welding"))
	if template then
		local copy = template:Clone()
		if copy:IsA("Attachment") then copy.Parent = part
		else
			for _, object in copy:GetDescendants() do
				if object:IsA("Attachment") or ((object:IsA("ParticleEmitter") or object:IsA("Light") or object:IsA("Sound")) and object.Parent==copy) then object.Parent = part end
			end
			copy:Destroy()
		end
	end
	if not part:FindFirstChildWhichIsA("ParticleEmitter", true) then
		local attachment = Instance.new("Attachment"); attachment.Name = "welding"; attachment.Parent = part
		local sparks = Instance.new("ParticleEmitter")
		sparks.Name = "sparks"; sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		sparks.Rate = 45; sparks.Lifetime = NumberRange.new(0.1, 0.25); sparks.Speed = NumberRange.new(3, 7)
		sparks.SpreadAngle = Vector2.new(65, 65); sparks.LightEmission = 1
		sparks.Color = ColorSequence.new(Color3.fromRGB(255, 220, 120)); sparks.Parent = attachment
		local flash = Instance.new("PointLight"); flash.Name = "flash"; flash.Color = Color3.fromRGB(170, 210, 255)
		flash.Range = 8; flash.Brightness = 2; flash.Parent = attachment
	end
	local active=sound("active")
	if active then
		local loop=active:Clone(); loop.Looped=true; loop.Parent=part; loop:Play()
	end
	part.Parent = workspace:FindFirstChild("throwables") or workspace
	local session = {tool = tool, character = character, part = part, expires = os.clock() + 0.8, contactUntil = 0}
	sessions[player] = session
	enabled(session, false)
end

function Effects.Contact(player, tool, hit)
	Effects.Start(player, tool)
	local session = sessions[player]
	if not session or session.tool ~= tool then return end
	session.part.CFrame = CFrame.lookAt(hit.Position + hit.Normal * 0.02, hit.Position + hit.Normal)
	session.contactUntil = os.clock() + 0.65
	enabled(session, true)
end

RunService.Heartbeat:Connect(function()
	local now = os.clock()
	for player, session in sessions do
		if now > session.expires or player.Character ~= session.character
			or not V.Tool(player, session.tool, {"WeldingTool", "weldingtool"}) then
			Effects.Stop(player)
		else enabled(session, now <= session.contactUntil) end
	end
end)

return Effects
