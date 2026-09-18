--[[
function Flux.Shapes.Scrollbar(scrollbar)
    scrollbar:SetWide(10)
    function scrollbar:Paint() end
    function scrollbar.btnUp:Paint(w, h)
        surface.SetMaterial(Flux.Materials.ScrollbarUp)
        local DrawColor = self:IsHovered() and 255 or 200
        surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    function scrollbar.btnDown:Paint(w, h)
        surface.SetMaterial(Flux.Materials.ScrollbarDown)
        local DrawColor = self:IsHovered() and 255 or 200
        surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    function scrollbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        Flux.Shapes.Rectangle(1, 1, w-2, h-2)
        surface.SetDrawColor(64, 64, 64, 200)
        Shapes.ShadedRect(2, 2, w - 4, h - 4)
    end
end]]