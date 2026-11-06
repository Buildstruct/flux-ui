local Derma = Flux.Derma
function Derma.Window(title, parent, color)
    local Window = vgui.Create("DFrame")
    Window:SetTitle("")
    Window:ShowCloseButton(false)
    Window:SetSize(128, 128)
    Window:Center()
    Window:MakePopup()
    Window.Title = istable(title) and title or {title}
    Window.Color = color or Flux.Colors.Outline

    function Window:SetSubtitle(...) self.Subtitle = {...} return self end

    -- Close
    local Close = Flux.Elements.CloseButton(Window)
    Window.Close = Close
    function Window:PerformLayout(w, h) Close:SetPos(w - Close:GetWide() - 8, 8) end

    -- Paint
    function Window:Paint(w, h)
        Flux.Blur.Panel(self)
        Flux.Shapes.Frame(0, 0, w, h, Flux.Colors.Background, self.Color, false)
        surface.SetFont(Flux.Font(18, true))
        Flux.RGB(255, 255, 255, 255)
        Flux.Text.Outline(Flux.Text.Left, 12, 10, 1, unpack(self.Title))
        if self.Subtitle then
            surface.SetFont(Flux.Font(16, true))
            Flux.RGB(255, 255, 255, 255)
            Flux.Text.Outline(Flux.Text.Center, w / 2, 11, 1, unpack(self.Subtitle))
        end
    end

    function Window:PaintOver(w, h)
        Flux.Color(self.Color)
        Flux.Shapes.Border(0, 0, w, h, 4)
    end
    return Window
end