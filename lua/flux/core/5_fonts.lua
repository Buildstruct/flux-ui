local Fonts = {}
Flux.Fonts = Fonts

Fonts.Registered = {}

Fonts.WindowsFont = isstring(Flux.Config.Fonts) and Flux.Config.Fonts or Flux.Config.Fonts.Windows
Fonts.LinuxFont = isstring(Flux.Config.Fonts) and Flux.Config.Fonts or Flux.Config.Fonts.Linux

function Fonts.Create(size, bold)
    Fonts.Registered[size..(bold and ":bold" or "")] = true
    surface.CreateFont("FluxFont:"..size..(bold and ":bold" or ""), {
        font =  Flux.IsLinux and Fonts.LinuxFont or Fonts.WindowsFont,
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