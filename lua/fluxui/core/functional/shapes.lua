local Shapes = {}
FluxUI.Shapes = Shapes

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
    --local circleMesh = CircleMeshes[(segments or DefaultSegments) .. (amount or DefaultCircAmount)]
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
