"""Usage: python tests/run_class_combat.py /path/to/luau"""
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / "sync/ReplicatedStorage/Shared/Modules/Server Modules/ClassCombatService.luau").read_text()
source = source.replace("local Rules = require(ReplicatedStorage.Shared.Library.MeleeRules)", "")
source = source.replace("local Util = require(ReplicatedStorage.Shared.Library.Util)", "")
rules = (root / "sync/ReplicatedStorage/Shared/Library/MeleeRules.luau").read_text()
rules = "local Rules = (function()\n" + rules + "\nend)()\n"
fixture = (root / "tests/combat_fixture.luau").read_text()
spec = (root / "tests/class_combat.spec.luau").read_text()
source = source.rstrip().removesuffix("return Service")
with tempfile.TemporaryDirectory(prefix="class-combat-tests-") as directory:
    script = Path(directory) / "combat.luau"
    script.write_text(fixture + "\n" + rules + source + "\n" + spec)
    subprocess.run([sys.argv[1], str(script)], check=True)
