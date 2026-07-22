Flux.Colors = {
    Accent = Color(43, 85, 245),
    White = Color(255, 255, 255),
    DimWhite = Color(230, 230, 230),
    Gray = Color(185, 185, 185),
    DimGray = Color(145, 145, 145),
    Black = Color(0, 0, 0),

    Red = Color(255, 25, 25),
    Orange = Color(255, 100, 0),
    Green = Color(32, 255, 32),
    Yellow = Color(240, 240, 0),
    Blue = Color(63, 63, 255),
    Transparent = Color(0, 0, 0, 0),

    LightRed = Color(255, 200, 200),

    Background = Color(25, 25, 25, 220),
    ButtonBackground = Color(45, 45, 45, 225),

    DropdownBackground = Color(42, 42, 42, 215),
    DropdownOutline = Color(16, 16, 16, 240),

    Outline = Color(38, 38, 38, 255),
    ButtonOutline = Color(25, 25, 25, 245),

    Seperator = Color(127, 127, 127, 200),
    SubSeperator = Color(100, 100, 100, 175),

    Hyperlink = Color(132, 132, 255),
    HyperlinkHover = Color(92, 92, 255),

    TextHighlightColor = Color(186, 186, 255, 128)
}

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
    }),
    Placeholder = Material("matsys_regressiontest/background"),
    Corner8 = Material("gui/corner8"),
    Corner16 = Material("gui/corner16"),
    Corner32 = Material("gui/corner32"),
    Corner64 = Material("gui/corner64"),
    Corner512 = Material("gui/corner512"),
}

Flux.IsLinux = system.IsLinux()

Flux.ActiveElements = {}
Flux.Elements = {}
Flux.Derma = {}

-- Screen Resolution
Flux.OnScreenSizeChanged = {}
Flux.ScrW = ScrW()
Flux.ScrH = ScrH()
hook.Add("OnScreenSizeChanged", "FluxUI_ScreenResolution", function()
    Flux.ScrW = ScrW()
    Flux.ScrH = ScrH()
    for k, v in pairs(Flux.OnScreenSizeChanged) do if isfunction(v) then v() end end
    Flux.Print("Screen resolution was changed, updated ScrW and ScrH values: " .. Flux.ScrW .. "x" .. Flux.ScrH)
end)