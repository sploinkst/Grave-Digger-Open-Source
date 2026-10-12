"""Rebuild the Rojo GUI model from the preserved source and current coreScript."""
from pathlib import Path
import struct

ROOT = Path(__file__).resolve().parents[1]


def decompress_lz4(data):
    output = bytearray()
    cursor = 0
    while cursor < len(data):
        token = data[cursor]
        cursor += 1
        literals = token >> 4
        if literals == 15:
            while True:
                extra = data[cursor]
                cursor += 1
                literals += extra
                if extra != 255:
                    break
        output.extend(data[cursor:cursor + literals])
        cursor += literals
        if cursor == len(data):
            break
        offset = data[cursor] | data[cursor + 1] << 8
        cursor += 2
        length = (token & 15) + 4
        if (token & 15) == 15:
            while True:
                extra = data[cursor]
                cursor += 1
                length += extra
                if extra != 255:
                    break
        if offset == 0 or offset > len(output):
            raise ValueError("Invalid LZ4 offset")
        for _ in range(length):
            output.append(output[-offset])
    return bytes(output)


def build_model(source, core_script):
    if not source.startswith(b"<roblox!"):
        raise ValueError("Expected a binary Roblox model")
    result = bytearray(source[:32])
    cursor = 32
    scripts = 0
    while cursor < len(source):
        start = cursor
        tag, compressed, size, reserved = struct.unpack_from("<4sIII", source, cursor)
        cursor += 16
        payload = source[cursor:cursor + (compressed or size)]
        cursor += compressed or size
        raw = decompress_lz4(payload) if compressed else payload
        if len(raw) != size:
            raise ValueError("Invalid Roblox chunk size")
        if tag == b"PROP":
            length = struct.unpack_from("<I", raw, 4)[0]
            name = raw[8:8 + length].decode("utf-8")
            if name == "Tags":
                if any(raw[9 + length:]):
                    raise ValueError("Nonempty tags require a newer Rojo importer")
                continue  # Empty tags are the default; older Rojo rejects this encoding.
            if name == "Source":
                if raw[8 + length] != 1:
                    raise ValueError("Unsupported Source encoding")
                raw = raw[:9 + length] + struct.pack("<I", len(core_script)) + core_script
                result.extend(struct.pack("<4sIII", tag, 0, len(raw), reserved))
                result.extend(raw)
                scripts += 1
                continue
        result.extend(source[start:cursor])
    if scripts != 1:
        raise ValueError(f"Expected exactly one GUI script, found {scripts}")
    return bytes(result)


if __name__ == "__main__":
    source = (ROOT / "assets/ui/Main.source.rbxm").read_bytes()
    script = (ROOT / "sync/StarterGui/main/coreScript.client.luau").read_bytes()
    (ROOT / "assets/ui/Main.rbxm").write_bytes(build_model(source, script))
    print("Imported StarterGui: preserved hierarchy and replaced the single coreScript")
