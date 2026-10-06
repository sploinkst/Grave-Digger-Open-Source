local SEvent = {}
SEvent.__index = SEvent;

export type soundEvent = {
	timePosition: number;
	Amount: number;
	Executed: number;
	Enabled: boolean;
	Failsafe: number;
	soundInstance: Sound;
	Function: (any) -> (any);
}

local allEvents = {};
local Repeater = nil;

-- constructor function
function SEvent.new(
	soundInstance: Sound, timePosition: number,
	amount: number, fExec: (any) -> (any)
)
	if not soundInstance then return end
	if not timePosition then return end
	if not amount then return end
	if not fExec then return end

	local self = setmetatable({}, SEvent);

	self.timePosition = timePosition or 0;
	self.Amount = amount; -- -1 is infinite
	self.Executed = 0;
	self.Enabled = true;
	self.soundInstance = soundInstance;
	self.Function = fExec;
	self.Failsafe = 0;

	if Repeater == nil then -- no task running
		Repeater = task.spawn(function()
			while task.wait(0.05) do --  i assumed 0.05 seconds was the best thing between optimization and precision.
				for Key, Event: soundEvent in pairs(allEvents) do
					if Event.Enabled == false then continue end
					if math.abs(tick() - Event.Failsafe) < 1 then continue end

					local distanceToPosition = math.abs(Event.timePosition - Event.soundInstance.TimePosition);
					if distanceToPosition > 0.1 then continue end
					Event.Failsafe = tick();
					Event.Executed += 1;
					local success, result = pcall(function()
						Event.Function(Event);
					end)
					if Event.Amount > 0 then
						if Event.Executed >= Event.Amount then
							print("Uh oh, ended!")
							allEvents[Key] = nil;
							if #allEvents <= 0 then
								print("Ended")
								Repeater = nil; -- idk lol but ya
								break -- end the repeating in the while loop
							end
							continue
						end
						if not success then warn(`Issue executing soundEvent for Sound {Event.soundInstance:GetFullName()}.`); continue end
					end
				end
			end
		end);
	end

	table.insert(allEvents, self);
	return self;
end

function SEvent:Disable()
	self.Enabled = false;
end

function SEvent:Enable()
	self.Enabled = true;
end

return SEvent
