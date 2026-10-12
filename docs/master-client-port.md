# Master client integration

The three reference scripts are archived in `docs/master-controller-sources`. They are not executed. Their UI and input behavior is adapted through the existing modular services and the imported `main` StarterGui.

| Behavior | Active owner |
| --- | --- |
| Authored menu shell, panel navigation | MenuService and MenuLayout |
| Loadout, classes, weapon statistics, appearance, settings, credits, servers, tutorial | Existing MenuService handlers |
| Skin list and selection | WeaponSkinView and AppearanceService/WeaponSkins |
| Inventory metadata and equipping | ToolService, InventoryService, InventoryView, ToolMetadata |
| Player list | MenuService/PresentationHandler |
| Death screen and spawn selection | UI/DeathScreen and GameManager/SpawnSelection |
| Voice wheel and voice requests | VoiceReceiver, VoiceManager, VoiceCommandRules |
| Progression, score labels, hints, tutorial prompts, end panels, map picker, spawn fade | GameplayPresentationService/MasterHud |
| Weapon visuals and replication | MasterEffects.Dispatch, MasterEffectsService, MasterEffectsRelay |
| Original setting and bind names | SettingsManager and MasterClientSettings |
| Map voting | GameManager/MapVote and MatchControlService |

Existing movement, camera, tool, and combat controllers retain ownership of those systems. Weapon accuracy and damage tuning are not changed by this integration. The legacy player-list input and spawn-fade callbacks are removed to prevent duplicate ownership. Skin requests validate recognized weapon IDs, mastery requirements and special unlocks on the server. ValueBase changes now update persisted profile data using the actual Changed signal contract.

## Missing original server systems

The original campaign, train and engineer handlers are absent. The map picker therefore votes for the current game's existing CoreMaps models; selected templates are cloned so the map pool survives subsequent rounds. Voting validates player state and map names, replaces a player's prior vote, excludes departed voters and supports replay of the current ballot.

Train and engineer destinations require server-owned BaseParts or Models tagged `TrainSpawn` or `EngineerSpawn`, with a `Team` attribute matching the team's name. Models use a descendant `spawn` BasePart or their PrimaryPart. Buttons appear only when a valid destination exists. Destinations are revalidated at respawn; removed destinations fall back to base. Existing reinforcement and respawn-wave rules still apply.

This does not recreate absent campaign game modes, moving train gameplay, engineer construction assets, cosmetic purchase prices, or the original server's unspecified fall-damage and defection rules. Presentation messages have native receivers, but scenario-specific tutorial, campaign and dogtag events need their authoritative gameplay producers. Mapping a setting name does not itself implement a missing gameplay system.

## Validation

Use `sync.project.json`. All 629 active Luau scripts compile. Lua regression tests cover animation binding and waits, authored GUI discovery, inventory, material impacts, effects loading and replication, cosmetics, metadata, settings aliases and map-vote lifecycle. Rojo builds successfully. Studio playtesting and published asset permissions require the live experience; no live Studio session was connected during this work.
