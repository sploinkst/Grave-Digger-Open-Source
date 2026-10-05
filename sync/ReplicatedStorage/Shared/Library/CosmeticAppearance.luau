local Appearance = {}
Appearance.HairColours = {Brown = Color3.fromRGB(92, 58, 35), Black = Color3.fromRGB(24, 22, 21), Red = Color3.fromRGB(151, 59, 32), Blonde = Color3.fromRGB(218, 184, 112)}
Appearance.SkinColours = {Light = Color3.fromRGB(255, 219, 172), Fair = Color3.fromRGB(241, 194, 125), Tan = Color3.fromRGB(198, 134, 66), Brown = Color3.fromRGB(141, 85, 36), Dark = Color3.fromRGB(82, 50, 30)}
Appearance.Categories = {
	haircolour = {Key="HairColour", Label="Hair Colour", Choices={"Brown", "Black", "Red", "Blonde"}},
	skincolour = {Key="SkinColour", Label="Skin Colour", Choices={"Avatar", "Light", "Fair", "Tan", "Brown", "Dark"}},
	gender = {Key="Gender", Label="Gender", Choices={"m", "f"}, Labels={m="Male", f="Female"}},
	language = {Key="Language", Label="Language", Choices={"american", "brazil", "british", "german", "polish", "russian"}, Labels={american="American", brazil="Brazilian", british="British", german="German", polish="Polish", russian="Russian"}},
	helmet = {Key="Helmet", Label="Helmet", Choices={"Default", "None"}},
	accessories = {Key="Accessories", Label="Accessories"},
}

local function find(parent, name)
	if not parent then return nil end
	for _, child in parent:GetChildren() do
		if child.Name:lower() == name:lower() then return child end
	end
end

function Appearance.Assets()
	return find(find(game:GetService("ReplicatedStorage").Shared.Assets, "outfits"), "accessories")
end

function Appearance.Data(player)
	local root = player:FindFirstChild("PlayerData")
	local data = root and root:FindFirstChild("PlayerData")
	return data and data:FindFirstChild("Cosmetics")
end

function Appearance.BlankHead(character)
	local head = character:FindFirstChild("Head")
	if not head then return end
	if head:IsA("MeshPart") then head.TextureID = "" end
	for _, item in head:GetDescendants() do
		if item:IsA("Decal") or item:IsA("Texture") or item:IsA("SurfaceAppearance") or item:IsA("FaceControls") then item:Destroy()
		elseif item:IsA("SpecialMesh") then item.TextureId = "" end
	end
end

local function mount(character, source)
	local clone = source:Clone()
	clone:SetAttribute("CosmeticAppearance", true)
	for _, item in clone:GetDescendants() do
		if item:IsA("LuaSourceContainer") or (not clone:IsA("Accessory") and (item:IsA("JointInstance") or item:IsA("WeldConstraint"))) then item:Destroy() end
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if clone:IsA("Accessory") and humanoid then humanoid:AddAccessory(clone); return end
	clone.Parent = character
	local groups = {}
	for _, child in clone:GetChildren() do
		local anchor = character:FindFirstChild(child.Name)
		if anchor and anchor:IsA("BasePart") then table.insert(groups, {child, anchor}) end
	end
	if #groups == 0 then
		local primary = clone:IsA("Model") and (clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)) or (clone:IsA("BasePart") and clone)
		local limb = clone:FindFirstChild("limb")
		local anchor = primary and (limb and limb:IsA("StringValue") and character:FindFirstChild(limb.Value) or character:FindFirstChild(primary.Name) or character:FindFirstChild("Torso"))
		if not primary or not anchor or not anchor:IsA("BasePart") then clone:Destroy(); return end
		table.insert(groups, {clone, anchor})
	end
	for _, group in groups do
		local object, anchor = group[1], group[2]
		local reference = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart", true)
		if not reference then continue end
		local origin = reference.CFrame
		for _, part in {object, table.unpack(object:GetDescendants())} do
			if not part:IsA("BasePart") then continue end
			local offset = origin:ToObjectSpace(part.CFrame)
			part.CFrame = anchor.CFrame * offset
			part.Anchored, part.CanCollide, part.CanTouch, part.CanQuery, part.Massless = false, false, false, false, true
			if part.Name == anchor.Name then part.Transparency = 1 end
			local weld = Instance.new("Weld")
			weld.Part0, weld.Part1, weld.C0 = anchor, part, offset
			weld.Parent = part
		end
	end
end

function Appearance.Apply(character, data)
	Appearance.BlankHead(character)
	for _, entry in {{"Gender", "gender", "m"}, {"Language", "language", "american"}} do
		local saved = data and data:FindFirstChild(entry[1])
		local value = character:FindFirstChild(entry[2])
		if value and value:IsA("StringValue") then value.Value = saved and saved.Value or entry[3] end
	end
	local helmet = data and data:FindFirstChild("Helmet")
	if helmet and helmet.Value == "None" and character:GetAttribute("IsShockTrooper") ~= true then
		for _, item in character:GetDescendants() do
			local markedHelmet = item:GetAttribute("ClassHelmet") == true
			for name, value in item:GetAttributes() do
				if name:sub(-6) == "Helmet" and value == true then markedHelmet = true end
			end
			if item:GetAttribute("ClassAppearance") and (item.Name == "ClassHelmet" or markedHelmet or item.Name:lower():find("helmet")) then item:Destroy() end
		end
		for _, item in character:GetDescendants() do
			local transparency = item:GetAttribute("ClassHairTransparency")
			if item:IsA("BasePart") and typeof(transparency) == "number" then item.Transparency = transparency; item:SetAttribute("ClassHairTransparency", nil) end
		end
	end
	local hair = data and data:FindFirstChild("HairColour")
	local colour = Appearance.HairColours[hair and hair.Value] or Appearance.HairColours.Brown
	for _, accessory in character:GetChildren() do
		if accessory:GetAttribute("CosmeticAppearance") then accessory:Destroy()
		elseif accessory:IsA("Accessory") and (accessory.AccessoryType == Enum.AccessoryType.Hair or accessory.Name:lower():find("hair")) then
			for _, part in accessory:GetDescendants() do
				if part:IsA("BasePart") then part.Color = colour; part.Material = Enum.Material.SmoothPlastic end
				if part:IsA("MeshPart") then part.TextureID = ""
				elseif part:IsA("SpecialMesh") then part.TextureId = ""; part.VertexColor = Vector3.new(1, 1, 1)
				elseif part:IsA("SurfaceAppearance") then part:Destroy() end
			end
		end
	end
	local skin = data and data:FindFirstChild("SkinColour")
	local skinColour = Appearance.SkinColours[skin and skin.Value]
	if skinColour or (skin and skin.Value == "Avatar") then
		local colours = character:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors")
		for _, name in {"HeadColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3", "TorsoColor3"} do
			local colour = skinColour or character:GetAttribute("Avatar" .. name)
			if colour then colours[name] = colour end
		end
		colours.Parent = character
	end
	local equipped = data and data:FindFirstChild("Accessories")
	local assets = Appearance.Assets()
	if equipped and assets then
		for _, value in equipped:GetChildren() do
			local source = assets:FindFirstChild(value.Name)
			if value:IsA("BoolValue") and value.Value and source then mount(character, source) end
		end
	end
end
return Appearance
