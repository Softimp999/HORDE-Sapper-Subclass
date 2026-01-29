AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local MAT_ICE = "models/player/shared/ice_player"
local MODEL = "models/mechanics/wheels/wheel_smooth_18r.mdl"

function ENT:Initialize()
    self:SetModel(MODEL)
    self:SetMaterial(MAT_ICE)
    self:SetModelScale(0.75) -- Уменьшаем, колесо огромное
    
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    
    self.Stuck = false
    self.Triggered = false
end

function ENT:PhysicsCollide(data, phys)
    if self.Stuck then return end
    
    if data.HitEntity:IsWorld() or IsValid(data.HitEntity) then
        self.Stuck = true
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
        self:SetMoveType(MOVETYPE_NONE)
        
        local ang = data.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        
        self:SetPos(data.HitPos)
        self:SetAngles(ang)
        
        if IsValid(data.HitEntity) and not data.HitEntity:IsWorld() then
            self:SetParent(data.HitEntity)
        end
        
        self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
    end
end

function ENT:Think()
    if self.Triggered or not self.Stuck then return end
    
    -- Ищем врагов
    local targets = ents.FindInSphere(self:GetPos(), 256)
    for _, ent in ipairs(targets) do
        if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) and ent:Alive() and ent ~= self:GetOwner() then
            self:StartShockAttack()
            break
        end
    end
    
    self:NextThink(CurTime() + 0.2)
    return true
end

function ENT:StartShockAttack()
    self.Triggered = true
    
    self:EmitSound("npc/attack_helicopter/aheli_damaged_alarm1.wav")
    
    -- Запускаем 5 ударов с интервалом ~0.2 сек
    -- 1.5 сек задержка перед первым ударом
    timer.Simple(1.0, function() if IsValid(self) then self:DoShockWave() end end)
    timer.Simple(1.2, function() if IsValid(self) then self:DoShockWave() end end)
    timer.Simple(1.4, function() if IsValid(self) then self:DoShockWave() end end)
    
    -- Удаление после атаки
    timer.Simple(2.5, function()
        if IsValid(self) then 
             -- Финальный взрыв
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            util.Effect("cball_explode", effectdata)
            self:Remove() 
        end
    end)
end

function ENT:DoShockWave()
    if not IsValid(self) then return end
    
    local pos = self:GetPos()
    local dmgAmt = 10 -- Как у Screecher
    local radius = 256
    
    -- Эффект молнии
    local e = EffectData()
    e:SetOrigin(pos)
    e:SetNormal(Vector(0,0,1))
    util.Effect("screecher_blast", e, true, true)
    
    -- Наносим урон
    local dmg = DamageInfo()
    dmg:SetAttacker(self:GetOwner() or self)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_SHOCK)
    dmg:SetDamage(dmgAmt)
    
    util.BlastDamageInfo(dmg, pos, radius)

    -- Накладываем эффект Horde Shock
    if HORDE and HORDE.Status_Shock then
        for _, ent in pairs(ents.FindInSphere(pos, radius)) do
            if (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer()) and ent ~= self then
                -- Функция добавления дебаффа из Horde
                if ent.Horde_AddDebuffBuildup then
                    ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 10, self:GetOwner())
                end
            end
        end
    end
    
    self:EmitSound("npc/zombie/claw_strike1.wav", 75, 150) -- Звук удара током
end

function ENT:OnTakeDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    if self:Health() <= 0 then 
        self:StartShockAttack() -- Если сломали, сразу активируем
    end
end