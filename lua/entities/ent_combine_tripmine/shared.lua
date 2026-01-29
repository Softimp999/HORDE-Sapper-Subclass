ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Combine Tripmine"
ENT.Author = "Optimized"
ENT.Spawnable = false -- Мы спавним её через оружие, в меню она не нужна

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "DrawLaser")
    self:NetworkVar("Vector", 0, "BeamEnd")
end