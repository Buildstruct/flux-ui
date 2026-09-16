local Fonts = {Registered = {}}
FluxUI.Fonts = Fonts

local FontBold = {Windows = "Lexend Bold", Linux = "lexend-bold.ttf"}
local FontRegular = {Windows = "Lexend", Linux = "lexend-regular.ttf"}

function Fonts.InternalName(size, bold, italicized) return "FluxUI_" .. tostring(size) .. (bold and ":bold" or "") .. (italicized and ":ital" or "") end
function Fonts.Name(...)
    local FontName = Fonts.InternalName(...)
    return Fonts.Registered[FontName] and FontName or Fonts.Create(...)
end
FluxUI.Font = Fonts.Name
function Fonts.Create(size, bold, italicized)
    local FontName = Fonts.InternalName(size, bold, italicized)
    Fonts.Registered[FontName] = true
    surface.CreateFont(FontName, {
        font = FluxUI.IsLinux and (bold and FontBold.Linux or FontRegular.Linux) or (bold and FontBold.Windows or FontRegular.Windows),
        size = size,
        bold = bold and 1500 or 600,
        antialias = true,
        italic = italic or false
    })
    return FontName
end