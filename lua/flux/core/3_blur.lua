local Blur = {}
Flux.Blur = Blur
Flux.Blur.BaseNoiseSize = 175
Flux.Blur.NoiseSize = 1
Flux.Blur.NoiseEnabled = true

function Flux.Blur.Noise(x, y, w, h, alpha, passes, size)
    if not Flux.Blur.NoiseEnabled then return end
    local SizeMultiplier = math.Clamp((size or 3) / 3, 0, 1)
    local PassMultiplier = math.Clamp((passes or 4) / 4, 0, 1)
    local NoiseSize = Flux.Blur.BaseNoiseSize * Flux.Blur.NoiseSize
    surface.SetMaterial(Flux.Materials.Noise)
    surface.SetDrawColor(185, 185, 185, ((alpha or 32) * SizeMultiplier) * PassMultiplier)
    surface.DrawTexturedRectUV(x, y, w, h, 0, 0, w / NoiseSize, h / NoiseSize)
end

function Flux.Blur.Panel(panel, size, passes, alpha, noNoise)
    local x, y = panel:LocalToScreen(0, 0)

    surface.SetDrawColor(255, 255, 255, alpha or 255)
    surface.SetMaterial(Flux.Materials.Blur)
    size = size or 3
    passes = passes or 4

    for i = 1, size do
        Flux.Materials.Blur:SetFloat("$blur", (i / size) * passes)
        Flux.Materials.Blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, Flux.ScrW, Flux.ScrH)
    end

    if not noNoise then Flux.Blur.Noise(0, 0, panel:GetWide(), panel:GetTall(), 32 * ((alpha or 255) / 255), passes, size) end
end

function Flux.Blur.Section(x, y, w, h, size, passes, alpha, noNoise)
    size = size or 3
    passes = passes or 4

    render.SetScissorRect(x, y, x + w, y + h, true)
        surface.SetDrawColor(255, 255, 255, alpha or 255)
        surface.SetMaterial(Flux.Materials.Blur)
        for i = 1, size do
            Flux.Materials.Blur:SetFloat("$blur", (i / size) * passes)
            Flux.Materials.Blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(0, 0, Flux.ScrW, Flux.ScrH)
        end

        if not noNoise then Flux.Blur.Noise(0, 0, Flux.ScrW, Flux.ScrH, 32 * ((alpha or 255) / 255), passes, size) end
    render.SetScissorRect(0, 0, 0, 0, false)
    surface.SetDrawColor(Flux.DrawColor)
end