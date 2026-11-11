local Elements = FluxUI.Elements
function Elements.CloseButton(parent, close)
    local CloseButton = vgui.Create("DButton", parent)
    CloseButton.Font = "Trebuchet18"
    CloseButton:SetSize(20, 20)
    CloseButton:SetPos(parent:GetWide() - CloseButton:GetWide() - 10, 10)
    CloseButton:SetText("")
    function CloseButton:DoClick()
        if close and IsValid(close) then close:Remove() return end
        if IsValid(parent) then
            parent:Remove()
        end
    end

    function CloseButton:Paint(w, h)
        self.Lerp = (self:IsHovered() and input.IsMouseDown(MOUSE_FIRST)) and 0.3 or math.Approach(self.Lerp or 0, self:IsHovered() and 1 or 0, RealFrameTime() * 10)
        FluxUI.RGB(200, 32, 32, 64)
        FluxUI.Shapes.Circle(w / 2, h / 2, h / 2 * math.ease.OutExpo(self.Lerp))
        FluxUI.RGB(0, 0, 0, 128)
        FluxUI.Shapes.Circle(w / 2, h / 2, (h / 2 * math.ease.OutExpo(self.Lerp)) - 4)


        FluxUI.RGB(255, 100 * self.Lerp, 100 * self.Lerp, 255)
        surface.SetFont(self.Font)
        FluxUI.Text.Outline(FluxUI.Text.Center, w / 2, h / 2 - 8, 1, "X")
    end

    table.insert(FluxUI.ActiveElements, CloseButton)
    return CloseButton
end