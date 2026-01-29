AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = "models/weapons/w_slam.mdl"
ENT.HealthVal = 50
ENT.ArmDelay = 2 -- Время до активации
ENT.TriggerRadius = 100
ENT.Damage = 100
ENT.DamageRadius = 256
ENT.IsProximityMine = false -- Если true, база ищет врагов сама
ENT.SoundDeploy = "weapons/c4/c4_plant.wav"
ENT.SoundExplode = "BaseExplosionEffect.Sound"

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetHealth(self.HealthVal)
    self.SpawnTime = CurTime()
    self.Exploded = false
    
    -- Сохраняем владельца для Horde
    if IsValid(self:GetOwner()) then
        self.Horde_Owner = self:GetOwner()
    end

    if self.SoundDeploy then self:EmitSound(self.SoundDeploy) end
end

-- Получаем правильного владельца для начисления XP
function ENT:GetAttacker()
    local owner = self.Horde_Owner
    if not IsValid(owner) then owner = self:GetOwner() end
    if not IsValid(owner) then owner = self end
    return owner
end

function ENT:OnTakeDamage(dmginfo)
    self:TakePhysicsDamage(dmginfo)
    if self:Health() - dmginfo:GetDamage() <= 0 then
        self:Explode()
    else
        self:SetHealth(self:Health() - dmginfo:GetDamage())
    end
end

function ENT:Think()
    -- 1. Таймер активации
    if not self:GetArmed() then
        if CurTime() > self.SpawnTime + self.ArmDelay then
            self:SetArmed(true)
            self:OnArmed()
            self:EmitSound("weapons/c4/c4_click.wav")
        end
        return
    end

    -- 2. Проверка врагов (для простых мин)
    if self.IsProximityMine then
        for _, v in pairs(ents.FindInSphere(self:GetPos(), self.TriggerRadius)) do
            if IsValid(v) and (v:IsNPC() or (v:IsPlayer() and v ~= self:GetAttacker())) and v:Health() > 0 then
                self:Explode()
                break
            end
        end
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:OnArmed()
    -- Можно переопределить
end

function ENT:Explode()
    if self.Exploded then return end
    self.Exploded = true
    
    local pos = self:GetPos()
    local attacker = self:GetAttacker()

    -- Визуал
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect("Explosion", effectdata)
    self:EmitSound(self.SoundExplode)

    -- Урон (вызываем функцию конкретной мины)
    self:DoExplosion(pos, attacker)
    
    self:Remove()
end

-- Стандартный взрыв (переопределяется в подклассах)
function ENT:DoExplosion(pos, attacker)
    util.BlastDamage(self, attacker, pos, self.DamageRadius, self.Damage)
end