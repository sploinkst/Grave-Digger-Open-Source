local View = {}; View.__index = View
function View.new()
	local gui = Instance.new("BillboardGui")
	gui.Name = "MedicalPatientReadout"; gui.Size = UDim2.fromOffset(280, 90)
	gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true
	local self = setmetatable({Gui = gui}, View)
	for index, name in {"Condition", "Surgery", "Chemicals"} do
		local text = Instance.new("TextLabel")
		text.Name = name; text.Size = UDim2.new(1, 0, 0, 28); text.Position = UDim2.fromOffset(0, (index - 1) * 28)
		text.BackgroundTransparency = 1; text.Font = Enum.Font.GothamBold; text.TextSize = 15
		text.TextColor3 = Color3.fromRGB(220, 235, 225); text.TextStrokeTransparency = 0.3
		text.TextWrapped = true; text.Parent = gui; self[name] = text
	end
	return self
end
function View:Show(patient, report, chemicalUnits, sickness, exactHealth)
	self.Gui.Adornee = patient.root; self.Gui.Parent = patient.root
	self.Condition.Text = report.label .. (exactHealth and string.format(" (%d health)", math.ceil(patient.humanoid.Health)) or "")
	self.Condition.TextColor3 = Color3.fromRGB(table.unpack(report.color))
	self.Surgery.Text = report.surgery; self.Surgery.TextColor3 = Color3.fromRGB(240, 70, 70)
	self.Chemicals.Text = sickness and string.format("Sick - %du Chemicals", chemicalUnits)
		or chemicalUnits > 0 and string.format("%du Chemicals", chemicalUnits) or "Clean bloodstream"
	self.Chemicals.TextColor3 = sickness and Color3.fromRGB(230, 155, 90) or Color3.fromRGB(190, 255, 212)
end
function View:Hide() self.Gui.Adornee = nil; self.Gui.Parent = nil end
function View:Destroy() self.Gui:Destroy() end
return View
