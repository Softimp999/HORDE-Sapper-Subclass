PERK.PrintName = "Sapper Base"
PERK.Description = [[
The Sapper class is a crowd-control class that can also provide high single target damage.
This class doesn't use any weapons except mines & traps.

Complexity: HIGH

{1} increased Blast damage. ({2} per level, up to {3}).
{4} immunity to explosion damage.
{5} increased damage taken from non-explosive sources. (-0.5% per level, up to -25%)

Regenerate {6} sticky mine every {7} seconds, if you have 0 ammo.
Press SHIFT+E to deploy {10} Houndeye.]]
PERK.Icon = "materials/subclasses/sapper.png"

local PARAMS = {
    [1] = {percent = true, level = 0.004, max = 0.1, classname = "Sapper"},
    [2] = {value = 0.004, percent = true},
    [3] = {value = 0.1, percent = true},
    [4] = {value = 1.0, percent = true},

    [5] = {value = 1.35, percent = true},

    [6] = {value = 1},
    [7] = {value = 15},

    [8] = {value = 0.005},
    [9] = {value = 0.10},

    -- Houndeye limit
    [10] = {value = 1}
}

PERK.Params = PARAMS
PERK.Hooks = {}

local function GetSapperHoundeyes(ply)
    local list = {}
    for _, ent in pairs(ents.FindByClass("npc_vj_horde_houndeye")) do
        if ent:GetOwner() == ply then
            table.insert(list, ent)
        end
    end
    return list
end

PERK.Hooks.Horde_UseActivePerk = function(ply)
    if not SERVER then return end
    if not ply:Horde_GetPerk("sapper_base") then return end

    local maxCount = PARAMS[10].value
    local current = GetSapperHoundeyes(ply)

    if #current >= maxCount then
        ply:Horde_SetPerkCooldown(0)
        return
    end

    local tr = ply:GetEyeTrace()
    if not tr.Hit then return end

    local ent = ents.Create("npc_vj_horde_houndeye")
    if not IsValid(ent) then return end

    ent:SetPos(tr.HitPos + Vector(0, 0, 10))
    ent:SetAngles(Angle(0, ply:GetAngles().y, 0))
	ent:SetNWEntity("HordeOwner", ply)
    ent:SetOwner(ply)
    ent:Spawn()
    ent:Activate()

    ply:Horde_SetPerkCooldown(10)
end

PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "sapper_base" then
        timer.Create("Horde_SapperBase" .. ply:SteamID(), PARAMS[7].value, 0, function ()
            if not IsValid(ply) or not ply:Alive() then return end

            if ply:HasWeapon("weapon_sticky_mine") then
                local wep = ply:GetWeapon("weapon_sticky_mine")
                local ammoType = wep:GetPrimaryAmmoType()
                if ply:GetAmmoCount(ammoType) <= 0 then
                    ply:GiveAmmo(PARAMS[6].value, ammoType)
                end
            else
                if HORDE.items["weapon_sticky_mine"] then
                    ply:Give("weapon_sticky_mine")
                end
            end
        end)

        ply:Horde_SetPerkCooldown(0)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "sapper_base" then
        timer.Remove("Horde_SapperBase" .. ply:SteamID())

        for _, ent in pairs(GetSapperHoundeyes(ply)) do
            if IsValid(ent) then
                ent:Remove()
            end
        end
    end
end

PERK.Hooks.Horde_OnPlayerDamageTaken = function(ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("sapper_base") then return end

    if HORDE:IsBlastDamage(dmginfo) then
        bonus.resistance = bonus.resistance + 1.0
    else
        local scale = ply:Horde_GetPerkLevelBonus("sapper_base_vulnerability_scale")
        if scale and scale > 1 then
            dmginfo:ScaleDamage(scale)
        end
    end
end

PERK.Hooks.Horde_PrecomputePerkLevelBonus = function (ply)
    if SERVER then
        ply:Horde_SetPerkLevelBonus(
            "sapper_base_damage",
            math.min(PARAMS[3].value, PARAMS[2].value * ply:Horde_GetLevel("Sapper"))
        )

        local reduction = math.min(
            PARAMS[9].value,
            ply:Horde_GetLevel("Sapper") * PARAMS[8].value
        )

        local current_scale = PARAMS[5].value - reduction
        ply:Horde_SetPerkLevelBonus("sapper_base_vulnerability_scale", current_scale)

        PARAMS[5].value = current_scale - 1
    end
end

PERK.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("sapper_base") then return end

    if HORDE:IsBlastDamage(dmginfo) then
        bonus.increase = bonus.increase + ply:Horde_GetPerkLevelBonus("sapper_base_damage")
    end
end
