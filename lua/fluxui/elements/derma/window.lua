function FluxUI.Derma.Window(title, parent, color)
    local Window = vgui.Create("DFrame")
    Window:SetTitle("")
    Window:ShowCloseButton(false)
    Window:SetSize(128, 128)
    Window:Center()
    Window:MakePopup()
    Window.Title = istable(title) and title or {title}
    Window.Color = color or FluxUI.Colors.Frame.Outline

    function Window:SetSubtitle(...) self.Subtitle = {...} return self end

    local Close = FluxUI.Elements.CloseButton(Window)
    Window.Close = Close
    function Window:PerformLayout(w, h) Close:SetPos(w - Close:GetWide() - 8, 8) end
    function Window:Paint(w, h)
        FluxUI.Shapes.Frame(0, 0, w, h, FluxUI.Colors.Frame.Background, self.Color)
        surface.SetFont(FluxUI.Font(18, true))
        FluxUI.RGB(255, 255, 255, 255)
        FluxUI.Text.Outline(FluxUI.Text.Left, 12, 10, 1, unpack(self.Title))
        if self.Subtitle then
            surface.SetFont(FluxUI.Font(16, true))
            FluxUI.RGB(255, 255, 255, 255)
            FluxUI.Text.Outline(FluxUI.Text.Center, w / 2, 11, 1, unpack(self.Subtitle))
        end
    end

    function Window:PaintOver(w, h)
        FluxUI.Color(self.Color)
        FluxUI.Shapes.Border(0, 0, w, h, 4)
    end
    return Window
end