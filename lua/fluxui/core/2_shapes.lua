if true then return end
local Shapes = {}
Flux.Shapes = Shapes

local ShadedBorderConvar = CreateClientConVar("fluxui_shadedborders", "1", true, false, "Enable/Disable shading on borders", 0, 1)
Flux.Shapes.EnableShadingBorders = ShadedBorderConvar:GetBool()
cvars.AddChangeCallback("fluxui_shadedborders", function(_, old, new)
    Flux.Shapes.EnableShadingBorders = tonumber(new) == 1
end, "fluxui_shadedborders_toggle")

Flux.Shapes.Rectangle = surface.DrawRect

function Flux.Shapes.RoundedRect(x, y, w, h, roundness, topLeft, topRight, bottomLeft, bottomRight)
    if roundness <= 0 then return Flux.Shapes.Rectangle(x, y, w, h) end

    local calcRoundness = math.min(ScreenScale(roundness), math.floor(w / 2), math.floor(h / 2))
    Flux.Shapes.Rectangle(x + calcRoundness, y, w - (calcRoundness * 2), h)
    Flux.Shapes.Rectangle(x, y + calcRoundness, calcRoundness, h - (calcRoundness * 2))
    Flux.Shapes.Rectangle(x + (w - calcRoundness), y + calcRoundness, calcRoundness, h - (calcRoundness * 2))

    surface.SetMaterial(Flux.Materials["Corner" .. tostring((calcRoundness > 64 and 512 or calcRoundness > 32 and 64 or calcRoundness > 16 and 32 or calcRoundness > 8 and 16) or 8)])

    if topLeft == false then
        Flux.Shapes.Rectangle(x, y, calcRoundness, calcRoundness)
    else
        surface.DrawTexturedRectUV(x, y, calcRoundness, calcRoundness, 0, 0, 1, 1)
    end

    if topRight == false then
        Flux.Shapes.Rectangle(x + (w - calcRoundness), y, calcRoundness, calcRoundness)
    else
        surface.DrawTexturedRectUV(x + (w - calcRoundness), y, calcRoundness, calcRoundness, 1, 0, 0, 1)
    end

    if bottomLeft == false then
        Flux.Shapes.Rectangle(x, y + (h - calcRoundness), calcRoundness, calcRoundness)
    else
        surface.DrawTexturedRectUV(x, y + (h - calcRoundness), calcRoundness, calcRoundness, 0, 1, 1, 0)
    end

    if bottomRight == false then
        Flux.Shapes.Rectangle(x + (w - calcRoundness), y + (h - calcRoundness), calcRoundness, calcRoundness)
    else
        surface.DrawTexturedRectUV(x + (w - calcRoundness), y + (h - calcRoundness), calcRoundness, calcRoundness, 1, 1, 0, 0)
    end
end

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

function Flux.Shapes.Border(x, y, w, h, outline, dontShade)
    if not Flux.Shapes.EnableShadingBorders or dontShade then return surface.DrawOutlinedRect(x, y, w, h, outline) end

    local PreviousDrawColor = surface.GetDrawColor()
    local DoubleOutlineSize = outline * 2
    Flux.Shapes.Rectangle(x, y, outline, h)
    Flux.Shapes.Rectangle(x + w - outline, y, outline, h)
    Flux.Shapes.Rectangle(x + outline, y, w - DoubleOutlineSize, outline)
    Flux.Shapes.Rectangle(x + outline, y + h - outline, w - DoubleOutlineSize, outline)

    surface.SetDrawColor(0, 0, 0, PreviousDrawColor.a / 2)
    Flux.Shapes.Rectangle(x, y + h - outline, w, outline)
    Flux.Shapes.Rectangle(x, y, w, outline)
    Flux.Shapes.Shade(x, y + outline, outline, h - DoubleOutlineSize, PreviousDrawColor.a / 2)
    Flux.Shapes.Shade(x + w - outline, y + outline, outline, h - DoubleOutlineSize, PreviousDrawColor.a / 2)
    surface.SetDrawColor(PreviousDrawColor.r, PreviousDrawColor.g, PreviousDrawColor.b, PreviousDrawColor.a)
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

local LastHColor, LastHAlpha
function Flux.Shapes.HalfCircle(x, y, radius, rot)
    local Alpha, DrawColorVector = Flux.DrawColor.a / 255, Flux.Memory.PullOrPush(Flux.DrawColor.r .. Flux.DrawColor.g .. Flux.DrawColor.b, Vector(Flux.DrawColor.r / 255, Flux.DrawColor.g / 255, Flux.DrawColor.b / 255))
    if LastHColor ~= DrawColorVector then HalfCircleMaterial:SetVector("$color", DrawColorVector) end
    if LastHAlpha ~= Alpha then HalfCircleMaterial:SetFloat("$alpha", Alpha) end
    LastHAlpha, LastHColor = Alpha, DrawColorVector

    surface.SetMaterial(HalfCircleMaterial)
    surface.DrawTexturedRectRotated(x, y, radius, radius, rot or 0)
end