local Derma = Flux.Derma
local Utility = Flux.Utility
function Derma.Button(parent, callback, ...)
    local FluxButton = vgui.Create("DButton", parent)
    FluxButton.Color = Flux.Colors.ButtonBackground
    FluxButton.OutlineColor = Flux.Colors.ButtonOutline
    FluxButton.TextColor = Flux.Colors.White
    FluxButton.Content = {...}
    FluxButton.ContentPadding = 14
    FluxButton.DoLayout = false
    FluxButton.Font = "DebugOverlay"
    FluxButton.Flux = true
    FluxButton:SetText("")

    function FluxButton:DoClick() if callback then callback(self) end end
    function FluxButton:SetAutoLayout(value) self.DoLayout = value return self end
    function FluxButton:SetContentPadding(value) self.ContentPadding = value return self end
    function FluxButton:SetColor(value) self.Color = value return self end
    function FluxButton:SetFont(value) self.Font = value return self end
    function FluxButton:SetIcon(value) self.Icon = isstring(value) and Material(value) or value return self end
    function FluxButton:SetOutlineColor(value) self.OutlineColor = value return self end
    function FluxButton:SetTextColor(value) self.TextColor = value return self end
    function FluxButton:SetText(...) 
        self.Content = {...}
        self:InvalidateLayout(true)
        return self 
    end

    function FluxButton:PerformLayout()
        surface.SetFont(self.Font)
        local TextW, TextH = Flux.Text.GetTextSize(unpack(self.Content))
        if self.DoLayout or not self.Ready then 
            self:SetWide(TextW + self.ContentPadding + (self.Icon and self:GetTall()-12 + 8 or 0))
        end
        self.TextH = TextH
        self.TextW = TextW
    end
    FluxButton:PerformLayout()
    FluxButton.Ready = true

    function FluxButton:Paint(w, h)
        Flux.Blur.Panel(self)
        Flux.Color(Utility.ConvertRainbow(self.Color))
        Flux.Shapes.Rectangle(0, 0, w, h)
        Flux.Color(Utility.ConvertRainbow(self.OutlineColor))
        Flux.Shapes.Border(0, 0, w, h, 2)

        local ButtonHovered = self:IsHovered()
        Flux.Shapes.Shade(0, 0, w, h, ButtonHovered and 240 or 165)

        Flux.Color(Utility.ConvertRainbow(self.TextColor), ButtonHovered and 255 or 190)
        surface.SetFont(self.Font)
        Flux.Text.Center((w/2) + (self.Icon and (h-12)/2 + 3 or 0), (h/2) - self.TextH/2, unpack(self.Content))
        if self.Icon then
            surface.SetDrawColor(255, 255, 255, ButtonHovered and 245 or 190)
            surface.SetMaterial(self.Icon)
            
            local OnlyIcon = self.Content and self.Content[1] == "" and not self.Content[2]
            if OnlyIcon then
                surface.DrawTexturedRect(w/2 - (h-12)/2, h/2 - (h-12)/2, h - 12, h - 12)
            else
                surface.DrawTexturedRect(w/2 - self.TextW/2 - (h-12)/2 - 3, h/2 - (h-12)/2, h - 12, h - 12)
            end
        end
    end

    table.insert(Flux.ActiveElements, FluxButton)
    return FluxButton
end