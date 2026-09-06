"""Run the production whistle handlers against a lightweight Luau fixture.

Usage: python tests/run_whistle.py /path/to/luau
"""
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / "sync/ReplicatedStorage/Shared/Modules/Server Modules/ReplicantManager.luau").read_text()
handlers = source.split("function module.start_module()", 1)[1].split("\tjesseGrenadeEvent.OnServerEvent", 1)[0]
fixture = (root / "tests/whistle_fixture.luau").read_text()
spec = (root / "tests/whistle.spec.luau").read_text()
with tempfile.TemporaryDirectory(prefix="whistle-tests-") as directory:
    script = Path(directory) / "whistle.luau"
    script.write_text(fixture + "\n" + handlers + "\n" + spec)
    subprocess.run([sys.argv[1], str(script)], check=True)
