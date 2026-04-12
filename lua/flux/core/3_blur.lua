local Blur = {}    
Flux.Blur = Blur

function Flux.Blur.Panel(panel, size, passes, alpha)
    local x, y = panel:LocalToScreen(0, 0)
    surface.SetDrawColor(255, 255, 255, alpha or 255)
    surface.SetMaterial(Flux.Materials.Blur)
    size = size or 3
    passes = passes or 4

    for i = 1, size do
        Flux.Materials.Blur:SetFloat("$blur", (i/size)*passes)
        Flux.Materials.Blur:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x*-1, y*-1, Flux.ScrW, Flux.ScrH)
    end
end

function Flux.Blur.Section(x, y, w, h, size, passes, alpha)
    surface.SetDrawColor(255, 255, 255, alpha or 255)
    surface.SetMaterial(Flux.Materials.Blur)
    size = size or 3
    passes = passes or 4

    render.SetScissorRect(x, y, x + w, y + h, true)
        for i = 1, size do
            Flux.Materials.Blur:SetFloat("$blur", (i/size)*passes)
            Flux.Materials.Blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(0, 0, Flux.ScrW, Flux.ScrH)
        end
    render.SetScissorRect(0, 0, 0, 0, false) 
    surface.SetDrawColor(Flux.DrawColor)
end