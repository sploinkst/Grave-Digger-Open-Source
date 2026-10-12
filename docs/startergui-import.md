The sync project imports assets/ui/Main.rbxm as StarterGui.main. It contains all 2,644 instances from the supplied model, with names, classes and nesting verified against the supplied hierarchy. The original model is preserved as Main.source.rbxm.

The embedded coreScript is replaced with sync/StarterGui/main/coreScript.client.luau, preserving one LocalScript rather than adding a duplicate. Run `python tools/import_startergui.py` after changing that script. Empty tag records are omitted for compatibility with the installed Rojo reader; no nonempty tags are discarded.

The main HUD persists across respawns. AuthoredAssets.MainGui explicitly selects the ScreenGui containing core_game, so a sibling Folder named main cannot steal camera, popup or elite-selection bindings. The legacy loadout_menu remains in the hierarchy; the existing MenuService controls the active menu.

Build and synchronize with sync.project.json. Validation confirms the hierarchy and build, not a live Studio playtest or external image/font/audio asset permissions.
