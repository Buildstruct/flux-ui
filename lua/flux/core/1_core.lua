Flux.DrawColor = {r = 255, g = 255, b = 255, a = 255}
Flux.OutlineDrawColor = {r = 0, g = 0, b = 0, a = 255}

function Flux.ResetColor() Flux.RGB(255, 255, 255) end
function Flux.Color(ColorObject, ForceAlpha)
    if not ColorObject then Flux.ResetColor() return end
    if not ColorObject.r and not ColorObject.g and not ColorObject.b then return Flux.Warn("Attempted to call Flux.Color with a non color object. The ActiveColor was not changed.") end
    if not istable(Flux.DrawColor) then Flux.DrawColor = {r = ColorObject.r, g = ColorObject.g, b = ColorObject.b, a = ColorObject.a or 255} return end

    Flux.DrawColor.r = ColorObject.r
    Flux.DrawColor.g = ColorObject.g
    Flux.DrawColor.b = ColorObject.b
    Flux.DrawColor.a = ForceAlpha or ColorObject.a or 255

    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.RGB(R, G, B, A)
    if not istable(Flux.DrawColor) then Flux.DrawColor = {r = R or 255, g = G or 255, b = B or 255, a = A or 255} return end

    Flux.DrawColor.r = R or 255
    Flux.DrawColor.g = G or 255
    Flux.DrawColor.b = B or 255
    Flux.DrawColor.a = A or 255

    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
    surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Flux.RGBOutline(R, G, B, A)
    if not istable(Flux.OutlineDrawColor) then Flux.OutlineDrawColor = {r = R or 255, g = G or 255, b = B or 255, a = A or 255} return end

    Flux.OutlineDrawColor.r = R or 255
    Flux.OutlineDrawColor.g = G or 255
    Flux.OutlineDrawColor.b = B or 255
    Flux.OutlineDrawColor.a = A or 255

    surface.SetTextColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.OutlineDrawColor.a)
    surface.SetDrawColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.OutlineDrawColor.a)
end

-- Debug Interface
local DebugCVar = CreateClientConVar("fluxui_debug", "1", true, true, "Debug information for the FluxUI Library", 0, 1)
function Flux.ToggleDebugInterface(toggle)
    if not toggle or toggle == false then
        Flux.Print("Disabling FluxUI-Debug hook.")
        hook.Remove("DrawOverlay", "FluxUI-Debug")
        return
    end

    local CachedMaterials = table.Count(Flux.Materials)
    Flux.Version = string.EndsWith(Flux.Version, "-debug") and Flux.Version or Flux.Version .. "-debug"
    Flux.Print("Creating the FluxUI-Debug interface")
    hook.Add("DrawOverlay", "FluxUI-Debug", function()
        -- Draw Time
        if gui.IsGameUIVisible() then return end
        local R,G,B,A = Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a
        local DrawTime = math.Round(RealFrameTime(), 3)*1000

        -- Version String
        surface.SetFont(Flux.Font(14, false))
        surface.SetDrawColor(Flux.Colors.Accent.r, Flux.Colors.Accent.g, Flux.Colors.Accent.b, 200)
        surface.DrawRect(6, Flux.ScrH - 1, 328, 1)
        Flux.RGB(255,255,255,175)
        Flux.Text.Outline(Flux.Text.Left, 6, Flux.ScrH - 15, 1, Flux.Colors.Accent, Flux.Prefix, Flux.Colors.White, " " .. Flux.Version.."@"..Flux.ScrW.."x"..Flux.ScrH)
        
        -- Draw debug info
        local VisibleElements, TotalElements = 0, 0
        for k, v in pairs(Flux.ActiveElements) do
            if not v:IsValid() then table.remove(Flux.ActiveElements, k) continue end
            if v:IsVisible() then VisibleElements = VisibleElements + 1 end
            TotalElements = TotalElements + 1
        end
        
        local CachedMaterials = CachedMaterials .. " cached material(s)"
        local VisibleElements = VisibleElements.."/"..TotalElements.." elements"
        local RenderTime = DrawTime .. "ms render time"
        Flux.RGB(255,255,255,175)
        Flux.Text.Outline(Flux.Text.Left, 38, Flux.ScrH - 28, 1, CachedMaterials, " | ", VisibleElements, " | ", (DrawTime > 42 and Flux.Colors.Red or DrawTime > 15 and Flux.Colors.Orange or Flux.Colors.White), RenderTime)
        
        -- DrawColor and OutlineColor
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(6, Flux.ScrH - 15 - 11, 26, 10)
        surface.SetDrawColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
        surface.DrawRect(8, Flux.ScrH - 15 - 9, 10, 6)
        surface.SetDrawColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.OutlineDrawColor.a)
        surface.DrawRect(20, Flux.ScrH - 15 - 9, 10, 6)

        -- Initalized
        if not Flux.Initalized then
            Flux.RGB(150 + math.sin(SysTime() * 5)*75, 0, 0, 200)
            Flux.Text.Outline(Flux.Text.Left, 6, Flux.ScrH - 42, 1, "if you are seeing this piece of text, something in flux is royally fucked")
        end

        -- Reset
        Flux.RGB(R,G,B,A)
    end)
end

Flux.ToggleDebugInterface(Flux.Debug)
cvars.AddChangeCallback("fluxui_debug", function(_, old, new) 
    Flux.Debug = tostring(new) == "1"
    Flux.ToggleDebugInterface(Flux.Debug)
end, "fluxui_debug_toggle")