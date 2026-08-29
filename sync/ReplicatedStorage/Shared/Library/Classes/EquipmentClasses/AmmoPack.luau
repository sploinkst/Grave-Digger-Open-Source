--!strict
local AmmoPack = {}
AmmoPack.__index = AmmoPack

local BaseEquipment = require(script.Parent.Parent.BaseEquipment)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Util = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Library"):WaitForChild("Util"))

local AmmoPackEvent = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Library")
	:WaitForChild("Events")
	:WaitForChild("AmmoPack")

local AssistBB = ReplicatedStorage
	:WaitForChild("Shared")
	:WaitForChild("Assets")
	:WaitForChild("UI")
	:WaitForChild("Assist_BB")

local Mouse = Players.LocalPlayer:GetMouse()

setmetatable(AmmoPack, { __index = BaseEquipment })

export type AmmoPack = typeof(setmetatable({} :: {
	className: "AmmoPack",
	name: string,
	MaxEquipment: number,
	EquipmentReloadTime: number,
	Connection: RBXScriptConnection?,
	AssistClone: BillboardGui,
	LastTarget: BasePart?,
	PlayerTarget: Model?,
}, AmmoPack))


function AmmoPack.new(): AmmoPack
	local self = BaseEquipment.new({
		name = "Concussion"
	})

	setmetatable(self, AmmoPack)

	self.className = "AmmoPack"
	self.MaxEquipment = 2
	self.EquipmentReloadTime = 30

	self.Connection = nil
	self.AssistClone = AssistBB:Clone()

	self.LastTarget = nil
	self.PlayerTarget = nil

	return self
end


function AmmoPack:SpecialStart()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	local MAX_DISTANCE = 30

	self.Connection = RunService.RenderStepped:Connect(function()
		local target = Mouse.Target

		-- Validate existing target distance every frame
		if self.PlayerTarget then
			local playerCharacter = Players.LocalPlayer.Character
			local hrp = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")

			local targetTorso = self.PlayerTarget:FindFirstChild("Torso")
				or self.PlayerTarget:FindFirstChild("UpperTorso")
				or self.PlayerTarget:FindFirstChild("HumanoidRootPart")

			if not hrp or not targetTorso or (hrp.Position - targetTorso.Position).Magnitude > MAX_DISTANCE then
				self.PlayerTarget = nil
				self.AssistClone.Parent = ReplicatedStorage
			end
		end

		-- No change, ignore this frame
		if target == self.LastTarget then
			return
		end

		self.LastTarget = target

		-- Reset current assist
		self.PlayerTarget = nil
		self.AssistClone.Parent = ReplicatedStorage

		if not target then
			return
		end

		local character = target:FindFirstAncestorOfClass("Model")

		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		-- Ignore local player
		if character == Players.LocalPlayer.Character then
			return
		end

		local torso = character:FindFirstChild("Torso")
			or character:FindFirstChild("UpperTorso")
			or character:FindFirstChild("HumanoidRootPart")

		if not torso then
			return
		end

		local playerCharacter = Players.LocalPlayer.Character
		local hrp = playerCharacter and playerCharacter:FindFirstChild("HumanoidRootPart")

		if not hrp then
			return
		end

		-- Distance check
		if (hrp.Position - torso.Position).Magnitude > MAX_DISTANCE then
			return
		end
		
		if not Players:GetPlayerFromCharacter(character) then
			return
		end
		
		if Util.hasfullammo(game.Players:GetPlayerFromCharacter(character)) then
			return
		end
		
		if game.Players:GetPlayerFromCharacter(character).Team ~= game.Players.LocalPlayer.Team then
			return
		end

		self.PlayerTarget = character
		self.AssistClone.Parent = torso
	end)
end


function AmmoPack:SpecialStop()
	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	self.AssistClone.Parent = nil
	self.PlayerTarget = nil
	self.LastTarget = nil
end


function AmmoPack:Activate()
	local count = self:GetCount()
	if not count or count <= 0 then
		return
	end
	
	self:CountDown(-1)

	if not self.PlayerTarget then
		AmmoPackEvent:FireServer()
	else
		AmmoPackEvent:FireServer(self.PlayerTarget)
	end

	print("AmmoPack Activated")
end


return AmmoPack
