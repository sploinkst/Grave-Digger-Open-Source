local KingslayerRevolver = require(script.Parent.LegacyGunFactory).create({
	className = "KingslayerRevolver",
	AuthoredWelds = {
		equipc0 = CFrame.new(-0.257659912, -1.43795609, -0.50579834, 0, 0, -1, 0.99999994, 0, 0, 0, -1, 0),
		equipc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		lefthand = false,
		holster_point = "Torso",
		holsterc0 = CFrame.new(-1.07449341, -0.18704772, -0.313476562, 0.338645965, -0.604027152, 0.721437454, 0.828506589, 0.554849684, 0.0756458044, -0.445981085, 0.572097838, 0.688336194),
		holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		alt_holsterc0 = CFrame.new(0.0736999512, -0.684338331, -0.582336426, 0.342020154, -0.939692616, 0, 0.939692616, 0.342020154, 0, 0, 0, 1),
		alt_holsterc1 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	},
	assetName = "walker",
	AnimationGunType = "KingslayerRevolver",
	StrictAnimations = true,
	AnimationMap = {
		Hold = "held", Fire = "fire", Fire_Left = "fire_left", Fire_Empty = "fire_empty",
		Fire_Break = "fire_break", Fire_Weak = "fire_weak", Reload_Start = "reload_start", Reload_End = "reload_end",
		Reload_Add_Ball = "reload_add_ball", Reload_Cap_Add = "reload_cap_add", Reload_Cap_Remove = "reload_cap_remove",
		Reload_Cylinder = "reload_cylinder", Reload_Dump = "reload_dump", Reload_Idle = "reload_idle",
		Reload_Lever = "reload_lever", Reload_Powder = "reload_powder", Spin_Cylinder = "spin_cylinder",
		Spin_Start = "spin_start", Spin_Loop = "spin_loop", Spin_End = "spin_end", Spin_End_Flashy = "spin_end_flashy",
	},
	reloadStartIsFullReload = true,
	WeaponCategory = "Pistol",
	Designation = "Primary",
	Weight = 2,
	LegacyStats = {
		name = "'Kingslayer' Percussion Revolver",
		icon = "118851184935301",
		ammo_give = ".44 Lead Ball",
		damage = 180,
		range = 40,
		range_damage = 170,
		far = 90,
		far_damage = 99,
		melee_damage = 80,
		melee_swing_speed = 0.7,
		melee_range = 5,
		pen = 4,
		wallpen_distance = 50,
		wallpen_studs = 3,
		accuracy = 16,
		moving_accuracy = 120,
		fire_rate = 1.4,
		cycle = 0,
		cycle_rest = 0,
		draw_speed = 0.5,
		aim_speed = 0.3,
		recoil = 25,
		recoil_count = 9,
		movement = 3,
		firing_movement = 2.5,
		firing_movement_last = 0.75,
		ammo_reserves = 1,
		ammo_reserves_max = 2,
		capacity = 6,
		chamber = false,
		size = 2,
		wound = 1,
		length = 3.5,
		reload_start = 0,
		reload_empty = 0,
		reload_loop = 0,
		reload_loop_after = 0,
		reload_end = 0,
	},
	bulletSpeed = 800,
})

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Input = game:GetService("UserInputService")
local Rules = require(RS.Shared.Library.KingslayerRules)
local Assets = require(RS.Shared.Library.AuthoredAssets)
local Playback = require(RS.Shared.Library.SoundPlayback)
local player = Players.LocalPlayer
local baseEquip, baseUnequip = KingslayerRevolver._on_equip, KingslayerRevolver._on_unequip
local baseActivate = KingslayerRevolver.activate
local baseDestroy = KingslayerRevolver.destroy
KingslayerRevolver.Can_Drop = false
KingslayerRevolver.Starting_Reserve_Ammo = 12

function KingslayerRevolver:_kingSound(name)
	local source = self.SoundFolder and self.SoundFolder:FindFirstChild(name, true)
	if not source then source = Assets.Find(name, {RS.Shared.Assets}, "Sound") end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if source and source:IsA("Sound") then return Playback.Play(source, root, {PitchVariation=0.1}) end
end
function KingslayerRevolver:_cylinderVisuals()
	if not self.actual_model or not self.KingslayerState then return end
	for index, chamber in ipairs(self.KingslayerState.chambers) do
		local round = self.actual_model:FindFirstChild("round" .. index, true)
		if round then
			round:SetAttribute("CapLoaded", chamber.cap == true)
			round:SetAttribute("BallSeated", chamber.ball == true)
			round:SetAttribute("PowderCharge", chamber.powder or 0)
			if round:IsA("BasePart") then round.Transparency = chamber.ball == false and 1 or 0 end
		end
	end
end
function KingslayerRevolver:_panel()
	if self._kingPanel then return self._kingPanel end
	local gui = Instance.new("ScreenGui")
	gui.Name = "KingslayerLoading"; gui.ResetOnSpawn = false
	local label = Instance.new("TextLabel")
	label.Name = "Instructions"; label.AnchorPoint = Vector2.new(0.5, 1)
	label.Position = UDim2.fromScale(0.5, 0.93); label.Size = UDim2.fromOffset(540, 190)
	label.BackgroundColor3 = Color3.fromRGB(20, 18, 16); label.BackgroundTransparency = 0.2
	label.TextColor3 = Color3.fromRGB(235, 225, 205); label.TextSize = 17; label.TextWrapped = true
	label.Font = Enum.Font.Garamond; label.Parent = gui
	gui.Enabled = false; gui.Parent = player:WaitForChild("PlayerGui")
	self._kingPanel = gui
	return gui
end
function KingslayerRevolver:_display(message)
	if not self.KingslayerState then return end
	local state = self.KingslayerState
	local index = self.Reloading and Rules.Previous(state.cylinder) or state.cylinder
	local panel = self:_panel(); panel.Enabled = true
	local reserve = self.tool and self.tool:FindFirstChild("Reserve_Ammo")
	local text = "Chamber " .. index .. " of 6" .. (state.broken and " ? CYLINDER BROKEN" or "")
	text ..= "\n" .. Rules.Inspect(state.chambers[index]) .. "\nLead balls: " .. (reserve and reserve.Value or 0)
	if self.Reloading then
		text ..= "\n1 / D-pad left: cap ? Hold 2 / D-pad right: powder ? 3 / D-pad up: ram"
		text ..= "\nAlternate Action: ball ? Check Ammo: dump ? Fire: rotate ? 4 / D-pad down: close"
		text ..= "\nRamrod chamber: " .. Rules.Previous(index)
	end
	if message then
		text ..= "\n" .. message
	end
	panel.Instructions.Text = text
end
function KingslayerRevolver:_request(action, amount)
	local generation = self._kingGeneration
	local remote = RS.Shared.Library.Events:FindFirstChild("KingslayerAction")
	if not remote then self:_display("Loading service unavailable."); return nil end
	local ok, response = pcall(function() return remote:InvokeServer(self.tool, action, amount) end)
	if not self.Equipped or generation ~= self._kingGeneration then return nil end
	if not ok or not response then return nil end
	if response.state then self.KingslayerState = response.state; self:_cylinderVisuals() end
	if response.error then self:_display(response.error); return nil end
	return response
end
function KingslayerRevolver:_loadingAction(action, amount)
	if not self.Equipped or not self.Reloading or self._kingBusy then return end
	self._kingBusy = true
	local generation = self._kingGeneration
	local chamber = self.KingslayerState and self.KingslayerState.chambers[Rules.Previous(self.KingslayerState.cylinder)]
	local animation = ({Ball="Reload_Add_Ball", Pour="Reload_Powder", Dump="Reload_Dump", Ram="Reload_Lever", Rotate="Reload_Cylinder", Close="Reload_End"})[action]
	if action == "Cap" then animation = chamber and chamber.cap == false and "Reload_Cap_Add" or "Reload_Cap_Remove" end
	local response = self:_request(action, amount)
	if response then
		if action ~= "Pour" then self:_playAnim(animation, false, {restart=true}) end
		self:_display()
		task.wait(response.duration or 0.3)
	end
	if not self.Equipped or generation ~= self._kingGeneration then return end
	self._kingBusy = false
	if action == "Close" and response then
		self.Reloading = false; player:SetAttribute("CantUnequip", nil)
		if self._kingPanel then self._kingPanel.Enabled = false end
		self:_stopAllExcept(); self:_restoreBaseDeferred()
	end
end
function KingslayerRevolver:_pour()
	if not self.Equipped or not self.Reloading or self._kingBusy then return end
	self._kingBusy = true
	local generation = self._kingGeneration
	local response = self:_request("PourStart")
	if not response then self._kingBusy = false; return end
	local track = self:_playAnim("Reload_Powder", false, {restart=true})
	task.wait(response.duration or 0.75)
	if not self.Equipped or generation ~= self._kingGeneration then return end
	if track then track:AdjustSpeed(0) end
	local pourSound = self:_kingSound("powder_pour") or self:_kingSound("powder")
	self._pourSound = pourSound
	local start = os.clock()
	repeat
		task.wait()
		if not self.Equipped or generation ~= self._kingGeneration then break end
		self:_display("Pouring: " .. math.floor(math.min(os.clock() - start, 1) * 100) .. "%")
	until not self.Equipped or not self.Reloading or os.clock() - start >= 1 or (not self._powderHeld and os.clock() - start >= 0.1)
	if pourSound then pourSound:Destroy(); self._pourSound = nil end
	if track then track:AdjustSpeed(1) end
	if not self.Equipped or generation ~= self._kingGeneration then return end
	self._kingBusy = false
	self:_loadingAction("Pour", math.clamp(os.clock() - start, 0.1, 1))
end
function KingslayerRevolver:reload()
	if not self.Equipped or self._kingBusy or self.Firing or self.Equipping then return false end
	if self.Reloading then self:_loadingAction("Close"); return true end
	local response = self:_request("Open")
	if not response then return false end
	self.Reloading = true; self._kingBusy = true
	self:endAiming(); player:SetAttribute("CantUnequip", true)
	local generation = self._kingGeneration
	self:_playAnim("Reload_Start", false, {restart=true}); self:_display()
	task.wait(response.duration or 0.5)
	if self.Equipped and self._kingGeneration == generation then self._kingBusy = false; self:_playAnim("Reload_Idle") end
	return true
end
function KingslayerRevolver:ammo_check()
	if self.Reloading then self:_loadingAction("Dump"); return end
	self:_display()
end
function KingslayerRevolver:end_ammo_check()
	if self._kingPanel and not self.Reloading then self._kingPanel.Enabled = false end
end
function KingslayerRevolver:_onAltInput(pressed)
	if pressed and self.Reloading then self:_loadingAction("Ball") end
end
function KingslayerRevolver:activate()
	if self.Reloading then self:_loadingAction("Rotate"); return end
	return baseActivate(self)
end
function KingslayerRevolver:fire()
	if not self.Equipped or self._kingBusy or self.Reloading or self.Firing or self:_isBusyForActivation() or not self:_canFireNow() then return false end
	if self:_if_sprinting() or self:_if_jumping() or self.ForceBlockFire then return false end
	if not self:_findModelPart(self.MuzzlePartName or "muzzle") or not self.Caster or not self.CasterBehavior then return false end
	self._kingBusy = true
	local response = self:_request("Fire")
	if not response then self._kingBusy = false; return false end
	local shot = response.shot
	if shot.kind == "break" then self:_kingSound("walker_break") end
	if shot.capFired then self:_kingSound("cap") end
	local animation = shot.kind == "break" and "Fire_Break" or (shot.kind == "weak" and "Fire_Weak" or "Fire")
	local fired = false
	if shot.projectile then
		self.Capacity = 1
		fired = self:_fireSingleShot({bulletSpeed=self.BulletSpeed,fireAnimation=animation,sound=(shot.kind == "weak" and self.SoundFolder and self.SoundFolder:FindFirstChild("fire_weak")) or self.FireSound,requireAiming=false,metadata={KingslayerShotToken=shot.token}})
	else
		if shot.kind == "blank" or shot.kind == "break" then
			local muzzle = self:_findModelPart(self.MuzzlePartName or "muzzle")
			self:_playShotFeedback(muzzle, self.FireSound)
			self:_playAnim(animation, false, {restart=true})
		else
			self:_dryFire(); self:_playAnim("Fire_Empty", false, {restart=true})
		end
		task.wait(response.duration or self.FireInterval)
	end
	self.Capacity = 0; self._kingBusy = false
	return fired
end
function KingslayerRevolver:_on_equip()
	self._kingGeneration = (self._kingGeneration or 0) + 1
	baseEquip(self)
	self.DisableSteadyAimAccuracy = true; self.Can_Drop = false; self.Capacity = 0
	self._kingBusy = true
	local generation = self._kingGeneration
	task.spawn(function()
		self:_request("Get")
		if self.Equipped and self._kingGeneration == generation then self._kingBusy = false end
	end)
	self._kingInput = Input.InputBegan:Connect(function(input, processed)
		if processed or not self.Equipped or not self.Reloading then return end
		local key = input.KeyCode
		if key == Enum.KeyCode.Two or key == Enum.KeyCode.DPadRight then self._powderHeld = true; task.spawn(function() self:_pour() end)
		else
			local action = ({[Enum.KeyCode.One]="Cap",[Enum.KeyCode.DPadLeft]="Cap",[Enum.KeyCode.Three]="Ram",[Enum.KeyCode.DPadUp]="Ram",[Enum.KeyCode.Four]="Close",[Enum.KeyCode.DPadDown]="Close"})[key]
			if action then task.spawn(function() self:_loadingAction(action) end) end
		end
	end)
	self._kingEnd = Input.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Two or input.KeyCode == Enum.KeyCode.DPadRight then self._powderHeld = false end
	end)
end
function KingslayerRevolver:_cleanupKingslayer()
	self._kingGeneration = (self._kingGeneration or 0) + 1
	self._powderHeld = false; self._kingBusy = false
	if self._pourSound then self._pourSound:Destroy(); self._pourSound = nil end
	if self._kingInput then self._kingInput:Disconnect(); self._kingInput = nil end
	if self._kingEnd then self._kingEnd:Disconnect(); self._kingEnd = nil end
	if self._kingPanel then self._kingPanel:Destroy(); self._kingPanel = nil end
	player:SetAttribute("CantUnequip", nil)
end
function KingslayerRevolver:_on_unequip()
	self:_cleanupKingslayer()
	baseUnequip(self)
end
function KingslayerRevolver:destroy()
	self:_cleanupKingslayer()
	return baseDestroy(self)
end
return KingslayerRevolver
