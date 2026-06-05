local Memory = {}
Flux.Memory = Memory

Memory.Cache = {}
Memory.DeletionTime = 30

function Memory.Push(index, ...)
    Memory.Cache[index] = Memory.Cache[index] or {}
    Memory.Cache[index].Values = {...}
    Memory.Cache[index].LastTouched = Memory.Tick
    Memory.Cache[index].NextModify = Memory.Tick
    return ...
end

function Memory.Check(index)
    return Memory.Cache[index] ~= nil
end
function Memory.Pull(index, spitRaw)
    if not Memory.Cache[index] then
        return nil
    end

    Memory.Cache[index].LastTouched = Memory.Tick
    if spitRaw then return Memory.Cache[index].Values end
    return unpack(Memory.Cache[index].Values)
end

function Memory.PullOrPush(index, ...)
    if Memory.Cache[index] ~= nil  then
        local Pulled = Memory.Pull(index, true)

        if Memory.Cache[index].NextModify and Memory.Cache[index].NextModify < Memory.Tick then
            local vargs = {...}
            Memory.Cache[index].NextModify = Memory.Tick + Flux.Config.MemoryModificationDelay

            if #vargs == Pulled then
                local Duplicate = true
                for k, v in ipairs(vargs) do
                    if not Pulled[indexVarg] or v ~= Pulled[k] then
                        Duplicate = false
                        break
                    end
                end

                if not Duplicate then
                    Pulled = {Memory.Push(index, ...)}
                end
            end
        end

        return unpack(Pulled)
    end

    Memory.Push(index, ...)
    return ...
end

timer.Create("Flux:MemoryTick", Flux.Config.MemoryClearInterval, 0, function()
    Memory.Tick = SysTime()

    -- Remove things from memory that havent been used
    for k, v in pairs(Memory.Cache) do
        if not v.Values or not v.LastTouched or (Flux.Config.MemoryDeleteTime < Memory.Tick - v.LastTouched) then
            Memory.Cache[k] = nil
        end
    end
end)