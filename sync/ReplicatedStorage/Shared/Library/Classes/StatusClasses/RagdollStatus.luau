--!strict
local RagdollStatus = {}
RagdollStatus.__index = RagdollStatus

local BaseStatus = require(script.Parent.Parent.BaseStatus)
local Easy_Ragdoll_Module = require(game.ReplicatedStorage.Shared.Library.Externals.EasyRagdoll)


setmetatable(RagdollStatus, { __index = BaseStatus })

export type RagdollStatus = typeof(setmetatable({} :: {
	className: "RagdollStatus",
	name: string,
}, RagdollStatus))

function RagdollStatus.new(): RagdollStatus
	local self = BaseStatus.new({
		name = "ragdoll"
	})

	setmetatable(self, RagdollStatus)

	self.className = "RagdollStatus"
	
	return self
end

-- INTERNAL: enable ragdoll
function RagdollStatus:_apply(player: Player, direction: Vector3?)
	Easy_Ragdoll_Module.SetRagdoll(player.Character, true, true)
end

-- INTERNAL: disable ragdoll
function RagdollStatus:_un_apply(player: Player)
	Easy_Ragdoll_Module.SetRagdoll(player.Character, false)
end

-- // to be used for like on death and stuff
function RagdollStatus:_special_apply(character: Model)
	Easy_Ragdoll_Module.SetRagdoll(character, true, true, 0, true)
end

return RagdollStatus