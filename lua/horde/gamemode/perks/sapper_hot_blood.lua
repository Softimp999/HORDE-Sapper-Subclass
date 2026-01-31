PERK.PrintName = "Hot Blood"
PERK.Description = [[Your own explosions heal you for {1} of your maximum health.]]

PERK.Icon = "materials/perks/sapper/hot_blood.png"
PERK.Params = {
    [1] = {value = 0.1, percent = true}
}

PERK.Hooks = {}

PERK.Hooks.Horde_OnPlayerDamageTaken = function(ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("sapper_hot_blood") then return end
    

    local attacker = dmginfo:GetAttacker()
    
    if HORDE:IsBlastDamage(dmginfo) and attacker == ply then
        -- Лечим 10% от максимального здоровья
        local healAmount = ply:GetMaxHealth() * 0.10
        local newHealth = math.min(ply:GetMaxHealth(), ply:Health() + healAmount)
        
        -- Применяем лечение, только если здоровье не полное
        if ply:Health() < ply:GetMaxHealth() then
            ply:SetHealth(newHealth)
            -- Звук лечения (опционально)
            ply:EmitSound("items/medshot4.wav", 50, 100, 0.5)
        end
    end
end