AddCSLuaFile()

--[[ НАСТРОЙКИ ]]--
if CLIENT then
    SWEP.PrintName     = "Trap Placer"
    SWEP.Author        = "Optimized"
    SWEP.Category      = "Trap"
    SWEP.Slot          = 4
    SWEP.SlotPos       = 2
end

SWEP.Base          = "weapon_base"
SWEP.Spawnable     = true
SWEP.UseHands      = true

SWEP.ViewModel     = "models/weapons/c_slam.mdl"
SWEP.WorldModel    = "models/trap/trap.mdl"
SWEP.ViewModelFOV  = 60

SWEP.ThrowEntity   = "ent_trap" 

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic   = false
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo        = "none"

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    return true
end

function SWEP:Holster()
    if CLIENT and IsValid(self.ClientTrapModel) then
        self.ClientTrapModel:Remove()
        self.ClientTrapModel = nil
    end
    return true
end

function SWEP:OnRemove()
    self:Holster()
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    local tr = util.TraceLine({
        start  = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 120,
        filter = ply
    })

    if not tr.HitWorld then
        self:EmitSound("common/wpn_denyselect.wav")
        return
    end

    self:SetNextPrimaryFire(CurTime() + 1)
    self:SendWeaponAnim(ACT_VM_THROW)
    ply:SetAnimation(PLAYER_ATTACK1)

    timer.Simple(0.3, function()
        if not IsValid(self) or not IsValid(ply) or ply:GetActiveWeapon() ~= self then return end

        local tr2 = util.TraceLine({
            start  = ply:GetShootPos(),
            endpos = ply:GetShootPos() + ply:GetAimVector() * 120,
            filter = ply
        })

        if tr2.HitWorld then
            if SERVER then
                local ang = tr2.HitNormal:Angle()
                ang:RotateAroundAxis(ang:Right(), -90)

                local trap = ents.Create(self.ThrowEntity)
                if IsValid(trap) then
                    trap:SetPos(tr2.HitPos + tr2.HitNormal * 1)
                    trap:SetAngles(ang)
                    trap:SetOwner(ply)
                    trap:Spawn()
                    trap:Activate()

                    --[[ Фиксируем на месте ]]--
                    local phys = trap:GetPhysicsObject()
                    if IsValid(phys) then phys:EnableMotion(false) end

                    trap:EmitSound("buttons/lever6.wav")

                    --[[ Удаляем оружие из инвентаря ]]--
                    ply:StripWeapon(self:GetClass())
                end
            end
        else
            -- Если игрок дернулся и перестал смотреть на стену/пол -> возвращаем анимацию
            self:SendWeaponAnim(ACT_VM_DRAW)
        end
    end)
end

function SWEP:SecondaryAttack()
end

--[[ ВИЗУАЛ ]]--
if CLIENT then
    
    local VM_OFFSET = Vector(0, 5, 2) 
    local VM_ANGLE  = Angle(0, 180, 90)
    local VM_SCALE  = 1.5 --[[ Подбираем под масштаб энтити (2) ]]--

    local WM_OFFSET = Vector(4, -2, -2)
    local WM_ANGLE  = Angle(-20, 180, 0)
    local WM_SCALE  = 1.5

    --[[ 1. Скрываем SLAM ]]--
    function SWEP:PreDrawViewModel(vm, weapon, ply)
        render.SetBlend(0)
    end

    --[[ 2. Рисуем капкан от 1-го лица ]]--
    function SWEP:PostDrawViewModel(vm, weapon, ply)
        render.SetBlend(1)
        if not IsValid(vm) then return end

        if not IsValid(self.ClientTrapModel) then
            self.ClientTrapModel = ClientsideModel("models/trap/trap.mdl", RENDERGROUP_OPAQUE)
            self.ClientTrapModel:SetNoDraw(true)
            self.ClientTrapModel:SetModelScale(VM_SCALE)
        end

        local bone = vm:LookupBone("ValveBiped.Bip01_R_Hand")
        if not bone then return end

        local matrix = vm:GetBoneMatrix(bone)
        if not matrix then return end

        local pos, ang = LocalToWorld(VM_OFFSET, VM_ANGLE, matrix:GetTranslation(), matrix:GetAngles())

        self.ClientTrapModel:SetPos(pos)
        self.ClientTrapModel:SetAngles(ang)
        self.ClientTrapModel:DrawModel()
    end

    --[[ 3. Рисуем капкан от 3-го лица ]]--
    function SWEP:DrawWorldModel()
        local ply = self:GetOwner()
        if not IsValid(ply) then
            self:DrawModel()
            return
        end

        local bone = ply:LookupBone("ValveBiped.Bip01_R_Hand")
        if not bone then self:DrawModel() return end

        local matrix = ply:GetBoneMatrix(bone)
        if not matrix then self:DrawModel() return end

        local pos, ang = LocalToWorld(WM_OFFSET, WM_ANGLE, matrix:GetTranslation(), matrix:GetAngles())

        self:SetRenderOrigin(pos)
        self:SetRenderAngles(ang)

        local mat = Matrix()
        mat:Scale(Vector(WM_SCALE, WM_SCALE, WM_SCALE))
        self:EnableMatrix("RenderMultiply", mat)
        
        self:DrawModel()
        
        self:DisableMatrix("RenderMultiply")
    end
end