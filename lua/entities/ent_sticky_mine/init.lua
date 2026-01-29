AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "ent_mine_base"
ENT.PrintName = "Sticky Mine"

ENT.Model = "models/props_lab/tpplug.mdl"
ENT.IsProximityMine = true -- Используем поиск врагов из базы
ENT.TriggerRadius = 100
ENT.Damage = 350
ENT.DamageRadius = 300
ENT.ArmDelay = 1

-- Добавляем логику прилипания
function ENT:PhysicsCollide(data, phys)
    if self.Stuck then return end
    
    if data.HitEntity:IsWorld() or IsValid(data.HitEntity) then
        self.Stuck = true
        
        -- Звук удара
        self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
        
        local ang = data.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), 180)
        
        self:SetPos(data.HitPos)
        self:SetAngles(ang)
        
        -- Привариваем
        constraint.Weld(self, data.HitEntity, 0, 0, 0, true, false)
        
        -- Замораживаем физику чтобы не дергалась
        local p = self:GetPhysicsObject()
        if IsValid(p) then p:EnableMotion(false) end
    end
end