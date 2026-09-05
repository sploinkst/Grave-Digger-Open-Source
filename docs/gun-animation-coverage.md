# Gun animation coverage

Update: the base firearm controller now selects `reload_empty` (for reload start/hand-loading) and `check_empty` when magazine `Capacity == 0`. It falls back to the normal clip if the empty clip is absent. The historical unused lists below predate that change; these two names are no longer pending for connected gun folders. Veteran/clip-specific variants remain pending. Hellion now uses `reload_empty` as the empty opening rather than as its closing clip; its former `reload_empty_vet` closing selection is no longer used.

Static audit of the eight implemented gun classes, their inherited controllers, and the local sourcemap. This is not a live Studio inventory or playback test. A clip counts as used only when gameplay selects it; discovering or registering a clip alone does not count.

## Held idle

The shared controller maps `held` to looping `Hold`, restores it after actions and ADS, and keeps it playing while sprinting. Alternate firing modes now use the same held idle outside ADS. Adjudicator now requests `held` instead of `locked` for normal idle.

The exported `autosg` and `rsc` folders have **no `held` clip**. These guns use the existing `PrinceRifle_Held` fallback until their own clips are supplied. Grace uses its existing `GraceRevolver_Held` asset. The exported `lebel` folder is empty; its legacy `RBX_ANIMSAVES/lebel_rig` supplies `held` and the other available clips. Empty authored folders now allow that fallback.

## Available clips without a gameplay trigger

Names are the exact source names. `locked` entries include mode-specific idle tracks that are now intentionally superseded by `held` outside ADS.

### mosin / VolkRifle

These clips are discovered/registered, but gameplay does not select them:

- `locked`
- `reload_clip`
- `reload_clip_start_empty`
- `reload_clip_start_empty_novet`
- `reload_clip_start_one`
- `reload_empty`
- `reload_empty_vet`
- `reload_start_vet`

### lever / CrestfallRifle

These clips are discovered/registered, but gameplay does not select them:

- `check_empty`
- `locked`
- `reload_empty`
- `reload_empty_vet`
- `reload_empty_vetOLD`

### henry / JudgementRifle

These clips are discovered/registered, but gameplay does not select them:

- `meleealt1`
- `meleealt2`
- `reload_start_vet`
- `sprint`
- `vet_roundreplace`

### lebel / PrinceRifle

- `alt_toggled_off`
- `altmelee1`
- `altmelee2`
- `reload_alt_extra`
- `reload_empty_vet`
- `reload_end_vet`
- `reload_start_vet`
- `sprint`

### springfield  WhisperRifle

- `cycle_pedersen`
- `locked`
- `locked_alt`
- `pedersen_bolt_place`
- `pedersen_bolt_remove`
- `pedersen_charge`
- `pedersen_device_off`
- `pedersen_device_on`
- `pedersen_jam`
- `pedersen_mag_eject`
- `pedersen_mag_in`
- `pedersen_mag_out`
- `reload_clip`
- `reload_clip_start_empty`
- `reload_clip_start_one`
- `reload_empty`
- `reload_heavyloop`
- `reload_start_vet`

### autosg / HellionShotgun

- `check_empty`
- `locked`

### rsc / AdjudicatorRifle

- `locked`

### saa / GraceRevolver

This authored folder is not connected to GraceRevolver. Grace still plays its separate legacy assets, including ordinary fire/reload/check actions; this list does not mean those actions are absent:

- `akimbo_fire`
- `akimbo_fire_empty`
- `akimbo_saa_spins`
- `check`
- `fire`
- `fire_empty`
- `hipfire`
- `ocelot_draw_spin`
- `quickdraw`
- `quickdraw_start`
- `reload_end`
- `reload_loop`
- `reload_loop_after`
- `reload_loop_after_twice`
- `reload_start`
- `reload_start_vet`
- `stock_fire`
- `stock_fire_empty`
- `stock_fire_empty_left`
- `stock_fire_left`

## Repeated gaps

- Veteran reload selection is missing for Mosin, Lever, Henry, Lebel and Springfield. Hellion and Adjudicator already select their relevant veteran reload clips.
- `check_empty` is registered for Lever and Hellion, but the shared ammo-check action always selects `Check`.
- The authored `sprint` clips for Henry and Lebel have no weapon-controller trigger. Character sprint overlays come from a separate animation folder.
- Mosin and Springfield do not select their clip-loading/empty-reload variants; their normal reload path uses start/loop/end.
- Henry's alternate melee and veteran round-replacement clips are not selected. Springfield's Pedersen-specific clips are not mapped to its existing Pedersen gameplay.

## Other authored firearm folders without a dedicated GunClasses controller

These folders exist in the exported inventory but have no dedicated controller among the eight audited gun classes. The following is an inventory of their clips, not a claim about utility, equipment or map scripts outside this audit.

### browningmg

`aim`, `draw`, `fire`, `held`, `reload_start`.

### crossbow

`aim`, `aim_left`, `altmelee1`, `altmelee2`, `check`, `draw`, `fire`, `fire_left`, `held`, `locked`, `melee1`, `melee2`, `reload_start`, `short`, `speen`, `sprint`.

### dbgun

`aim`, `aim_left`, `check`, `draw`, `fire`, `fire_left`, `held`, `melee1`, `melee2`, `meleealt1`, `reload_dual_doom`, `reload_dual_vet`, `reload_empty_doom`, `reload_empty_vet`, `reload_end`, `reload_end_doom`, `reload_loop`, `reload_loop_alt`, `reload_start`, `short`, `sprint`.

### enfield

`aim`, `bipod_aim`, `bipod_cycle`, `bipod_fire`, `blank_boltback`, `blank_boltback_empty`, `blank_end`, `blank_reload`, `check`, `cutoff_off`, `cutoff_on`, `cycle`, `discard_grenade`, `fire`, `load_blank`, `load_blank_vet`, `load_grenade`, `locked`, `reload_clip`, `reload_clip_empty`, `reload_empty`, `reload_end`, `reload_loop`, `reload_start`, `reload_start_vet`, `unload_grenade`.

### lewis

`aim`, `bipod_aim`, `bipod_fire`, `check`, `draw`, `fire`, `held`, `locked`, `melee1`, `melee2`, `reload_bolt`, `reload_start`, `shieldplace`, `short`, `sprint`.

### mares

`aim`, `aim_left`, `akimbo_fire`, `akimbo_fire_empty`, `akimbo_locked`, `alt_changefire`, `check`, `fire`, `fire_last`, `fire_last_left`, `fire_left`, `locked`, `reload_empty`, `reload_empty_vet`, `reload_loop`, `reload_start`, `spin_left`, `spin_right`.

### mauser

`akimbo_fire`, `akimbo_locked`, `alt_changeaim`, `alt_changeaim_left`, `alt_changefire`, `alt_changefire_left`, `alt_stockoff`, `alt_stockon`, `check`, `check_empty`, `fire`, `locked`, `reload_full`, `reload_full_vet`, `reload_one`, `reload_one_vet`, `reload_start`, `reload_start_vet`.

### mausercarbine

`aim`, `aim_left`, `draw`, `fire`, `fire_left`, `held`, `melee1`, `melee2`, `short`.

### mgturret

`aim`, `draw`, `fire`, `held`, `reload_start`.

### mondragon

`aim`, `aim_left`, `check`, `check_empty`, `fire`, `fire_left`, `held`, `reload_clip`, `reload_empty`, `reload_end`, `reload_loop`, `reload_start`, `sprint`.

### mpgun

`aim`, `aim_left`, `check`, `draw`, `fire`, `fire_left`, `held`, `locked`, `melee1`, `melee2`, `reload_bolt`, `reload_start`, `reload_start_soldat`, `short`, `sprint`, `sprint_greyhound`.

### mpistol

`akimbo_fire`, `akimbo_locked`, `check`, `draw`, `fire`, `held`, `locked`, `reload_end`, `reload_end_locked`, `reload_end_locked_vet`, `reload_start`, `reload_start_vet`, `tag_look`.

### pieper

`akimbo_fire`, `akimbo_fire_empty`, `akimbo_locked`, `check`, `fire`, `fire_empty`, `fire_empty_left`, `fire_left`, `hammer_lower`, `hammer_pull`, `locked`, `reload_end`, `reload_loop`, `reload_loop_after`, `reload_partial`, `reload_start`, `reload_start_vet`.

### pugsley

`aim`, `aim_left`, `check`, `cycle`, `draw`, `fire`, `fire_left`, `held`, `melee2`, `reload_bolt`, `reload_start`, `short`, `sprint`.

### remington

`akimbo_fire`, `akimbo_locked`, `alt_changeaim`, `alt_changefire`, `check`, `fire`, `locked`, `long_aim`, `long_aim_left`, `long_check`, `long_draw`, `long_fire`, `long_fire_left`, `long_held`, `long_sprint`, `reload_start`, `reload_start_vet`.

### rooklauncher

`aim`, `aim_left`, `draw`, `fire`, `fire_left`, `held`, `locked`, `reload_start`, `sprint`.

### steyr

`akimbo_fire`, `akimbo_locked`, `alt_changeaim`, `alt_changeaim_left`, `alt_changefire`, `alt_changefire_left`, `check`, `fire`, `locked`, `reload_clip`, `reload_empty`, `reload_end`, `reload_loop`, `reload_one_vet`, `reload_start`, `reload_start_vet`, `steyrdraw`.

### trench

`aim`, `aim_left`, `check`, `cycle`, `cycle_left`, `draw`, `fire`, `fire_left`, `held`, `locked`, `melee1`, `melee2`, `reload_empty`, `reload_loop`, `reload_start`.

### walker

`fire`, `fire_break`, `fire_empty`, `fire_left`, `fire_weak`, `held`, `reload_add_ball`, `reload_cap_add`, `reload_cap_remove`, `reload_cylinder`, `reload_dump`, `reload_end`, `reload_idle`, `reload_lever`, `reload_powder`, `reload_start`, `spin_cylinder`, `spin_end`, `spin_end_flashy`, `spin_loop`, `spin_start`.

### wex

`aim`, `aim_left`, `draw`, `firing`, `firing_left`, `held`.

