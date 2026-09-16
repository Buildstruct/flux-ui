local Utility = {}
FluxUI.Utility = Utility

function Utility.ConvertRainbow(freq, ...)
    local tbl = {...}
    if freq ~= nil and not isnumber(freq) then table.insert(tbl, 1, freq) end
    freq = isnumber(freq) and freq or 1
    for k, v in ipairs(tbl) do
        if v == true then tbl[k] = HSVToColor((SysTime() * (30 * freq)) % 360, 1, 1) end
    end
    return unpack(tbl)
end