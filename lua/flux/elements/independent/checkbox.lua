local Elements = Flux.Elements
local tick = Material("icon16/tick.png")

function Elements.Checkbox(parent, callback, default)
    local Checkbox = vgui.Create("DButton", parent)
    Checkbox:SetSize(24, 24)
    Checkbox:SetText("")
    Checkbox.Value = default and tobool(default) or false
    function Checkbox:DoClick()
        self.Value = not self.Value
        if not callback then return end
        callback(self.Value)
    end

    function Checkbox:Paint(w, h)
        self.Lerp = math.Approach(self.Lerp or (self.Value and 1 or 0), self.Value and 1 or 0, RealFrameTime() * 13)
        
        Flux.Color(Flux.Colors.ButtonBackground, 185)
        Flux.Shapes.ShadedRect(0, 0, w, h)
        Flux.Color(Flux.Colors.ButtonOutline)
        Flux.Shapes.Border(0, 0, w, h, 2)

        if self:IsHovered() then
            Flux.RGB(255, 255, 255, input.IsMouseDown(MOUSE_FIRST) and 28 or 8)
            Flux.Shapes.Rectangle(2, 2, w - 4, h - 4)
        end

        local offset = self:IsHovered() and input.IsMouseDown(MOUSE_FIRST) and 2 or 0
        surface.SetDrawColor(255, 255, 255, 255 * self.Lerp)
        surface.SetMaterial(tick)
        surface.DrawTexturedRect(5 + offset/2, 5 + offset/2, h-10-offset, h-10-offset)


    end

    table.insert(Flux.ActiveElements, Checkbox)
    return Checkbox
end