-- Recharge times belong to the server; HUD counts are replicated snapshots.
local State={}
function State.New(capacity)
	return {count=capacity,recharge=0}
end
function State.Refresh(state,capacity,interval,now)
	if interval<=0 then return state.count end
	while state.count<capacity and now>=state.recharge do
		state.count+=1; state.recharge+=interval
	end
	return state.count
end
function State.Consume(state,capacity,interval,now)
	State.Refresh(state,capacity,interval,now)
	if state.count<=0 then return false end
	if state.count==capacity then state.recharge=now+interval end
	state.count-=1
	return true
end
return State
