local Utility = {}
Flux.Utility = Utility
Flux.Util = Utility

function Utility.ConvertRainbow(freq, ...)
    local tbl = {...}
    if freq and not isnumber(freq) then table.insert(tbl, 1, freq) end
    for k, v in ipairs(tbl) do
        if v == true then tbl[k] = HSVToColor((SysTime() * (30 * (freq and isnumber(freq) and freq) or 1)) % 360, 1, 1) end
    end
    return unpack(tbl)
end