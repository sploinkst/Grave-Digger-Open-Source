local BaseStatus = require(script.Parent.Parent.BaseStatus)
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Audio = require(Shared.Library.GameAudio)
local C = {}
C.__index = C
setmetatable(C, {__index = BaseStatus})
function C.new()
    local self = BaseStatus.new({name="Spotted"})
    setmetatable(self,C)
    self.className, self.duration = "SpottedStatus", 10
    return self
end
function C:_apply(player, duration, enhanced, source)
    local character = player.Character
    if character and character:GetAttribute("Apparition") and not enhanced then
        player:SetAttribute(self.name,nil); self.duration = 0; return
    end
    self.duration = duration or 10
    player:SetAttribute("SpottedEnhanced", enhanced == true)
    player:SetAttribute("SpottedByUserId", source and source.UserId or nil)
    local event = Shared.Library.Events:FindFirstChild("Presentation")
    if not event then return end
    event:FireClient(player, "pinged_by", {})
    local origin = source and source.Character and source.Character:FindFirstChild("HumanoidRootPart")
    if not origin or not source.Team then return end
    for _, teammate in Players:GetPlayers() do
        local root = teammate.Character and teammate.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = teammate.Character and teammate.Character:FindFirstChildOfClass("Humanoid")
        if teammate.Team == source.Team and root and humanoid and humanoid.Health > 0 and (root.Position-origin.Position).Magnitude <= Audio.PingRadius then
            event:FireClient(teammate, "enemy_ping", {targetUserId=player.UserId, sourceUserId=source.UserId})
        end
    end
end
function C:_un_apply(player)
    player:SetAttribute("SpottedEnhanced",nil)
    player:SetAttribute("SpottedByUserId",nil)
end
return C
