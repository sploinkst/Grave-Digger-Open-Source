--!strict
local BaseEquipment = {}
BaseEquipment.__index = BaseEquipment

local InputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local HoldingG = false

export type BaseEquipment = typeof(setmetatable({} :: {
	className: "BaseEquipment",
	name: string,
	MaxEquipment: number,
	EquipmentReloadTime: number,
	Tick: number,
	EquipmentBB: any,
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
	self.Counting = false
	self.Activated = false

	return self
end

function BaseEquipment:Start(character)
	local characterHRP = character:WaitForChild("HumanoidRootPart")

	local equipmentBB = characterHRP:WaitForChild("Equipment_BB")
	self.EquipmentBB = equipmentBB
	self.EquipmentBB.bb.count.Text = tostring(self.MaxEquipment)

	print(self.className, "started, and set count.")

	InputService.InputBegan:Connect(function(input, gps)
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
	end)
	
	if self.SpecialStart then
		self:SpecialStart()
	end
end

function BaseEquipment:Activate(character)
	-- Override in subclasses.
end

function BaseEquipment:CountDown(value: number)
	local current = tonumber(self.EquipmentBB.bb.count.Text) or 0

	current = math.clamp(current + value, 0, self.MaxEquipment)

	self.EquipmentBB.bb.count.Text = tostring(current)

	self:StartCount()
end

function BaseEquipment:StartCount()
	local current = tonumber(self.EquipmentBB.bb.count.Text) or 0

	if self.Counting then
		return
	end

	if current >= self.MaxEquipment then
		return
	end

	self.Counting = true

	local frame1 = self.EquipmentBB.bb.progress.frame1.img.grad
	local frame2 = self.EquipmentBB.bb.progress.frame2.img.grad

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