local Elements = Flux.Elements

Elements.Tooltip = {
    Left = function(x, y, ...)
        surface.SetFont("DebugOverlay")
        local w, h = Flux.Text.GetTextSize(...)
        Flux.Shapes.Frame(x, y - h / 2 - 3, w + 20, h + 15, nil, Flux.DrawColor, false, 1)
        Flux.RGB(255, 255, 255, Flux.DrawColor.a)
        Flux.Text.Outline(Flux.Text.Left, x + 10, y - (h / 2 - 3) + 3, 1, ...)
    end,
    Right = function(x, y, ...)
        surface.SetFont("DebugOverlay")
        local w, h = Flux.Text.GetTextSize(...)
        Flux.Shapes.Frame(x - w, y - h / 2 - 3, w + 15, h + 15, nil, Flux.DrawColor, false, 1)
        Flux.RGB(255, 255, 255, Flux.DrawColor.a)
        Flux.Text.Outline(Flux.Text.Left, x - w + 10, y - (h / 2 - 3) + 3, 1, ...)
    end
}