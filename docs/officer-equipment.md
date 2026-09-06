# Officer equipment

Trench Whistle: G draws or holsters; Q selects Advance, Defend, or Focus;
T selects 60 or 30 seconds; M1 issues the order. The server owns capacity,
expiry, team checks, range, and duplicate prevention. Survivalist permits two
different active orders. Nearby Officers can supply all three different orders.
The same order never multiplies itself. Holstering preserves active orders.
Death, character replacement, or changing teams cancels the issuer's orders.
Aura membership is checked every 0.25 seconds within 80 studs, including self.

Existing balance values are preserved: Advance gives 1.15x speed; Defend gives
1.15x reload and firing speed; Focus gives 1.15x accuracy and 0.8x recoil.
The supplied description does not specify these magnitudes.

Recon Kit is now a selectable inventory tool. Point at an enemy and press M1.
The server checks the equipped kit, living Officer and target, opposing teams,
line of sight, range, and request frequency. Provisional tuning is a 1000-stud
spotting range, 200-stud ally sharing range around the Officer, a 10-second mark,
and one request per second. The linked detailed Trello card was inaccessible.
The repository asset map contains no Recon Kit/binocular model or animations;
the tool currently provides targeting and marks without a held visual model.

## Verification

Run `python tests/run_whistle.py <path-to-luau>` to exercise the production
whistle server handlers with mocked players and time. This checks durations,
capacity, combinations, range, team exclusion, death, and respawn cleanup.

Studio playtest still required: deploy an Officer, switch from a gun to G,
cycle Q/T, issue orders, holster, return to the same gun, and repeat after death.
Test with a Survivalist and multiple Officers on both teams; move across the
80-stud boundary. Confirm the authored whistle grip, clips, sounds, and count
display. Equip Recon Kit and test visible enemies, walls, allies, and dead targets.
