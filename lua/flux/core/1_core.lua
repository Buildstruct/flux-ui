Flux.DrawColor = {r = 255, g = 255, b = 255, a = 255}
Flux.OutlineDrawColor = {r = 0, g = 0, b = 0, a = 255}

function Flux.ResetColor() Flux.RGB(255, 255, 255) end
function Flux.Color(ColorObject, ForceAlpha)
    if not ColorObject then Flux.ResetColor() return end
    if not ColorObject.r and not ColorObject.g and not ColorObject.b then return Flux.Warn("Attempted to call Flux.Color with a non color object. The ActiveColor was not changed.") end
    if not istable(Flux.DrawColor) then Flux.DrawColor = {r = ColorObject.r, g = ColorObject.g, b = ColorObject.b, a = ColorObject.a or 255} return end

    Flux.DrawColor.r = ColorObject.r
    Flux.DrawColor.g = ColorObject.g
    Flux.DrawColor.b = ColorObject.b
    Flux.DrawColor.a = ForceAlpha or ColorObject.a or 255

    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.RGB(R, G, B, A)
    if not istable(Flux.DrawColor) then Flux.DrawColor = {r = R or 255, g = G or 255, b = B or 255, a = A or 255} return end

    Flux.DrawColor.r = R or 255
    Flux.DrawColor.g = G or 255
    Flux.DrawColor.b = B or 255
    Flux.DrawColor.a = A or 255

    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.RGBOutline(R, G, B, A)
    if not istable(Flux.OutlineDrawColor) then Flux.OutlineDrawColor = {r = R or 255, g = G or 255, b = B or 255, a = A or 255} return end

    Flux.OutlineDrawColor.r = R or 255
    Flux.OutlineDrawColor.g = G or 255
    Flux.OutlineDrawColor.b = B or 255
    Flux.OutlineDrawColor.a = A or 255

    surface.SetTextColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.OutlineDrawColor.a)
    surface.SetDrawColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.OutlineDrawColor.a)
end