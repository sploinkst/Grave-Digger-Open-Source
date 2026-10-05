-- Surgery validation and completion are separate from weapon replication.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Status = require(script.Parent.StatusService)
local Aid = require(script.Parent.AidService)
local Service = {}
local Events = RS.Shared.Library.Events
local notifyAt = setmetatable({}, {__mode = "k"})

local function patientFor(sender, target)
	if typeof(target) ~= "Instance" then return nil end
	local recipient = target:IsA("Player") and target or target:IsA("Model") and Players:GetPlayerFromCharacter(target)
	if not recipient or not sender.Team or sender.Team ~= recipient.Team then return nil end
	local character, patient = sender.Character, recipient.Character
	local medic = character and character:FindFirstChildOfClass("Humanoid")
	local humanoid = patient and patient:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local targetRoot = patient and patient:FindFirstChild("HumanoidRootPart")
	local tool = character and character:FindFirstChild("Medkit")
	if not medic or medic.Health <= 0 or not humanoid or humanoid.Health <= 0
		or not root or not targetRoot or not tool or not tool:IsA("Tool")
		or character:GetAttribute("ActionBlocked") or patient:GetAttribute("SurgeryBlocked")
		or patient:GetAttribute("IsDreadnought") or (root.Position - targetRoot.Position).Magnitude > 12 then return nil end
	return recipient, character, patient, humanoid
end

function Service.Complete(sender, target, wound)
	local recipient, character, patient, humanoid = patientFor(sender, target)
	if not recipient then return false end
	local data = patient:FindFirstChild("CharacterData")
	local wounds = data and data:FindFirstChild("Wounds")
	if typeof(wound) ~= "Instance" or not wound:IsA("StringValue") or wound.Parent ~= wounds
		or not Status.HasStatus(recipient, "WoundStatus") then return false end
	Status.RemoveStatus(recipient, "WoundStatus", wound)
	if #wounds:GetChildren() > 0 then return true end
	if Status.HasStatus(recipient, "ConcussionStatus") then Status.RemoveStatus(recipient, "ConcussionStatus") end
	if Status.HasStatus(recipient, "ClottingStatus") then Status.RemoveStatus(recipient, "ClottingStatus") end
	if character:GetAttribute("Hippocratic") then Status.GiveStatus(recipient, "MoraleStatus", 40) end
	local health = sender ~= recipient and (character:GetAttribute("AllyHealHealth") or 100) or 100
	humanoid.Health = math.max(humanoid.Health, math.min(humanoid.MaxHealth, health))
	Aid.Record(recipient, sender, character)
	return true
end

function Service.start_module()
	if Service.started then return end
	Service.started = true
	Events.Heal.OnServerEvent:Connect(Service.Complete)
	Events.HealNotify.OnServerEvent:Connect(function(sender, target)
		local recipient = patientFor(sender, target)
		if not recipient or recipient == sender or os.clock() < (notifyAt[sender] or 0) then return end
		notifyAt[sender] = os.clock() + 2
		Events.Presentation:FireClient(recipient, "server_message", {
			key = "surgery_aid", message = sender.Name .. ": Stand still while I heal you.", duration = 2,
		})
	end)
end

return Service
