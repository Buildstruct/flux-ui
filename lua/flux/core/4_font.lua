local Fonts = {}
Flux.Fonts = {}

Fonts.Registered = {}

Fonts.WindowsFont = "Consolas"
Fonts.LinuxFont = "DejaVu Sans Mono"
Fonts.LinuxBoldFont = "DejaVu Sans Mono"

function Fonts.Create(size, bold)
    Fonts.Registered[size..(bold and ":bold" or "")] = true
    surface.CreateFont("FluxFont:"..size..(bold and ":bold" or ""), {
        font =  Flux.IsLinux and (bold and Fonts.LinuxBoldFont or Fonts.LinuxFont) or Fonts.WindowsFont,
        size = size,
        weight = bold and 1500 or 0,
        antialias = true
    })
end

function Fonts.Name(size, bold)
    if not Fonts.Registered[size..(bold and ":bold" or "")] then Fonts.Create(size, bold) end
    return "FluxFont:"..size..(bold and ":bold" or "")
end

Flux.Font = Fonts.Name