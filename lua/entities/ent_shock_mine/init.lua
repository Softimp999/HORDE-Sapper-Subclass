AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Type = "anim"
ENT.Base = "ent_mine_base"
ENT.PrintName = "Shock Mine"

-- Настройки
ENT.Model = "models/mechanics/wheels/wheel_smooth_18r.mdl"
ENT.Material = "models/player/shared/ice_player"
ENT.IsProximityMine = true -- База ищет врагов
ENT.TriggerRadius = 150    -- Радиус срабатывания
ENT.Damage = 50            -- Урон за ОДИН удар
ENT.DamageRadius = 256     -- Радиус поля
ENT.ArmDelay = 1.0

-- 1. ЛИПУЧЕСТЬ (Копируем из Sticky Mine)
function ENT:PhysicsCollide(data, phys)
    if self.Stuck then return end
    
    local ent = data.HitEntity
    
    -- ПРОВЕРКА: Если мы попали в Игрока, NPC или NextBot — НЕ ПРИЛИПАЕМ
    if IsValid(ent) and (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) then
        return
    end
    
    -- Если попали в мир или проп — прилипаем
    if ent:IsWorld() or IsValid(ent) then
        self.Stuck = true
        
        self:EmitSound("weapons/hegrenade/he_bounce-1.wav")
        
        local ang = data.HitNormal:Angle()
        ang:RotateAroundAxis(ang:Right(), -90)
        
        self:SetPos(data.HitPos)
        self:SetAngles(ang)
        
        constraint.Weld(self, ent, 0, 0, 0, true, false)
        
        local p = self:GetPhysicsObject()
        if IsValid(p) then p:EnableMotion(false) end
    end
end

-- 2. ПЕРЕОПРЕДЕЛЯЕМ ВЗРЫВ ПОЛНОСТЬЮ
-- ВАЖНО: Мы НЕ вызываем self.BaseClass.Explode(self), потому что база удаляет мину.
function ENT:Explode()
    if self.Exploded then return end
    self.Exploded = true
    
    -- Звук тревоги (раскрутка)
    self:EmitSound("npc/attack_helicopter/aheli_damaged_alarm1.wav")
    
    -- Отключаем поиск врагов в Think базы, чтобы она не пыталась взорвать нас снова
    self.IsProximityMine = false 

    -- Создаем последовательность ударов
    -- 1 секунда задержки, потом 5 ударов
    local startDelay = 1.0
    local interval = 0.3
    
    for i = 0, 4 do
        timer.Simple(startDelay + (i * interval), function()
            if IsValid(self) then
                self:DoShockWave()
            end
        end)
    end

    -- Удаляем мину только после всех ударов (через 1.0 + 5*0.3 + 0.5 запас)
    timer.Simple(startDelay + (5 * interval) + 0.5, function()
        if IsValid(self) then
            self:FinalRemove()
        end
    end)
end

-- 3. ФУНКЦИЯ УДАРА (Волна)
function ENT:DoShockWave()
    local pos = self:GetPos()
    local attacker = self:GetAttacker() -- Берет владельца из базы (Horde_Owner)

    -- Визуал: Screecher Blast (Синяя волна)
    local e = EffectData()
    e:SetOrigin(pos)
    e:SetNormal(Vector(0,0,1))
    e:SetScale(1)
    util.Effect("screecher_blast", e, true, true)
    
    -- Звук удара
    self:EmitSound("npc/zombie/claw_strike1.wav", 75, 100)
    
    -- Урон по площади
    local dmg = DamageInfo()
    dmg:SetAttacker(attacker)
    dmg:SetInflictor(self)
    dmg:SetDamageType(DMG_SHOCK)
    dmg:SetDamage(self.Damage)
    
    util.BlastDamageInfo(dmg, pos, self.DamageRadius)

    -- Эффекты Horde (Status Shock)
    local targets = ents.FindInSphere(pos, self.DamageRadius)
    for _, ent in pairs(targets) do
        if (ent:IsNPC() or ent:IsNextBot() or ent:IsPlayer()) and ent ~= self and ent ~= attacker then
            
            -- Проверяем разные версии API Horde
            if ent.Horde_AddDebuffBuildup and HORDE.Status_Shock then
                 ent:Horde_AddDebuffBuildup(HORDE.Status_Shock, 15, attacker)
            elseif ent.Horde_AddStatus then
                 ent:Horde_AddStatus("shock", 5)
            end
            
        end
    end
end

-- 4. ФИНАЛЬНОЕ УДАЛЕНИЕ
function ENT:FinalRemove()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("cball_explode", effectdata) -- Маленький "пук" в конце
    self:Remove()
end