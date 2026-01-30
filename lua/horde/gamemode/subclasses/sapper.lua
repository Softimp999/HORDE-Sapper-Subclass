SUBCLASS.PrintName = "Sapper" -- Required
SUBCLASS.UnlockCost = 50
SUBCLASS.ParentClass = HORDE.Class_Demolition -- Required for any new classes
SUBCLASS.Icon = "subclasses/sapper.png" -- Required
SUBCLASS.Description = [[
Explosive munition expert class.
Uses only mine and trap related weapons.]] -- Required
SUBCLASS.BasePerk = "sapper_base"
SUBCLASS.Perks = {
    [1] = {title = "Symbiosis", choices = {"sapper_hot_blood", "sapper_loyality"}},
    [2] = {title = "Potency", choices = {"demolition_fragmentation", "sapper_evolution"}},
    [3] = {title = "Trigger", choices = {"sapper_detonator", "sapper_kinship"}},
    [4] = {title = "Metamorphosis", choices = {"sapper_pyromaniac", "sapper_mutation"}},
} -- Required