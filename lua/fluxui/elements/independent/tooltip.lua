FluxUI.Elements.Tooltip = {
    Left = function(x, y, ...)
        surface.SetFont("DebugOverlay")
        local w, h = FluxUI.Text.GetTextSize(...)
        FluxUI.Shapes.Frame(x, y - h / 2 - 3, w + 20, h + 15, nil, FluxUI.DrawColor, false, 1)
        FluxUI.RGB(255, 255, 255, FluxUI.DrawColor.a)
        FluxUI.Text.Outline(FluxUI.Text.Left, x + 10, y - (h / 2 - 3) + 3, 1, ...)
    end,
    Right = function(x, y, ...)
        surface.SetFont("DebugOverlay")
        local w, h = FluxUI.Text.GetTextSize(...)
        FluxUI.Shapes.Frame(x - w, y - h / 2 - 3, w + 15, h + 15, nil, FluxUI.DrawColor, false, 1)
        FluxUI.RGB(255, 255, 255, FluxUI.DrawColor.a)
        FluxUI.Text.Outline(FluxUI.Text.Left, x - w + 10, y - (h / 2 - 3) + 3, 1, ...)
    end
}