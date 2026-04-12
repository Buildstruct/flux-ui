local String = {}
Flux.String = String

function String.Pascal(...)
    local ret = {}
    for k, v in ipairs({...}) do
        if not isstring(v) then
            ret[k] = v
            continue
        end
        ret[k] = string.upper(string.sub(v, 1, 1)) .. string.lower(string.sub(v, 2))
    end
    return unpack(ret)
end