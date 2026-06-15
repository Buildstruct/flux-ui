local Gradient = {}
Flux.Gradient = Gradient

function Gradient.Down(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientUp)
    surface.DrawTexturedRect(x, y, w, h)
end
function Gradient.Up(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientDown)
    surface.DrawTexturedRect(x, y, w, h)
end
function Gradient.Right(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientLeft)
    surface.DrawTexturedRect(x, y, w, h)
end

function Gradient.Left(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientRight)
    surface.DrawTexturedRect(x, y, w, h)
end

local Shapes = {}
Flux.Shapes = Shapes

Flux.Shapes.Rectangle = surface.DrawRect
Flux.Shapes.Border = surface.DrawOutlinedRect
function Flux.Shapes.Frame(x, y, w, h, BackgroundColor, OutlineColor, Blur, AlphaMultiplier)
    BackgroundColor = BackgroundColor or Flux.Colors.Background
    OutlineColor = OutlineColor or Flux.Colors.Outline
    AlphaMultiplier = AlphaMultiplier or 1
    if Blur then Flux.Blur.Section(x, y, w, h, nil, nil, 255 * AlphaMultiplier) end

    surface.SetDrawColor(BackgroundColor.r, BackgroundColor.g, BackgroundColor.b, AlphaMultiplier and BackgroundColor.a * AlphaMultiplier or BackgroundColor.a)
    Flux.Shapes.Rectangle(x, y, w, h)
    Flux.Shapes.Shade(x, y, w, h, 180 * AlphaMultiplier)

    local OutlineAlpha = AlphaMultiplier and OutlineColor.a * AlphaMultiplier or OutlineColor.a
    surface.SetDrawColor(OutlineColor.r - 15, OutlineColor.g - 15, OutlineColor.b - 15, OutlineAlpha)
    Flux.Shapes.Border(x, y, w, h, 4)
    surface.SetDrawColor(OutlineColor.r, OutlineColor.g, OutlineColor.b, OutlineAlpha)
    Flux.Shapes.Border(x, y, w, h, 2)

    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.ShadedBorder(x, y, w, h, outline)
    Flux.Shapes.Rectangle(0, y, outline, h)
    Flux.Shapes.Rectangle(w - outline, y, outline, h)
    Flux.Shapes.Shade(0, y + outline, outline, h - (outline * 2), Flux.DrawColor.a / 1.5)
    Flux.Shapes.Shade(w - outline, y + outline, outline, h - (outline * 2), Flux.DrawColor.a / 1.5)

    Flux.Shapes.Rectangle(x, h-outline, w, outline)
    Flux.Shapes.Rectangle(x, 0, w, outline)
    surface.SetDrawColor(0, 0, 0, Flux.DrawColor.a / 1.5)

    Flux.Shapes.Rectangle(x, h-outline, w, outline)
    Flux.Shapes.Rectangle(x, 0, w, outline)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.Shade(x, y, w, h, alpha)
    surface.SetDrawColor(0, 0, 0, alpha or 180)
    surface.SetMaterial(Flux.Materials.GradientDown)
    surface.DrawTexturedRect(x, y, w, h)
    surface.SetMaterial(Flux.Materials.GradientUp)
    surface.DrawTexturedRect(x, y, w, h / 6)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.ShadedRect(x, y, w, h, followDrawAlpha)
    Flux.Shapes.Rectangle(x, y, w, h)
    Flux.Shapes.Shade(x, y, w, h, followDrawAlpha and Flux.DrawColor.a or nil)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.Shapes.Scrollbar(scrollbar)
    scrollbar:SetWide(10)
    function scrollbar:Paint() end
    function scrollbar.btnUp:Paint(w, h)
        surface.SetMaterial(Flux.Materials.ScrollbarUp)
        local DrawColor = self:IsHovered() and 255 or 200
        surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    function scrollbar.btnDown:Paint(w, h)
        surface.SetMaterial(Flux.Materials.ScrollbarDown)
        local DrawColor = self:IsHovered() and 255 or 200
        surface.SetDrawColor(DrawColor, DrawColor, DrawColor)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    function scrollbar.btnGrip:Paint(w, h)
        surface.SetDrawColor(0, 0, 0, 200)
        Flux.Shapes.Rectangle(1, 1, w-2, h-2)
        surface.SetDrawColor(64, 64, 64, 200)
        Shapes.ShadedRect(2, 2, w - 4, h - 4)
    end

end

-- Hacky perforamnce boost: Only render the sphere(s) once, push it to the RT, and only render said RT
-- We could honestly just render a bunch of segments to make it look very smooth, as its only ran once
-- nobody wil really notice since its ran during loading screen lol. Overall its a 25x performance boost
-- compared to the method listed on the wiki.
local CircleRT, CircleMaterial = nil, Flux.Materials.Placeholder
local HalfCircleRT, HalfCircleMaterial = nil, Flux.Materials.Placeholder
function Flux.GenerateCircle()
    hook.Add("PreDrawHUD", "FluxUI_CircleGeneration", function()
        hook.Remove("PreDrawHUD", "FluxUI_CircleGeneration")
        local CircleGenerationStart = SysTime()
        CircleRT = GetRenderTarget("FluxUICircle" .. Flux.ScrW .. Flux.ScrH, 4096, 4096)
        CircleMaterial = CreateMaterial("FluxUICircle" .. Flux.ScrW .. Flux.ScrH, "UnlitGeneric", {["$basetexture"] = CircleRT:GetName(), ["$translucent"] = 1})
        HalfCircleRT = GetRenderTarget("FluxUIHalfCircle" .. Flux.ScrW .. Flux.ScrH, 4096, 4096)
        HalfCircleMaterial = CreateMaterial("FluxUIHalfCircle" .. Flux.ScrW .. Flux.ScrH, "UnlitGeneric", {["$basetexture"] = HalfCircleRT:GetName(), ["$translucent"] = 1})

        render.PushRenderTarget(CircleRT, 0, 0, CircleRT:Width(), CircleRT:Width())
            render.Clear(0, 0, 0, 0)
            draw.NoTexture()
            surface.SetDrawColor(255, 255, 255)
            cam.Start2D()
                cam.Start3D(Vector(10000,0,0), Angle(0,180,0), 1, 0, 0, CircleRT:Width(), CircleRT:Width())
                    render.DrawSphere( Vector(-10000,0,0), 175, 360, 360, Color(255, 255, 255, 80))
                    render.DrawSphere( Vector(-10000,0,0), 175 - 0.3, 360, 360, Color(255, 255, 255, 250))
                    render.DrawSphere( Vector(-10000,0,0), 175 - 0.7, 360, 360, Color(255, 255, 255, 255))
                cam.End3D()
            cam.End2D()
        render.PopRenderTarget()

        render.PushRenderTarget(HalfCircleRT, 0, 0, HalfCircleRT:Width(), HalfCircleRT:Width())
            render.Clear(0, 0, 0, 0)
            draw.NoTexture()
            surface.SetDrawColor(255, 255, 255)
            cam.Start2D()
                render.SetScissorRect(0, 0, HalfCircleRT:Width() / 2, HalfCircleRT:Width(), true)
                    cam.Start3D(Vector(10000,0,0), Angle(0,180,0), 1, 0, 0, HalfCircleRT:Width(), HalfCircleRT:Width())
                        render.DrawSphere( Vector(-10000,0,0), 175, 360, 360, Color(255, 255, 255, 80))
                        render.DrawSphere( Vector(-10000,0,0), 175 - 0.3, 360, 360, Color(255, 255, 255, 250))
                        render.DrawSphere( Vector(-10000,0,0), 175 - 0.7, 360, 360, Color(255, 255, 255, 255))
                    cam.End3D()
                render.SetScissorRect(0, 0, 0, 0, false)
            cam.End2D()
        render.PopRenderTarget()
        Flux.Print("Circle Generation took: " .. math.Round(SysTime() - CircleGenerationStart, 4) .. "s")
    end)
end
Flux.GenerateCircle()
Flux.OnScreenSizeChanged.CircleGeneration = Flux.GenerateCircle

local LastColor, LastAlpha
function Flux.Shapes.Circle(x, y, radius)
    local Alpha, DrawColorVector = Flux.DrawColor.a / 255, Flux.Memory.PullOrPush(Flux.DrawColor.r .. Flux.DrawColor.g .. Flux.DrawColor.b, Vector(Flux.DrawColor.r / 255, Flux.DrawColor.g / 255, Flux.DrawColor.b / 255))
    if LastColor ~= DrawColorVector then CircleMaterial:SetVector("$color", DrawColorVector) end
    if LastAlpha ~= Alpha then CircleMaterial:SetFloat("$alpha", Alpha) end
    LastAlpha, LastColor = Alpha, DrawColorVector

    surface.SetMaterial(CircleMaterial)
    surface.DrawTexturedRect(x - radius / 2, y - radius / 2, radius, radius)
end

local LastColor, LastAlpha
function Flux.Shapes.HalfCircle(x, y, radius, rot)
    local Alpha, DrawColorVector = Flux.DrawColor.a / 255, Flux.Memory.PullOrPush(Flux.DrawColor.r .. Flux.DrawColor.g .. Flux.DrawColor.b, Vector(Flux.DrawColor.r / 255, Flux.DrawColor.g / 255, Flux.DrawColor.b / 255))
    if LastColor ~= DrawColorVector then HalfCircleMaterial:SetVector("$color", DrawColorVector) end
    if LastAlpha ~= Alpha then HalfCircleMaterial:SetFloat("$alpha", Alpha) end
    LastAlpha, LastColor = Alpha, DrawColorVector

    surface.SetMaterial(HalfCircleMaterial)
    surface.DrawTexturedRectRotated(x, y, radius, radius, rot or 0)
end