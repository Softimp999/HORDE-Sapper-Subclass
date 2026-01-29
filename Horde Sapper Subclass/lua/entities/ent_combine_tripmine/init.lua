AddCSLuaFile("cl_init.lua") -- ОТПРАВЛЯЕМ КЛИЕНТСКУЮ ЧАСТЬ ИГРОКУ
AddCSLuaFile("shared.lua")  -- ОТПРАВЛЯЕМ ОБЩУЮ ЧАСТЬ
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_mine01.mdl")
    self:SetMoveType(MOVETYPE_NONE) -- Не двигается
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    self:PhysicsInit(SOLID_VPHYSICS)
    
    self:SetHealth(25)
    
    -- Зарядка 1.5 секунды
    self.PowerUpTime = CurTime() + 1.5
    self:EmitSound("items/suitchargeno1.wav")
    self.Active = false
end

function ENT:Think()
    if not self.Active and CurTime() >= self.PowerUpTime then
        self:ActivateMine()
    end
    
    if self.Active then
        self:BeamThink()
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:ActivateMine()
    self.Active = true
    self:EmitSound("weapons/mine_activate.wav")
    
    -- Считаем луч один раз и отправляем клиенту
    local tr = self:GetBeamTrace()
    self:SetBeamEnd(tr.HitPos)
    self:SetDrawLaser(true)
    self.BeamLen = tr.Fraction
end

function ENT:BeamThink()
    local tr = self:GetBeamTrace()
    
    -- Если луч прервали (дистанция изменилась)
    if math.abs(self.BeamLen - tr.Fraction) > 0.05 then
        if tr.HitNonWorld or (IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())) then
            self:Explode()
        end
    end
end

function ENT:GetBeamTrace()
    local up = self:GetUp()
    local src = self:GetPos() + up * 5
    local endpos = src + up * 2048

    return util.TraceLine({
        start = src,
        endpos = endpos,
        filter = {self, self:GetOwner()}
    })
end

function ENT:OnTakeDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    if self:Health() <= 0 then self:Explode() end
end

function ENT:Explode()
    if self.Exploded then return end
    self.Exploded = true
    
    local pos = self:GetPos()
    local owner = self:GetOwner()
    if not IsValid(owner) then owner = self end

    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect("Explosion", effectdata)
    
    util.BlastDamage(self, owner, pos, 350, 150)
    self:Remove()
end