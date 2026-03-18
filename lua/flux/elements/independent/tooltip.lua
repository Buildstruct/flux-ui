local Elements = Flux.Elements
function Elements.Tooltip(text, x, y, center)
    surface.SetFont("DebugOverlay")
    local w, h = surface.GetTextSize(text)
    Flux.Shapes.Frame(x, y - h/2 - 3, w + 15, h + 6, nil, nil, nil, 0.95 )
    surface.SetTextColor(0, 0, 0, Flux.DrawColor.a)
    surface.SetTextPos(x + 15/2 + 1, y - h/2 + 2)
    surface.DrawText(text)
    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
    surface.SetTextPos(x + 15/2, y - h/2 + 1)
    surface.DrawText(text)
end