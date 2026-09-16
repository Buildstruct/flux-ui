-- Color
FluxUI.DrawColor = {r = 255, g = 255, b = 255, a = 255}
FluxUI.OutlineColor = {r = 0, g = 0, b = 0, a = 255}

function FluxUI.ResetColor() FluxUI.RGB(255, 255, 255, 255); FluxUI.OutlineRGB(0, 0, 0, 255) end
function FluxUI.Alpha(alpha, outline)
    local DrawTable = (outline and outline == true) and FluxUI.OutlineColor or FluxUI.DrawColor
    DrawTable.a = alpha or 255
    surface.SetTextColor(DrawTable.r, DrawTable.g, DrawTable.b, DrawTable.a)
    surface.SetDrawColor(DrawTable.r, DrawTable.g, DrawTable.b, DrawTable.a)
end
function FluxUI.Color(col, alpha, outline)
    local DrawTable = (outline and outline == true) and FluxUI.OutlineColor or FluxUI.DrawColor
    DrawTable.r, DrawTable.g, DrawTable.b = col.r or 255, col.g or 255, col.b or 255
    DrawTable.a = alpha or 255
    surface.SetTextColor(DrawTable.r, DrawTable.g, DrawTable.b, DrawTable.a)
    surface.SetDrawColor(DrawTable.r, DrawTable.g, DrawTable.b, DrawTable.a)
end

function FluxUI.RGB(r, g, b, alpha, outline)
    local DrawTable = (outline and outline == true) and FluxUI.OutlineColor or FluxUI.DrawColor
    DrawTable.r, DrawTable.g, DrawTable.b = r or 255, g or 255, b or 255
    DrawTable.a = alpha or 255
    surface.SetTextColor(DrawTable.r, DrawTable.g, DrawTable.b, DrawTable.a)
    surface.SetDrawColor(DrawTable.r, DrawTable.g, DrawTable.b, DrawTable.a)
end

-- Memory Management
local Memory = {
    Cache = {},
    Keys = {},
    DeletionTime    = 0.2,
    ModifyDelay     = 0.1,
    ClearInterval   = 0.1,
    Tick = SysTime()
}
FluxUI.Memory = Memory

-- This helps a lot with things like text size, since we dont need to calculate it per frame anymore.
timer.Create("FluxUI:MemoryManager", Memory.ClearInterval, 0, function()
    Memory.Tick = SysTime()
    for i = #Memory.Keys, 1, -1 do
        if not Memory.Cache[Memory.Keys[i]] then table.remove(Memory.Keys, i) continue end
        local v = Memory.Cache[Memory.Keys[i]]
        if (not v.Values or not v.Tick) or Memory.Tick - v.Tick > Memory.DeletionTime then
            Memory.Cache[Memory.Keys[i]] = nil
            table.remove(Memory.Keys, i)
        end
    end
    for i = 1, #Memory.Keys do Memory.Cache[Memory.Keys[i]].Key = i end
end)

function Memory.Push(index, ...)
    local ST = SysTime()
    if not Memory.Cache[index] then
        local key = #Memory.Keys + 1
        Memory.Cache[index] = {Key = key, Tick = ST, Induct = ST, Values = {...}}
        Memory.Keys[key] = index
    else
        Memory.Cache[index].Values = {...}
        Memory.Cache[index].Tick = ST
    end
    return Memory.Cache[index].Values
end

function Memory.Compare(original, ...)
    local length = select("#", ...)
    local Difference = false
    if length ~= #original then Difference = true end
    if not Difference then
        for k = 1, length do
            if select(k, ...) == original[k] then continue end
            Difference = true
            break
        end
    end
    return Difference
end

function Memory.Pull(index, ...)
    local ST = SysTime()
    local length = select("#", ...)
    if not Memory.Cache[index] then
        if length == 0 then return nil end
        return Memory.Push(index, ...)
    end
    Memory.Cache[index].Tick = ST
    if length > 0 and (not Memory.Cache[index].Next or Memory.Cache[index].Next < ST) then
        Memory.Cache[index].Next = ST + Memory.ModifyDelay
        local Difference = false
        if length ~= #Memory.Cache[index].Values then Difference = true end
        if not Difference then
            for k = 1, length do
                if select(k, ...) == Memory.Cache[index].Values[k] then continue end
                Difference = true
                break
            end
        end
        if Difference then Memory.Push(index, ...) end
    end
    return Memory.Cache[index].Values
end
function Memory.PullUnpacked(...) return unpack(Memory.Pull(...)) end

function Memory.Exists(index)
    return Memory.Cache[index] ~= nil
end
-- PullFunction allows you to pass a function and arguments so that way
-- it will avoid unneccesary overhead, e.g.
-- Memory.Pull("TestIndex", surface.GetTextSize("hi")) will always
-- run the GetTextSize function because it gets reduced to a value
-- prior to execution.
function Memory.PullFunction(index, func, ...)
    local cached = Memory.Pull(index)
    if not cached then
        FluxUI.Memory.Push(index)
        Memory.Cache[index].FuncSet = {...}
        return FluxUI.Memory.Push(index, func(...))
    else
        -- Double check to make sure that the values that are being given to us aren't
        -- different
        local length = select("#", ...)
        Memory.Cache[index].FuncSet = Memory.Cache[index].FuncSet or {...}
        local Difference = false
        if length ~= #Memory.Cache[index].FuncSet then chat.AddText("FUCK") Difference = true end
        if not Difference then
            for k = 1, length do
                if select(k, ...) == Memory.Cache[index].FuncSet[k] then continue end
                Difference = true
                break
            end
        end
        if Difference then return Memory.Push(index, func(...)) end
        return cached
    end
end
function Memory.PullFunctionUnpacked(...) return unpack(Memory.PullFunction(...)) end -- Lazy