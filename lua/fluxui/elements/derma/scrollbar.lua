local function DrawArrow(hovered, w, h)
    local DrawColor = hovered and 255 or 200
    surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
    surface.DrawTexturedRect(0, 0, w, h)
end

function FluxUI.Derma.Scrollbar(sb, wide)
    sb = sb.GetVBar and sb:GetVBar() or sb
    sb:SetWide(width or 10)
    sb.Paint = nil
    function sb.btnUp:Paint(w, h)
        surface.SetMaterial(FluxUI.Materials.Scrollbar.Up)
        DrawArrow(self:IsHovered(), w, h)
    end
    function sb.btnDown:Paint(w, h)
        surface.SetMaterial(FluxUI.Materials.Scrollbar.Down)
        DrawArrow(self:IsHovered(), w, h)
    end
    function sb.btnGrip:Paint(w, h)
        FluxUI.Color(FluxUI.Colors.Scrollbar.Background)
        FluxUI.Shapes.ShadedRect(0, 0, w, h)
        FluxUI.Color(FluxUI.Colors.Scrollbar.Outline)
        FluxUI.Shapes.Border(0, 0, w, h, 2)
    end
end