local Gradient = {}
FluxUI.Gradient = Gradient

function Gradient.Down(x, y, w, h)
    surface.SetMaterial(FluxUI.Materials.Gradient.Up)
    surface.DrawTexturedRect(x, y, w, h)
end
function Gradient.Up(x, y, w, h)
    surface.SetMaterial(FluxUI.Materials.Gradient.Down)
    surface.DrawTexturedRect(x, y, w, h)
end
function Gradient.Right(x, y, w, h)
    surface.SetMaterial(FluxUI.Materials.Gradient.Left)
    surface.DrawTexturedRect(x, y, w, h)
end

function Gradient.Left(x, y, w, h)
    surface.SetMaterial(FluxUI.Materials.Gradient.Right)
    surface.DrawTexturedRect(x, y, w, h)
end