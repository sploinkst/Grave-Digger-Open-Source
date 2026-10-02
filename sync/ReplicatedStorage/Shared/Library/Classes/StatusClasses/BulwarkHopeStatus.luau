--!strict
local BaseStatus = require(script.Parent.Parent.BaseStatus)
local C = {}
C.__index = C
setmetatable(C, { __index = BaseStatus })

local function isVanguard(character: Model?): boolean
	if not character then return false end
	if string.lower(tostring(character:GetAttribute("Class") or "")) == "vanguard" then return true end
	local value = character:FindFirstChild("class")
	return value ~= nil and value:IsA("StringValue") and string.lower(value.Value) == "vanguard"
end

function C.new()
	local self = BaseStatus.new({ name = "BulwarkHope" })
	setmetatable(self, C)
	self.className = "BulwarkHopeStatus"
	self.duration = 1
	return self
end

function C:_apply(player: Player, duration: number?)
	local character = player.Character
	if isVanguard(character) then
		player:SetAttribute(self.name, nil)
		self.duration = 0
		return
	end
	self.duration = duration or 1
	if character then
		character:SetAttribute("BulwarkFireRateMultiplier", 1.1)
		character:SetAttribute("BulwarkSurgeryMultiplier", 1.15)
	end
end

function C:_un_apply(player: Player)
	local character = player.Character
	if character then
		character:SetAttribute("BulwarkFireRateMultiplier", nil)
		character:SetAttribute("BulwarkSurgeryMultiplier", nil)
	end
end

return C
