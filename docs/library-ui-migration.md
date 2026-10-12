# Library UI migration

`ReplicatedStorage.Shared.Library.UI` is the sole authored UI source. The supplied hierarchy is archived in `library-ui-hierarchy.txt`. `sync.project.json` no longer mounts `assets/ui/Main.rbxm` into StarterGui. PlayerService removes the retired `main` ScreenGui from StarterGui and PlayerGui, mounts the library screens once, and keeps them across respawns. Rojo metadata preserves existing authored children and screen classes. Testing and duplicate voice-wheel scripts do not run.

| Feature | Destination |
| --- | --- |
| Inventory | `UI/Inventory/inventory/ex` (the alternate `Main/Example` layout is hidden) |
| Menus | `UI/Menu/Main_Frame` and `UI/Menu_Scenes` |
| Loadout and weapon mastery | `UI/Menu_Scenes/Loadout/Main_Frame` |
| Appearance | `UI/Menu_Scenes/Appearance/cosmeticsframe` |
| Settings | `UI/Menu_Scenes/Settings/settingsframe` |
| Voice commands | `UI/VoiceWheel/Holder` |
| Death, spectating and spawn options | `UI/Spectate/Holder` |
| Chat | `UI/Chat/ChatFrame` |
| Alerts | `UI/Alerts/alert` |
| Text popups and global messages | `UI/Notifications/Main/Example` |
| Player list | `UI/Playerlist/playerlist` (ReplicantService owns rows; PresentationHandler owns visibility) |
| Scoreboard and objectives | `UI/Scoring` (ReplicantService owns updates) |
| Spawn fade | `UI/Black/fadetoblack` |
| Flinch overlay | `UI/Flinching/flinch` |

## Extras integration

The moved objects are now owned by `UI/Extras`, a persistent ScreenGui. `AuthoredAssets.CoreGame()` resolves that screen for the existing overlay controllers, without reviving `StarterGui/main`. Widget lookup prioritizes Extras and keeps Inventory, VoiceWheel, Spectate, Scoring and other dedicated screens in their existing locations. Menu visibility hides Extras; inactive panels and sample templates begin hidden. Blood and recon containers remain available for generated markers.

The October 11 move log supplies selectionboxes, hunt_vignette, binocsoverlay, splatters, healthlow, injuredhealth, morale, helmetoverlay, hitmarkers, akimbocrosshair, inventoryitemname, rotating_indicator, traitortext, hint_popup, tutorialcontrols, tutorialobj, gamemode_title, gamemode_description, gamemode_label, gamemode_modifier, dogtags, endofmatch, endoftruce and endofgame. Existing controllers now reach these objects through Extras. Scenario-specific presentation still depends on the corresponding server event being produced.

Not present in that move log:

- `barrelobstruction` (previously confirmed missing).
- `Campaign/warmap` with its children: campaign/map voting panel.
- `Menu/Main_Frame/rank`, `medalcount`, `timeplayed`, `xpbar/internal`: progression display. XP-bar lookup now accepts nesting under Main_Frame.

The Studio move log is not a serialized GUI asset. The Extras Rojo metadata preserves the objects authored in Studio; their images, layout and children still need to exist in the connected place. The standalone local build contains the Extras ScreenGui and code, but cannot embed unseen Studio objects from this log.

## Validation

Active Luau scripts compile and the Rojo project builds. Regression tests cover inventory layout selection and equipping, library-screen lookup and replacement, and removal of legacy-main lookup. Live Studio verification is still required for authored layout and asset availability.
