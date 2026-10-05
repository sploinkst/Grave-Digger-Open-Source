-- Pure inventory state: caches refill Supplies without touching the mixture.
local State = {}
function State.new(maximum)
	return {supplies = maximum, capacity = maximum, mix = {}, ready = 0}
end
function State.SetCapacity(state, maximum)
	if maximum > state.capacity then state.supplies += maximum - state.capacity end
	state.capacity = maximum
	state.supplies = math.min(maximum, state.supplies)
end
function State.Mix(state, chemical)
	if state.supplies < 1 then return false end
	state.supplies -= 1
	table.insert(state.mix, chemical)
	return true
end
function State.Discard(state) state.mix = {} end
function State.Restock(state) state.supplies = state.capacity end
return State
