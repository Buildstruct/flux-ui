local Animation = {}
FluxUI.Animation = Animation
Animation.Interfaces = {
    Keys = {},
    Panels = {}
}

local function AddToInterfaces(panel)
    if Animation.Interfaces.Keys[panel] then return Animation.Interfaces.Keys[panel] end
    local index = #Animation.Interfaces.Panels + 1
    Animation.Interfaces.Keys[panel] = #Animation.Interfaces
    Animation.Interfaces.Panels[index] = panel
    panel:SetPaintedManually(true)
    return index
end

local function RemoveFromInterfaces(panel)
    local index = Animation.Interfaces.Keys[panel]
    if not index then return nil end
    table.remove(Animation.Interfaces.Panels, index)
    Animation.Interfaces.Keys[panel] = nil
    panel._FluxUIAnimations = nil
    panel:SetPaintedManually(false)
    return index
end

local Animations = {
    ["Scale"] = {
        PreDraw = function(panel, data, x, y, w, h)
            local lerp = math.Clamp((SysTime() - data.StartTime) / (data.EndTime - data.StartTime), 0, 1)
            FluxUI.Translation.Scale(Lerp(data.Ease(lerp), data.From, data.To), w, h, x, y)
        end,
        PostDraw = function(panel, data)
            FluxUI.Translation.Scale()
        end
    },
    ["Opacity"] = {
        PreDraw = function(panel, data)
            local lerp = math.Clamp((SysTime() - data.StartTime) / (data.EndTime - data.StartTime), 0, 1)
            data.PastAlphaMutli = surface.GetAlphaMultiplier()
            surface.SetAlphaMultiplier(Lerp(data.Ease(lerp), data.From, data.To) * data.PastAlphaMutli)
        end,
        PostDraw = function(panel, data)
            surface.SetAlphaMultiplier(data.PastAlphaMutli)
        end
    }
}

function Animation.Clear(panel) RemoveFromInterfaces(panel) end
for k, v in pairs(Animations) do
    Animation[k] = function(panel, from, to, ease, dur, callback)
        if not panel or not IsValid(panel) then return end
        panel._FluxUIAnimations = panel._FluxUIAnimations or {}
        panel._FluxUIAnimations[k] = {Callback = callback, Ease = ease or math.ease.OutExpo, From = from or 0, To = to or 1, StartTime = SysTime(), EndTime = SysTime() + (dur or 1)}
        AddToInterfaces(panel)
        return true
    end
end

hook.Add("DrawOverlay", "zen.fluxui.derma_animations", function()
    local ST = SysTime()
    for k, v in ipairs(Animation.Interfaces.Panels) do
        if not v or not IsValid(v) or not v._FluxUIAnimations then
            for pnl, _ in pairs(Animation.Interfaces.Keys) do if not pnl or not IsValid(pnl) then Animation.Interfaces.Keys[pnl] = nil end end
            table.remove(Animation.Interfaces.Panels, k)
            continue
        end
        if table.Count(v._FluxUIAnimations) <= 0 then RemoveFromInterfaces(v) end
        local StartX, StartY = v:LocalToScreen(0, 0)
        local Wide, Tall = v:GetSize()
        if v._FluxUIAnimations then for anim, data in pairs(v._FluxUIAnimations) do Animations[anim].PreDraw(v, data, StartX, StartY, Wide, Tall) end end
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(1)
        render.SetStencilReferenceValue(1)
        render.SetStencilTestMask(1)
        render.SetStencilCompareFunction(STENCIL_ALWAYS)
        render.SetStencilPassOperation(STENCIL_REPLACE)
        render.SetStencilFailOperation(STENCIL_KEEP)
        render.SetStencilZFailOperation(STENCIL_KEEP)
        render.OverrideColorWriteEnable(true, false)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(StartX, StartY, v:GetWide(), v:GetTall())
        render.OverrideColorWriteEnable(false)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
        v:PaintManual(false)
        render.SetStencilEnable(false)
        if not v._FluxUIAnimations then continue end
        for anim, data in pairs(v._FluxUIAnimations) do
            if data.EndTime < ST then
                v._FluxUIAnimations[anim] = nil
                if data.Callback then data.Callback(v) end
            end
            Animations[anim].PostDraw(v, data, StartX, StartY, Wide, Tall)
        end
    end
end)