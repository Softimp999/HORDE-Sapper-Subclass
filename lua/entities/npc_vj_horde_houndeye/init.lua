AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/hl2beta/houndeye.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 400
ENT.SightDistance = 8000
ENT.HullType = HULL_TINY
ENT.PlayerFriendly = true
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY", "CLASS_COMBINE"} -- NPCs with the same class with be allied to each other
ENT.BloodColor = "Yellow" -- The blood type, this will determine what it should use (decal, particle, etc.)
ENT.Immune_Sonic = true -- Immune to sonic damage
ENT.Immune_Electricity = true
ENT.Immune_AcidPoisonRadiation = true -- Immune to Acid, Poison and Radiation
ENT.Immune_Blast = true
ENT.Horde_Immune_Status_All = true

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {ACT_RANGE_ATTACK1} -- Melee Attack Animations
ENT.MeleeAttackDistance = 194 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 300 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 2.15 -- This counted in seconds | This calculates the time until it hits something
ENT.MeleeAttackDamage = 75
ENT.MeleeAttackDamageType = DMG_SONIC -- Type of Damage
ENT.MeleeAttackDSPSoundType = 34 -- What type of DSP effect? | Search online for the types
ENT.MeleeAttackDSPSoundUseDamage = false -- Should it only do the DSP effect if gets damaged x or greater amount
ENT.DisableDefaultMeleeAttackDamageCode = true -- Disables the default melee attack damage code

ENT.HasMeleeAttackKnockBack = true -- If true, it will cause a knockback to its enemy
ENT.MeleeAttackKnockBack_Forward1 = 512 -- How far it will push you forward | First in math.random
ENT.MeleeAttackKnockBack_Forward2 = 768 -- How far it will push you forward | Second in math.random
ENT.MeleeAttackKnockBack_Up1 = 20 -- How far it will push you up | First in math.random
ENT.MeleeAttackKnockBack_Up2 = 20 -- How far it will push you up | Second in math.random
ENT.MeleeAttackKnockBack_Right1 = 0 -- How far it will push you right | First in math.random
ENT.MeleeAttackKnockBack_Right2 = 0 

ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {ACT_DIESIMPLE} -- Death Animations
ENT.DeathAnimationChance = 2 -- Put 1 if you want it to play the animation all the time
ENT.PushProps = false -- Should it push props when trying to move?
ENT.AttackProps = false -- Should it attack props when trying to move?
ENT.FootStepTimeRun = 0.3 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 1 -- Next foot step sound when it is walking
ENT.AnimTbl_IdleStand = {ACT_IDLE, "leaderlook"}
	-- ====== Flinching Code ====== --
ENT.CanFlinch = 2 -- 0 = Don't flinch | 1 = Flinch at any damage | 2 = Flinch only from certain damages
ENT.FlinchChance = 1 -- Chance of it flinching from 1 to x | 1 will make it always flinch
ENT.AnimTbl_Flinch = {ACT_SMALL_FLINCH} -- If it uses normal based animation, use this
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"hl2beta_houndeye/he_step1.wav","hl2beta_houndeye/he_step2.wav","hl2beta_houndeye/he_step3.wav"}
ENT.SoundTbl_Idle = {"hl2beta_houndeye/he_idle1.wav","hl2beta_houndeye/he_idle2.wav","hl2beta_houndeye/he_idle3.wav","hl2beta_houndeye/he_idle4.wav"}
ENT.SoundTbl_Alert = {"hl2beta_houndeye/he_alert1.wav","hl2beta_houndeye/he_alert2.wav","hl2beta_houndeye/he_alert3.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"hl2beta_houndeye/he_attack1.wav","hl2beta_houndeye/he_attack2.wav"}
//ENT.SoundTbl_MeleeAttack = {"hl2beta_houndeye/he_attack1.wav","hl2beta_houndeye/he_attack2.wav"}
ENT.SoundTbl_Pain = {"hl2beta_houndeye/he_pain1.wav","hl2beta_houndeye/he_pain2.wav","hl2beta_houndeye/he_pain3.wav","hl2beta_houndeye/he_pain4.wav","hl2beta_houndeye/he_pain5.wav"}
ENT.SoundTbl_Death = {"hl2beta_houndeye/he_die1.wav","hl2beta_houndeye/he_die2.wav","hl2beta_houndeye/he_die3.wav"}

ENT.MainSoundPitch = 100
ENT.MainSoundPitchStatic = true
ENT.GeneralSoundPitch1 = 100
ENT.GeneralSoundPitch2 = 100
ENT.IdleSoundPitch1 = 100
ENT.IdleSoundPitch2 = 100
ENT.AlertSoundPitch1 = 100
ENT.AlertSoundPitch2 = 100
ENT.EnemyTalkSoundPitch1 = 100
ENT.EnemyTalkSoundPitch2 = 100
ENT.BeforeMeleeAttackSoundPitch1 = 100
ENT.BeforeMeleeAttackSoundPitch2 = 100
ENT.MeleeAttackSoundPitch1 = 100
ENT.MeleeAttackSoundPitch2 = 100
ENT.ExtraMeleeSoundPitch1 = 100
ENT.ExtraMeleeSoundPitch2 = 100
ENT.MeleeAttackMissSoundPitch1 = 100
ENT.MeleeAttackMissSoundPitch2 = 100
ENT.PainSoundPitch1 = 100
ENT.PainSoundPitch2 = 100
ENT.DeathSoundPitch1 = 100
ENT.DeathSoundPitch2 = 100
ENT.GrenadeSoundPitch1 = 100
ENT.GrenadeSoundPitch2 = 100
ENT.SawPlayerPitch1 = 100
ENT.SawPlayerPitch2 = 100
ENT.StupidPlayerPitch1 = 100
ENT.StupidPlayerPitch2 = 100
ENT.FollowPlayerPitch1 = 100
ENT.FollowPlayerPitch2 = 100
ENT.UnFollowPlayerPitch1 = 100
ENT.UnFollowPlayerPitch2 = 100
ENT.BecomeEnemyToPlayerPitch1 = 100
ENT.BecomeEnemyToPlayerPitch2 = 100
ENT.GrenadeAttackSoundPitch1 = 100
ENT.GrenadeAttackSoundPitch2 = 100
ENT.OnGrenadeSightSoundPitch1 = 100
ENT.OnGrenadeSightSoundPitch2 = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
    self:SetCollisionBounds(Vector(16, 16, 35), Vector(-16, -16, 0))

    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) then
            self:SetNWEntity("HordeOwner", owner)
            self.HordeOwner = owner
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAlert()
	if self.VJ_IsBeingControlled == true then return end
	self:VJ_ACT_PLAYACTIVITY({"madidle","madidle3"},true,1,true) // ACT_IDLE_ANGRY
	/*timer.Simple(1,function() if self:IsValid() then
		//self:TaskComplete()
		self.NextChaseTime = CurTime()
		self:DoChaseAnimation()
		end
	end)*/
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	if IsValid(self:GetEnemy()) then
		self.AnimTbl_IdleStand = {ACT_IDLE_ANGRY}
		if self:IsMoving() then
			if timer.TimeLeft( "hunt"..self:EntIndex() ) == nil and math.random() < 0.5 then
				VJ_EmitSound(self,"hl2beta_houndeye/he_hunt"..math.random(1,4)..".wav",75,math.random(95,105))
				timer.Create( "hunt"..self:EntIndex(), 0.5, 1, function() end )	
			end
		end
	else
		self.AnimTbl_IdleStand = {ACT_IDLE,"leaderlook"}
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnMeleeAttack_BeforeChecks()
	effects.BeamRingPoint(self:GetPos() + Vector(0,0,16), 0.3, 2, 400, 16, 0, Color(188, 220, 255), {material="sprites/vj_bms_shockwave", framerate=20})
	effects.BeamRingPoint(self:GetPos() + Vector(0,0,16), 0.3, 2, 200, 16, 0, Color(188, 220, 255), {material="sprites/vj_bms_shockwave", framerate=20})
	
	if self.HasSounds == true && GetConVarNumber("vj_npc_sd_meleeattack") == 0 then
		VJ_EmitSound(self,"hl2beta_houndeye/he_blast"..math.random(1,3)..".wav",100,math.random(95,105))
	end
	
	util.VJ_SphereDamage(self, self, self:GetPos() + Vector(0,0,16), 350, math.random(75,150), self.MeleeAttackDamageType, true, true, {DisableVisibilityCheck=true, Force=80})
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomDeathAnimationCode(dmginfo,hitgroup)
	self:SetLocalPos(Vector(self:GetPos().x,self:GetPos().y,self:GetPos().z +5))
end
---------------------------------------------------------------------------------------------------------------------------------------------

/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------*/---------
VJ.AddNPC("Houndeye","npc_vj_horde_houndeye", "HORDE: Sapper")
ENT.Horde_TurretMinion = true