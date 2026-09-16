-- FluxUI, a open sourced UI component library, authored by phys STEAM_0:0:24262296
local FluxUI = {}
_G.FluxUI = FluxUI
FluxUI.StartTick = SysTime()
FluxUI.Prefix = "FluxUI"
FluxUI.Version = "2.0.0"

-- Baseline Variables
FluxUI.White = Color(255, 255, 255)
FluxUI.Accent = Color(84, 43, 245)

-- Logging
function FluxUI.Print(...) if not FluxUI.Developer then return end MsgC(FluxUI.White, "(", FluxUI.Accent, FluxUI.Prefix, FluxUI.White, ") ", ...) Msg('\n') end
function FluxUI.Warn(...) FluxUI.Print(FluxUI.White, "(", FluxUI.Accent, "WARN", FluxUI.White, ") ", ...) end
function FluxUI.Error(...) FluxUI.Print(FluxUI.White, "(", FluxUI.Accent, "ERROR", FluxUI.White, ") ", ...) end
FluxUI.Print("Starting version " .. FluxUI.Version)

-- Workshop Collection (WHY GARRY WHY WHY WHY WHY WHY HWY HWY WHY HWY)
if SERVER then resource.AddWorkshop("3774817509") end

-- Recursively include everything
local includeCl = SERVER and AddCSLuaFile or include
local function includeRecursive(path)
    local files, dirs = file.Find(path .. "/*", "LUA")
    for k, v in SortedPairsByValue(files) do
        if not string.EndsWith(v, ".lua") then continue end
        includeCl(path .. "/" .. v)
    end
    for k, v in pairs(dirs) do includeRecursive(path .. "/" .. v) end
end
includeRecursive("fluxui/core")
--includeRecursive("fluxui/elements")

FluxUI.Initalized = true
FluxUI.Print("Ready in " .. math.Round(SysTime() - FluxUI.StartTick, 2) .. " seconds.")