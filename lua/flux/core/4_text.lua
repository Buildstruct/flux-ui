local Text = {}
Flux.Text = Text

function Text.Scale()
    return surface.GetTextSize(" ")
end

function Text.MemoryIdentifier()
    local w,h = surface.GetTextSize(" ")
    return w .. h
end

function Text.StripToString(...)
    local vargs, stripped = {...}, {}
    for i = 1, #vargs do
        local data = vargs[i]
        if istable(data) and data.r and data.g and data.b then continue end
        table.insert(stripped, tostring(data))
    end
    return stripped
end

function Text.StrippedConcat(...)
    local vargs, stripped = {...}, ""
    for i = 1, #vargs do
        local data = vargs[i]
        if istable(data) and data.r and data.g and data.b then continue end
        stripped = stripped .. tostring(data)
    end
    return stripped
end

function Text.Lower(...)
    local vargs, changed = {...}, {}
    for i = 1, #vargs do
        local data = vargs[i]
        if not isstring(data) then changed[i] = data end
        changed[i] = string.lower(data)
    end
    return unpack(changed)
end

function Text.Upper(...)
    local vargs, changed = {...}, {}
    for i = 1, #vargs do
        local data = vargs[i]
        if not isstring(data) then changed[i] = data end
        changed[i] = string.upper(data)
    end
    return unpack(changed)
end

function Text.GetTextSize(...)
    local stripped = Text.StrippedConcat(...)
    
    if Flux.Memory.Check(stripped..Text.MemoryIdentifier()) then
        return Flux.Memory.Pull(stripped..Text.MemoryIdentifier())
    end

    local width, curwidth, height = 0, 0, 0
    local Lines = string.Split(stripped, "\n")
    for i = 1, #Lines do
        local line = Lines[i]
        if not isstring(line) then continue end
        local textWidth, textHeight = Flux.Memory.PullOrPush(line..Text.MemoryIdentifier(), surface.GetTextSize(line))
        curwidth = curwidth + textWidth
        width = math.max(curwidth, width)

        if #Lines > 1 and #Lines ~= i then
            height = height + textHeight
            curwidth = 0
        else
            height = height + textHeight
        end
    end

    Flux.Memory.Push(stripped, width, height)
    return width, height
end

function Text.Wrap(width, ...) 
    local ret = {}
    width = width or 100
    for k, v in ipairs({...}) do
        if not isstring(v) then table.insert(ret, v) continue end
        local words = string.Split(v, " ")
        local CurW = 0
        for i = 1, #words do
            local word = words[i]
            local size = surface.GetTextSize(word)
            if CurW+size >= width then
                CurW = 0
                table.insert(ret, "\n")
                table.insert(ret, word.." ")
            else
                CurW = CurW + size
                table.insert(ret, word.." ")
            end
        end
    end
    return unpack(ret)
end

function Text.Draw(x, y, ...)
    local Origin, vargs = x, {...}

    for i = 1, #vargs do
        local data = vargs[i]

        if istable(data) and data.r and data.g and data.b then
            surface.SetTextColor(data.r, data.g, data.b, math.Clamp(data.a, 0, Flux.DrawColor.a))
            continue
        elseif not isstring(data) then
            data = tostring(data)
        end

        local Lines = string.Split(data, "\n")
        for k = 1, #Lines do
            local line = Lines[k]
            local w, h = Flux.Memory.PullOrPush(line..Text.MemoryIdentifier(), surface.GetTextSize(line))
            surface.SetTextPos(x, y)
            surface.DrawText(line)
            x = x + w

            if #Lines > 1 and #Lines ~= k then
                y = y + h 
                x = Origin
            end
        end
    end

    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
end

function Text.Outline(func, x, y, stroke, ...)
    local StrippedText = Text.StripToString(...)
    stroke = stroke or 1

    for xFlip = -stroke, stroke, 1 do
        for yFlip = -stroke, stroke, 1 do
            surface.SetTextColor(Flux.OutlineDrawColor.r, Flux.OutlineDrawColor.g, Flux.OutlineDrawColor.b, Flux.DrawColor.a)
            func(x + xFlip, y + yFlip, unpack(StrippedText))
        end
    end

    surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
    return func(x, y, ...)
end

function Text.Center(x, y, ...)
    local w, h = Text.GetTextSize(...)
    Text.Draw(x - w/2, y, ...)
    return w, h
end

function Text.Right(x, y, ...)
    local w, h = Text.GetTextSize(...)
    Text.Draw(x - w, y, ...)
    return w, h
end

function Text.Left(x, y, ...)
    local w, h = Text.GetTextSize(...)
    Text.Draw(x, y, ...)
    return w, h
end