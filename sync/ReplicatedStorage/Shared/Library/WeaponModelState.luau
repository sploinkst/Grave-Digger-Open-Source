local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local State = {}

local function visible(group, enabled)
	if not group then return end
	local objects = group:GetDescendants()
	table.insert(objects, group)
	for _, part in objects do
		if part:IsA("BasePart") or part:IsA("Decal") then
			local original = part:GetAttribute("WeaponModelTransparency")
			if original == nil then original = part.Transparency
				if original == 1 and part.Name ~= "hitbox" then original = 0 end
				part:SetAttribute("WeaponModelTransparency", original) end
			part.Transparency = enabled and original or 1
		end
	end
end

local function group(weapon, name)
	local model = weapon.actual_model
	local parts = model and (model:FindFirstChild("parts") or model)
	return parts and parts:FindFirstChild(name, true)
end

local function handRound(weapon)
	if weapon._modelHandRound and weapon._modelHandRound.Parent then return weapon._modelHandRound end
	local character = Players.LocalPlayer.Character
	local armName = weapon.Round_Target_Part or (weapon.motor_6d_data and weapon.motor_6d_data.Part0 == "Left Arm" and "Right Arm" or "Left Arm")
	local arm = character and character:FindFirstChild(armName)
	local source = weapon.Round or group(weapon, "casing")
	if not arm or not source then return end
	local clone = source:Clone()
	local root = clone:IsA("BasePart") and clone or clone:FindFirstChildWhichIsA("BasePart", true)
	if not root then clone:Destroy(); return end
	clone.Name = (weapon.MasterAssetName or weapon.className) .. "_round"
	local c0 = source:GetAttribute("HandC0") or CFrame.new(0, -1, 0)
	local delta = arm.CFrame * c0 * root.CFrame:Inverse()
	local parts = clone:GetDescendants(); table.insert(parts, clone)
	for _, object in parts do
		if object:IsA("JointInstance") or object:IsA("WeldConstraint") or object:IsA("LuaSourceContainer") then object:Destroy() end
	end
	for _, part in parts do
		if part:IsA("BasePart") then
			part.CFrame = delta * part.CFrame; part.Anchored = false; part.Massless = true
			part.CanCollide = false; part.CanTouch = false; part.CanQuery = false; part.LocalTransparencyModifier = 0
			if part ~= root then
				local weld = Instance.new("WeldConstraint"); weld.Part0 = root; weld.Part1 = part; weld.Parent = root
			end
		end
	end
	local mount = Instance.new("Motor6D")
	mount.Name = clone.Name; mount.Part0 = arm; mount.Part1 = root; mount.C0 = c0; mount.Parent = root
	clone.Parent = arm; weapon._modelHandRound = clone
	return clone
end

function State.Update(weapon)
	local model = weapon.actual_model
	if not model then return end
	local asset = (weapon.MasterAssetName or ""):gsub("variant$", "")
	local loaded = (weapon.Capacity or 0) > 0
	if asset == "henry" and weapon.IsVeteran and not weapon.Reloading then
		visible(handRound(weapon), not weapon.Alt_Mode)
	end
	if asset == "crossbow" then visible(group(weapon, "bolt"), loaded and weapon.CrossbowCocked ~= false) end
	if asset == "springfield" and not weapon.Alting and not weapon.Reloading then
		visible(group(weapon, "pedersen"), weapon.PedersenMode == true)
		visible(group(weapon, "pedersenmag"), weapon.PedersenMode == true)
		visible(group(weapon, "bolt"), weapon.PedersenMode ~= true)
	end
	for _, name in {"Locked", "Akimbo_Locked", "Locked_Alt"} do
		local track = weapon.RegisteredAnimations and weapon.RegisteredAnimations[name]
		local active = name == "Locked_Alt" and weapon.AltSlideLocked
			or name == "Akimbo_Locked" and weapon.SlideLocked and weapon.DualWieldActive
			or name == "Locked" and weapon.SlideLocked and not weapon.DualWieldActive
		if track then
			if active and not track.IsPlaying then track:Play(0.1)
			elseif not active and track.IsPlaying then track:Stop(0.05) end
		end
	end
	if not weapon.Reloading then
		visible(group(weapon, "last_round"), loaded)
		if asset == "dbgun" then
			visible(group(weapon, "shell1"), (weapon.Capacity or 0) >= 1)
			visible(group(weapon, "shell2"), (weapon.Capacity or 0) >= 2)
		end
	end
end

function State.Keyframe(weapon, marker)
	local effect = marker:gsub("^vfx_", "")
	if effect == "hand_shell_visible" or effect == "hand_shell_invisible" then
		local round = handRound(weapon)
		if not round then return false end
		visible(round, effect == "hand_shell_visible")
		return true
	elseif effect == "crossbow_update_quiver" then
		if weapon._updateQuiver then weapon:_updateQuiver() end
		return true
	elseif effect == "crossbow_bolt_visibility" then
		visible(group(weapon, "bolt"), (weapon.Capacity or 0) > 0)
		return true
	elseif effect == "casing_visibility" or effect == "magazine_last_round" then
		visible(group(weapon, effect == "casing_visibility" and "casing" or "last_round"), (weapon.Capacity or 0) > 0)
		return true
	elseif effect == "springfield_pedersen_on" or effect == "springfield_pedersen_off" then
		visible(group(weapon, "pedersen"), effect == "springfield_pedersen_on")
		return true
	elseif effect == "springfield_bolt_off" or effect == "springfield_bolt_on" then
		visible(group(weapon, "bolt"), effect == "springfield_bolt_on")
		return true
	elseif effect == "springfield_pedersen_mag_on" or effect == "springfield_pedersen_mag_off" then
		visible(group(weapon, "pedersenmag"), effect == "springfield_pedersen_mag_on")
		return true
	elseif effect == "henry_offhandround" then
		local round = handRound(weapon)
		visible(round, weapon.IsVeteran and not weapon.Alt_Mode and (weapon.Capacity or 0) > 0)
		return true
	end
	return false
end

function State.Stop(weapon)
	if weapon._modelStateConnection then weapon._modelStateConnection:Disconnect(); weapon._modelStateConnection = nil end
	if weapon._modelHandRound then weapon._modelHandRound:Destroy(); weapon._modelHandRound = nil end
end

function State.Start(weapon)
	State.Stop(weapon)
	if not weapon.IsFirearm then return end
	local asset = (weapon.MasterAssetName or ""):gsub("variant$", "")
	if (asset == "pieper" or asset == "crossbow") and weapon.SlideLocked == nil then weapon.SlideLocked = true end
	State.Update(weapon)
	weapon._modelStateConnection = RunService.Heartbeat:Connect(function()
		if weapon.Equipped then State.Update(weapon) end
	end)
end

return State
