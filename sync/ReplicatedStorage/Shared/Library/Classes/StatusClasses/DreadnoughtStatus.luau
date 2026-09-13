--!strict
local DreadnoughtStatus = {}
DreadnoughtStatus.__index = DreadnoughtStatus

local BaseStatus = require(script.Parent.Parent.BaseStatus)

setmetatable(DreadnoughtStatus, { __index = BaseStatus })
export type DreadnoughtStatus = typeof(setmetatable({} :: {
	className: "DreadnoughtStatus",
	name: string,
}, DreadnoughtStatus))

function DreadnoughtStatus.new(): DreadnoughtStatus
	local self = BaseStatus.new({
		name = "Dreadnought",
	})

	setmetatable(self, DreadnoughtStatus)
	self.className = "DreadnoughtStatus"
	return self
end

function DreadnoughtStatus:_apply(player: Player)
	player:SetAttribute("PendingDreadnought", true)
end

function DreadnoughtStatus:_un_apply(_player: Player)
	-- PendingDreadnought is consumed by ClassService during the next spawn.
end

return DreadnoughtStatus
