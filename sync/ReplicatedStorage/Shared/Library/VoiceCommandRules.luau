local Rules = {}
Rules.Commands = {danger=true, ammo=true, healing=true, help=true, thanks=true, officerfollow=true, officerdefend=true, officerorder=true}
Rules.Officer = {officerfollow=true, officerdefend=true, officerorder=true}
Rules.Labels = {ammo="Need ammunition!", healing="Need a medic!", help="Need support!", thanks="Thank you!", officerfollow="Follow me!", officerdefend="Defend here!", officerorder="Follow the order!", danger="Danger there!"}
Rules.Requests = {ammo="AmmoRequestedUntil", healing="MedicRequestedUntil", help="SupportRequestedUntil"}
Rules.Inputs = {["Voice Command: Request Ammo"]="ammo", ["Voice Command: Danger There"]="danger", ["Voice Command: Request Medic"]="healing", ["Voice Command: Need Support"]="help", ["Voice Command: Thank You"]="thanks", ["Officer Command: Defend Here"]="officerdefend", ["Officer Command: Follow Me"]="officerfollow", ["Officer Command: Compound Order"]="officerorder"}
return Rules
