PERK.PrintName = "Black Spot"
PERK.Description = [[Mines have a {1} chance to leave a mark of death on enemies.
Marked enemies will take {2} additional damage based on their maximum health.]]
PERK.Icon = "materials/perks/sapper/black_spot.png"
PERK.Params = {
     [1] = {value = 0.25, percent = true},
     [2] = {value = 0.75, percent = true}
}

PERK.Hooks = {}

PERK.Hooks.Horde_OnPlayerDamage = function (ply, npc, bonus, hitgroup, dmginfo)
    if not ply:Horde_GetPerk("demolition_seismic_wave") then return end
    if HORDE:IsBlastDamage(dmginfo) and dmginfo:GetDamage() >= 100 then
        local dmg = dmginfo:GetDamage() / 4
        local pos = npc:GetPos()
        timer.Simple(0.5, function()
            if !IsValid(ply) then return end
            local bpos = pos + VectorRand()
            local d = DamageInfo()
            d:SetAttacker(ply)
            d:SetInflictor(ply)
            d:SetDamageType(DMG_SONIC)
            d:SetDamage(dmg)
            util.BlastDamageInfo(d, bpos, math.min(250, dmg * 2))
            local e = EffectData()
                e:SetNormal(Vector(0,0,1))
                e:SetOrigin(bpos)
                e:SetRadius(math.min(250, dmg * 2))
            util.Effect("seismic_wave", e, true, true)
        end)
    end
end