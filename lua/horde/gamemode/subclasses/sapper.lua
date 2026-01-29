SUBCLASS.PrintName = "Sapper" -- Required
SUBCLASS.UnlockCost = 50
SUBCLASS.ParentClass = HORDE.Class_Demolition -- Required for any new classes
SUBCLASS.Icon = "subclasses/sapper.png" -- Required
SUBCLASS.Description = [[
Explosive munition expert class.
Uses only mine and trap related weapons.]] -- Required
SUBCLASS.BasePerk = "sapper_base"
SUBCLASS.Perks = {
    [1] = {title = "Stealth", choices = {"sapper_beast_breath", "assault_charge"}},
    [2] = {title = "Weaponory", choices = {"demolition_direct_hit", "demolition_seismic_wave"}},
    [3] = {title = "Approach", choices = {"demolition_fragmentation", "demolition_knockout"}},
    [4] = {title = "Annihilation", choices = {"demolition_chain_reaction", "demolition_pressurized_warhead"}},
} -- Required