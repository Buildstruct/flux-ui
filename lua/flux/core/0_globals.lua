Flux.Materials = {
    Blur = Material("pp/blurscreen"),
    GradientUp = Material("vgui/gradient-u"),
    GradientDown = Material("vgui/gradient-d"),
    GradientRight = Material("vgui/gradient-r"),
    GradientLeft = Material("vgui/gradient-l"),
    ScrollbarUp = Material("icon16/bullet_arrow_up.png"),
    ScrollbarDown = Material("icon16/bullet_arrow_down.png"),
    DropdownSubmenu = Material("icon16/bullet_arrow_down.png"),
    Noise = CreateMaterial("fluxblurnoisefx", "UnlitGeneric", {
        ["$basetexture"] = "engine/noise-blur-256x256",
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    })
}

Flux.IsLinux = system.IsLinux()

Flux.ActiveElements = {}
Flux.Elements = {}
Flux.Derma = {}

-- Screen Resolution
Flux.ScrW = ScrW()
Flux.ScrH = ScrH()
hook.Add("OnScreenSizeChanged", "FluxScreenResolution", function() 
    Flux.ScrW = ScrW()
    Flux.ScrH = ScrH()
    Flux.Print("Screen resolution was changed, updated ScrW and ScrH values: " .. Flux.ScrW .. "x" .. Flux.ScrH)
end)