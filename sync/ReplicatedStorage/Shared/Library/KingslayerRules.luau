local Rules = {}
function Rules.Previous(index) return (index + 4) % 6 + 1 end
function Rules.Next(index) return index % 6 + 1 end
function Rules.New()
	local state = {cylinder = 1, broken = false, chambers = {}}
	for index = 1, 6 do state.chambers[index] = {cap = false, ball = false, powder = false} end
	return state
end
function Rules.Inspect(chamber)
	local cap = chamber.cap == false and "No Cap.." or (chamber.cap == "fired" and "Spent Cap.." or "Cap loaded.")
	local ball = chamber.ball == "half" and "Ball not seated.." or (chamber.ball == false and "No Ball.." or "Ball loaded.")
	local p = chamber.powder
	local powder = "Powder loaded."
	if p == false then powder = "No Powder." elseif p <= 0.2 then powder = "Too little powder.." elseif p < 0.5 then powder = "Not enough powder.." elseif p >= 1 then powder = "Too much powder.." end
	return cap .. "\n" .. ball .. "\n" .. powder
end
function Rules.Load(state, action, reserve, amount)
	if state.broken then return false, reserve, "The cylinder is broken." end
	local chamber = state.chambers[Rules.Previous(state.cylinder)]
	if action == "Cap" then chamber.cap = chamber.cap == false and true or false
	elseif action == "Ball" then
		if reserve <= 0 then return false, reserve, "I don't have any more Lead Balls left.." end
		if chamber.ball ~= false then return false, reserve, "I already have a Lead Ball loaded." end
		chamber.ball = "half"; reserve = reserve - 1
	elseif action == "Pour" then
		if chamber.ball ~= false then return false, reserve, "I can't fill with a Lead Ball in the way.." end
		if chamber.powder ~= false and chamber.powder >= 1 then return false, reserve, "There's too much powder in this chamber.." end
		if type(amount) ~= "number" or amount ~= amount or amount < 0.1 or amount > 1 then return false, reserve, "Invalid powder amount." end
		chamber.powder = math.min(1, (chamber.powder or 0) + amount)
	elseif action == "Dump" then
		if chamber.ball ~= false then return false, reserve, "I can't dump powder with a Lead Ball in the way.." end
		chamber.powder = false
	elseif action == "Ram" then
		local underLever = state.chambers[Rules.Previous(Rules.Previous(state.cylinder))]
		if underLever.ball == "half" then underLever.ball = true end
	elseif action == "Rotate" or action == "Close" then state.cylinder = Rules.Next(state.cylinder)
	else return false, reserve, "Unknown loading action." end
	return true, reserve
end
function Rules.Fire(state)
	if state.broken then return {kind = "broken", projectile = false, factor = 0} end
	local chamber = state.chambers[state.cylinder]
	local result = {kind = "empty", projectile = false, factor = 0}
	if chamber.cap == true then
		chamber.cap = "fired"
		local powder = chamber.powder
		if powder ~= false then
			result.kind = powder < 0.5 and "weak" or "normal"
			result.projectile = chamber.ball == true or chamber.ball == "half"
			-- The source sends weak-load classifications to an unavailable server.
			-- These explicit replacement damage multipliers preserve their tiers.
			result.factor = powder <= 0.2 and 0.2 or (powder < 0.5 and 0.5 or 1)
			if not result.projectile then result.kind = "blank"; result.factor = 0 end
			if powder >= 1 then result.kind = "break"; state.broken = true end
			chamber.powder = false; chamber.ball = false
		end
	end
	state.cylinder = Rules.Next(state.cylinder)
	return result
end
return Rules
