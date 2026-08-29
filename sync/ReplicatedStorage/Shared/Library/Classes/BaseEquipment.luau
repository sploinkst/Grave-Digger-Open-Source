local ReplicatedStorage = game:GetService("ReplicatedStorage")
--!strict
local BaseEquipment = {}
BaseEquipment.__index = BaseEquipment

local TweenService = game:GetService("TweenService")
local SettingsManager = require(ReplicatedStorage.Shared.Modules["Client Modules"].SettingsManager)

local HoldingG = false

export type BaseEquipment = typeof(setmetatable({} :: {
	className: "BaseEquipment",
	name: string,
	MaxEquipment: number,
	EquipmentReloadTime: number,
	Tick: number,
	EquipmentBB: any,
	Character: Model?,
	Counting: boolean,
}, BaseEquipment))

function BaseEquipment.new(info: { name: string }): BaseEquipment
	local self = setmetatable({}, BaseEquipment)

	self.className = "BaseEquipment"
	self.name = info.name
	self.MaxEquipment = 2
	self.EquipmentReloadTime = 30
	self.Tick = 0
	self.EquipmentBB = nil
	self.Character = nil
	self.Counting = false
	self.Activated = false

	return self
end

function BaseEquipment:Start(character)
	self.Character = character
	local characterHRP = character:WaitForChild("HumanoidRootPart")

	local equipmentBB = characterHRP:WaitForChild("Equipment_BB")
	self.EquipmentBB = equipmentBB
	local bb = equipmentBB:WaitForChild("bb")
	local count = bb:WaitForChild("count")
	if count:IsA("TextLabel") then
		count.Text = tostring(self.MaxEquipment)
	end

	print(self.className, "started, and set count.")

	--[[InputService.InputBegan:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode ~= Enum.KeyCode.G then
			return
		end
		
		if self.PlayerTarget then
			self:Activate(character)
		end

		HoldingG = true

		task.delay(0.5, function()
			if HoldingG and not self.Activated then
				print("Held G for 3 seconds!")
				self.Activated = true
				self:Activate(character)
			end
		end)
	end)

	InputService.InputEnded:Connect(function(input, gps)
		if gps then
			return
		end

		if input.KeyCode ~= Enum.KeyCode.G then
			return
		end

		HoldingG = false
		self.Activated = false
		print("Released G")
	end)]]
	
	SettingsManager.HookInput("Class Equipment", function(_, Pressed)
		if Pressed then
			if self.PlayerTarget then
				self:Activate(character)
			end

			HoldingG = true

			task.delay(0.5, function()
				if HoldingG and not self.Activated then
					print("Held G for 3 seconds!")
					self.Activated = true
					self:Activate(character)
				end
			end)
		else
			HoldingG = false
			self.Activated = false
			print("Released G")
		end
	end)
	
	if self.SpecialStart then
		self:SpecialStart()
	end
end

function BaseEquipment:Activate(character)
	-- Override in subclasses.
end

function BaseEquipment:_getEquipmentGui(): BillboardGui?
	local character = self.Character
	local characterHRP = character and character:FindFirstChild("HumanoidRootPart")
	local equipmentBB = characterHRP and characterHRP:FindFirstChild("Equipment_BB")
	local bb = equipmentBB and equipmentBB:FindFirstChild("bb")

	if not bb or not bb:IsA("BillboardGui") then
		return nil
	end

	self.EquipmentBB = equipmentBB
	return bb
end

function BaseEquipment:GetCount(): number?
	local bb = self:_getEquipmentGui()
	local count = bb and bb:FindFirstChild("count")
	return count and count:IsA("TextLabel") and tonumber(count.Text) or nil
end

function BaseEquipment:CountDown(value: number)
	local bb = self:_getEquipmentGui()
	local count = bb and bb:FindFirstChild("count")
	if not count or not count:IsA("TextLabel") then return end

	local current = tonumber(count.Text) or 0

	current = math.clamp(current + value, 0, self.MaxEquipment)

	count.Text = tostring(current)

	self:StartCount()
end

function BaseEquipment:StartCount()
	local bb = self:_getEquipmentGui()
	if not bb then return end

	local count = bb:FindFirstChild("count")
	local progress = bb:FindFirstChild("progress")
	if not count or not count:IsA("TextLabel") or not progress then return end

	local current = tonumber(count.Text) or 0

	if self.Counting then
		return
	end

	if current >= self.MaxEquipment then
		return
	end

	self.Counting = true

	local frame1 = progress.frame1.img.grad
	local frame2 = progress.frame2.img.grad

	frame1.Rotation = 0
	frame2.Rotation = -180

	local tween1 = TweenService:Create(
		frame1,
		TweenInfo.new(self.EquipmentReloadTime / 2),
		{ Rotation = 180 }
	)

	local tween2 = TweenService:Create(
		frame2,
		TweenInfo.new(self.EquipmentReloadTime / 2),
		{ Rotation = 0 }
	)

	tween1:Play()

	tween1.Completed:Once(function()
		tween2:Play()

		tween2.Completed:Once(function()
			-- Allow another countdown cycle.
			self.Counting = false

			self:CountDown(1)

			-- Reset progress wheel.
			frame1.Rotation = 0
			frame2.Rotation = -180
		end)
	end)
end

return BaseEquipment
