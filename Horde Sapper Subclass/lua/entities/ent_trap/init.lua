AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- =========================
-- Настройки
-- =========================
local TRAP_SIZE = 8 -- Радиус срабатывания (ширина коробки будет 50x50)
local TRAP_HEIGHT = 32 -- Высота зоны срабатывания
local STUN_DURATION = 5 -- Время стана

function ENT:Initialize()
    self:SetUseType(SIMPLE_USE)
    self:SetModel("models/trap/trap.mdl")
    self:SetModelScale(2, 0)
    
    -- Инициализируем физику
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    -- Делаем кастомный квадратный хитбокс для физики, чтобы она не каталась
    local mins = Vector(-TRAP_SIZE, -TRAP_SIZE, 0)
    local maxs = Vector(TRAP_SIZE, TRAP_SIZE, 10)
    self:SetCollisionBounds(mins, maxs)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    self.Triggered = false
end

-- =========================
-- Основной цикл (Вместо Touch)
-- =========================
function ENT:Think()
    -- Если ловушка уже сработала, ничего не ищем
    if self.Triggered then return end

    -- Определяем зону поиска (Квадратная коробка)
    local pos = self:GetPos()
    local mins = pos + Vector(-TRAP_SIZE, -TRAP_SIZE, 0)
    local maxs = pos + Vector(TRAP_SIZE, TRAP_SIZE, TRAP_HEIGHT)

    -- Ищем сущности внутри коробки
    -- FindInBox работает быстрее и надежнее, чем Touch
    local entities = ents.FindInBox(mins, maxs)

    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent:Health() > 0 then
            -- Проверяем, кто наступил (NPC, Игрок или NextBot)
            if (ent:IsNPC() or ent:IsPlayer() or ent:IsNextBot()) and ent ~= self then
                self:TriggerTrap(ent)
                return -- Прерываем цикл, одного врага достаточно
            end
        end
    end

    -- Проверяем 10 раз в секунду (оптимально для производительности)
    self:NextThink(CurTime() + 0.1)
    return true
end

-- =========================
-- Логика срабатывания (Вынесена отдельно)
-- =========================
function ENT:TriggerTrap(ent)
    if self.Triggered then return end
    self.Triggered = true

    -- Визуал
    self:SetModel("models/trap/trap_close.mdl")
    self:SetModelScale(2, 0)
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS) -- Проходим сквозь, чтобы не застрять
    self:EmitSound("trap/trap.mp3")

    -- СТАН
    if ent then
        if ent.Horde_AddStun then
            ent:Horde_AddStun(STUN_DURATION)
        elseif ent:IsNPC() then
            ent:SetSchedule(SCHED_NPC_FREEZE)
            timer.Simple(STUN_DURATION, function()
                if IsValid(ent) and not ent:IsPlayer() then ent:SetSchedule(SCHED_WAKE_ANGRY) end
            end)
        end
    end

    -- Удаление ловушки через время
    timer.Create("TrapRemove_" .. self:EntIndex(), STUN_DURATION, 1, function()
        if IsValid(self) then
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            util.Effect("cball_explode", effectdata)
            self:Remove()
        end
    end)
end

-- =========================
-- Урон по ловушке
-- =========================
function ENT:OnTakeDamage(dmg)
    if self.Triggered then return end
    
    -- Срабатывает впустую
    self:TriggerTrap(nil)
    
    -- Пустая ловушка исчезает быстрее (через 5 сек)
    local timerID = "TrapRemove_" .. self:EntIndex()
    if timer.Exists(timerID) then
        timer.Adjust(timerID, 5, 1, nil)
    end
end