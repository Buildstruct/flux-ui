local Blur = {NoiseSize = 1, BaseNoiseSize = 175}
FluxUI.Blur = Blur

local BlurCVar = CreateClientConVar("fluxui_blurenabled", "1", true, false, "Enable/Disable global blurring for all FluxUI elements", 0, 1)
local NoiseCVar = CreateClientConVar("fluxui_blurnoise", "1", true, false, "Enable/Disable a subtle noise effect under blurred elements", 0, 1)
FluxUI.Blur.NoiseEnabled = NoiseCVar:GetBool()
FluxUI.Blur.Enabled = BlurCVar:GetBool()
cvars.AddChangeCallback("fluxui_blurnoise", function(_, old, new)
    FluxUI.Blur.NoiseEnabled = tonumber(new) == 1
end, "fluxui_blurnoise_toggle")
cvars.AddChangeCallback("fluxui_blurenabled", function(_, old, new)
    FluxUI.Blur.Enabled = tonumber(new) == 1
end, "fluxui_blur_toggle")

function FluxUI.Blur.Noise(x, y, w, h, alpha, passes, size)
    if not FluxUI.Blur.NoiseEnabled then return end
    local SizeMultiplier = math.Clamp((size or 3) / 3, 0, 1)
    local PassMultiplier = math.Clamp((passes or 4) / 4, 0, 1)
    local NoiseSize = FluxUI.Blur.BaseNoiseSize * FluxUI.Blur.NoiseSize
    surface.SetMaterial(FluxUI.Materials.Noise)
    surface.SetDrawColor(185, 185, 185, ((alpha or 28) * SizeMultiplier) * PassMultiplier)
    surface.DrawTexturedRectUV(x, y, w, h, 0, 0, w / NoiseSize, h / NoiseSize)
end

function FluxUI.Blur.Panel(panel, size, passes, alpha, noNoise)
    if not FluxUI.Blur.Enabled then return end
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

function FluxUI.Blur.Section(x, y, w, h, size, passes, alpha, noNoise)
    if not FluxUI.Blur.Enabled then return end
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