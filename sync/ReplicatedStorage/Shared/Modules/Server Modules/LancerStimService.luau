-- Injection timing comes from the master client; health and effect strength are tunable.
local V = require(script.Parent.MasterActions.Validation)
local Service = {}
local pending = setmetatable({}, {__mode = "k"})
local effects = setmetatable({}, {__mode = "k"})
local names = {"LancerStim", "PainkillerInjector", "lancerstim"}

function Service.Restock(player)
    local character = player.Character
    if not character then return end
    local backpack = player:FindFirstChildOfClass("Backpack")
    local containers = {character}
    if backpack then table.insert(containers, backpack) end
    for _, container in ipairs(containers) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and table.find(names, tool.Name) and not pending[tool] then
                tool:SetAttribute("Charges", tool:GetAttribute("MaxCharges") or 1)
            end
        end
    end
end

function Service.Use(player, tool)
    local character, _, humanoid = V.Tool(player, tool, names)
    if not character or character:GetAttribute("charging") or pending[tool] then return false end
    local charges = tool:GetAttribute("Charges")
    if charges == nil then charges = 1 end
    if charges <= 0 or not V.Cooldown(player, "LancerStim", 2) then return false end
    local token = {}
    pending[tool] = token
    tool:SetAttribute("Injecting", true)
    task.delay(0.4, function()
        if pending[tool] ~= token then return end
        pending[tool] = nil
        tool:SetAttribute("Injecting", nil)
        local current = V.Tool(player, tool, names)
        if current ~= character or humanoid.Health <= 0 then return end
        local remaining = tool:GetAttribute("Charges")
        if remaining == nil then remaining = 1 end
        if remaining <= 0 then return end
        tool:SetAttribute("Charges", remaining - 1)
        humanoid.Health = math.min(humanoid.MaxHealth, math.max(humanoid.Health, tool:GetAttribute("HealTo") or 100))
        local duration = tool:GetAttribute("Duration") or 20
        local effect = {}
        effects[character] = effect
        character:SetAttribute("LancerStimUntil", workspace:GetServerTimeNow() + duration)
        character:SetAttribute("LancerPainSuppressed", true)
        character:SetAttribute("LancerStimSpreadMultiplier", 1.5)
        -- Generation checks keep an older dose from clearing a refreshed effect.
        task.delay(duration, function()
            if effects[character] ~= effect then return end
            effects[character] = nil
            if character.Parent then
                character:SetAttribute("LancerStimUntil", nil)
                character:SetAttribute("LancerPainSuppressed", nil)
                character:SetAttribute("LancerStimSpreadMultiplier", nil)
            end
        end)
        V.Remote("UtilityAction"):FireClient(player, tool, "LancerStimUsed")
    end)
    return true
end
return Service
