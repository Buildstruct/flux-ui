local Text = {}
    Flux.Text = Text

    function Text.StripToString(...)
        local vargs, stripped = {...}, {}
        for i = 1, #vargs do
            local data = vargs[i]
            if istable(data) and data.r and data.g and data.b then continue end
            table.insert(stripped, tostring(data))
        end
        return stripped
    end

    function Text.GetTextSize(...)
        local width, curwidth, height = 0, 0, 0
        local Lines = string.Split(table.concat(Text.StripToString(...), ""), "\n")

        for i = 1, #Lines do
            local line = Lines[i]
            if not isstring(line) then continue end
            local textWidth, textHeight = surface.GetTextSize(line)
            curwidth = curwidth + textWidth
            width = math.max(curwidth, width)

            if #Lines > 1 and #Lines ~= i then
                height = height + textHeight
                curwidth = 0
            else
                height = height + textHeight
            end
        end

        return width, height
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
                local w, h = surface.GetTextSize(line)
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
                surface.SetTextColor(0, 0, 0, Flux.DrawColor.a)
                func(x + xFlip, y + yFlip, unpack(StrippedText))
            end
        end

        surface.SetTextColor(Flux.DrawColor.r, Flux.DrawColor.g, Flux.DrawColor.b, Flux.DrawColor.a)
        return func(x, y, ...)
    end

    function Text.Center(x, y, ...)
        local w, h = Text.GetTextSize(...)
        Text.Draw(x - w/2, y, ...)
        return w/2, h
    end

    function Text.Right(x, y, ...)
        local w, h = Text.GetTextSize(...)
        Text.Draw(x - w, y, ...)
        return -w, h
    end

    function Text.Left(x, y, ...)
        local w, h = Text.GetTextSize(...)
        Text.Draw(x, y, ...)
        return w, h
    end