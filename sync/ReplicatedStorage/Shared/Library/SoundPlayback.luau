--!strict

-- Independent playback for transient sounds. Every call owns a fresh Sound
-- and, for spatial audio, a stationary world anchor. Later calls can never
-- restart an earlier shot and deleting the source weapon cannot cut its tail.

local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local FAILSAFE_SECONDS = 600
local SoundPlayback = {}

export type Options = {
	PlaybackSpeed: number?,
	Volume: number?,
	PitchShift: number?,
	PitchVariation: number?,
	TimePosition: number?,
	RollOffMaxDistance: number?,
}

local function soundWorldCFrame(parent: Instance?): CFrame?
	if not parent then return nil end
	if parent:IsA("Attachment") then return parent.WorldCFrame end
	if parent:IsA("BasePart") then return parent.CFrame end
	if parent:IsA("Model") then return parent:GetPivot() end
	local part = parent:FindFirstAncestorWhichIsA("BasePart")
	if part then return part.CFrame end
	return nil
end

local function anchorContainer(): Instance
	local details = Workspace:FindFirstChild("Game_Details")
	local preferred = details and (details:FindFirstChild("Effects") or details) or Workspace
	local existing = preferred:FindFirstChild("OneShotSounds")
	if existing then return existing end
	local folder = Instance.new("Folder")
	folder.Name = "OneShotSounds"
	folder.Parent = preferred
	return folder
end

local function playbackParent(parent: Instance?): (Instance, BasePart?)
	local origin = soundWorldCFrame(parent)
	if not origin then return SoundService, nil end

	local anchor = Instance.new("Part")
	anchor.Name = "OneShotSoundAnchor"
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.CastShadow = false
	anchor.Transparency = 1
	anchor.Size = Vector3.new(0.05, 0.05, 0.05)
	anchor.CFrame = origin
	anchor.Parent = anchorContainer()
	return anchor, anchor
end

function SoundPlayback.Play(source: Sound, parent: Instance?, options: Options?): Sound?
	if not source or not source:IsA("Sound") then return nil end
	local settings = options or {}
	local clone = source:Clone()
	local target, anchor = playbackParent(parent)
	local speed = settings.PlaybackSpeed or source.PlaybackSpeed
	local variation = settings.PitchVariation or 0
	if variation > 0 then
		speed += math.random(-variation * 100, variation * 100) / 100
	end
	clone.PlaybackSpeed = math.max(speed, 0.05)
	clone.Volume = settings.Volume or source.Volume
	clone.TimePosition = settings.TimePosition or 0
	clone.Looped = false
	if settings.RollOffMaxDistance then
		clone.RollOffMinDistance = math.min(clone.RollOffMinDistance, settings.RollOffMaxDistance)
		clone.RollOffMaxDistance = settings.RollOffMaxDistance
	end

	local pitchShift = settings.PitchShift or 0
	if pitchShift ~= 0 then
		local effect = Instance.new("PitchShiftSoundEffect")
		effect.Octave = pitchShift
		effect.Parent = clone
	end

	local cleaned = false
	local function cleanup()
		if cleaned then return end
		cleaned = true
		if clone.Parent then clone:Destroy() end
		if anchor and anchor.Parent then anchor:Destroy() end
	end

	-- Connect before Play so cached, extremely short bullet layers cannot end
	-- before their cleanup listener exists.
	clone.Ended:Once(cleanup)
	clone.Parent = target
	local played, playError = pcall(function()
		clone:Play()
	end)
	if not played then
		warn("[SoundPlayback] Failed to play", source:GetFullName(), playError)
		cleanup()
		return nil
	end

	-- Ended is authoritative. This only catches invalid assets that never load.
	task.delay(FAILSAFE_SECONDS, cleanup)
	return clone
end

return SoundPlayback
