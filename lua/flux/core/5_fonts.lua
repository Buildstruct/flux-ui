local Fonts = {}
Flux.Fonts = Fonts

Fonts.Registered = {}

Fonts.WindowsFont = isstring(Flux.Config.Fonts) and Flux.Config.Fonts or Flux.Config.Fonts.Windows
Fonts.LinuxFont = isstring(Flux.Config.Fonts) and Flux.Config.Fonts or Flux.Config.Fonts.Linux

function Fonts.Create(size, bold, italic)
    Fonts.Registered[size .. (bold and ":bold" or "") .. (italic and ":italic" or "")] = true
    surface.CreateFont("FluxFont:" .. size .. (bold and ":bold" or "") .. (italic and ":italic" or ""), {
        font =  Flux.IsLinux and Fonts.LinuxFont or Fonts.WindowsFont,
        size = size,
        weight = bold and 1500 or 0,
        antialias = true,
        italic = italic or false,
    })
end

function Fonts.Name(size, bold, italic)
    if not Fonts.Registered[size .. (bold and ":bold" or "") .. (italic and ":italic" or "")] then Fonts.Create(size, bold, italic) end
    return "FluxFont:" .. size .. (bold and ":bold" or "") .. (italic and ":italic" or "")
end

Flux.Font = Fonts.Name