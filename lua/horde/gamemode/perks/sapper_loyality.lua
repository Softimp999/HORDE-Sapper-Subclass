PERK.PrintName = "Loyality"
PERK.Description = [[
Your houndeyes begin to chase your traps.]]
PERK.Icon = "materials/perks/sapper/loyality.png"

PERK.Params = {}
PERK.Hooks = {}

local HOUNDEYE_CLASS = "npc_vj_horde_houndeye"
local MINE_CLASS = "ent_mine_base"
local THINK_INTERVAL = 2

local nextThink = 0

PERK.Hooks.Think = function()
    if CurTime() < nextThink then return end
    nextThink = CurTime() + THINK_INTERVAL

    for _, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end
        if not ply:Horde_GetPerk("sapper_loyality") then continue end

        -- собираем мины игрока
        local mines = {}
        for _, mine in ipairs(ents.FindByClass(MINE_CLASS)) do
            if mine:GetNWEntity("HordeOwner") == ply then
                mines[#mines + 1] = mine
            end
        end
        if #mines == 0 then continue end

        -- houndeye игрока
        for _, npc in ipairs(ents.FindByClass(HOUNDEYE_CLASS)) do
            if npc:GetNWEntity("HordeOwner") ~= ply then continue end
            if npc.Dead then continue end

            local enemy = npc:GetEnemy()
            if IsValid(enemy) and enemy:GetClass() == MINE_CLASS then
                continue
            end

            local npcPos = npc:GetPos()
            local nearestMine
            local nearestDist = math.huge

            for _, mine in ipairs(mines) do
                if not IsValid(mine) then continue end
                local dist = npcPos:DistToSqr(mine:GetPos())
                if dist < nearestDist then
                    nearestDist = dist
                    nearestMine = mine
                end
            end

            if IsValid(nearestMine) then
                npc:SetEnemy(nearestMine, true)
                npc:VJ_TASK_GOTO_TARGET("TASK_RUN_PATH")
                npc.LoyalityTarget = nearestMine
            end
        end
    end
end
