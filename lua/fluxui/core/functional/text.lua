local Text = {}
FluxUI.Text = Text

function Text.Scale() return surface.GetTextSize(" ") end

function Text.Lower(...)
    local vargs = {...}
    for i = 1, #vargs do
        local v = vargs[i]
        if not isstring(v) then continue end
        vargs[i] = string.lower(v)
    end
    return vargs
end
function Text.Upper(...)
    local vargs = {...}
    for i = 1, #vargs do
        local v = vargs[i]
        if not isstring(v) then continue end
        vargs[i] = string.upper(v)
    end
    return vargs
end

function Text.ToString(...)
    local length = select("#", ...)
    local finalString = ""
    for k = 1, length do
        local v = select(k, ...)
        if istable(v) and v.r and v.g and v.b then continue end
        finalString = finalString .. tostring(v)
    end
    return finalString
end

-- This function is meant for internal use only for memory
-- indexes just bc it doesnt strip out tables. since if you change
-- colors mid-text then it wouldn't update prior with just ToString
-- since, well, it had nothing to compare lol
function Text.FullIdentifier(...)
    local length = select("#", ...)
    local finalString = ""
    for k = 1, length do
        local v = select(k, ...)
        finalString = finalString .. tostring(v)
    end
    return finalString
end

function Text.GetTextSize(...)
    local stripped = Text.ToString(...)
    local scaleW, scaleH = Text.Scale()
    local memoryID = "f" .. stripped .. scaleW .. scaleH
    local fromMemory = FluxUI.Memory.Pull(memoryID)
    if fromMemory then return unpack(fromMemory) end

    local width, height = 0, 0
    local lines = string.Split(stripped, "\n")
    for i = 1, #lines do
        if not isstring(lines[i]) then continue end
        local linew, lineh = surface.GetTextSize(lines[i])
        width = math.max(width, linew)
        height = height + lineh
    end
    FluxUI.Memory.Push(memoryID, width, height)
    return width, height
end

function Text.BuildLines(scaleW, scaleH, ...)
    local stripped = Text.FullIdentifier(...)
    local memoryID = "l" .. stripped .. scaleW .. scaleH
    local lines = FluxUI.Memory.Pull(memoryID)
    lines = lines and lines[1] or nil
    if not lines then
        local vargs = {...} -- doesn't matter if we rebuild them here bc its only once
        local currentLine = {}
        lines = {}
        for i = 1, #vargs do
            local v = vargs[i]
            if istable(v) and v.r and v.g and v.b then
                table.insert(currentLine, v)
                continue
            end
            local exploded = string.Split(tostring(v), "\n")
            for k = 1, #exploded do
                table.insert(currentLine, exploded[k])
                if k < #exploded then table.insert(lines, currentLine); currentLine = {} end
            end
        end
        table.insert(lines, currentLine)
        FluxUI.Memory.Push(memoryID, lines)
    end
    return lines
end

function Text.Draw(x, y, lines, scaleW, scaleH, alignment)
    local totalw, totalh = 0, 0
    for k = 1, #lines do
        local line = lines[k]
        local linew, lineh = 0, 0
        for i = 1, #line do
            local str = line[i]
            if istable(str) and str.r and str.g and str.b then continue end
            local w, h = FluxUI.Memory.PullFunctionUnpacked("s.c" .. str .. scaleW .. scaleH, surface.GetTextSize, str)
            linew = linew + w
            lineh = math.max(lineh, h)
        end
        if lineh == 0 then local _, h = Text.Scale(); lineh = h end

        local origin = x - (alignment == TEXT_ALIGN_CENTER and (linew / 2) or alignment == TEXT_ALIGN_RIGHT and linew or 0)
        for i = 1, #line do
            local str = line[i]
            if istable(str) and str.r and str.g and str.b then
                surface.SetTextColor(str.r, str.g, str.b, str.a * (FluxUI.DrawColor.a / 255))
                continue
            end
            local w = FluxUI.Memory.PullUnpacked("s.c" .. str .. scaleW .. scaleH)
            surface.SetTextPos(origin, y)
            surface.DrawText(str)
            origin = origin + w
        end
        totalw, totalh = math.max(totalw, linew), totalh + lineh
        y = y + lineh
    end
    surface.SetTextColor(FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a)
    return totalw, totalh
end

function Text.Left(x, y, ...)
    local scaleW, scaleH = Text.Scale()
    local lines = Text.BuildLines(scaleW, scaleH, ...)
    return Text.Draw(x, y, lines, scaleW, scaleH, TEXT_ALIGN_LEFT)
end

function Text.Center(x, y, ...)
    local scaleW, scaleH = Text.Scale()
    local lines = Text.BuildLines(scaleW, scaleH, ...)
    return Text.Draw(x, y, lines, scaleW, scaleH, TEXT_ALIGN_CENTER)
end

function Text.Right(x, y, ...)
    local scaleW, scaleH = Text.Scale()
    local lines = Text.BuildLines(scaleW, scaleH, ...)
    return Text.Draw(x, y, lines, scaleW, scaleH, TEXT_ALIGN_RIGHT)
end

function Text.Outline(func, x, y, stroke, ...)
    local stripped = Text.ToString(...)
    stroke = math.max(stroke, 1) or 1
    for xFlip = -stroke, stroke, 1 do
        for yFlip = -stroke, stroke, 1 do
            surface.SetTextColor(FluxUI.OutlineColor.r, FluxUI.OutlineColor.g, FluxUI.OutlineColor.b, FluxUI.DrawColor.a)
            func(x + xFlip, y + yFlip, stripped)
        end
    end
    surface.SetTextColor(FluxUI.DrawColor.r, FluxUI.DrawColor.g, FluxUI.DrawColor.b, FluxUI.DrawColor.a)
    return func(x, y, ...)
end