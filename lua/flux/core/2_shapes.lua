local Shapes = {}
Flux.Shapes = Shapes

Flux.Shapes.Rectangle = surface.DrawRect
Flux.Shapes.Border = surface.DrawOutlinedRect
function Flux.Shapes.Frame(x, y, w, h, BackgroundColor, OutlineColor, Blur, AlphaMultiplier)
    BackgroundColor = BackgroundColor or Flux.Colors.Background
    OutlineColor = OutlineColor or Flux.Colors.Outline
    if Blur then Flux.Blur.Section(x, y, w, h) end
    
    surface.SetDrawColor(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, AlphaMultiplier and BackgroundColor.a * AlphaMultiplier or BackgroundColor.a)
    Flux.Shapes.Rectangle(x, y, w, h)
    Flux.Shapes.Shade(x, y, w, h)

    local OutlineAlpha = AlphaMultiplier and OutlineColor.a * AlphaMultiplier or OutlineColor.a
    surface.SetDrawColor(OutlineColor.r, OutlineColor.g, OutlineColor.b, OutlineAlpha)
    Flux.Shapes.Border(x, y, w, h, 2)
    surface.SetDrawColor(OutlineColor.r - 15, OutlineColor.g - 15, OutlineColor.b - 15, OutlineAlpha)
    Flux.Shapes.Border(x + 2, y + 2, w - 4, h - 4, 2)
    
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.Shade(x, y, w, h, alpha)
    surface.SetDrawColor(0, 0, 0, alpha or 180)
    surface.SetMaterial(Flux.Materials.GradientDown)
    surface.DrawTexturedRect(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientUp)
    surface.DrawTexturedRect(x, y, w, h/6)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.ShadedRect(x, y, w, h)
    Flux.Shapes.Rectangle(x, y, w, h)
    Flux.Shapes.Shade(x, y, w, h)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end