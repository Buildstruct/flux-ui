local Shapes = {}
FluxUI.Shapes = Shapes

-- Console Variables
local ShadedBorderConvar = CreateClientConVar("fluxui_shadedborders", "1", true, false, "Enable/Disable shading on borders", 0, 1)
Shapes.BordersShaded = ShadedBorderConvar:GetBool()
cvars.AddChangeCallback("fluxui_shadedborders", function(_, old, new)
    Shapes.BordersShaded = tonumber(new) == 1
end, "fluxui_shadedborders_toggle")

-- Rectangles
Shapes.Rectangle = surface.DrawRect

-- Special Rectangles
function Shapes.RoundedRect(x, y, w, h, rounding, topLeft, topRight, bottomLeft, bottomRight)
    if rounding <= 0 then return Flux.Shapes.Rectangle(x, y, w, h) end

    local calcRoundness = math.min(ScreenScale(rounding), math.floor(w / 2), math.floor(h / 2))
    Shapes.Rectangle(x + calcRoundness, y, w - (calcRoundness * 2), h)
    Shapes.Rectangle(x, y + calcRoundness, calcRoundness, h - (calcRoundness * 2))
    Shapes.Rectangle(x + (w - calcRoundness), y + calcRoundness, calcRoundness, h - (calcRoundness * 2))
    surface.SetMaterial(FluxUI.Materials.Corner["Size" .. tostring((calcRoundness > 64 and 512 or calcRoundness > 32 and 64 or calcRoundness > 16 and 32 or calcRoundness > 8 and 16) or 8)])
    -- i don't like doing one-liner codes but i'd rather look at this than 50 lines worth of if statements or worse condensed if statements
    do (topLeft == false and Shapes.Rectangle or surface.DrawTexturedRectUV)(x, y, calcRoundness, calcRoundness, 0, 0, 1, 1) end
    do (topRight == false and Shapes.Rectangle or surface.DrawTexturedRectUV)(x + (w - calcRoundness), y, calcRoundness, calcRoundness, 1, 0, 0, 1) end
    do (bottomLeft == false and Shapes.Rectangle or surface.DrawTexturedRectUV)(x, y + (h - calcRoundness), calcRoundness, calcRoundness, 0, 1, 1, 0) end
    do (bottomRight == false and Shapes.Rectangle or surface.DrawTexturedRectUV)(x + (w - calcRoundness), y + (h - calcRoundness), calcRoundness, calcRoundness, 1, 1, 0, 0) end
end
function Shapes.Frame(x, y, w, h, backgroundCol, outlineCol, alphaMult)
    local oldDrawColor = surface.GetDrawColor()
    backgroundCol = backgroundCol or FluxUI.Colors.Frame.Background
    outlineCol = outlineCol or FluxUI.Colors.Frame.Outline
    alphaMult = alphaMult or 1
    surface.SetDrawColor(backgroundCol.r, backgroundCol.g, backgroundCol.b, backgroundCol.a * alphaMult)
    Shapes.Rectangle(x, y, w, h)
    Shapes.Shade(x, y, w, h, 180 * alphaMult)
    surface.SetDrawColor(outlineCol.r - 15, outlineCol.g - 15, outlineCol.b - 15, outlineCol.a * alphaMult)
    Shapes.Border(x, y, w, h, 4)
    surface.SetDrawColor(outlineCol.r, outlineCol.g, outlineCol.b, outlineCol.a * alphaMult)
    Shapes.Border(x, y, w, h, 2)
    surface.SetDrawColor(oldDrawColor.r, oldDrawColor.g, oldDrawColor.b, oldDrawColor.a)
end

-- Shading
function Shapes.Shade(x, y, w, h, alpha)
    surface.SetDrawColor(0, 0, 0, alpha or 180)
    surface.SetMaterial(FluxUI.Materials.Gradient.Down)
    surface.DrawTexturedRect(x, y + (h / 2), w, h / 2)
    surface.SetMaterial(FluxUI.Materials.Gradient.Up)
    surface.DrawTexturedRect(x, y, w, h / 3)
    surface.SetDrawColor(FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a)
end

function Shapes.ShadedRect(x, y, w, h, ignoreAlpha)
    Shapes.Rectangle(x, y, w, h)
    Shapes.Shade(x, y, w, h, not ignoreAlpha and FluxUI.DrawColor.a or nil)
    surface.SetDrawColor(FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a)
end

-- Borders
function Shapes.Border(x, y, w, h, stroke, forceNoShade)
    if forceNoShade or not Shapes.BordersShaded then return surface.DrawOutlinedRect(x, y, w, h, stroke) end
    stroke = stroke or 1
    
    local oldDrawColor = surface.GetDrawColor()
    multipliedStroke = stroke * 2
    Shapes.Rectangle(x, y, stroke, h)
    Shapes.Rectangle(x + w - stroke, y, stroke, h)
    Shapes.Rectangle(x + stroke, y, w - multipliedStroke, stroke)
    Shapes.Rectangle(x + stroke, y + h - stroke, w - multipliedStroke, stroke)
    surface.SetDrawColor(0, 0, 0, oldDrawColor.a / 2)
    Shapes.Rectangle(x, y + h - stroke, w, stroke)
    Shapes.Rectangle(x, y, w, stroke)
    Shapes.Shade(x, y + stroke, stroke, h - multipliedStroke, oldDrawColor.a / 2)
    Shapes.Shade(x + w - stroke, y + stroke, stroke, h - multipliedStroke, oldDrawColor.a / 2)
    surface.SetDrawColor(oldDrawColor.r, oldDrawColor.g, oldDrawColor.b, oldDrawColor.a)
end

-- Circles
local CircleMeshes = {}
local DefaultSegments, DefaultCircAmount = 36, 1
function FluxUI.GenerateCircle(segments, amount)
    local vertices, circleMesh = {}, Mesh()
    segments = segments or DefaultSegments
    amount = amount or DefaultCircAmount

    local rotation = 360 * amount
    for i = 0, segments do
        local angle1 = math.rad((i / segments) * rotation)
        local angle2 = math.rad(((i + 1) / segments) * rotation)
        table.insert(vertices, {pos = Vector(0, 0, 0), u = 0.5, v = 0.5})
        table.insert(vertices, {pos = Vector(math.cos(angle1), math.sin(angle1), 0), u = math.cos(angle1), v = math.sin(angle1)})
        table.insert(vertices, {pos = Vector(math.cos(angle2), math.sin(angle2), 0), u = math.cos(angle2), v = math.sin(angle2)})
    end
    circleMesh:BuildFromTriangles(vertices)
    return circleMesh
end

local CircleMatrix = Matrix()
function FluxUI.Shapes.Circle(x, y, radius, segments, amount)
    segments = segments or DefaultSegments
    amount = amount or DefaultCircAmount
    if radius <= 0 or segments <= 0 or amount <= 0 then return end  -- it could cause a lag spike when we have to start drawing a special circle. oh well
    local circleMesh = FluxUI.Memory.PullFunctionUnpacked("Circ:" .. segments .. amount, FluxUI.GenerateCircle, segments, amount)
    
    render.SetColorMaterial()
    cam.Start2D()
        CircleMatrix:SetTranslation(Vector(x, y, 0))
        CircleMatrix:SetScale(Vector(radius / 2, radius / 2, 0))
        cam.PushModelMatrix(CircleMatrix) circleMesh:Draw() cam.PopModelMatrix()
    cam.End2D()
end
