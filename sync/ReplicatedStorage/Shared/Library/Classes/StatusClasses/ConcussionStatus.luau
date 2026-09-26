--!strict
local ConcussionStatus = {}
ConcussionStatus.__index = ConcussionStatus

local BaseStatus = require(script.Parent.Parent.BaseStatus)

setmetatable(ConcussionStatus, { __index = BaseStatus })
export type ConcussionStatus = typeof(setmetatable({} :: {
	className: "ConcussionStatus",
	name: string,
	duration: number,
}, ConcussionStatus))

function ConcussionStatus.new(): ConcussionStatus
	local self = BaseStatus.new({
		name = "Concussion"
	})

	setmetatable(self, ConcussionStatus)

	self.className = "ConcussionStatus"
	self.duration = 3

	return self
end

function ConcussionStatus:_apply(player: Player, duration: number?)
	local character = player.Character
	if character and character:GetAttribute("ConcussionImmune") then
		player:SetAttribute(self.name, nil)
		self.duration = 0
		return
	end
	self.duration = duration or 3
	if character then
		character:SetAttribute("Hitstun", true)
		character:SetAttribute("SprintBlocked", true)
		character:SetAttribute("JumpBlocked", true)
	end
end

function ConcussionStatus:_un_apply(player: Player)
	local character = player.Character
	if character then
		character:SetAttribute("Hitstun", nil)
		if not player:GetAttribute("Cripple") and not player:GetAttribute("Knockdown") and not player:GetAttribute("Hitstun") then
			character:SetAttribute("SprintBlocked", nil)
			character:SetAttribute("JumpBlocked", nil)
		end
	end
end

return ConcussionStatus
