PERK.PrintName = "Sapper Base"
PERK.Description = [[
The Sapper class is a crowd-control class that can also provide high single target damage.
This class doesn't use any weapons except mines & traps.

Complexity: HIGH

{7} increased Blast damage. ({8} per level, up to {9}).
{1} decreased Blast damage resistance.

Regenerate {5} sticky mine every {6} seconds, if you do not have one.]]
PERK.Params = {
    [1] = {value = -0.25, percent = true, classname = "Sapper"},
    [2] = {value = 0.25, percent = true},
    [3] = {value = 0.01, percent = true},
    [4] = {value = 0.5, percent = true},
    [5] = {value = 1},
    [6] = {value = 15},
    [7] = {percent = true, level = 0.004, max = 0.1, classname = "Sapper"},
    [8] = {value = 0.004, percent = true},
    [9] = {value = 0.1, percent = true},
}

PERK.Hooks = {}
PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "sapper_base" then
        timer.Create("Horde_SapperBase" .. ply:SteamID(), 30, 0, function ()
            if not ply:IsValid() or not ply:Alive() then return end
            if HORDE.items["weapon_sticky_mine"] then
                if not ply:HasWeapon("weapon_sticky_mine") then
                    ply:Give("weapon_sticky_mine", ply:GetAmmoCount("weapon_sticky_mine") > 0)
                end
            end
        end)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "sapper_base" then
        timer.Remove("Horde_SapperBase" .. ply:SteamID())
    end
end

PERK.Hooks.Horde_OnPlayerDamageTaken = function(ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("sapper_base")  then return end
    if HORDE:IsBlastDamage(dmginfo) then
        bonus.resistance = bonus.resistance + ply:Horde_GetPerkLevelBonus("sapper_base")
    end
end

PERK.Hooks.Horde_PrecomputePerkLevelBonus = function (ply)
    if SERVER then
        ply:Horde_SetPerkLevelBonus("sapper_base", math.min(0.5, 0.25 + 0.01 * ply:Horde_GetLevel("Sapper")))
        ply:Horde_SetPerkLevelBonus("sapper_base2", math.min(0.10, 0.004 * ply:Horde_GetLevel("Sapper")))
    end
end

PERK.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("sapper_base") then return end
    if HORDE:IsBlastDamage(dmginfo) then
        bonus.increase = bonus.increase + ply:Horde_GetPerkLevelBonus("sapper_base2")
    end
end