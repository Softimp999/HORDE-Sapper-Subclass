PERK.PrintName = "Houndeyes"
PERK.Description = [[Summons a protective Houndeyes minion for Sapper subclass.]]
PERK.Icon = "materials/subclasses/sapper.png"
PERK.Params = {
}

PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "sapper_houndeyes" then
        ply:Horde_SetPerkCooldown(15)
        ply:Horde_SetPerkInternalCooldown(0)
		
        net.Start("Horde_SyncActivePerk")
            net.WriteUInt(HORDE.Status_Houndeyes, 8)
            net.WriteUInt(0, 3)
        net.Send(ply)
        
        net.Start("Horde_PerkStartCooldown")
            net.WriteUInt(ply:Horde_GetPerkInternalCooldown(), 8)
        net.Send(ply)
        
        ply:Horde_SetMaxFearStack(ply:Horde_GetMaxFearStack() + 1)
    end
end