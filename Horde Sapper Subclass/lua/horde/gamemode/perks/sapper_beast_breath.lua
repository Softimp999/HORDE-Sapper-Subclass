PERK.PrintName = "Beast Breath"
PERK.Description = [[
Regenerate {1} of maximum health per second.]]

PERK.Icon = "materials/perks/phase_walk.png"
PERK.Params = {
    [1] = {value = 0.05, percent = true},
}

PERK.Hooks = {}
PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "sapper_beast_breath" then
        ply:Horde_SetHealthRegenPercentage(0.05)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "sapper_beast_breath" then
        ply:Horde_SetHealthRegenPercentage(0)
    end
end

PERK.Hooks.Horde_OnPlayerDebuffApply = function (ply, debuff, bonus)
    if ply:Horde_GetPerk("sapper_beast_breath") and debuff == HORDE.Status_Break then
        bonus.apply = 0
        return true
    end
end
