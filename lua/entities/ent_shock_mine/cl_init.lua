include('shared.lua')

function ENT:Initialize()
    self:SetMaterial("models/player/shared/ice_player")
end

function ENT:Draw()
    self:DrawModel()
end

-- ==========================================
-- Желтая обводка (Halo)
-- ==========================================
hook.Add("PreDrawHalos", "Horde_ShockMine_Halo", function()
    -- Находим все наши мины на карте
    local mines = ents.FindByClass("ent_shock_mine")
    
    if #mines > 0 then
        halo.Add(
            mines,                      -- Список энтити
            Color(255, 255, 0),         -- Цвет (Желтый)
            2,                          -- Толщина по X
            2,                          -- Толщина по Y
            1,                          -- Количество проходов (размытие)
            true,                       -- Видно сквозь стены (Additive) - ставим true, чтобы светилось
            false                       -- Игнорировать Z (видеть сквозь стены) - ставим false, чтобы не видеть через всю карту
        )
    end
end)