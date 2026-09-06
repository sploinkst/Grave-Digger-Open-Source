"""Usage: python tests/run_helmet_command.py /path/to/luau"""
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
read = lambda name: (root / name).read_text(encoding="utf-8")
source = read("sync/ReplicatedStorage/Shared/Library/ClassAppearance.luau")
attach = "local function attachPart" + source.split("local function attachPart", 1)[1].split("local function isHelmet", 1)[0]
script = read("tests/combat_fixture.luau") + "\nlocal helmetDebug = function() end\n" + attach + read("tests/helmet_attachment.spec.luau")
command = read("sync/ReplicatedStorage/Shared/Modules/Server Modules/CommandService/Commands/03 - Executives/shockTrooperServer.luau")
command = command[command.index("return function"):]
script += """
local Classes = {Selected = function(player) return player.selected end, EliteDefinitions = {
    ["Storm Trooper"] = {RequiredClass = "Soldat"}, ["Anti-Material Trooper"] = {RequiredClass = "Rook"}}}
local assigned
local ClassService = {SetShockTrooper = function(player, kit)
    if not Classes.EliteDefinitions[kit] then return false, "Unknown kit" end
    assigned = {player, kit}; return true, kit
end}
local command = (function()
""" + command + """
end)()
local target = {Name = "Example", selected = "Rook"}
command(nil, target)
equal(assigned[1],target,"command targets requested player")
equal(assigned[2],"Anti-Material Trooper","Rook defaults to matching shock")
target.selected = "Mortician"
command(nil,target)
equal(assigned[2],"Storm Trooper","fallback for classes without a weapon kit")
command(nil,target,"Anti-Material Trooper")
equal(assigned[2],"Anti-Material Trooper","explicit kit override")
equal(command(nil,target,"invalid"),"Unknown kit","report invalid kit")
print("Shocktrooper command checks passed")
"""
with tempfile.TemporaryDirectory(prefix="helmet-command-tests-") as directory:
    path = Path(directory) / "test.luau"
    path.write_text(script, encoding="utf-8")
    subprocess.run([sys.argv[1], str(path)], check=True)
