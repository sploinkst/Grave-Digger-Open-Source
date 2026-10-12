local Rules = {}
Rules.Scenes = {Loadout=true, Appearance=true, Servers=true, Settings=true, Credits=true}
Rules.Missions = {control="Control Points", assault="Assault Objectives", push="Territory Push", train="Armoured Train", infection="???", laststand="Last Stand", truce="The Truce", training="Training"}
function Rules.ShowServer(server, filters, regions)
	local selected = false
	for _, enabled in pairs(regions) do if enabled then selected = true end end
	if selected and not regions[server.region] then return false end
	if filters.filterlow and server.players <= 4 then return false end
	if filters.filterfull and server.players >= 30 then return false end
	if filters.filternew and server.lifetime >= 1200 then return false end
	return true
end
function Rules.HatPosition(value)
	if type(value) ~= "number" or value ~= value or math.abs(value) == math.huge then return nil end
	return math.clamp(value, 0, 1)
end
return Rules
