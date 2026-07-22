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

    Flux.Version = string.EndsWith(Flux.Version, "-debug") and Flux.Version or Flux.Version .. "-debug"
    Flux.Print("Creating the FluxUI-Debug interface")
    local RenderTimeGraph, NextRenderTimeGraph = {}, 0
    local MaxGraphHistory = 60
    local NextElementCheckTime = 0
    local VisibleElements, TotalElements = 0, 0
    hook.Add("DrawOverlay", "FluxUI-Debug", function()
        -- Draw Time
        if gui.IsGameUIVisible() then return end

        -- Background
        local Size = 325
        Flux.RGB(0, 0, 0)
        Flux.Gradient.Up(Flux.ScrW / 2 - Size / 2, Flux.ScrH - 25, Size, 32)

        -- Watermark
        surface.SetFont(Flux.Font(12, true))
        Flux.Color(Flux.Colors.DimGray)
        local _, VersionH = Flux.Text.Outline(Flux.Text.Center, Flux.ScrW / 2, Flux.ScrH - 12, 1, Flux.Version .. "@" .. Flux.ScrW .. "x" .. Flux.ScrH)
        surface.SetFont(Flux.Font(15, true))
        Flux.Color(Flux.Colors.Accent)
        Flux.Text.Outline(Flux.Text.Center, Flux.ScrW / 2, Flux.ScrH - 14 - VersionH, 1, "FluxUI")
        surface.SetFont(Flux.Font(13))

        -- Rendertime
        local RenderTime = math.Round(RealFrameTime(), 3) * 1000
        local RenderTimeColor = RenderTime > 40 and Flux.Colors.Red or RenderTime > 15 and Flux.Colors.Orange or Flux.Colors.Gray
        Flux.Color(RenderTimeColor, RenderTime < 15 and 0 or 255)
        Flux.Gradient.Up(Flux.ScrW / 2 + Size / 2 - 6 - 75, Flux.ScrH - 8, 75, 16)
        Flux.Color(RenderTimeColor)
        Flux.Text.Outline(Flux.Text.Right, Flux.ScrW / 2 + Size / 2 - 8, Flux.ScrH - 13, 1, RenderTime .. "ms", Flux.Colors.Gray, " render")
        if NextRenderTimeGraph < SysTime() then
            NextRenderTimeGraph = SysTime() + 0.025
            table.insert(RenderTimeGraph, 1, RenderTime)
            table.remove(RenderTimeGraph, MaxGraphHistory)
        end

        -- Graph
        local GraphStart = Flux.ScrW / 2 + Size / 2
        local LastX, LastY
        local HighestValue = 0
        for k, v in ipairs(RenderTimeGraph) do
            local CurrentColor = Flux.Colors.Green:Lerp(Flux.Colors.Red, math.Clamp((v - 10) / 30, 0, 1))
            Flux.Color(CurrentColor, 255 * (1 - math.Clamp(k / MaxGraphHistory, 0, 1)))
            local X, Y = GraphStart - (k * 2), Flux.ScrH - 18 - v
            if k == 1 then Flux.Shapes.Rectangle(X - 1, Y - 1, 2, 2) end
            if LastX then surface.DrawLine(LastX, LastY, X, Y) end
            LastX, LastY = X, Y
            HighestValue = math.max(HighestValue, v)
        end
        Flux.Color(HighestValue > 40 and Flux.Colors.Red or HighestValue > 15 and Flux.Colors.Orange or Flux.Colors.Gray, HighestValue > 15 and 175 or 110)
        Flux.Text.Outline(Flux.Text.Left, GraphStart + 6, Flux.ScrH - 9 - 15 - HighestValue, 1, HighestValue .. "ms")

        -- Active Elements
        if NextElementCheckTime < SysTime() then
            NextElementCheckTime = SysTime() + 0.1
            VisibleElements, TotalElements = 0, 0
            for k, v in pairs(Flux.ActiveElements) do
                if not v:IsValid() then table.remove(Flux.ActiveElements, k) continue end
                local CurrentElement, Visible = v, true
                while CurrentElement do
                    if IsValid(CurrentElement:GetParent()) then
                        Visible = CurrentElement:IsVisible()
                        CurrentElement = CurrentElement:GetParent()
                    else
                        Visible = CurrentElement:IsVisible()
                        break
                    end
                    if not Visible then break end
                end
                VisibleElements = VisibleElements + (Visible and 1 or 0)
                TotalElements = TotalElements + 1
            end
        end
        Flux.Color(Flux.Colors.Gray)
        Flux.Text.Outline(Flux.Text.Left, Flux.ScrW / 2 - Size / 2 + 8, Flux.ScrH - 13, 1, VisibleElements .. "/" .. TotalElements .. " objects")

        -- Initalization
        if not Flux.Initalized then
            surface.SetFont(Flux.Font(16, true))
            Flux.RGB(150 + math.sin(SysTime() * 5) * 75, 0, 0, 200)
            Flux.Text.Outline(Flux.Text.Left, 2, Flux.ScrH - 17, 2, "[ERROR] FluxUI did not initalize properly! This should never happen, please check console!")
        end

        Flux.RGB(R,G,B,A)
    end)
end

Flux.ToggleDebugInterface(DebugCVar:GetBool())
cvars.AddChangeCallback("fluxui_developer", function(_, old, new)
    Flux.Debug = tonumber(new)
    Flux.ToggleDebugInterface(Flux.Debug ~= 0)
end, "fluxui_developer_toggle")