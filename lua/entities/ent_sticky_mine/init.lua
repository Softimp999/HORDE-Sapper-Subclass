AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/tpplug.mdl")
    
    -- Физика для полета
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:PhysicsInit(SOLID_VPHYSICS)
    
    -- Чтобы мина не взрывалась об игрока, который её кинул, в первую секунду
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE) 
    
    self.Stuck = false -- Прилипла или нет
    self.Armed = false -- Взведена или нет
end

-- Когда мина во что-то врезается
function ENT:PhysicsCollide(data, phys)
    if self.Stuck then return end -- Если уже прилипла, игнорируем
    
    -- Если ударилась о мир (стены) или проп
    if data.HitEntity:IsWorld() or IsValid(data.HitEntity) then
        self:Stick(data)
    end
end

function ENT:Stick(data)
    self.Stuck = true
    
    -- 1. Останавливаем физику
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:EnableMotion(false) end
    self:SetMoveType(MOVETYPE_NONE)
    
    -- 2. Выравниваем по поверхности
    -- Normal - это вектор "из стены". Превращаем его в угол.
    local ang = data.HitNormal:Angle()
    
    -- tpplug лежит на боку, поэтому поворачиваем его на 90 градусов,
    -- чтобы "подошва" штекера смотрела в стену.
    ang:RotateAroundAxis(ang:Right(), -180)
    
    self:SetPos(data.HitPos)
    self:SetAngles(ang)
    
    -- 3. Привариваем (Parent) если это движущийся объект (лифт, дверь, проп)
    if IsValid(data.HitEntity) and not data.HitEntity:IsWorld() then
        self:SetParent(data.HitEntity)
    end
    
    -- 4. Звук прилипания
    self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
    
    -- 5. Взводим через 0.25 сек (звук активации)
    timer.Simple(0.25, function()
        if not IsValid(self) then return end
        self.Armed = true
        self:EmitSound("buttons/blip1.wav")
    end)
end

function ENT:Think()
    -- Работаем только если взведена
    if not self.Armed then return end
    
    -- Ищем врагов в радиусе 60 юнитов (довольно близко, чтобы наступить)
    local targets = ents.FindInSphere(self:GetPos(), 60)
    
    for _, ent in ipairs(targets) do
        if (ent:IsPlayer() or ent:IsNPC()) and ent:Alive() then
            self:Explode()
            break
        end
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

-- Взрыв при получении урона
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
    
    -- Эффект
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    util.Effect("Explosion", effectdata)
    
    -- Звук
    self:EmitSound("BaseExplosionEffect.Sound")
    
    -- Урон 100
    util.BlastDamage(self, owner, pos, 256, 100)
    
    self:Remove()
end