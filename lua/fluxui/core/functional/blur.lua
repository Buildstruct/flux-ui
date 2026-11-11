local Blur = {}
FluxUI.Blur = Blur

local Experimental = {}
local DrawTexturedUVFunc = surface.DrawTexturedRectRawUV or surface.DrawTexturedRectUV
Blur.Experimental = Experimental

Blur.NoiseSize = 175

local BlurEnabledConvar = CreateClientConVar("fluxui_blurenabled", "1", true, false, "Enable/Disable global blurring for all FluxUI elements", 0, 1)
local NoiseEnabledConvar = CreateClientConVar("fluxui_blurnoise", "1", true, false, "Enable/Disable a subtle noise effect under blurred elements", 0, 1)
local ExperimentalEnabledConvar = CreateClientConVar("fluxui_blurexperimental", "0", true, false, "Enable/Disable the experimental blur method which is much more performant", 0, 1)

Blur.Enabled = BlurEnabledConvar:GetBool()
Blur.NoiseEnabled = NoiseEnabledConvar:GetBool()
Blur.ExperimentalEnabled = ExperimentalEnabledConvar:GetBool()
cvars.AddChangeCallback("fluxui_blurnoise", function(_, _, new) Blur.NoiseEnabled = tonumber(new) == 1 end, "fluxui_blurnoise_toggle")
cvars.AddChangeCallback("fluxui_blurenabled", function(_, _, new) Blur.Enabled = tonumber(new) == 1 end, "fluxui_blur_toggle")
cvars.AddChangeCallback("fluxui_blurexperimental", function(_, _, new) Blur.ExperimentalEnabled = tonumber(new) == 1 end, "fluxui_blurexp_toggle")

function Blur.Noise(x, y, w, h, alpha)
    if not Blur.NoiseEnabled then return end
    surface.SetMaterial(FluxUI.Materials.Noise)
    surface.SetDrawColor(190, 190, 190, alpha or 28)
    DrawTexturedUVFunc(x, y, w, h, 0, 0, w / Blur.NoiseSize, h / Blur.NoiseSize)
end

-- Experimental Blurring, i want this to be based off of how hyprland and niri (wm) do thier blurring. it gets the screen and drwas it at low resolutions.
Experimental.Cached = {}
Experimental.BlurKPMaterial = CreateMaterial("FluxUI_BlurKawasePass", "UnlitGeneric", {["$basetexture"] = "color/white", ["$ignorez"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
Experimental.BlurBlitMaterial = CreateMaterial("FluxUI_BlurBlit", "UnlitGeneric", {["$basetexture"] = "color/white", ["$ignorez"] = 1})
Experimental.DownsampleOffset = 1.5

local function Generate(passes)
    local RTCache = {}
    local w, h = FluxUI.ScrW, FluxUI.ScrH
    for i = 1, passes do
        w, h = math.max(1, math.floor(w / 2)), math.max(1, math.floor(h / 2))
        table.insert(RTCache, {w = w, h = h, RenderTarget = GetRenderTargetEx("FluxUI_BlurExp_" .. passes .. w .. h .. FluxUI.ScreenTag, w, h, RT_SIZE_LITERAL, MATERIAL_RT_DEPTH_NONE, bit.bor(4, 8, 256), 0, IMAGE_FORMAT_RGBA8888)})
    end
    RTCache.Material = CreateMaterial("FluxUI_BlurExp_Static" .. passes .. FluxUI.ScreenTag, "UnlitGeneric", {["$basetexture"] = "color/white", ["$ignorez"] = 1, ["$vertexcolor"] = 1, ["$vertexalpha"] = 1})
    RTCache.Material:SetTexture("$basetexture", RTCache[1].RenderTarget)
    Experimental.Cached[passes] = RTCache
    return RTCache
end

local function Blit(rt, w, h, base)
    Experimental.BlurBlitMaterial:SetTexture("$basetexture", base or Experimental.ScreenTexture)
    render.PushRenderTarget(rt)
        render.Clear(0, 0, 0, 255)
        render.OverrideAlphaWriteEnable(true, false)
        cam.Start2D()
            surface.SetMaterial(Experimental.BlurBlitMaterial)
            surface.SetDrawColor(255, 255, 255, 255)
            DrawTexturedUVFunc(0, 0, w, h, 0, 0, 1, 1)
        cam.End2D()
        render.OverrideAlphaWriteEnable(false)
    render.PopRenderTarget()
end
local function KawasePass(rt, w, h, lastRT, lastW, lastH)
    local U, V = Experimental.DownsampleOffset / lastW, Experimental.DownsampleOffset / lastH
    Experimental.BlurKPMaterial:SetTexture("$basetexture", lastRT)
    render.PushRenderTarget(rt)
        render.Clear(0, 0, 0, 255)
        render.OverrideAlphaWriteEnable(true, false)
        cam.Start2D()
            surface.SetMaterial(Experimental.BlurKPMaterial)
            for i = 1, 4 do
                local x, y = (i % 2 == 1) and -U or U, (i <= 2) and -V or V
                surface.SetDrawColor(255, 255, 255, 255 / i)
                DrawTexturedUVFunc(0, 0, w, h, x, y, 1 + x, 1 + y)
            end
        cam.End2D()
        render.OverrideAlphaWriteEnable(false)
    render.PopRenderTarget()
end
function Experimental.Prepare(passes, force)
    passes = math.max(1, math.floor(passes or 3))
    local CachedRTs = Experimental.Cached[passes] or Generate(passes)
    local FN = FrameNumber()
    if not force and CachedRTs.LastFrame and CachedRTs.LastFrame == FN then return CachedRTs.Material end
    CachedRTs.LastFrame = FN

    if force or (not Experimental.LastScreenFrame or Experimental.LastScreenFrame ~= FN) then
        render.UpdateScreenEffectTexture()
        Experimental.ScreenTexture = render.GetScreenEffectTexture()
        Experimental.ScreenTextureWidth, Experimental.ScreenTextureHeight = Experimental.ScreenTexture:Width(), Experimental.ScreenTexture:Height()
        Experimental.LastScreenFrame = FN
    end

    Blit(CachedRTs[1].RenderTarget, CachedRTs[1].w, CachedRTs[1].h, nil)
    for i = 2, passes do KawasePass(CachedRTs[i].RenderTarget, CachedRTs[i].w, CachedRTs[i].h, CachedRTs[i - 1].RenderTarget, CachedRTs[i - 1].w, CachedRTs[i - 1].h, 1.5) end
    for i = passes - 1, 1, -1 do Blit(CachedRTs[i].RenderTarget, CachedRTs[i].w, CachedRTs[i].h, CachedRTs[i + 1].RenderTarget) end
    return CachedRTs.Material
end

function Experimental.Panel(panel, passes, alpha, noise, darken, refresh)
    local alphaMultiplier = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier(1)

    local PaintState = surface.GetPanelPaintState()
    darken = darken and 255 * (1 - darken) or 255
    surface.SetMaterial(Experimental.Prepare(passes or 3, true))
    surface.SetDrawColor(darken, darken, darken, (alpha or 255) * alphaMultiplier)
    DrawTexturedUVFunc(-PaintState.translate_x, -PaintState.translate_y, FluxUI.ScrW, FluxUI.ScrH, 0, 0, 1, 1)
    if noise ~= false then Blur.Noise(0, 0, panel:GetWide(), panel:GetTall(), ((alpha or 255) / 12) * alphaMultiplier) end

    surface.SetDrawColor(FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a)
    surface.SetAlphaMultiplier(alphaMultiplier)
end
function Experimental.Section(x, y, w, h, passes, alpha, noise, darken, refresh)
    local alphaMultiplier = surface.GetAlphaMultiplier()
    surface.SetAlphaMultiplier(1)

    darken = darken and 255 * (1 - darken) or 255
    surface.SetMaterial(Experimental.Prepare(passes or 3, refresh))
    surface.SetDrawColor(darken, darken, darken, (alpha or 255) * alphaMultiplier)
    DrawTexturedUVFunc(x, y, w, h, x / FluxUI.ScrW, y / FluxUI.ScrH, (x + w) / FluxUI.ScrW, (y + h) / FluxUI.ScrH)
    if noise ~= false then Blur.Noise(x, y, w, h, ((alpha or 255) / 200) * alphaMultiplier) end

    surface.SetDrawColor(FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a)
    surface.SetAlphaMultiplier(alphaMultiplier)
end

-- NORMAL BLURRING
function FluxUI.Blur.Panel(panel, size, passes, alpha, noNoise, ...)
    if not FluxUI.Blur.Enabled then return end
    if Blur.ExperimentalEnabled then return Experimental.Panel(panel, passes, alpha, not noNoise, ...) end
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(255, 255, 255, alpha or 255)
    surface.SetMaterial(FluxUI.Materials.Blur)
    size = size or 3
    passes = passes or 4

    for i = 1, size do
        FluxUI.Materials.Blur:SetFloat("$blur", (i / size) * passes)
        FluxUI.Materials.Blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, FluxUI.ScrW, FluxUI.ScrH)
    end

    if not noNoise then FluxUI.Blur.Noise(0, 0, panel:GetWide(), panel:GetTall(), 28 * ((alpha or 255) / 255), passes, size) end
end
function FluxUI.Blur.Section(x, y, w, h, size, passes, alpha, noNoise, ...)
    if not FluxUI.Blur.Enabled then return end
    if Blur.ExperimentalEnabled then return Experimental.Section(x, y, w, h, passes, alpha, not noNoise, ...) end
    size = size or 3
    passes = passes or 4

    render.SetScissorRect(x, y, x + w, y + h, true)
        surface.SetDrawColor(255, 255, 255, alpha or 255)
        surface.SetMaterial(FluxUI.Materials.Blur)
        for i = 1, size do
            FluxUI.Materials.Blur:SetFloat("$blur", (i / size) * passes)
            FluxUI.Materials.Blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(0, 0, FluxUI.ScrW, FluxUI.ScrH)
        end

        if not noNoise then FluxUI.Blur.Noise(0, 0, FluxUI.ScrW, FluxUI.ScrH, 28 * ((alpha or 255) / 255), passes, size) end
    render.SetScissorRect(0, 0, 0, 0, false)
    surface.SetDrawColor(FluxUI.DrawColor)
end
