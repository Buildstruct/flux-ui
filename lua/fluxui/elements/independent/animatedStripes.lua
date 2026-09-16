local Elements = Flux.Elements
function Elements.AnimatedStripes(x, y, w, h, len, speedMultiplier)
    len = len or 120
    local p = (CurTime() * 12 * (speedMultiplier or 1)) % len - len
    while p < w do
        surface.DrawPoly({
            { x = p, y = 0 },
            { x = p + len * 0.5, y = 0},
            { x = p + len * 0.75, y = h},
            { x = p + len * 0.25, y = h}
        })
        p = p + len
    end
end