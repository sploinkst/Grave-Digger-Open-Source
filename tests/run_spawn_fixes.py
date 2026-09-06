"""Usage: python tests/run_spawn_fixes.py /path/to/luau"""
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
read = lambda name: (root / name).read_text(encoding="utf-8")
appearance = read("sync/ReplicatedStorage/Shared/Library/ClassAppearance.luau")
helper = "local function attachFlatHelmet" + appearance.split("local function attachFlatHelmet", 1)[1].split("local function isHelmet", 1)[0]
helmet = read("tests/combat_fixture.luau") + """
local mounted
local attachModel = function(character, model, helmet)
    mounted = model
    equal(helmet,true,"assembly uses helmet mount")
    equal(model.PrimaryPart.Name,"Head","assembly mounts through authored Head")
    return true
end
""" + helper + """
local sourceHead = node("Head","Part")
local sourceShell = node("knock","Part")
local source = node("soldat","Folder",{Head=sourceHead,knock=sourceShell})
local copiedHead = node("Head","Part")
local copiedShell = node("knock","Part")
local copiedScarf = node("Scarf","Part")
local copiedJoint = node("helmetfly","JointInstance")
copiedJoint.Part0 = copiedHead; copiedJoint.Part1 = copiedShell
local copiedShirt = node("shirt","Shirt")
local copied = node("soldat","Folder",{Head=copiedHead,knock=copiedShell,Scarf=copiedScarf,helmetfly=copiedJoint,shirt=copiedShirt})
function copied:GetChildren() return {copiedHead,copiedShell,copiedScarf,copiedJoint,copiedShirt} end
local clones = 0
function source:Clone() clones += 1; return copied end
Instance.new = function(kind)
    local assembly = node("Model",kind)
    function assembly:FindFirstChild(name)
        for _, child in copied:GetChildren() do
            if child.Parent == self and child.Name == name then return child end
        end
    end
    return assembly
end
assert(attachFlatHelmet({},source))
equal(clones,1,"clone head rig together")
equal(copiedShell.Parent,mounted,"helmet shell stays with head")
equal(copiedScarf.Parent,mounted,"scarf stays with head")
equal(copiedJoint.Parent,mounted,"retain top-level helmet motor")
equal(copiedJoint.Part0,copiedHead,"motor references cloned head")
equal(copiedJoint.Part1,copiedShell,"motor references cloned shell")
equal(copiedShirt.Parent,copied,"clothing excluded from head rig")
equal(sourceShell.Parent,source,"source outfit unchanged")
print("Flat helmet assembly checks passed")
"""
music = read("sync/ReplicatedStorage/Shared/Modules/Client Modules/MusicService.luau")
audio = """
local copies, plays = 0, 0
local soundService = {}
local clone
local source = {IsA = function(_,class) return class == "Sound" end, Clone = function()
    copies += 1
    clone = {Play = function() plays += 1 end}
    return clone
end}
local atmosphere = {WaitForChild = function(_,name)
    assert(name == "cave5")
    coroutine.yield()
    return source
end}
local function folder(name,child)
    return {WaitForChild = function(_, requested) assert(requested == name); return child end}
end
local storage = folder("Shared",folder("Assets",folder("Sounds",folder("Atmosphere",atmosphere))))
local game = {GetService = function(_,name) return name == "SoundService" and soundService or storage end}
local module = (function()
""" + music + """
end)()
local first = coroutine.create(module.start_module)
assert(coroutine.resume(first))
module.start_module()
assert(copies == 0,"second startup must not race the pending source")
assert(coroutine.resume(first))
module.start_module()
assert(copies == 1 and plays == 1,"startup/respawn does not duplicate or restart ambience")
assert(clone.Looped == true,"ambience loops indefinitely")
assert(clone.Parent == soundService,"ambience persists outside the character")
print("Join ambience checks passed")
"""
with tempfile.TemporaryDirectory(prefix="spawn-fix-tests-") as directory:
    for name, script in [("helmet", helmet), ("audio", audio)]:
        path = Path(directory) / (name + ".luau")
        path.write_text(script, encoding="utf-8")
        subprocess.run([sys.argv[1], str(path)], check=True)
