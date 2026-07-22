local Flux = {}
_G.Flux = Flux
Flux.StartTick = SysTime()
Flux.Prefix = "flux-ui"
Flux.Version = "1.5.0"

-- Begin Initalization
function Flux.Print(...) if not Flux.Developer then return end MsgC(Flux.Colors.White, "(", Flux.Colors.Accent, Flux.Prefix, Flux.Colors.White, ") ", ...) Msg('\n') end
function Flux.Warn(...) Flux.Print(Flux.Colors.White, "(", Flux.Colors.Accent, "WARN", Flux.Colors.White, ") ", ...) end
function Flux.Error(...) Flux.Print(Flux.Colors.White, "(", Flux.Colors.Accent, "ERROR", Flux.Colors.White, ") ", ...) end
Flux.Print("Starting version " .. Flux.Version)

-- Include
local ServerInclude = SERVER and include or function() end
local ClientInclude = SERVER and AddCSLuaFile or include
local SharedInclude = function(f) ServerInclude(f) ClientInclude(f) end
local function RecursiveInclude(path, callback)
    local Files, Directories = file.Find(path .. "/*", "LUA")
    for k, v in SortedPairsByValue(Files) do
        if not string.EndsWith(v, ".lua") then continue end
        callback(path .. "/" .. v)
    end
    for k, v in pairs(Directories) do RecursiveInclude(path .. "/" .. v, callback) end
end

SharedInclude("flux/config.lua")
SharedInclude("flux/utility.lua")
RecursiveInclude("flux/core", ClientInclude)
RecursiveInclude("flux/elements", ClientInclude)

Flux.Initalized = true
Flux.Print("Ready in " .. math.Round(SysTime() - Flux.StartTick, 2) .. " seconds.")