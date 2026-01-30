PERK.PrintName = "Sapper Base"
PERK.Description = [[
The Sapper class is a crowd-control class that can also provide high single target damage.
This class doesn't use any weapons except mines & traps.

Complexity: HIGH

{1} increased Blast damage. ({2} per level, up to {3}).
You have {4} vulnerability to Blast damage.

Regenerate {5} sticky mine every {6} seconds, if you have 0 ammo.]]

-- 1. Настройки
local PARAMS = {
    [1] = {percent = true, level = 0.004, max = 0.1, classname = "Sapper"},
    [2] = {value = 0.004, percent = true}, -- Прирост урона
    [3] = {value = 0.1, percent = true},   -- Макс урона
    [4] = {value = 1.0, percent = true},   -- РЕЗИСТ 1.0 = 100% (Иммунитет)
    [5] = {value = 1},                     -- Кол-во мин
    [6] = {value = 15},                    -- Таймер
}

PERK.Params = PARAMS
PERK.Hooks = {}

PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "sapper_base" then
        timer.Create("Horde_SapperBase" .. ply:SteamID(), PARAMS[6].value, 0, function ()
            if not IsValid(ply) or not ply:Alive() then return end
            
            if ply:HasWeapon("weapon_sticky_mine") then
                local wep = ply:GetWeapon("weapon_sticky_mine")
                local ammoType = wep:GetPrimaryAmmoType()
                
                if ply:GetAmmoCount(ammoType) <= 0 then
                    ply:GiveAmmo(PARAMS[5].value, ammoType)
                end
            else
                if HORDE.items["weapon_sticky_mine"] then 
                    ply:Give("weapon_sticky_mine")
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

-- Хук ПОЛУЧЕНИЯ урона (Резист)
PERK.Hooks.Horde_OnPlayerDamageTaken = function(ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("sapper_base") then return end
    
    -- Если урон от взрыва (BLAST), добавляем резист
    if HORDE:IsBlastDamage(dmginfo) then
        -- Добавляем 1.0 (100%), что полностью поглотит урон
        bonus.resistance = bonus.resistance + ply:Horde_GetPerkLevelBonus("sapper_base_resistance")
    end
end

-- Расчет бонусов
PERK.Hooks.Horde_PrecomputePerkLevelBonus = function (ply)
    if SERVER then
        -- Бонус к урону
        ply:Horde_SetPerkLevelBonus("sapper_base_damage", math.min(PARAMS[3].value, 0 + PARAMS[2].value * ply:Horde_GetLevel("Sapper")))
        
        -- Бонус к защите (Теперь положительный!)
        ply:Horde_SetPerkLevelBonus("sapper_base_resistance", PARAMS[4].value)
    end
end

-- Хук НАНЕСЕНИЯ урона (Усиление атаки)
PERK.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("sapper_base") then return end
    
    if HORDE:IsBlastDamage(dmginfo) then
        bonus.increase = bonus.increase + ply:Horde_GetPerkLevelBonus("sapper_base_damage")
    end
end