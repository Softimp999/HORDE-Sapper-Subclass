PERK.PrintName = "Loyality"
PERK.Description = [[
Your houndeyes begin to chase your traps.]]
PERK.Icon = "materials/perks/sapper/loyality.png"

PERK.Params = {}
PERK.Hooks = {}

PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "sapper_loyality" then
        local timerName = "Horde_Sapper_Loyality_" .. ply:SteamID()
        
        -- Таймер срабатывает раз в 2 секунды (чаще не надо, чтобы не ломать AI)
        timer.Create(timerName, 2, 0, function()
            if not IsValid(ply) then timer.Remove(timerName) return end
            
            -- 1. Ищем наших Хаундаев
            local minions = {}
            for _, ent in ipairs(ents.FindByClass("npc_vj_horde_houndeye")) do
                -- Проверяем Horde_Owner (твоя переменная) или NWEntity (стандарт VJ)
                if ent.Horde_Owner == ply or ent:GetNWEntity("HordeOwner") == ply then
                    table.insert(minions, ent)
                end
            end
            
            if #minions == 0 then return end -- Нет миньонов - отдыхаем

            -- 2. Ищем мины (ЯВНО перечисляем классы, звездочка не работает!)
            local mineClasses = {
                "ent_sticky_mine",
                "ent_shock_mine",
                "ent_combine_tripmine",
                "ent_trap"
            }
            
            local myMines = {}
            
            for _, class in ipairs(mineClasses) do
                for _, ent in ipairs(ents.FindByClass(class)) do
                    -- Проверяем, что мина принадлежит игроку
                    if IsValid(ent) and (ent.Horde_Owner == ply or ent:GetOwner() == ply) then
                        table.insert(myMines, ent)
                    end
                end
            end
            
            -- ДЕБАГ (Если видишь это в консоли - значит мины нашлись)
            -- print("Sapper Debug: Minions: " .. #minions .. " | Mines: " .. #myMines)
            
            -- Если мин нет, пусть бегут за игроком (или стоят)
            if #myMines == 0 then return end

            -- 3. Раздаем команды
            for _, npc in ipairs(minions) do
                if not IsValid(npc) or npc:Health() <= 0 then continue end
                
                -- Если NPC уже дерется в ближнем бою, не мешаем ему
                if npc.VJ_IsBeingControlled then continue end
                -- if npc:IsBusy() then continue end -- Можно раскомментировать, если не хочешь отвлекать от боя

                -- Ищем ближайшую мину
                local closestMine = nil
                local minDist = 99999999
                local npcPos = npc:GetPos()
                
                for _, mine in ipairs(myMines) do
                    local dist = npcPos:DistToSqr(mine:GetPos())
                    if dist < minDist then
                        minDist = dist
                        closestMine = mine
                    end
                end

                if closestMine then
                    local dist = npcPos:Distance(closestMine:GetPos())
                    
                    -- Если до мины далеко (> 200 юнитов) -> Бежать к ней
                    if dist > 200 then
                        -- Чтобы не спамить команду "беги", проверяем, не бежим ли мы уже туда
                        if npc.LastLoyaltyTarget ~= closestMine or not npc:IsMoving() then
                            
                            -- VJ Base логика движения
                            npc:SetLastPosition(closestMine:GetPos())
                            npc:SetSchedule(SCHED_FORCED_GO_RUN)
                            
                            npc.LastLoyaltyTarget = closestMine
                            -- print("Sending Houndeye to mine!")
                        end
                    else
                        -- Мы пришли к мине. Можно включить Idle, чтобы он охранял точку
                        if npc:IsMoving() then
                            npc:SetSchedule(SCHED_IDLE_STAND)
                            npc:StopMoving()
                        end
                    end
                end
            end
        end)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "sapper_loyality" then
        timer.Remove("Horde_Sapper_Loyality_" .. ply:SteamID())
    end
end