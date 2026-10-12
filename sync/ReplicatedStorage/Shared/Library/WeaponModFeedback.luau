-- Continuous mod stances and bipod contact feedback from the tool master.
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Feedback = {}

function Feedback.Update(weapon, now)
	if not weapon.Equipped then return end
	local supported = weapon._hasBipodSupport and weapon:_hasBipodSupport() or false
	if supported then weapon._bipodContactAt = now end
	local buffer = weapon.tool and weapon.tool:GetAttribute("BipodBuffer") or 0.2
	weapon._bipodActive = supported or (weapon.Aiming and weapon._bipodContactAt ~= nil
		and now - weapon._bipodContactAt <= buffer) or false
	if not weapon.Aiming and not supported then weapon._bipodContactAt = nil end
	local previous = weapon._bipodSupported or false
	weapon._bipodSupported = supported
	if previous ~= supported and weapon.Aiming
		and now - (weapon._bipodSoundAt or -math.huge) >= 0.2 then
		local sounds = Shared.Assets:FindFirstChild("Sounds")
		local name = (supported and "bipod_deploy" or "bipod_undeploy") .. math.random(1, 4)
		local sound = sounds and sounds:FindFirstChild(name, true)
		local player = Players.LocalPlayer
		local character = player and player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if sound and sound:IsA("Sound") and root then
			weapon:_play_sfx(sound, root, nil, nil, nil, 0.1)
		end
		weapon._bipodSoundAt = now
	end

	-- Fire/cycle actions layer over the stance. Inspections and reloads own
	-- their own animations until they finish; never replay draw or action clips.
	if not weapon.Aiming or weapon.Equipping or weapon.Reloading or weapon.Checking
		or weapon.Meleeing or weapon.Alting or weapon.Spinning or weapon.IsShorted
		or weapon.ForceBlockFire or not weapon:_usesCombatAim() then return end
	local want = weapon:_aimTrack()
	if not want then return end
	local anims = weapon.RegisteredAnimations or {}
	for _, name in ipairs({"Aim", "Aim_Left", "Bipod_Aim"}) do
		local other = anims[name]
		if other and other ~= want and other.IsPlaying then other:Stop(weapon:_aimDuration()) end
	end
	if anims.Hold and anims.Hold ~= want and anims.Hold.IsPlaying then anims.Hold:Stop(0.06) end
	if not want.IsPlaying then
		want.Looped = true
		want:Play(weapon:_aimDuration(), 1, 0.5)
	end
end

function Feedback.Stop(weapon)
	if weapon._modFeedbackConnection then weapon._modFeedbackConnection:Disconnect() end
	weapon._modFeedbackConnection = nil
	weapon._bipodSupported = nil
	weapon._bipodContactAt = nil
	weapon._bipodSoundAt = nil
	weapon._bipodActive = false
end

function Feedback.Start(weapon)
	Feedback.Stop(weapon)
	weapon._modFeedbackConnection = RunService.RenderStepped:Connect(function()
		if not weapon.Equipped then Feedback.Stop(weapon); return end
		Feedback.Update(weapon, os.clock())
	end)
end

return Feedback
