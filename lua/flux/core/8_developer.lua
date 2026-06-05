local Developer = {}
Flux.Developer = Developer

-- Debug Interface
local DebugCVar = CreateClientConVar("fluxui_developer", "0", true, false, "Developer information for the FluxUI Library", 0, 2)
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

        -- Active Elements
        local VisibleElements, TotalElements = 0, 0
        for k, v in pairs(Flux.ActiveElements) do
            if not v:IsValid() then table.remove(Flux.ActiveElements, k) continue end
            if v:IsVisible() then VisibleElements = VisibleElements + 1 end
            TotalElements = TotalElements + 1
        end

        -- Variables
        local R,G,B,A = Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a
        local DrawTime = math.Round(RealFrameTime(), 3) * 1000
        local VersionStr = Flux.Version .. "@" .. Flux.ScrW .. "x" .. Flux.ScrH

        -- DrawColor and OutlineColor
        surface.SetDrawColor(0, 0, 0, 225)
        surface.DrawRect(2, Flux.ScrH - 10 - 4, 18, 12)
        surface.SetDrawColor(R,G,B,A)
        surface.DrawRect(4, Flux.ScrH - 10 - 2, 8, 8)
        surface.SetDrawColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.OutlineDrawColor.a)
        surface.DrawRect(14, Flux.ScrH - 10 - 2, 4, 8)

        -- Text
        surface.SetFont(Flux.Font(13, true))
        Flux.RGB(255,255,255,175)
        local TextW, TextH = Flux.Text.Outline(Flux.Text.Left, 24, Flux.ScrH - 14, 1,
            "(", Flux.Colors.Accent, Flux.Prefix, Flux.Colors.White, " ", VersionStr, ")", Flux.Colors.Gray,
            " ", CachedMaterials .. " cached material(s)", " | ", VisibleElements .. "/" .. TotalElements .. " elements", " | ",
            DrawTime > 40 and Flux.Colors.Red or DrawTime > 15 and Flux.Colors.Orange or Flux.Colors.Gray, DrawTime, "ms", Flux.Colors.Gray, " render time"
        )
        surface.SetDrawColor(Flux.Colors.Accent.r, Flux.Colors.Accent.g, Flux.Colors.Accent.b, 200)
        surface.DrawRect(2, Flux.ScrH - 1, TextW + 24, 1)

        -- Initalization
        if not Flux.Initalized then
            surface.SetFont(Flux.Font(16, true))
            Flux.RGB(150 + math.sin(SysTime() * 5) * 75, 0, 0, 200)
            Flux.Text.Outline(Flux.Text.Left, 2, Flux.ScrH - 20 - TextH, 2, "[ERROR] FluxUI did not initalize properly! This should never happen, please check console!")
        end

        Flux.RGB(R,G,B,A)
    end)
end

Flux.ToggleDebugInterface(DebugCVar:GetBool())
cvars.AddChangeCallback("fluxui_developer", function(_, old, new)
    Flux.Debug = tonumber(new)
    Flux.ToggleDebugInterface(Flux.Debug ~= 0)
end, "fluxui_developer_toggle")