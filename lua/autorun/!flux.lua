local Flux = {Debug = true}
_G.Flux = Flux
Flux.StartTick = SysTime()
Flux.Prefix = "flux-ui"
Flux.Version = "0.10.0"

Flux.Colors = {
    Accent = Color(43, 85, 245),
    White = Color(255, 255, 255),
    Gray = Color(185, 185, 185),
    Black = Color(0, 0, 0),

    Red = Color(255, 25, 25),
    Orange = Color(255, 100, 0),
    Green = Color(32, 255, 32),

    Background = Color(25, 25, 25, 220),
    ButtonBackground = Color(45, 45, 45, 225),

    DropdownBackground = Color(42, 42, 42, 215),
    DropdownOutline = Color(16, 16, 16, 240),

    Outline = Color(38, 38, 38, 255),
    ButtonOutline = Color(25, 25, 25, 245),
}

-- Begin Initalization
function Flux.Print(...) if not Flux.Debug then return end MsgC(Flux.Colors.White, "(", Flux.Colors.Accent, Flux.Prefix, Flux.Colors.White, ") ", ...) Msg('\n') end
function Flux.Warn(...) Flux.Print(Flux.Colors.White, "(", Flux.Colors.Accent, "WARN", Flux.Colors.White, ") ", ...) end
function Flux.Error(...) Flux.Print(Flux.Colors.White, "(", Flux.Colors.Accent, "ERROR", Flux.Colors.White, ") ", ...) end
Flux.Print("Starting version " .. Flux.Version)

-- Include
local ServerInclude = SERVER and include or function() end
local ClientInclude = SERVER and AddCSLuaFile or include
local SharedInclude = function(f) ServerInclude(f) ClientInclude(f) end
local function RecursiveInclude(path, callback)
    local Files, Directories = file.Find(path .. "/*", "LUA")
    for k, v in SortedPairs(Files) do
        if not string.EndsWith(v, ".lua") then continue end
        callback(path .. "/" .. v)
    end
    for k, v in pairs(Directories) do RecursiveInclude(path.."/"..v, callback) end
end

SharedInclude("flux/config.lua")
ServerInclude("flux/server.lua")
SharedInclude("flux/utility.lua")
RecursiveInclude("flux/core", ClientInclude)
RecursiveInclude("flux/elements", ClientInclude)

Flux.Initalized = true
Flux.Print("Ready in " .. math.Round(SysTime() - Flux.StartTick, 2) .. " seconds.")