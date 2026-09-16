local Developer = {}
FluxUI.Developer = Developer

local DeveloperConVar = CreateClientConVar("fluxui_developer", "0", true, false, "Developer information for the FluxUI Library", 0, 2)

function FluxUI.DeveloperInterface(toggle)
    if not toggle then
        FluxUI.Print("Disabling FluxUI Developer Interface")
        return hook.Remove("DrawOverlay", "FluxUI:DeveloperUI")
    end

    FluxUI.Version = string.EndsWith(FluxUI.Version, ".dev") and FluxUI.Version or FluxUI.Version .. ".dev"
    FluxUI.Print("Creating the FluxUI-Debug interface")

    local RTGraph, NextRTGraph, GraphHistory = {}, 0, 60
    local Elements, TotalElements, NextElementCheck = 0, 0, 0
    hook.Add("DrawOverlay", "FluxUI:DeveloperUI", function()
        if gui.IsGameUIVisible() then return end

        if not FluxUI.Initalized then
            surface.SetFont("Trebuchet24")
            surface.SetTextColor(150 + math.sin(SysTime() * 5) * 75, 0, 0, 200)
            surface.SetTextPos(10, ScrH() - 28)
            surface.DrawText("FluxUI failed to initalize properly. Please check console and reconnect!")
            return
        end

        -- Variables
        local ST = SysTime()
        local R, G, B, A = FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a
        local OR, OG, OB, OA = FluxUI.OutlineColor.r, FluxUI.OutlineColor.g, FluxUI.OutlineColor.b, FluxUI.OutlineColor.a
        local CenterX = FluxUI.ScrW / 2

        -- Background
        local Size = 325
        FluxUI.RGB(0, 0, 0)
        FluxUI.Gradient.Up(CenterX - Size / 2, FluxUI.ScrH - 25, Size, 32)

        -- Watermark
        surface.SetFont(FluxUI.Font(16))
        local _, Font16Height = FluxUI.Text.Scale()
        FluxUI.Color(FluxUI.Colors.GrayDim)
        FluxUI.Text.Outline(FluxUI.Text.Center, CenterX, FluxUI.ScrH - Font16Height, 1, FluxUI.Version .. "@" .. FluxUI.ScrW .. "x" .. FluxUI.ScrH)
        surface.SetFont(FluxUI.Font(24, true))
        local _, Font24Height = FluxUI.Text.Scale()
        FluxUI.Color(FluxUI.Accent)
        FluxUI.Text.Outline(FluxUI.Text.Center, CenterX, FluxUI.ScrH - Font16Height - Font24Height + 2, 1, FluxUI.Prefix)

        -- Draw Colors
        surface.SetFont(FluxUI.Font(12))
        local _, Font12Height = FluxUI.Text.Scale()
        FluxUI.RGB(R, G, B, A)
        FluxUI.Gradient.Up(CenterX - Size / 2, FluxUI.ScrH - 25, 3, 32)
        FluxUI.RGB(R, 0, 0, 100); FluxUI.Text.Right(CenterX - Size / 2 - 3, FluxUI.ScrH - (Font12Height * 3), R)
        FluxUI.RGB(0, G, 0, 100); FluxUI.Text.Right(CenterX - Size / 2 - 3, FluxUI.ScrH - (Font12Height * 2), G)
        FluxUI.RGB(0, 0, B, 100); FluxUI.Text.Right(CenterX - Size / 2 - 3, FluxUI.ScrH - Font12Height, B)
        FluxUI.RGB(OR, OG, OB, OA)
        FluxUI.Gradient.Up(CenterX - Size / 2 + Size - 3, FluxUI.ScrH - 25, 3, 32)
        FluxUI.RGB(OR, 0, 0, 100); FluxUI.Text.Left(CenterX + Size / 2 + 3, FluxUI.ScrH - (Font12Height * 3), OR)
        FluxUI.RGB(0, OG, 0, 100); FluxUI.Text.Left(CenterX + Size / 2 + 3, FluxUI.ScrH - (Font12Height * 2), OG)
        FluxUI.RGB(0, 0, OB, 100); FluxUI.Text.Left(CenterX + Size / 2 + 3, FluxUI.ScrH - Font12Height, OB)

        -- Objects
        if NextElementCheck < ST then
            NextElementCheck = ST + 0.1
            Elements, TotalElements = 0, 0
            for k, v in pairs(FluxUI.ActiveElements) do
                if not v:IsValid() then table.remove(FluxUI.ActiveElements, k) continue end
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
                Elements = Elements + (Visible and 1 or 0)
                TotalElements = TotalElements + 1
            end
        end
        FluxUI.Color(FluxUI.Colors.GrayDim)
        surface.SetFont(FluxUI.Font(18))
        local _, Font18Height = FluxUI.Text.Scale()
        FluxUI.Text.Outline(FluxUI.Text.Left, CenterX - (Size / 2) + 10, FluxUI.ScrH - Font18Height, 1, Elements .. "/" .. TotalElements .. " objects")

        -- Memory Objects
        FluxUI.Color(FluxUI.Colors.GrayDim, 100)
        surface.SetFont(FluxUI.Font(16))
        FluxUI.Text.Outline(FluxUI.Text.Left, CenterX - (Size / 2) + 10, FluxUI.ScrH - Font18Height - 11, 1, "Memory Size: " .. table.Count(FluxUI.Memory.Cache))

        -- Rendertime
        local RenderTime = math.Round(RealFrameTime(), 3) * 1000
        local RenderTimeColor = RenderTime > 40 and FluxUI.Colors.Red or RenderTime > 15 and FluxUI.Colors.Orange or FluxUI.Colors.Gray
        FluxUI.Color(RenderTimeColor, RenderTime < 15 and 0 or 64)
        local rtWidth = FluxUI.Text.GetTextSize(RenderTime .. "ms render") -- the things i have to do for good uis
        FluxUI.Gradient.Up(CenterX + (Size / 2) - 10 - rtWidth - 5, FluxUI.ScrH - 10, rtWidth + 10, 15)
        FluxUI.Alpha(255)
        FluxUI.Text.Outline(FluxUI.Text.Right, CenterX + (Size / 2) - 10, FluxUI.ScrH - Font18Height, 1, RenderTimeColor, RenderTime .. "ms", FluxUI.Colors.Gray, " render")
        if NextRTGraph < ST then
            NextRTGraph = ST + 0.025
            table.insert(RTGraph, 1, RenderTime)
            table.remove(RTGraph, GraphHistory)
        end

        local graphX = CenterX + Size / 2 - 5
        local lastx, lasty, highestValue = nil, nil, 0
        for k = 1, #RTGraph do
            local v = RTGraph[k]
            local color = FluxUI.Colors.Green:Lerp(FluxUI.Colors.Red, math.Clamp((v - 10) / 30, 0, 1))
            FluxUI.Color(color, 255 * (1 - math.Clamp(k / GraphHistory, 0, 1)))
            local x, y = graphX - (k * 2), FluxUI.ScrH - 18 - v
            if lastx then surface.DrawLine(lastx, lasty, x, y) end
            lastx, lasty = x, y
            highestValue = math.max(highestValue, v)
        end
        surface.SetFont(FluxUI.Font(13))
        FluxUI.Color(highestValue > 40 and FluxUI.Colors.Red or highestValue > 15 and FluxUI.Colors.Orange or FluxUI.Colors.Gray, highestValue > 15 and 255 or 75)
        FluxUI.Text.Left(graphX + 6, math.min(FluxUI.ScrH - (Font12Height * 4), FluxUI.ScrH - 9 - 12 - highestValue), highestValue .. "ms")

        -- Cache for developer 2
        FluxUI.RGB(R, G, B, A)
        FluxUI.RGB(OR, OG, OB, OA, true)
    end)
end

FluxUI.DeveloperInterface(DeveloperConVar:GetBool())
cvars.AddChangeCallback("fluxui_developer", function(_, old, new)
    FluxUI.Developer = tonumber(new)
    FluxUI.DeveloperInterface(FluxUI.Developer ~= 0)
end, "fluxui_developer_toggle")