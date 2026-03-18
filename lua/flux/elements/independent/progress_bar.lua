local Elements = Flux.Elements
function Elements.ProgressBar(x, y, w, h, progress, alpha)
    progress = progress or 0
    alpha = alpha or 255
    Flux.Shapes.Frame(x, y, w, h, nil, nil, nil, alpha/255)
    
    -- Indeterminate
    if progress == true then
        local cycle = SysTime() % 2
        local startEase, endingEase = math.ease.InOutExpo(math.Clamp(cycle - 0.5, 0, 1)),  math.ease.InOutExpo(math.Clamp(cycle, 0, 1))
        Flux.Shapes.ShadedRect(x+4 + (startEase*w), y+4, (endingEase - startEase) * w - 8, h-8)
    -- Determinate
    else
        Flux.Shapes.ShadedRect(x+4, y+4, (w-8)*math.Clamp(progress/100, 0, 1), h-8)
    end
end