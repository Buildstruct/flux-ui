local Derma = Flux.Derma
function Derma.Button(parent, callback, ...)
    local FluxButton = vgui.Create("DButton", parent)
    FluxButton.Color = Flux.Colors.ButtonBackground
    FluxButton.OutlineColor = Flux.Colors.ButtonOutline
    FluxButton.Content = {...}
    FluxButton.ContentPadding = 14
    FluxButton.Font = "DebugOverlay"
    FluxButton:SetText("")

    function FluxButton:DoClick() callback(self) end
    function FluxButton:SetContentPadding(value) self.ContentPadding = value return self end
    function FluxButton:SetColor(value) self.Color = value return self end
    function FluxButton:SetFont(value) self.Font = value return self end
    function FluxButton:SetIcon(value) self.Icon = isstring(value) and Material(value) or value return self end
    function FluxButton:SetOutlineColor(value) self.OutlineColor = value return self end
    function FluxButton:SetText(...) 
        self.Content = {...}
        self:InvalidateLayout()
        return self 
    end

    function FluxButton:PerformLayout()
        surface.SetFont(self.Font)
        local TextW, TextH = Flux.Text.GetTextSize(unpack(self.Content))
        self:SetWide(TextW + self.ContentPadding + (self.Icon and self:GetTall()-8 + 4 or 0))
        self.TextH = TextH
    end

    function FluxButton:Paint(w, h)
        Flux.Blur.Panel(self)
        Flux.Color(self.Color)
        Flux.Shapes.Rectangle(0, 0, w, h)
        Flux.Color(self.OutlineColor)
        Flux.Shapes.Border(0, 0, w, h, 2)

        local ButtonHovered = self:IsHovered()
        Flux.Shapes.Shade(0, 0, w, h, ButtonHovered and 240 or 165)

        Flux.RGB(255, 255, 255, ButtonHovered and 255 or 190)
        surface.SetFont(self.Font)
        Flux.Text.Left((self.ContentPadding/2) + (self.Icon and h-8 + 4 or 0), (h/2) - self.TextH/2, unpack(self.Content))

        if self.Icon then
            surface.SetDrawColor(255, 255, 255, ButtonHovered and 245 or 190)
            surface.SetMaterial(self.Icon)
            surface.DrawTexturedRect(6, h/2 - (h-8)/2, h - 8, h - 8)
        end
    end

    table.insert(Flux.ActiveElements, FluxButton)
    return FluxButton
end