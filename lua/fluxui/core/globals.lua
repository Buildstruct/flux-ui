-- Baseline
FluxUI.IsLinux = system.IsLinux()
FluxUI.Derma = {}
FluxUI.Elements = {}
FluxUI.ActiveElements = {}

-- Resolution
FluxUI.ScrW, FluxUI.ScrH = ScrW(), ScrH()
hook.Add("OnScreenSizeChanged", "FluxUI:ScreenResolution", function()
    FluxUI.ScrW, FluxUI.ScrH = ScrW(), ScrH()
    FluxUI.Print("Screen Resolution was modified, new resolution: " .. FluxUI.ScrW .. "x" .. FluxUI.ScrH)
end)

-- Colors
FluxUI.Colors = {
    -- Grays
    White       = FluxUI.White,
    WhiteDim    = Color(230, 230, 230),
    Gray        = Color(180, 180, 180),
    GrayDim     = Color(140, 140, 140),
    DarkGray    = Color(65, 65, 65),
    DarkGrayDim = Color(30, 30, 30),
    Black       = Color(0, 0, 0),

    -- Vibrant
    RedLight        = Color(255, 175, 175),
    Red             = Color(255, 30, 30),
    OrangeLight     = Color(255, 180, 123),
    Orange          = Color(255, 125, 25),
    YellowLight     = Color(240, 240, 0),
    Yellow          = Color(240, 240, 0),
    GreenLight      = Color(175, 245, 175),
    Green           = Color(30, 245, 30),
    BlueLight       = Color(200, 200, 255),
    Blue            = Color(64, 64, 255),
    MagentaLight    = Color(255, 170, 252),
    Magenta         = Color(255, 64, 249),

    -- Elements
    Dropdown = {
        Background  = Color(45, 45, 45, 220),
        Outline     = Color(24, 24, 24, 240)
    },
    Button = {
        Background      = Color(40, 40, 40),
        BackgroundHover = Color(55, 55, 55),
        Outline         = Color(32, 32, 32)
    },
    Divider = {
        Primary     = Color(125, 125, 125, 200),
        Secondary   = Color(100, 100, 100, 180),
        Tertiary    = Color(75, 75, 75, 145)
    },
    Hyperlink = {
        Default = Color(132, 132, 255),
        Hover   = Color(92, 92, 255)
    },
    TextEntry = {
        Background      = Color(40, 40, 40),
        BackgroundHover = Color(55, 55, 55),
        Outline         = Color(32, 32, 32),
        TextHighlight   = Color(186, 186, 255, 128)
    }
}

-- Materials
FluxUI.Materials = {
    Blur = Material("pp/blurscreen"),
    Noise = CreateMaterial("FluxUINoise", "UnlitGeneric", {
        ["$basetexture"] = "engine/noise-blur-256x256",
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$vertexcolor"] = 1
    }),
    Gradient = {
        Left    = Material("vgui/gradient-l"),
        Right   = Material("vgui/gradient-r"),
        Up      = Material("vgui/gradient-u"),
        Down    = Material("vgui/gradient-d"),
    },
    Scrollbar = {
        Up      = Material("icon16/bullet_arrow_up.png"),
        Down    = Material("icon16/bullet_arrow_down.png")
    },
    Corner = {
        Size8 = Material("gui/corner8"),
        Size16 = Material("gui/corner16"),
        Size32 = Material("gui/corner32"),
        Size64 = Material("gui/corner64"),
        Size512 = Material("gui/corner512")
    },
    Placeholder = Material("matsys_regressiontest/background")
}

