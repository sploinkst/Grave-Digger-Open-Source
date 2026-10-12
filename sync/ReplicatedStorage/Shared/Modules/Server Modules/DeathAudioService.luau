local RS = game:GetService("ReplicatedStorage")
local Playback = require(RS.Shared.Library.SoundPlayback)
local Rules = require(RS.Shared.Library.DeathAudioRules)
local Service = {}
local records = setmetatable({}, {__mode = "k"})

local function play(folder, name, location)
	local source = folder and folder:FindFirstChild(name)
	if source and source:IsA("Sound") then Playback.Play(source, location, {PitchVariation = 0.1, FollowParent=true}) end
end

-- Register BEFORE damage so synchronous Died callbacks retain the fatal hit.
-- Failed/nonlethal damage never plays death audio, and each humanoid plays once.
function Service.Bind(character, humanoid)
	if not character or not humanoid then return end
	local record = records[humanoid]
	if not record then
		record = {}; records[humanoid] = record
        record.play=function()
			if record.played then return end
            record.played=true
            local emitter=record.corpse or character
            local recent=record.fatal and record.time and os.clock()-record.time<=0.5
            if not (recent and (record.part=="Head" or record.explosion)) then
                require(RS.Shared.Library.CharacterVoice).Play(character,"yell",emitter)
            end
            if not recent or not record.destructive then return end
			local sounds = RS.Shared.Assets:FindFirstChild("Sounds")
			local folder = sounds and sounds:FindFirstChild("Deaths")
			local location = emitter:FindFirstChild(record.part, true)
			if not location or not location:IsA("BasePart") then location = emitter:FindFirstChild("Torso") or emitter:FindFirstChild("HumanoidRootPart") end
			if not location then return end
			local category = Rules.Category(record.part, record.explosion)
			play(folder, category == "dismember" and "dismember" .. math.random(1, 4) or category, location)
			play(folder, "bone" .. math.random(1, 3), location)
			play(folder, "chunk" .. math.random(1, 3), location)
        end
        humanoid.Died:Once(function() task.defer(record.play) end)
	end
end

function Service.AttachCorpse(character,humanoid,corpse)
 Service.Bind(character,humanoid)
 local record=records[humanoid]
 record.corpse=corpse
 if humanoid.Health<=0 then record.play() end
end

function Service.RecordDamage(character, humanoid, part, damage, explosion, cause)
 if not character or not humanoid or humanoid.Health<=0 then return end
 Service.Bind(character,humanoid)
 local record=records[humanoid]

	record.part = part or "Torso"
	record.explosion = explosion == true
    local name=tostring(cause or ""):lower():gsub("[^%w]","")
    record.destructive=name=="atgrenade" or name=="antiarmourgrenades" or name=="judgementrifle" or name=="judgementincendiaryrifle" or name:find("devastation",1,true)~=nil
	record.time = os.clock()
	record.fatal = type(damage) == "number" and damage >= humanoid.Health
end
return Service
