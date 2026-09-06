local cfMeta = {}
local function cf(x) return setmetatable({x = x}, cfMeta) end
cfMeta.__mul = function(a, b) return cf(a.x + b.x) end
cfMeta.__index = {ToObjectSpace = function(self, other) return cf(other.x - self.x) end}
local function descendants(parent)
	local result = {}
	for _, child in parent.children do
		table.insert(result, child)
		for _, nested in descendants(child) do table.insert(result, nested) end
	end
	return result
end
local created = {}
Instance.new = function(kind)
	local instance = node(kind, kind)
	table.insert(created, instance)
	return instance
end
local head = node("Head", "Part"); head.CFrame = cf(100)
local torso = node("Torso", "Part"); torso.CFrame = cf(90)
local character = node("Character", "Model", {Head = head, Torso = torso})
local root = node("extralift", "Part"); root.CFrame = cf(10)
local main = node("main", "Part"); main.CFrame = cf(12)
local lens = node("lens", "Part"); lens.CFrame = cf(13)
local motor = node("extrajoint", "JointInstance"); motor.Part0 = root; motor.Part1 = main
local weld = node("Weld", "JointInstance"); weld.Part0 = main; weld.Part1 = lens
root.children = {main = main, extrajoint = motor}
main.children = {lens = lens, Weld = weld}
root.GetDescendants = descendants
assert(attachPart(character, root, false))
equal(root.CFrame.x,100,"front assembly follows Head")
equal(main.CFrame.x,102,"preserve front mesh offset")
equal(lens.CFrame.x,103,"preserve nested lens offset")
equal(#created,1,"no duplicate welds over authored joints")
equal(created[1].Part0,head,"head anchor for extralift")
equal(root:GetAttribute("ClassHelmet"),nil,"front accessory is not a second helmet")
equal(motor.Part0,root,"preserve visor motor")
local orphan = node("loose", "Part"); orphan.CFrame = cf(104)
root.children.loose = orphan
created = {}
assert(attachPart(character,root,false))
equal(#created,2,"weld only disconnected component plus root")
equal(created[1].Part1,orphan,"repair detached mesh")
print("Helmet attachment checks passed")
